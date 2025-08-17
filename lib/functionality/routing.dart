// ignore: dangling_library_doc_comments
import 'package:go_router/go_router.dart';
import '../ui/screens/settings.dart';
import '../ui/screens/quick_id.dart';
import '../ui/screens/chat.dart';
import '../ui/screens/splash_page.dart';
import '../ui/components/navigation.dart';

/// This file centralizes the application's routing configuration using the `go_router` package.
/// It defines all the navigation paths, their corresponding screen widgets, and the overall
/// navigation structure, including a shell route for persistent UI elements like a navigation bar.
///
/// The `router` object defined here is intended to be used with `MaterialApp.router`
/// in the main entry point of the application (e.g., `main.dart`).
///
/// The routing structure includes:
/// - An initial splash screen.
/// - A `ShellRoute` that provides a persistent scaffold with a navigation bar.
/// - Child routes for the main sections of the app (Home, Chat, Settings) that render within the shell.

/// Defines the primary application routes that are nested within the `ShellRoute`.
/// These routes represent the main sections of the app accessible via the
/// persistent navigation bar provided by the parent `ShellRoute`.
/// Defines the primary application routes that are nested within the `ShellRoute`.
List<GoRoute> routes = [
  GoRoute(
    path: '/home',
    builder: (context, state) {
      return const GenerateMetadataScreen();
    },
    routes: [
      GoRoute(
        // The path is 'chat', relative to the parent. The full path becomes '/home/chat'.
        path: 'chat',
        builder: (context, state) {
          return const ChatPage();
        },
      ),
    ],
  ),
  // MODIFICA: La vecchia rotta '/chat' a livello principale è stata rimossa da qui.
  GoRoute(
    path: '/settings',
    builder: (context, state) {
      return const SettingsScreen();
    },
  ),
];

/// The main router configuration for the application.
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashPage(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithNavbar(child: child);
      },
      routes: routes,
    ),
  ],
);
