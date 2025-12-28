/// Tests for [AppState] and [ThemeNotifier] state management.
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:app/functionality/state.dart';
import 'package:mockito/mockito.dart';
import 'package:app/models/metadata.dart';

class MockListener extends Mock {
  void call();
}

void main() {
  group('AppState', () {
    test('Initial state has null metadata', () {
      final appState = AppState();
      expect(appState.metadata, isNull);
    });

    test('updateMetadata notifies listeners', () {
      final appState = AppState();
      final listener = MockListener();
      appState.addListener(listener.call);

      appState.updateMetadata(Metadata(
        name: 'Test',
        description: 'Desc',
        suggestedQuestions: [],
        height: '1m',
        weight: '10kg',
        type: [],
      ));

      verify(listener()).called(1);
      expect(appState.metadata?.name, 'Test');
    });

    test('clearMetadata resets state', () {
      final appState = AppState();
      appState.updateMetadata(Metadata(
        name: 'Test',
        description: 'Desc',
        suggestedQuestions: [],
        height: '1m',
        weight: '10kg',
        type: [],
      ));
      appState.clearMetadata();
      expect(appState.metadata, isNull);
    });
  });

  group('ThemeNotifier', () {
    test('Initial dark mode is false', () {
      final themeNotifier = ThemeNotifier();
      expect(themeNotifier.darkMode, false);
    });

    test('toggleDarkMode updates state', () {
      final themeNotifier = ThemeNotifier();
      final listener = MockListener();
      themeNotifier.addListener(listener.call);

      themeNotifier.toggleDarkMode(true);
      expect(themeNotifier.darkMode, true);
      verify(listener()).called(1);
    });

    test('brightness reflects dark mode', () {
      final themeNotifier = ThemeNotifier();
      expect(themeNotifier.brightness, Brightness.light);
      themeNotifier.toggleDarkMode(true);
      expect(themeNotifier.brightness, Brightness.dark);
    });
  });
}
