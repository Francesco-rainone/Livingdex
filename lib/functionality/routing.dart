/// App routing configuration using go_router.
import 'package:go_router/go_router.dart';
import '../ui/screens/settings.dart';
import '../ui/screens/quick_id.dart';
import '../ui/screens/chat.dart';
import '../ui/screens/splash_page.dart';
import '../ui/components/navigation.dart';

/// Routes nested within [ShellRoute] for main app sections.
List<GoRoute> routes = [
  GoRoute(
    path: '/home',
    builder: (context, state) {
      return const GenerateMetadataScreen();
    },
    routes: [
      GoRoute(
        path: 'chat', // Relative path, full: /home/chat
        builder: (context, state) {
          return const ChatPage();
        },
      ),
    ],
  ),
  GoRoute(
    path: '/settings',
    builder: (context, state) {
      return const SettingsScreen();
    },
  ),
];

/// Main [GoRouter] instance with splash and shell routes.
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
