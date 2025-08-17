// Asynchronous programming library for features like Future, async, and await.
import 'dart:async';

// Library for JSON encoding/decoding and UTF-8 handling.
import 'dart:convert' as convert;

// Application configuration for the deploy on cloud run for the gemini model (in my case the model is: gemini-2.0-flash)
import '../../config.dart';

// Reusable UI components for the application (e.g., buttons, tag capsules).
import '../components/core_components.dart';

// Core Flutter package for building UI and Material Design widgets.
import 'package:flutter/material.dart';

// Pre-built chat UI package for displaying messages, input fields, and typing indicators.
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

// Data types defined by the flutter_chat_types library (e.g., User, Message).
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

// State management package using the Provider pattern.
import 'package:provider/provider.dart';

// Package for generating universally unique identifiers (UUIDs).
import 'package:uuid/uuid.dart';

// HTTP library for making network requests (GET, POST, etc.).
import 'package:http/http.dart' as http;

// Global application state, containing metadata, settings, etc.
import '../../functionality/state.dart';

// added import for go_router
import 'package:go_router/go_router.dart';

// ====================
//   MAIN WIDGET
// ====================

/// A chat page where the user can interact with the "RotomDex" virtual agent.
///
/// This widget displays:
/// - A list of exchanged messages.
/// - Initial suggested questions.
/// - An input field for sending new messages.
/// - Bot responses generated via an external API.
class ChatPage extends StatefulWidget {
  const ChatPage({this.onExit, super.key});

  /// An optional callback function to handle exiting the chat page.
  /// This can be used, for example, to close the chat view.
  final VoidCallback? onExit;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

// ====================
//   CHAT STATE
// ====================

class _ChatPageState extends State<ChatPage> {
  // A flag to indicate if the bot is currently processing a response.
  // Used to show the "typing..." indicator in the UI.
  bool loading = false;

  // The list of messages displayed in the chat UI.
  final List<types.Message> _messages = [];

  // Represents the user interacting with the application.
  final types.User _user = const types.User(
    id: 'user',
    firstName: 'You',
  );

  // Represents the "RotomDex" virtual agent.
  final types.User _agent = const types.User(
    firstName: 'Rotom',
    id: 'agent',
    imageUrl:
        'https://archives.bulbagarden.net/media/upload/thumb/1/10/0479Rotom-Pok%C3%A9dex.png/300px-0479Rotom-Pok%C3%A9dex.png',
  );

  @override
  void initState() {
    super.initState();

    // When the page is initialized, add a welcome message from the bot.
    _messages.add(
      types.TextMessage(
        id: const Uuid().v4(), // Generate a unique ID for the message.
        author: _agent, // The author is the Rotom agent.
        text: 'Ciao sono Rotomdex, fammi sapere come posso aiutarti!',
      ),
    );
  }

  /// Adds a new message to the chat list and triggers a UI update.
  /// Messages are inserted at the beginning of the list because the chat UI is inverted.
  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message); // Insert the message at the top.
    });
  }

  /// Handles the "send" button press in the chat input.
  ///
  /// This function performs three main actions:
  /// 1. Creates a user message object.
  /// 2. Adds the message to the chat list for display.
  /// 3. Initiates the process to send the message to the agent for a response.
  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      id: const Uuid().v4(),
      text: message.text,
    );

    _addMessage(textMessage);
    _sendMessageToAgent(message); // Request a response from the bot.
  }

  /// Calls the backend API to get a response from the virtual agent.
  ///
  /// The parameters (`name`, `description`, `height`, `weight`) are derived from
  /// metadata associated with the object the user is asking about (e.g., a Pokémon).
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
    // Create the API endpoint URI for the backend service (`/ask_gemini`).
    var endpoint = Uri.https(cloudRunHost, '/ask_gemini', {'query': query});

    // Execute the HTTP GET request.
    var response = await http.get(endpoint);

    // If the backend responds successfully (HTTP 200 OK).
    if (response.statusCode == 200) {
      // Decode the response body using UTF-8 to prevent issues with special characters.
      var responseText = convert.utf8.decode(response.bodyBytes);

      // Remove any asterisks used for formatting (e.g., markdown bolding).
      return responseText.replaceAll(RegExp(r'\*'), '');
    }

    // Return a fallback message in case of an API error.
    return 'Sorry, I can\'t answer that right now.';
  }

  /// Sends the user's message to the agent and handles the response.
  void _sendMessageToAgent(types.PartialText message) async {
    setState(() {
      loading = true; // Activate the "typing..." indicator.
    });

    // Retrieve metadata from the global application state using Provider.
    var metadata = context.read<AppState>().metadata!;

    // Request a response from the backend by calling the askAgent function.
    var text = await askAgent(
      metadata.name,
      metadata.height,
      metadata.weight,
      metadata.description,
      message.text,
    );

    // Create a new message object with the bot's response.
    final textMessage = types.TextMessage(
      author: _agent,
      id: const Uuid().v4(),
      text: text,
    );

    // Add the bot's message to the chat UI.
    _addMessage(textMessage);

    setState(() {
      loading = false; // Deactivate the "typing..." indicator.
    });
  }

  /// Initiates the send process using a predefined question from the suggestions.
  void _pickSuggestedQuestion(String question) {
    var message = types.PartialText(text: question);
    _handleSendPressed(message);
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve metadata from the global state. `watch` is used to rebuild if it changes.
    var metadata = context.watch<AppState>().metadata;

    // A nullable widget to hold the suggested questions.
    Widget? suggestionsWidget;

    // Display suggested questions only at the beginning of the chat (when only the welcome message exists).
    if (metadata != null && _messages.length == 1) {
      suggestionsWidget = Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: TagCapsule(
          onTap:
              _pickSuggestedQuestion, // Callback for when a user taps a suggestion.
          title: 'Suggested Questions',
          tags: metadata.suggestedQuestions,
        ),
      );
    }

    // The list of users currently typing, used for the typing indicator.
    List<types.User> typingUsers = [];
    if (loading) {
      typingUsers.add(_agent);
    }

    // ====================
    //   UI CONSTRUCTION
    // ====================
    return Column(
      children: [
        // The top application bar.
        AppBar(
          // Use context.pop() from go_router to navigate back.
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // This function now works correctly with the new router structure.
              context.pop();
            },
          ),
          title: const Text('Chiedi a Rotom'),
          actions: [],
        ),

        // The main body containing the chat interface.
        Expanded(
          child: Chat(
            // Configure the typing indicator.
            typingIndicatorOptions: TypingIndicatorOptions(
              typingUsers: typingUsers,
            ),
            // A widget to display at the bottom of the message list (e.g., suggestions).
            listBottomWidget: suggestionsWidget,
            // The list of messages to display.
            messages: _messages,
            // The function to call when the send button is pressed.
            onSendPressed: _handleSendPressed,
            showUserAvatars: true,
            showUserNames: true,
            // The current user.
            user: _user,
            // Customize the chat theme to match the application's color scheme.
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

            // A custom builder for rendering user avatars.
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
