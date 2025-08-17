import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/controllers/splash_controller.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('Reindirizzamento dopo 1750ms con GoRouter reale',
      (WidgetTester tester) async {
    // Configura il router reale
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

    // Carica l'app con il router configurato
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );

    // Ottieni il contesto dal widget caricato
    final context = tester.element(find.byType(Scaffold));
    final controller = SplashController();

    // Esegui il metodo load
    await controller.load(context);

    // Aspetta il completamento del delay e della navigazione
    await tester.pumpAndSettle(const Duration(milliseconds: 1750));

    // Verifica la posizione corrente del router
  });
}
