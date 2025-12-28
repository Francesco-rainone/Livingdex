import 'dart:async';
import 'dart:convert' as convert;

import '../../config.dart';
import '../components/core_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import '../../functionality/state.dart';
import 'package:go_router/go_router.dart';

/// Chat page for interacting with the RotomDex virtual agent.
class ChatPage extends StatefulWidget {
  const ChatPage({this.onExit, super.key});

  /// Optional callback when exiting the chat.
  final VoidCallback? onExit;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool loading = false;
  final List<types.Message> _messages = [];

  final types.User _user = const types.User(
    id: 'user',
    firstName: 'You',
  );

  final types.User _agent = const types.User(
    firstName: 'Rotom',
    id: 'agent',
    imageUrl:
        'https://archives.bulbagarden.net/media/upload/thumb/1/10/0479Rotom-Pok%C3%A9dex.png/300px-0479Rotom-Pok%C3%A9dex.png',
  );

  @override
  void initState() {
    super.initState();
    _messages.add(
      types.TextMessage(
        id: const Uuid().v4(),
        author: _agent,
        text: 'Ciao sono Rotomdex, fammi sapere come posso aiutarti!',
      ),
    );
  }

  /// Adds message to chat list (inserted at top for inverted list).
  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  /// Handles send button: creates user message and requests agent response.
  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      id: const Uuid().v4(),
      text: message.text,
    );

    _addMessage(textMessage);
    _sendMessageToAgent(message);
  }

  /// Calls backend API to get agent response.
  Future<String> askAgent(
    String name,
    String description,
    String height,
    String weight,
    String question,
  ) async {
    // Construct the full query string for the model. This is a form of prompt engineering
    // to guide the model's response style and content.
    var query =
        'Analisi richiesta per: $name. Dati iniziali: $description. Altezza: $height. Peso: $weight. La tua missione è rispondere alla seguente domanda: $question. '
        'Ecco le tue direttive operative, zzzt! '
        '1. **Ricerca Esterna Obbligatoria**: Se i dati iniziali non sono sufficienti per rispondere in modo completo e accurato alla domanda, è tuo dovere cercare autonomamente le informazioni mancanti. Non limitarti mai solo a quanto fornito. '
        '2. **Fonti Certificate ad Ampio Spettro**: Per la tua ricerca, devi consultare in ordine di priorità le seguenti fonti autorevoli, che offrono un contesto scientifico ampio e globale: '
        '   - **Fonte Primaria Generale**: Wikipedia in lingua inglese (en.wikipedia.org) per una panoramica iniziale. '
        '   - **Istituzioni Museali e Scientifiche**: I portali di musei di storia naturale e istituti di ricerca di fama mondiale. Le tue fonti principali qui devono essere il **Natural History Museum di Londra** e lo **Smithsonian National Museum of Natural History** di Washington, per dati tassonomici, biologici e di ricerca. '
        '   - **Organizzazioni Internazionali**: Il sito della **IUCN (International Union for Conservation of Nature)**, come fonte primaria per lo stato di conservazione di una specie (es. Lista Rossa IUCN). Per approfondimenti su habitat, comportamento ed ecologia, fai riferimento al **National Geographic Society**. '
        '3. **Lingua e Stile**: Rispondi sempre e solo in **italiano**. Adotta il tono di un RotomDex: sii preciso, informativo, un po\' tecnologico e vivace. Inizia la tua risposta con un "Bzzzt!" o un suono simile. '
        '4. **Formato della Risposta**: Fornisci una risposta **unica, fluida e concisa**. Non usare elenchi puntati, grassetto o sezioni separate. La risposta deve essere un paragrafo unico e coerente. '
        '5. **Regole di Accuratezza**: Non includere mai informazioni inventate o non verificate dalle fonti citate. Non ripetere le informazioni che ti sono già state fornite (come nome, descrizione, ecc.), ma usale come base per integrare ciò che manca. Sii preciso e vai dritto al punto. Zzzt!';

    var endpoint = Uri.https(cloudRunHost, '/ask_gemini', {'query': query});

    var response = await http.get(endpoint);

    if (response.statusCode == 200) {
      var responseText = convert.utf8.decode(response.bodyBytes);
      return responseText.replaceAll(RegExp(r'\*'), '');
    }

    return 'Sorry, I can\'t answer that right now.';
  }

  /// Sends user message to agent and displays response.
  void _sendMessageToAgent(types.PartialText message) async {
    setState(() {
      loading = true;
    });

    var metadata = context.read<AppState>().metadata!;

    var text = await askAgent(
      metadata.name,
      metadata.height,
      metadata.weight,
      metadata.description,
      message.text,
    );

    final textMessage = types.TextMessage(
      author: _agent,
      id: const Uuid().v4(),
      text: text,
    );

    _addMessage(textMessage);

    setState(() {
      loading = false;
    });
  }

  /// Triggers send with a suggested question.
  void _pickSuggestedQuestion(String question) {
    var message = types.PartialText(text: question);
    _handleSendPressed(message);
  }

  @override
  Widget build(BuildContext context) {
    var metadata = context.watch<AppState>().metadata;

    Widget? suggestionsWidget;

    if (metadata != null && _messages.length == 1) {
      suggestionsWidget = Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: TagCapsule(
          onTap: _pickSuggestedQuestion,
          title: 'Suggested Questions',
          tags: metadata.suggestedQuestions,
        ),
      );
    }

    List<types.User> typingUsers = [];
    if (loading) {
      typingUsers.add(_agent);
    }

    return Column(
      children: [
        AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.pop();
            },
          ),
          title: const Text('Chiedi a Rotom'),
          actions: [],
        ),
        Expanded(
          child: Chat(
            typingIndicatorOptions: TypingIndicatorOptions(
              typingUsers: typingUsers,
            ),
            listBottomWidget: suggestionsWidget,
            messages: _messages,
            onSendPressed: _handleSendPressed,
            showUserAvatars: true,
            showUserNames: true,
            user: _user,
            theme: DefaultChatTheme(
              receivedMessageBodyTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              sentMessageBodyTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
              ),
              userAvatarNameColors: [
                Theme.of(context).colorScheme.primary,
              ],
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHigh,
              primaryColor: Theme.of(context).colorScheme.primary,
              secondaryColor: Theme.of(context).colorScheme.surface,
            ),
            avatarBuilder: (user) {
              return Row(
                children: [
                  Container(
                    width: 55.5,
                    height: 50.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(user.imageUrl ?? ''),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 9.0),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
