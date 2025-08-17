import 'package:flutter/material.dart';

import '../models/metadata.dart';

/// Manages the application's global state related to processed content.
///
/// This class extends [ChangeNotifier] to provide a simple and effective
/// way to manage and notify listeners (typically widgets) about state changes.
/// It specifically holds the [Metadata] extracted from a user-selected file.
class AppState extends ChangeNotifier {
  /// Holds the metadata extracted from the currently processed item.
  ///
  /// It is nullable because there might be no item processed yet, or the
  /// state might have been cleared.
  Metadata? metadata;

  /// Updates the current metadata with a new value and notifies listeners.
  ///
  /// This method should be called when new metadata has been successfully
  /// extracted and needs to be displayed in the UI. Calling this will trigger
  /// a rebuild of any listening widgets.
  ///
  /// [newMetadata] The new [Metadata] object to be stored in the state.
  void updateMetadata(Metadata newMetadata) {
    metadata = newMetadata;
    notifyListeners();
  }

  /// Resets the metadata to its initial null state and notifies listeners.
  ///
  /// This is useful for clearing the UI when the user discards the current
  /// item or starts a new process.
  void clearMetadata() {
    metadata = null;
    notifyListeners();
  }
}

/// Manages the application's theme state (light/dark mode).
///
/// As a [ChangeNotifier], this class allows the entire application's theme
/// to be dynamically updated. Widgets can listen to this notifier to rebuild
/// with the appropriate theme colors and styles when the theme is toggled.
class ThemeNotifier extends ChangeNotifier {
  /// A boolean flag to determine if dark mode is currently active.
  /// Defaults to `false` (light mode).
  bool darkMode = false;

  /// A convenience getter that returns the appropriate [Brightness]
  /// based on the current [darkMode] value.
  ///
  /// This is typically used to configure the `brightness` property of a [ThemeData] object.
  Brightness get brightness => darkMode ? Brightness.dark : Brightness.light;

  /// Toggles the application's theme between light and dark mode.
  ///
  /// [val] The boolean value to set for the dark mode. `true` enables
  /// dark mode, and `false` enables light mode.
  void toggleDarkMode(bool val) {
    darkMode = val;
    notifyListeners();
  }
}
