import 'package:flutter/material.dart';

import '../models/metadata.dart';

/// Global app state holding processed [Metadata].
class AppState extends ChangeNotifier {
  /// Current metadata, null if not yet processed.
  Metadata? metadata;

  /// Updates [metadata] and notifies listeners.
  void updateMetadata(Metadata newMetadata) {
    metadata = newMetadata;
    notifyListeners();
  }

  /// Resets [metadata] to null and notifies listeners.
  void clearMetadata() {
    metadata = null;
    notifyListeners();
  }
}

/// Manages light/dark theme state.
class ThemeNotifier extends ChangeNotifier {
  /// True if dark mode is enabled.
  bool darkMode = false;

  /// Returns [Brightness.dark] or [Brightness.light] based on [darkMode].
  Brightness get brightness => darkMode ? Brightness.dark : Brightness.light;

  /// Sets dark mode and notifies listeners.
  void toggleDarkMode(bool val) {
    darkMode = val;
    notifyListeners();
  }
}
