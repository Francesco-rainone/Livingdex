import './capabilities.dart';

/// Defines application-wide policies for enabling or disabling features
/// based on the device's hardware capabilities.
///
/// This class acts as a high-level abstraction over the raw capability checks
/// provided by the `Capabilities` class. It allows other parts of the application
/// to make decisions based on clear, semantic policies rather than direct
/// hardware queries. For example, instead of checking `Capabilities.hasCamera`
/// directly in the UI code, one would check `Policy.shouldTakePicture`.
class Policy {
  /// Determines if features related to picture-taking should be enabled.
  ///
  /// Returns `true` if the device is equipped with a camera, indicating that
  /// UI elements and functionalities for capturing images should be available.
  /// This value is derived from [Capabilities.hasCamera].
  static bool get shouldTakePicture {
    return Capabilities.hasCamera;
  }

  /// Determines if keyboard shortcuts should be registered and available to the user.
  ///
  /// Returns `true` if a physical keyboard is detected, suggesting that the
  /// application can offer keyboard-based navigation and actions for an
  /// enhanced user experience on desktop or laptop-like devices.
  /// This value is derived from [Capabilities.hasPhysicalKeyboard].
  static bool get shouldHaveKeyboardShortcuts {
    return Capabilities.hasPhysicalKeyboard;
  }
}
