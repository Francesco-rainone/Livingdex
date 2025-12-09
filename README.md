# Livingdex

> 🇮🇹 **[Leggi in Italiano](README.it.md)**

Livingdex is a Flutter application that uses **Gemini 2.0 Flash** to simulate a real-life Pokédex, dedicated to identifying plants and animals.

| <img width="391" height="376" alt="icona_livingdex" src="https://github.com/user-attachments/assets/188e5869-94bd-4a71-989c-a17d21e2a4d1" />| ![splashdefinitivo](https://github.com/user-attachments/assets/39a7e358-e7dc-47f0-a434-8f31942f9beb)| ![nigga](https://github.com/user-attachments/assets/224c9752-cf03-4fb5-8ea9-d04865192734)|
|:--:|:--:|:--:|
| **Application Icon** | **Splash Screen** | **Dark Mode** |

|![homepage](https://github.com/user-attachments/assets/50e3b2b3-a8f3-4cb8-8313-e10e1445cfe7)|![daje](https://github.com/user-attachments/assets/bef0477d-337c-487d-8793-96277792a6b7)|![5913418231807330700 (1)](https://github.com/user-attachments/assets/7a6b2b77-9f85-4ac8-9660-3f9cdbe104ef)| 
|:--:|:--:|:--:|
| **Main Screen** | **Information Screen** | **Rotomdex Chatbot (full-screen image)** |
<br>

## 🗂️ Table of Contents

- [2025 Updates](#-2025-updates) 
- [Project Description](#-project-description)
- [Technical Analysis](#-technical-analysis)
- [Main Features](#-main-features)
- [Architecture and Technologies](#%EF%B8%8F-architecture-and-technologies)
  - [Technologies Used](#technologies-used)
  - [Backend Architecture Cloud Run](#backend-architecture-cloud-run)
- [Configuration and Installation](#%EF%B8%8F-configuration-and-installation)
  - [Prerequisites](#1-prerequisites)
  - [Google Cloud Backend Configuration](#2-google-cloud-backend-configuration)
  - [Flutter Project Configuration](#3-flutter-project-configuration)
  - [Running the Flutter App](#running-the-flutter-app)
  - [Common Errors](#common-errors)
- [Contributions and Future Developments](#-contributions-and-future-developments)
- [Useful Links](#-useful-links)

---


## 📣 2025 Updates

*   **Migration to Gemini 2.0 Flash**: The project has been upgraded from Gemini 1.5 to Gemini 2.0 Flash for better performance.
*   **Introduction of Firebase AI Logic**: The architecture has moved from a direct dependency on **Firebase Vertex AI** to the new **Firebase AI Logic**.

### Advantages of the New Approach

The main advantage of **Firebase AI Logic** is **flexibility**. You can now easily choose which AI provider to use (Vertex AI or Google AI) directly from the code configuration, without having to rewrite the calling logic. This allows you to:
*   Test and compare the models and pricing of both providers.
*   Simplify maintenance and future updates.

### Code Example: Before vs Now

**Before (Firebase Vertex AI):**
```dart
// The logic was tightly coupled to FirebaseVertexAI
model = FirebaseVertexAI.instance.generativeModel(
  model: geminiModel,
  generationConfig: GenerationConfig(
    temperature: 0,
    responseMimeType: 'application/json',
  ),
);
```
**Now (Firebase AI Logic):**
With Firebase AI Logic, the provider choice is configured in the file that manages the model calling logic (in this case, <code>lib/quick_id.dart</code>)

👉 Vertex AI Provider (for enterprise solutions and RAG):
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
👉 Google AI Provider (for prototyping and lower costs):
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
## 📖 Project Description

Livingdex is a personal project that I enjoyed developing. The main goal is to satisfy people's curiosity about the animals and plants they encounter. By taking a photo through the application, you can identify the living being in the image, obtain detailed information (name, weight, height, description enriched with curiosities), and interact with a chatbot for further exploration that will respond by consulting certified sources.

Livingdex is designed to encourage people to look around and see their surroundings better, with a fresh perspective on the environment. Everything is presented with an interface that recalls the aesthetics of a Pokédex, enhanced with additional features like dark mode.

## 📑 Technical Analysis
Here you can find the functional analysis of the project and the folder with the unit tests performed:
- [Functional Analysis](Analisi_Funzionale.en.md)
- [Unit Tests](test/)

## ✨ Main Features
- **Visual Recognition:** Identification of plants and animals via Gemini 2.0 Flash.
- **Pokédex-Themed Interface:** UI inspired by the original design for an immersive experience.
- **Integrated Chatbot (Rotomdex):** Virtual assistant that provides reliable information from English Wikipedia, thanks to a Reasoning Engine that performs RAG (Retrieval-Augmented Generation).
- **Dark Mode:** For a customizable and comfortable visual experience.

## 🛠️ Architecture and Technologies

### Technologies Used
- **Language and Framework**: Dart and Flutter
- **AI and Provider**: Gemini 2.0 Flash, Firebase AI Logic (with Vertex AI or Google AI provider)
- **Backend**: Google Cloud Platform, Cloud Run, Firebase, FlutterFire

#### Backend Architecture (Cloud Run)
To handle requests from the app, a backend on Cloud Run is required. **Two approaches are recommended**:

#### Approach 1: Reasoning Engine (Recommended)
This approach orchestrates multiple services to provide high-quality responses (RAG).

1.  **Receives the image** from the app via an HTTP endpoint.
2.  Uploads it to **Cloud Storage**.
3.  Performs a search on **Vertex AI Search** to find relevant information.
4.  Builds a prompt for Gemini, including the search context.
5.  Calls the Gemini model via **Firebase AI Logic** requesting structured JSON output.
6.  Returns the formatted data to the app.

**Structured JSON Response Example**:

```json

{
  "id": "req-1234",
  "identified": true,
  "species": "Acer platanoides",
  "common_name": "Platano",
  "confidence": 0.93,
  "height_estimate": "5-10 m",
  "description": "Short description...",
  "sources": [
    {"name":"Wikipedia", "url":"https://en.wikipedia.org/...."}
  ]
}
```
#### Approach 2: Simple Proxy
A simpler alternative if RAG is not needed. The backend acts as a proxy that authenticates the request and forwards it to Gemini. It's faster and cheaper to implement, but with lower response quality.

## ⚙️ Configuration and Installation
The app works on mobile devices and, at the moment, has been tested only on **Android**. iOS configuration **has not been tested** and may cause installation and configuration issues.

### 1. Prerequisites
Make sure you have the following installed:
- **Flutter SDK**: [Official Guide](https://docs.flutter.dev/get-started/install)
- **IDE**: Visual Studio Code and Android Studio for an optimal development experience.
- **Google Cloud & Firebase Account**: To use backend and AI services.

### 2. Google Cloud Backend Configuration
This guide is based on the recommended **Reasoning Engine** approach.

#### 2.1. Vertex AI Search Preparation
- In your Google Cloud project, create a **search data store** on Vertex AI Search.
- Configure **a search app** with the necessary data for identification (e.g., descriptions from Wikipedia).

#### 2.2. Agent Deployment on Cloud Run
- Create an application (e.g., in Node.js or Python) that acts as a **Reasoning Engine**.
- Deploy the app on **Cloud Run**. This service will orchestrate calls to Vertex AI Search and Gemini.

#### 2.3. Enabling Firebase AI Logic
- In your Firebase project, enable Firebase AI Logic.
- Configure the integration to communicate with your agent's endpoint on Cloud Run.

## 3. Flutter Project Configuration

### 3.1. Connect Firebase
- Create the <code>config.dart</code> file inside <code>lib/</code> and insert your Cloud Run service URL and the model you want to use.
  ```dart
  const geminiModel = 'gemini-2.0-flash';
  const cloudRunHost = 'your-cloud-run-service.a.run.app';
  ```
- <code>lib/quick_id.dart:</code> Choose which AI provider to use (Vertex AI or Google AI) as shown in the [Updates](#-2025-updates) section

### 3.2. Update Configuration Files
- <code>flutterfire configure</code> to connect the Flutter project to your Firebase project. This will generate the <code>lib/firebase_options.dart</code> file.
**Example of <code>lib/firebase_options.dart</code>**:
 ```dart
// File automatically generated by `flutterfire configure`.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Example for Android
    if (defaultTargetPlatform == TargetPlatform.android) {
      return const FirebaseOptions(
        apiKey: 'ANDROID_API_KEY_PLACEHOLDER',
        appId: 'ANDROID_APP_ID_PLACEHOLDER',
        messagingSenderId: 'SENDER_ID_PLACEHOLDER',
        projectId: 'PROJECT_ID_PLACEHOLDER',
        storageBucket: 'PROJECT_ID.appspot.com',
      );
    }

    // Add configurations for other platforms here (e.g., iOS)

    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }
}

  ```

### Running the Flutter App
- Install all project dependencies:
<code>flutter pub get</code>
- Start the application on an emulator or physical device:
<code>flutter run -d <device-id></code>
**Tip**: It's preferable to run the app on a physical device. [Follow this guide for device configuration.](https://developer.android.com/studio/run/device?hl=it#:~:text=platform-tools-common-,Connect%20to%20your%20device%20using%20USB,%2Fplatform-tools%2F%20directory.)

## ❗Common Errors:
- **Image Quality < 360p**:  
   If the image quality is below 360p, the Gemini API may misinterpret the subject or fail to recognize the image, reporting that the subject is neither an animal nor a plant. In this case, a generic error message will be displayed indicating that the image cannot be identified.
- **Slow Loading**:  
   Slow loading of the subject's description may be due to an internet connection problem or communication with the Gemini API, which may take longer depending on connection quality.

## 🤝 Contributions and Future Developments

### Future Developments
- **Text-to-Speech**: Add a voice reading function for descriptions to improve accessibility.
- **iOS Support**: Test and resolve any compatibility issues.
- **UI/UX Improvements**: Optimize the user interface.

### How to Contribute
If you want to contribute, you are welcome! The areas of greatest need are those listed above. Open a Pull Request to propose your changes.

---
## 🔗 Useful Links
- [Firebase AI Logic – Official Documentation](https://firebase.google.com/docs/ai-logic/faq-and-troubleshooting?hl=it&api=dev#differences-between-gemini-api-providers)
- [Pricing Differences: Vertex AI vs Google AI](https://cloud.google.com/vertex-ai/pricing)
- [Flutter Installation Guide on Windows (YouTube)](https://youtu.be/8saLa5fh0ZI)
- [Google Reference Repo (Photo Discovery Sample)](https://github.com/GoogleCloudPlatform/generative-ai/tree/main/gemini/sample-apps/photo-discovery)
- [Vertex AI Overview](https://cloud.google.com/vertex-ai/docs/overview)
- [How to Install Flutter on Windows](https://youtu.be/0SRvmcsRu2w) 
