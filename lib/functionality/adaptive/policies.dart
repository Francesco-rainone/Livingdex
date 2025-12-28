import './capabilities.dart';

/// Feature policies based on device [Capabilities].
class Policy {
  /// True if camera features should be enabled.
  static bool get shouldTakePicture {
    return Capabilities.hasCamera;
  }

  /// True if keyboard shortcuts should be registered.
  static bool get shouldHaveKeyboardShortcuts {
    return Capabilities.hasPhysicalKeyboard;
  }
}
