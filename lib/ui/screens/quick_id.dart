// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';

import '../components/adaptive_helper_widgets.dart';
import '../../models/metadata.dart';
import '../components/core_components.dart';
import '../../functionality/state.dart';
import '../../functionality/adaptive/policies.dart';
import 'chat.dart';
import '../utilities.dart';
import '../../config.dart';

/// Camera/gallery screen for capturing images and generating AI metadata.
class GenerateMetadataScreen extends StatefulWidget {
  const GenerateMetadataScreen({super.key});

  @override
  State<GenerateMetadataScreen> createState() => _GenerateMetadataScreenState();
}

/// State for [GenerateMetadataScreen]. Uses [WidgetsBindingObserver] for camera lifecycle.
class _GenerateMetadataScreenState extends State<GenerateMetadataScreen>
    with WidgetsBindingObserver {
  late GenerativeModel model;
  bool _loading = false;
  Uint8List? _image;
  final Duration _modelTimeout = const Duration(seconds: 27);

  List<CameraDescription> cameras = [];
  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  double zoomSensitivity = 0.5;
  double _previousScale = 1.0;
  double _minZoomLevel = 1.0;
  double _maxZoomLevel = 1.0;
  double _currentZoomLevel = 1.0;
  bool _isZoomSupported = false;

  bool _isTakingPicture = false;
  final int _captureRetryCount = 3;
  final Duration _captureRetryDelay = const Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    final googleAI = FirebaseAI.vertexAI();
    model = googleAI.generativeModel(
      model: geminiModel,
      generationConfig: GenerationConfig(
        temperature: 0.1,
        responseMimeType: 'application/json',
      ),
    );

    _initializeCamera();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _cameraController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Manages camera based on app lifecycle (dispose on inactive, reinit on resume).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  /// Initializes camera controller and retrieves zoom capabilities.
  Future<void> _initializeCamera() async {
    try {
      if (_cameraController != null) {
        await _cameraController!.dispose();
      }

      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras[0],
          ResolutionPreset.high,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );

        await _cameraController!.initialize();

        double minZoom = await _cameraController!.getMinZoomLevel();
        double maxZoom = await _cameraController!.getMaxZoomLevel();

        if (mounted) {
          setState(() {
            _minZoomLevel = minZoom;
            _maxZoomLevel = maxZoom;
            _currentZoomLevel = minZoom;
            _isZoomSupported = maxZoom > minZoom;
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  /// Opens gallery to pick an image, then triggers metadata generation.
  void pickImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage == null) return;

      final fileBytes = await pickedImage.readAsBytes();
      setState(() => _image = fileBytes);
      _sendVertexMessage();
    } catch (e) {
      _showError(e.toString());
    }
  }

  /// Resets view: reinitializes camera and clears image/metadata.
  Future<void> removeImage(BuildContext context) async {
    await _initializeCamera();

    if (mounted) {
      setState(() {
        _image = null;
        context.read<AppState>().clearMetadata();
      });
    }
  }

  /// Captures image with retry logic for buffer errors, corrects EXIF orientation.
  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (_isTakingPicture) {
      return;
    }

    _isTakingPicture = true;
    try {
      if (_cameraController!.value.isPreviewPaused == false) {
        await _cameraController!.pausePreview();
      }

      XFile? imageFile;
      int attempts = 0;

      while (attempts < _captureRetryCount) {
        try {
          imageFile = await _cameraController!.takePicture();
          break;
        } on CameraException catch (ce) {
          final msg = (ce.description ?? ce.code).toLowerCase();
          final isBufferError = msg.contains('unable to acquire') ||
              msg.contains('maximages') ||
              msg.contains('imagereader') ||
              msg.contains('buffer');

          if (isBufferError) {
            attempts++;
            if (attempts < _captureRetryCount) {
              await Future.delayed(_captureRetryDelay);
              continue;
            } else {
              rethrow;
            }
          } else {
            rethrow;
          }
        } catch (e) {
          rethrow;
        }
      }

      if (imageFile == null) {
        _showError('Failed to capture image.');
        return;
      }

      final originalFile = File(imageFile.path);
      final rotatedFile =
          await FlutterExifRotation.rotateImage(path: originalFile.path);
      final imageBytes = await rotatedFile.readAsBytes();

      if (mounted) {
        setState(() {
          _image = imageBytes;
        });
      }

      _sendVertexMessage();
    } catch (e) {
      _showError(e.toString());
    } finally {
      _isTakingPicture = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final metadata = context.watch<AppState>().metadata;
    final isExpanded = MediaQuery.sizeOf(context).width >= Breakpoints.expanded;

    // Camera preview active
    if (_image == null && _isCameraInitialized) {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(64.5),
          child: AppBar(
            flexibleSpace: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(2),
                bottomRight: Radius.circular(2),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('lib/appbar/banner.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            backgroundColor: Colors.pink,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(2),
                bottomRight: Radius.circular(2),
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            SizedBox.expand(
              child: GestureDetector(
                onScaleStart:
                    _isZoomSupported ? (details) => _previousScale = 1.0 : null,
                onScaleUpdate: _isZoomSupported
                    ? (details) {
                        final delta = details.scale / _previousScale;
                        _currentZoomLevel = (_currentZoomLevel * delta)
                            .clamp(_minZoomLevel, _maxZoomLevel);
                        _cameraController!.setZoomLevel(_currentZoomLevel);
                        _previousScale = details.scale;
                      }
                    : null,
                onTapDown: (details) {
                  if (_cameraController?.value.isInitialized ?? false) {
                    try {
                      final previewSize = _cameraController!.value.previewSize!;
                      final scale =
                          MediaQuery.of(context).size.width / previewSize.width;
                      final tapPos = details.localPosition;
                      final x = (tapPos.dx / scale) / previewSize.width;
                      final y = (tapPos.dy / scale) / previewSize.height;

                      _cameraController!.setFocusPoint(
                        Offset(x.clamp(0.0, 1.0), y.clamp(0.0, 1.0)),
                      );
                    } catch (e) {
                      print('Error setting focus point: $e');
                    }
                  }
                },
                child: AspectRatio(
                  aspectRatio: _cameraController!.value.aspectRatio,
                  child: CameraPreview(_cameraController!),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(22.0),
                child: FloatingActionButton(
                  onPressed: _captureImage,
                  child: const Icon(Icons.camera_alt),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Image review screen
    if (_image != null) {
      return isExpanded
          ? ExpandedScreen(
              image: _image!,
              loading: _loading,
              metadata: metadata,
              onRemoveImage: () => removeImage(context),
            )
          : CompactScreen(
              image: _image!,
              loading: _loading,
              metadata: metadata,
              onRemoveImage: () => removeImage(context),
            );
    }

    // Initial loading state
    return Scaffold(
      appBar: AppBar(title: const Text('Waiting for Camera')),
      body: const Center(child: Text('Please wait a moment.')),
    );
  }

  /// Sends image to Vertex AI and updates app state with generated metadata.
  Future<void> _sendVertexMessage() async {
    if (_loading || _image == null) return;

    setState(() => _loading = true);

    try {
      final response = await model.generateContent(
        [
          Content.multi([
            TextPart(
              // The detailed prompt instructs the AI on the desired output format (JSON)
              // and the specific "Pokédex" style for the content. It includes rules for
              // handling valid (animals, plants) and invalid subjects.
              """Rispondimi sempre in italiano e non suddividere il testo in paragrafi fai un blocco unico. 
              Restituiscimi le seguenti specifiche come se fossi un Pokédex: 
              Qual è l'essere vivente descritto? 
              Risponderai con nome: il nome comune e scientifico della specie tra parentesi,
              altezza: altezza media dell'essere vivente in metri,
              peso: peso medio dell'essere vivente in chilogrammi,
              descrizione: premessa cerca di fare la descrizione lunga minimo 5 righe il più fedele possibile nell'imitare quella di un pokedex,
              cercando anche di non ripeterti mai nel fornire le informazioni richieste, 
              all'interno di essa non nominerai mai il nome a cui hai già risposto in precedenza in nessun modo, 
              inzia la descrizione direttamente con le informazioni che vuoi comunicare senza inziare con questo animale o questo uccello,
              insomma non specificare mai che è un'animale, una pianta ecc.. dai direttamente l'informazione seguente, informazione che non riguardi una cosa ovvia 
              come se è un'animale,un'uccello o un pesce.
              Le caratteristiche della descrizione sono le seguenti; 
              fornisci una descrizione delle caratteristiche fisiche solo se presentano delle particolarità rilevanti
              se è una descrizione generica puoi non parlare delle caratteristiche fisiche un'esempio di caratteristica fisica interessante 
              può essere questo: 
              Dahu Sarebbe un mammifero quadrupede caratterizzato dall'avere le gambe asimmetriche,
              quelle di destra più lunghe di quelle sinistra (o viceversa), per muoversi meglio sui ripidi pendii montani.
              Nel primo caso, si parlerebbe di Dahu levogiro, mentre nel secondo caso di dahu destrogiro, in quanto, a causa di questa sua caratteristica fisica
              sarebbe stato costretto a girare sempre attorno alla montagna nello stesso verso. 
              I dahu destrogiri avrebbero camminato in senso orario, mentre i Dahu levogiri avrebbero camminato in senso antiorario. 
              Un'altro esempio è la particolarità del volo del calabrone, anche la particolarità del volo del colibrì
              oppure un'altro esempio può essere quello dei rinoceronti neri che nonostante il nome non sono di colore nero
              e li hanno chiamati così per via di un'errore di traduzione. Descrivi dettagliatamente il
              comportamento e il tipo di dieta. 
              Sottolinea soprattutto le Abilità speciali o adattamenti unici che ha sviluppato per sopravvivere è importante. 
              Suggerisci 3 domande che posso fare per ottenere ulteriori informazioni su questo essere vivente. 
              Se l'essere vivente è un animale o una pianta, 
              le 3 domande suggerite dovranno riguardare una curiosità sull'essere vivente in questione, 
              il suo habitat e la specie. 
              Inoltre, se l'essere vivente non è un animale o una pianta (nelle piante sono inclusi anche i fiori come i tulipani i girasoli ecc... insomma tutti i tipi di fiori sono inclusi. Così come anche i funghi sono inclusi tra le piante, praticamente tutti i vegetali lo sono), 
              metti nome come: nome non valido 
              e come descrizione metti: il soggetto visualizzato non è né un animale né una pianta, 
              si prega di rimuovere il soggetto e riprovare con un'altra immagine. 
              Assicurati di utilizzere correttamente lo stile, 
              la formattazione e il linguaggio di un Pokédex 
              mentre rielabori le informazioni. 
              Rispondi in formato JSON e assicurati che all'interno del formato i valori siano stringa con le keys "name", "height", "weight", "description" e "suggestedQuestions".""",
            ),
            InlineDataPart('image/jpeg', _image!),
          ])
        ],
      ).timeout(_modelTimeout);

      if (response.text != null) {
        final jsonMap = json.decode(response.text!);
        if (mounted) {
          context.read<AppState>().updateMetadata(
                Metadata.fromJson(jsonMap),
              );
        }
      } else {
        _showError("API did not return a response.");
      }
    } on TimeoutException {
      _showError('Content generation timed out. Please try again.');
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  /// Shows error dialog with message.
  void _showError(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: SingleChildScrollView(child: Text(message)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Compact screen layout (mobile portrait): vertical list with image and metadata.
class CompactScreen extends StatelessWidget {
  const CompactScreen({
    required this.image,
    required this.loading,
    required this.metadata,
    required this.onRemoveImage,
    super.key,
  });

  final Uint8List image;
  final bool loading;
  final Metadata? metadata;
  final VoidCallback onRemoveImage;

  /// Navigates to chat screen.
  void goToChat(BuildContext context) {
    if (loading) return;
    context.push('/home/chat');
  }

  @override
  Widget build(BuildContext context) {
    Widget content = LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: AspectRatio(
                  aspectRatio: 0.5,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.memory(
                      image,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox.square(dimension: 13),
            Padding(
              padding: const EdgeInsets.all(12),
              child: MetadataCard(
                loading: loading,
                metadata: metadata,
              ),
            ),
            const SizedBox.square(dimension: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RemoveImageButton(onPressed: onRemoveImage),
                const SizedBox.square(dimension: 8),
                TellMeMoreButton(onPressed: () => goToChat(context)),
              ],
            ),
            const SizedBox.square(dimension: 20),
          ],
        );
      },
    );

    // Add keyboard shortcuts if the policy allows.
    if (Policy.shouldHaveKeyboardShortcuts) {
      content = ShortcutHelper(
        bindings: <ShortcutActivator, VoidCallback>{
          // Ctrl+T to open chat.
          const SingleActivator(control: true, LogicalKeyboardKey.keyT): () {
            goToChat(context);
          },
        },
        child: content,
      );
    }
    return content;
  }
}

/// The UI layout for expanded screens (e.g., tablets, desktops).
///
/// Displays the image and metadata side-by-side. The chat interface is shown
/// in an [OverlayPortal] for a more desktop-like experience.
class ExpandedScreen extends StatelessWidget {
  ExpandedScreen({
    required this.image,
    required this.loading,
    required this.metadata,
    required this.onRemoveImage,
    super.key,
  });

  final Uint8List image;
  final bool loading;
  final Metadata? metadata;
  final VoidCallback onRemoveImage;

  final OverlayPortalController _aiChatController = OverlayPortalController();

  /// Toggles chat overlay visibility.
  void showChat() {
    if (loading) return;
    _aiChatController.toggle();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: constraints.maxWidth * .55),
                child: Card(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.memory(image, fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),
              SizedBox.square(dimension: constraints.maxWidth * .010),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints:
                        BoxConstraints(maxWidth: constraints.maxWidth * .4),
                    child: MetadataCard(loading: loading, metadata: metadata),
                  ),
                  const SizedBox.square(dimension: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RemoveImageButton(onPressed: onRemoveImage),
                      const SizedBox.square(dimension: 8),
                      TellMeMoreButton(onPressed: () => showChat()),
                      ChatPopUp(
                        opController: _aiChatController,
                        onToggleChat: () => showChat(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (Policy.shouldHaveKeyboardShortcuts) {
      content = ShortcutHelper(
        bindings: <ShortcutActivator, VoidCallback>{
          const SingleActivator(control: true, LogicalKeyboardKey.keyT): () {
            showChat();
          },
        },
        child: content,
      );
    }
    return content;
  }
}

/// Button to remove current image.
class RemoveImageButton extends StatelessWidget {
  const RemoveImageButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: Icon(
        FontAwesomeIcons.trashCan,
        color: Theme.of(context).colorScheme.error,
      ),
      onPressed: onPressed,
      label: Text(
        'Rimuovi Immagine',
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontSize: 13,
        ),
      ),
    );
  }
}

/// Button to navigate to/open chat interface.
class TellMeMoreButton extends StatelessWidget {
  const TellMeMoreButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: const ButtonStyle(
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 25, vertical: 16),
        ),
      ),
      onPressed: onPressed,
      icon: const Icon(FontAwesomeIcons.solidMessage),
      label: const Text(
        'Dimmi di più',
        style: TextStyle(fontSize: 13),
      ),
    );
  }
}

/// Chat interface displayed in an OverlayPortal (for expanded layout).
class ChatPopUp extends StatelessWidget {
  const ChatPopUp({
    required this.opController,
    required this.onToggleChat,
    super.key,
  });

  final OverlayPortalController opController;
  final VoidCallback onToggleChat;

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: opController,
      overlayChildBuilder: (BuildContext context) {
        var width = MediaQuery.sizeOf(context).width;
        var height = MediaQuery.sizeOf(context).height;
        return Positioned(
          right: width * .05,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.surfaceDim,
                  blurRadius: 36,
                )
              ],
            ),
            width: width * .28,
            height: height * .5,
            child: ChatPage(onExit: onToggleChat),
          ),
        );
      },
    );
  }
}
