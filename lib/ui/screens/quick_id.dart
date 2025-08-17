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

// Internal project imports for UI components, models, and utilities.
import '../components/adaptive_helper_widgets.dart';
import '../../models/metadata.dart';
import '../components/core_components.dart';
import '../../functionality/state.dart';
import '../../functionality/adaptive/policies.dart';
import 'chat.dart';
import '../utilities.dart';
import '../../config.dart';

/// The main screen for generating image metadata.
///
/// This screen provides a camera interface for users to capture an image or
/// select one from their gallery. Once an image is provided, it is sent to
/// a Vertex AI model to generate descriptive metadata, which is then displayed.
/// The screen is responsive, adapting its layout for compact and expanded displays.
class GenerateMetadataScreen extends StatefulWidget {
  const GenerateMetadataScreen({super.key});

  @override
  State<GenerateMetadataScreen> createState() => _GenerateMetadataScreenState();
}

/// The state management class for [GenerateMetadataScreen].
///
/// It uses [WidgetsBindingObserver] to manage the camera's lifecycle in response
/// to app lifecycle changes (e.g., app paused, resumed).
class _GenerateMetadataScreenState extends State<GenerateMetadataScreen>
    with WidgetsBindingObserver {
  /// The Vertex AI generative model instance used for image analysis.
  late GenerativeModel model;

  /// A flag to indicate when an API call is in progress.
  /// Used to show loading indicators and prevent duplicate requests.
  bool _loading = false;

  /// Holds the byte data of the image captured by the camera or selected from the gallery.
  /// When `null`, the camera preview is shown. When populated, the image review screen is shown.
  Uint8List? _image;

  /// The timeout duration for the generative model API call.
  final Duration _modelTimeout = const Duration(seconds: 27);

  // --- Camera Control Variables ---

  /// A list of available cameras on the device.
  List<CameraDescription> cameras = [];

  /// The controller for the device camera, managing preview, capture, and focus.
  CameraController? _cameraController;

  /// A flag to track if the camera has been successfully initialized.
  bool _isCameraInitialized = false;

  // --- Camera Zoom Control Variables ---

  /// Sensitivity for pinch-to-zoom gestures.
  double zoomSensitivity = 0.5;

  /// The scale value from the previous `onScaleUpdate` event, used to calculate zoom delta.
  double _previousScale = 1.0;

  /// The minimum zoom level supported by the camera.
  double _minZoomLevel = 1.0;

  /// The maximum zoom level supported by the camera.
  double _maxZoomLevel = 1.0;

  /// The current zoom level applied to the camera.
  double _currentZoomLevel = 1.0;

  /// A flag indicating if the current camera supports zooming.
  bool _isZoomSupported = false;

  // --- Camera Capture Robustness Variables ---

  /// A flag to prevent concurrent picture-taking calls, which can cause errors.
  bool _isTakingPicture = false;

  /// The number of times to retry taking a picture if a buffer-related error occurs.
  /// This helps mitigate common `ImageReader_JNI` errors on some Android devices.
  final int _captureRetryCount = 3;

  /// The delay between capture retries.
  final Duration _captureRetryDelay = const Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    // Lock screen orientation to portrait mode for a consistent camera experience.
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // Initialize the Firebase Vertex AI model with specific generation configurations.
    final googleAI = FirebaseAI.vertexAI();
    model = googleAI.generativeModel(
      model: geminiModel, // Model name from config.dart
      generationConfig: GenerationConfig(
        temperature: 0.1, // Lower temperature for more deterministic responses.
        responseMimeType:
            'application/json', // Request a JSON formatted response.
      ),
    );

    // Start the camera initialization process.
    _initializeCamera();
    // Register this object as an observer of app lifecycle events.
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Restore preferred orientations when the screen is disposed.
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    // Release the camera controller resources.
    _cameraController?.dispose();
    // Remove the lifecycle observer.
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Handles app lifecycle state changes to manage the camera controller.
  /// This is crucial for releasing the camera when the app is in the background
  /// and re-initializing it when the app is resumed.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;

    // Do nothing if the controller is not available or not initialized.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    // Dispose of the controller when the app becomes inactive (e.g., goes to the background).
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    }
    // Re-initialize the camera when the app is resumed.
    else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  /// Initializes the camera.
  ///
  /// This function discovers available cameras, creates and initializes a
  /// [CameraController], and retrieves its zoom capabilities. It safely disposes
  /// of any existing controller before creating a new one to prevent resource leaks.
  Future<void> _initializeCamera() async {
    try {
      // Ensure any previous controller is disposed of before re-initializing.
      if (_cameraController != null) {
        await _cameraController!.dispose();
      }

      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        // Create a new camera controller using the first available camera (usually the back camera).
        _cameraController = CameraController(
          cameras[0],
          ResolutionPreset.high,
          enableAudio: false, // Audio is not needed for this application.
          imageFormatGroup: ImageFormatGroup.jpeg,
        );

        await _cameraController!.initialize();

        // Fetch zoom capabilities from the initialized controller.
        double minZoom = await _cameraController!.getMinZoomLevel();
        double maxZoom = await _cameraController!.getMaxZoomLevel();

        // Update the state only if the widget is still mounted.
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
      // Potentially show an error message to the user here.
    }
  }

  /// Opens the device's image gallery to select an image.
  ///
  /// After an image is picked, it triggers the metadata generation process.
  void pickImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage == null) return; // User canceled the picker.

      final fileBytes = await pickedImage.readAsBytes();
      setState(() => _image = fileBytes);
      _sendVertexMessage(); // Send the selected image for analysis.
    } catch (e) {
      _showError(e.toString());
    }
  }

  /// Resets the view by removing the current image and re-activating the camera.
  ///
  /// This function fully re-initializes the camera to ensure the preview is
  /// reliably restored, which is more robust than simply resuming a paused preview.
  Future<void> removeImage(BuildContext context) async {
    // Re-initialize the camera to guarantee a fresh and active preview stream.
    await _initializeCamera();

    // Update the state to remove the image and clear any existing metadata.
    if (mounted) {
      setState(() {
        _image = null;
        context.read<AppState>().clearMetadata();
      });
    }
  }

  /// Captures an image using the camera controller.
  ///
  /// This method includes logic to:
  /// 1. Prevent concurrent captures.
  /// 2. Pause the camera preview before taking a picture.
  /// 3. Retry the capture on specific `CameraException` types related to image buffers.
  /// 4. Correct the image orientation using EXIF data.
  /// 5. Trigger the metadata generation process upon successful capture.
  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    // Prevent multiple captures from being initiated simultaneously.
    if (_isTakingPicture) {
      return;
    }

    _isTakingPicture = true;
    try {
      // It's good practice to pause the preview before taking a picture.
      if (_cameraController!.value.isPreviewPaused == false) {
        await _cameraController!.pausePreview();
      }

      XFile? imageFile;
      int attempts = 0;

      // Retry loop to handle intermittent buffer errors on some devices.
      while (attempts < _captureRetryCount) {
        try {
          imageFile = await _cameraController!.takePicture();
          break; // Success, exit the loop.
        } on CameraException catch (ce) {
          final msg = (ce.description ?? ce.code).toLowerCase();
          // Check for common error messages related to buffer/ImageReader issues.
          final isBufferError = msg.contains('unable to acquire') ||
              msg.contains('maximages') ||
              msg.contains('imagereader') ||
              msg.contains('buffer');

          if (isBufferError) {
            attempts++;
            if (attempts < _captureRetryCount) {
              await Future.delayed(_captureRetryDelay); // Wait before retrying.
              continue;
            } else {
              rethrow; // Max retries reached, rethrow the exception.
            }
          } else {
            rethrow; // Not a buffer error, rethrow immediately.
          }
        } catch (e) {
          rethrow; // Rethrow any other unexpected errors.
        }
      }

      if (imageFile == null) {
        _showError('Failed to capture image.');
        return;
      }

      // Mobile cameras often save images with orientation data in EXIF tags.
      // This step rotates the image file to match the visual orientation.
      final originalFile = File(imageFile.path);
      final rotatedFile =
          await FlutterExifRotation.rotateImage(path: originalFile.path);
      final imageBytes = await rotatedFile.readAsBytes();

      if (mounted) {
        setState(() {
          _image = imageBytes;
        });
      }

      _sendVertexMessage(); // Start the AI analysis.
    } catch (e) {
      _showError(e.toString());
    } finally {
      // The preview is intentionally NOT resumed here. It is resumed when the user
      // explicitly taps the "remove image" button via `removeImage()`.
      _isTakingPicture = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final metadata = context.watch<AppState>().metadata;
    final isExpanded = MediaQuery.sizeOf(context).width >= Breakpoints.expanded;

    // --- State 1: Camera Preview is Active ---
    // If no image has been captured/selected and the camera is ready.
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
                // Handle pinch-to-zoom if supported.
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
                // Handle tap-to-focus.
                onTapDown: (details) {
                  if (_cameraController?.value.isInitialized ?? false) {
                    try {
                      final previewSize = _cameraController!.value.previewSize!;
                      // Calculate the tap position relative to the preview size.
                      final scale =
                          MediaQuery.of(context).size.width / previewSize.width;
                      final tapPos = details.localPosition;
                      final x = (tapPos.dx / scale) / previewSize.width;
                      final y = (tapPos.dy / scale) / previewSize.height;

                      // Set the focus point, clamping values to the [0, 1] range.
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
            // Bottom bar with capture button.
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

    // --- State 2: Image Review Screen ---
    // If an image has been captured or selected.
    if (_image != null) {
      // Choose the appropriate layout based on screen width.
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

    // --- State 3: Initial Loading State ---
    // Shown while the camera is initializing for the first time.
    return Scaffold(
      appBar: AppBar(title: const Text('Waiting for Camera')),
      body: const Center(child: Text('Please wait a moment.')),
    );
  }

  /// Sends the captured image and a text prompt to the Vertex AI model.
  ///
  /// This function constructs a multipart request containing a detailed prompt
  /// and the image data. It then processes the JSON response from the model
  /// and updates the application state with the generated metadata.
  Future<void> _sendVertexMessage() async {
    if (_loading || _image == null) return;

    setState(() => _loading = true);

    try {
      final response = await model.generateContent(
        [
          // This is a multimodal request with both text and image parts.
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
            // The image data itself, specified as JPEG.
            InlineDataPart('image/jpeg', _image!),
          ])
        ],
      ).timeout(_modelTimeout); // Apply a timeout to the API call.

      if (response.text != null) {
        final jsonMap = json.decode(response.text!);
        if (mounted) {
          // Use Provider to update the global app state with the new metadata.
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

  /// Displays an [AlertDialog] with a given error message.
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

// ============================================================================
// SECONDARY UI WIDGETS
// These widgets define the different layouts for the image review screen.
// ============================================================================

/// The UI layout for compact screens (e.g., mobile phones in portrait).
///
/// Displays the image and metadata card in a vertical list.
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

  /// Navigates to the chat screen.
  void goToChat(BuildContext context) {
    if (loading) return;
    // Use push() to add the page to the stack and use the new path.
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

  /// Controller to show or hide the chat overlay.
  final OverlayPortalController _aiChatController = OverlayPortalController();

  /// Toggles the visibility of the chat overlay.
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
              // Image container
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
              // Metadata and actions container
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
                      // The chat button also serves as the anchor for the chat popup.
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

    // Add keyboard shortcuts if the policy allows.
    if (Policy.shouldHaveKeyboardShortcuts) {
      content = ShortcutHelper(
        bindings: <ShortcutActivator, VoidCallback>{
          // Ctrl+T to toggle chat.
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

/// A button to remove the currently displayed image.
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

/// A button that navigates to or opens the chat interface.
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

/// A widget that displays the chat interface within an [OverlayPortal].
///
/// This is used in the expanded layout to show the chat as a floating panel.
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
        // Position the chat window at the bottom-right of the screen.
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
            // The ChatPage widget handles the actual chat logic.
            child: ChatPage(onExit: onToggleChat),
          ),
        );
      },
    );
  }
}
