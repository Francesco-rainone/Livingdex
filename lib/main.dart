import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'functionality/state.dart';
import 'functionality/routing.dart';
import 'controllers/splash_controller.dart';

/// The main entry point for the Flutter application.
///
/// This function initializes essential services before running the app.
Future<void> main() async {
  // Ensures that the Flutter widget binding is initialized. This is crucial
  // for calling platform-specific code or using plugins before runApp() is called,
  // particularly for asynchronous operations like Firebase initialization.
  WidgetsFlutterBinding.ensureInitialized();

  // Initializes Firebase services for the application. It uses the
  // platform-specific configuration from the auto-generated `firebase_options.dart` file.
  // The `await` keyword ensures that Firebase is fully initialized before the app starts.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Runs the root widget of the application, wrapping it with MultiProvider.
  // MultiProvider allows for providing multiple state management objects (providers)
  // to the entire widget tree, making them accessible from anywhere in the app.
  runApp(
    MultiProvider(
      providers: [
        // Provides the AppState instance throughout the app. AppState is a
        // ChangeNotifier that holds global application state, allowing widgets
        // to listen and react to changes.
        ChangeNotifierProvider<AppState>(create: (_) => AppState()),
        // Provides the SplashController instance. This controller manages the
        // state and logic for the application's splash screen, such as
        // initial data loading or determining the next route.
        ChangeNotifierProvider<SplashController>(
            create: (_) => SplashController()),
      ],
      child: const MyApp(),
    ),
  );
}

/// The root widget of the application.
///
/// It extends StatelessWidget because its state is managed externally by Provider.
/// This widget sets up the MaterialApp and the overall theme.
class MyApp extends StatelessWidget {
  /// Creates the MyApp widget.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // This ChangeNotifierProvider specifically handles the theme state.
    // It creates a ThemeNotifier, which manages theme properties like brightness
    // (light/dark mode), and makes it available to its descendants.
    return ChangeNotifierProvider<ThemeNotifier>(
      create: (_) => ThemeNotifier(),
      // The builder pattern is used here to rebuild the MaterialApp when the
      // ThemeNotifier notifies its listeners of a change.
      builder: (context, child) {
        // MaterialApp.router is used to enable a declarative routing system,
        // offering more control over navigation, deep linking, and transitions
        // compared to the standard MaterialApp constructor.
        return MaterialApp.router(
          title: 'Livingdex',
          // Hides the "debug" banner in the top-right corner of the screen.
          debugShowCheckedModeBanner: false,
          // The routerConfig property is assigned the router instance defined in
          // `functionality/routing.dart`. This object contains all the route
          // definitions and navigation logic for the app.
          routerConfig: router,
          // Defines the overall visual theme for the application.
          theme: ThemeData(
            // The ColorScheme is generated from a single seed color, which is a
            // modern Material 3 feature that creates a harmonious and complete
            // color palette automatically.
            colorScheme: ColorScheme.fromSeed(
              // The brightness is dynamically set by watching the ThemeNotifier.
              // `context.watch` subscribes this widget to changes in ThemeNotifier,
              // so when the brightness changes, the theme is automatically rebuilt.
              brightness: context.watch<ThemeNotifier>().brightness,
              // The base color used to generate the entire color scheme.
              seedColor: const Color.fromARGB(255, 171, 222, 244),
            ),
          ),
        );
      },
    );
  }
}
