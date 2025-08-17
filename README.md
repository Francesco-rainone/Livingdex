# Livingdex

Livingdex è un'applicazione Flutter che utilizza **Gemini 2.0 Flash** per simulare un Pokédex nella vita reale, dedicata all'identificazione di piante e animali.

| <img width="391" height="376" alt="icona_livingdex" src="https://github.com/user-attachments/assets/188e5869-94bd-4a71-989c-a17d21e2a4d1" />| ![splashdefinitivo](https://github.com/user-attachments/assets/39a7e358-e7dc-47f0-a434-8f31942f9beb)| ![nigga](https://github.com/user-attachments/assets/224c9752-cf03-4fb5-8ea9-d04865192734)|
|:--:|:--:|:--:|
| **Icona Applicazione** | **Splash Screen** | **Modalità Scura** |

|![homepage](https://github.com/user-attachments/assets/50e3b2b3-a8f3-4cb8-8313-e10e1445cfe7)|![homepage](https://github.com/user-attachments/assets/83b94a69-f2d1-4f46-9583-f415fc755610)|![5913418231807330700 (1)](https://github.com/user-attachments/assets/7a6b2b77-9f85-4ac8-9660-3f9cdbe104ef)| 
|:--:|:--:|:--:|
| **Schermata Principale** | **Schermata Delle Informazioni** | **Chatbot Rotomdex (immagine full-screen)** |
<br>

## 🗂️ Tabella dei Contenuti

- [Novità 2025](README.md#-novità-2025) 
- [Descrizione del Progetto](#-descrizione-del-progetto)
- [Analisi Tecnica](#-analisi-tecnica)
- [Funzionalità Principali](#-funzionalità-principali)
- [Architettura e Tecnologie](#%EF%B8%8F-architettura-e-tecnologie)
  - [Tecnologie Utilizzate](#tecnologie-utilizzate)
  - [Architettura del Backend Cloud Run](#architettura-del-backend-cloud-run)
- [Configurazione e Installazione](README.md#%EF%B8%8F-configurazione-e-installazione)
  - [Prerequisiti](#1-prerequisiti)
  - [Configurazione del Backend Google Cloud](#2-configurazione-del-backend-google-cloud)
  - [Configurazione del Progetto Flutter](#3-configurazione-del-progetto-flutter)
  - [Esecuzione dellApp Flutter](#esecuzione-dellapp-flutter)
  - [Errori Comuni](#errori-comuni)
- [Contributi e Sviluppi Futuri](#-contributi-e-sviluppi-futuri)
- [Link Utili](#-link-utili)

---


## 📣 Novità 2025

*   **Migrazione a Gemini 2.0 Flash**: Il progetto è stato aggiornato da Gemini 1.5 a Gemini 2.0 Flash per performance migliori.
*   **Introduzione di Firebase AI Logic**: L'architettura è passata da una dipendenza diretta da **Firebase Vertex AI** al nuovo **Firebase AI Logic**.

### Vantaggi del Nuovo Approccio

Il principale vantaggio di **Firebase AI Logic** è la **flessibilità**. Ora è possibile scegliere facilmente quale provider AI utilizzare (Vertex AI o Google AI) direttamente dalla configurazione del codice, senza dover riscrivere la logica di chiamata. Questo permette di:
*   Testare e confrontare i modelli e i prezzi dei due provider.
*   Semplificare la manutenzione e gli aggiornamenti futuri.

### Esempio di Codice: Prima vs Ora

**Prima (Firebase Vertex AI):**
```dart
// La logica era strettamente legata a FirebaseVertexAI
model = FirebaseVertexAI.instance.generativeModel(
  model: geminiModel,
  generationConfig: GenerationConfig(
    temperature: 0,
    responseMimeType: 'application/json',
  ),
);
```
**Ora (Firebase AI Logic):**
Con Firebase AI Logic, la scelta del provider va configurata nel file che gestisce la logica di chiamata al modello (in questo caso, <code>lib/quick_id.dart</code>)

👉 Provider Vertex AI (per soluzioni enterprise e RAG):
```dart
final googleAI = FirebaseAI.vertexAI();

model = googleAI.generativeModel(
  model: geminiModel,
  generationConfig: GenerationConfig(
    temperature: 0.1,
    responseMimeType: 'application/json',
  ),
);
```
👉 Provider Google AI (per prototipazione e costi inferiori):
```dart
final googleAI = FirebaseAI.googleAI();

model = googleAI.generativeModel(
  model: geminiModel,
  generationConfig: GenerationConfig(
    temperature: 0.1,
    responseMimeType: 'application/json',
  ),
);
```
## 📖 Descrizione del Progetto

Livingdex è un progetto personale che mi sono divertito a sviluppare. L'obiettivo principale è quello di soddisfare la curiosità delle persone riguardo agli animali e alle piante che incontrano. Scattando una foto tramite l'applicazione, è possibile identificare l'essere vivente inquadrato, ottenere informazioni dettagliate (nome, peso, altezza, descrizione arricchita con curiosità) e interagire con un chatbot per approfondire ulteriormente che risponderà consultando fonti certificate alle domande.

Livingdex è stata pensata per invogliare le persone a guardarsi intorno e vedere meglio ciò che li circonda, con uno sguardo nuovo sull’ambiente. Il tutto è presentato con un’interfaccia che richiama l’estetica di un Pokédex, arricchita da funzionalità aggiuntive come la modalità scura.

## 📑 Analisi Tecnica
Qui potete trovare l’analisi funzionale del progetto e la cartella con gli unit test svolti:
- [Analisi Funzionale](Analisi_Funzionale.md)
- [Unit Test](test/)

## ✨ Funzionalità Principali
- **Riconoscimento Visuale:** Identificazione di piante e animali tramite Gemini 2.0 Flash.
- **Interfaccia a Tema Pokédex:** UI ispirata al design originale per un'esperienza immersiva.
- **Chatbot Integrato (Rotomdex):** Assistente virtuale che fornisce informazioni affidabili da Wikipedia inglese, grazie a un Reasoning Engine che effettua RAG (Retrieval-Augmented Generation).
- **Modalità Scura:** Per un'esperienza visiva personalizzabile e confortevole.

## 🛠️ Architettura e Tecnologie

### Tecnologie Utilizzate
- **Linguaggio e Framework**: Dart e Flutter
- **Ai e Provider**: Gemini 2.0 Flash, Firebase AI Logic (con provider Vertex AI o Google AI)
- **Backend**: Google Cloud Platform, Cloud Run, Firebase, FlutterFire

#### Architettura del Backend (Cloud Run)
Per gestire le richieste dall'app, è necessario un backend su Cloud Run. **Si consigliano due approcci**:

#### Approccio 1: Reasoning Engine (Consigliato)
Questo approccio orchestra più servizi per fornire risposte di alta qualità (RAG).

1.  **Riceve l'immagine** dall'app tramite un endpoint HTTP.
2.  La carica su **Cloud Storage**.
3.  Esegue una ricerca su **Vertex AI Search** per trovare informazioni pertinenti.
4.  Costruisce un prompt per Gemini, includendo il contesto della ricerca.
5.  Chiama il modello Gemini tramite **Firebase AI Logic** richiedendo un output JSON strutturato.
6.  Restituisce i dati formattati all'app.

**Esempio di Risposta JSON Strutturata**:

```json

{
  "id": "req-1234",
  "identified": true,
  "species": "Acer platanoides",
  "common_name": "Platano",
  "confidence": 0.93,
  "height_estimate": "5-10 m",
  "description": "Descrizione breve...",
  "sources": [
    {"name":"Wikipedia", "url":"https://en.wikipedia.org/...."}
  ]
}
```
#### Approccio 2: Proxy Semplice
Un'alternativa più semplice se non si necessita di RAG. Il backend agisce come un proxy che autentica la richiesta e la inoltra a Gemini. È più veloce ed economico da implementare, ma con una qualità inferiore nelle risposte.

## ⚙️ Configurazione e Installazione
L'app funziona su dispositivi mobili e, al momento, è stata testata solo su **Android**. La configurazione su iOS **non è stata testata** e potrebbe causare problemi nell'installazione e nella configurazione dell'applicazione.

#### 1. Prerequisiti
Assicurati di avere installato quanto segue:
- **Flutter SDK**: [Guida ufficiale](https://docs.flutter.dev/get-started/install)
- **IDE**: Visual Studio Code e Android Studio per un'esperienza di sviluppo ottimale.
- **Account Google Cloud & Firebase**: Per utilizzare i servizi di backend e AI.

#### 2. Configurazione del Backend (Google Cloud)
Questa guida si basa sull'approccio consigliato del **Reasoning Engine**.

#### 2.1. Preparazione di Vertex AI Search
- Nel tuo progetto Google Cloud, crea un **data store di ricerca** su Vertex AI Search.
- Configura **un'app di ricerca** con i dati necessari per l'identificazione (es. descrizioni da Wikipedia).

#### 2.2. Deploy dell'Agente su Cloud Run
- Crea un'applicazione (es. in Node.js o Python) che funga da **Reasoning Engine**.
- Distribuisci l'app su **Cloud Run**. Questo servizio orchestrerà le chiamate a Vertex AI Search e Gemini.

#### 2.3. Abilitazione di Firebase AI Logic
- Nel tuo progetto Firebase, abilita Firebase AI Logic.
- Configura l'integrazione per comunicare con l'endpoint del tuo agente su Cloud Run.

## 3. Configurazione del Progetto Flutter

### 3.1. Collega Firebase
- crea il file <code> config.dart:</code> all'interno di <code>lib/ </code> inserisci l'URL del tuo servizio Cloud Run e il modello che vuoi utilizzare.
  ```dart
  const geminiModel = 'gemini-2.0-flash';
  const cloudRunHost = 'iltuo-servizio-su-cloud-run.a.run.app';
  ```
- <code> lib/quick_id.dart:</code> Scegli quale provider AI utilizzare (Vertex AI o Google AI) come mostrato nella sezione "Novità"..

### 3.2. Aggiorna i File di Configurazione
- <code> flutterfire configure</code> per collegare il progetto Flutter al tuo progetto Firebase. Verrà generato il file <code>lib/firebase_options.dart</code>.
**Esempio di <code>lib/firebase_options.dart</code>**:
 ```dart
// File generato automaticamente da `flutterfire configure`.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Esempio per Android
    if (defaultTargetPlatform == TargetPlatform.android) {
      return const FirebaseOptions(
        apiKey: 'ANDROID_API_KEY_PLACEHOLDER',
        appId: 'ANDROID_APP_ID_PLACEHOLDER',
        messagingSenderId: 'SENDER_ID_PLACEHOLDER',
        projectId: 'PROJECT_ID_PLACEHOLDER',
        storageBucket: 'PROJECT_ID.appspot.com',
      );
    }

    // Aggiungi qui le configurazioni per le altre piattaforme (es. iOS)

    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }
}

  ```

### Esecuzione dell'App Flutter
- Installa tutte le dipendenze del progetto:
<code> flutter pub get </code>
- Avvia l'applicazione su un emulatore o un dispositivo fisico:
<code> flutter run -d <device-id> </code>
**Consiglio**: È preferibile avviare l'app su un dispositivo fisico. Segui questa [Segui questa guida per la configurazione del dispositivo.](https://developer.android.com/studio/run/device?hl=it#:~:text=platform-tools-common-,Connect%20to%20your%20device%20using%20USB,%2Fplatform-tools%2F%20directory.)

## ❗Errori Comuni:
- **Qualità dell'Immagine < 360p**:  
   Se la qualità dell'immagine è inferiore a 360p, l'API Gemini può interpretare erroneamente il soggetto o non riuscire a riconoscere l'immagine, comunicando che il soggetto non è né un animale né una pianta. In tal caso, verrà visualizzato un messaggio di errore generico che indica che l'immagine non può essere identificata.
- **Lentezza nel Caricamento**:  
   La lentezza nel caricare la descrizione del soggetto potrebbe essere dovuta a un problema di connessione internet o alla comunicazione con l'API Gemini, che potrebbe richiedere più tempo in base alla qualità della connessione.

## 🤝 Contributi e Sviluppi Futuri

### Sviluppi Futuri
- **Text-to-Speech**: Aggiungere una funzione di lettura vocale delle descrizioni per migliorare l'accessibilità.
- **Supporto IOS**: Testare e risolvere eventuali problemi di compatibilità.
- **Miglioramenti UI/UX**:  Ottimizzare l'interfaccia utente.

### Come Contribuire
Se vuoi contribuire, sei il benvenuto/a! Le aree di maggiore necessità sono quelle elencate sopra. Apri una Pull Request per proporre le tue modifiche.

---
## 🔗 Link Utili
- [Firebase AI Logic – Documentazione Ufficiale](https://firebase.google.com/docs/ai-logic/faq-and-troubleshooting?hl=it&api=dev#differences-between-gemini-api-providers)
- [Differenze di Prezzo: Vertex AI vs Google AI](https://cloud.google.com/vertex-ai/pricing)
- [Guida Installazione Flutter su Windows (YouTube)](https://youtu.be/8saLa5fh0ZI)
- [Repo Google di riferimento (Photo Discovery Sample)](https://github.com/GoogleCloudPlatform/generative-ai/tree/main/gemini/sample-apps/photo-discovery)
- [Panoramica su Vertex AI](https://cloud.google.com/vertex-ai/docs/overview)

