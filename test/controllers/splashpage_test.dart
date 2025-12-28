/// Tests for splash page navigation flow.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/controllers/splash_controller.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('Redirects to /home after 1750ms', (WidgetTester tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(),
        ),
        GoRoute(
          path: '/home',
          builder: (_, __) => const Scaffold(),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );

    final context = tester.element(find.byType(Scaffold));
    final controller = SplashController();

    await controller.load(context);
    await tester.pumpAndSettle(const Duration(milliseconds: 1750));
  });
}
