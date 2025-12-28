// Mock device capabilities. Replace with native APIs in production.
// See: flutter.dev/adaptive

/// Mock device capability checks. Returns hardcoded values for demo.
class Capabilities {
  /// Returns true if camera is available.
  static bool get hasCamera {
    return true;
  }

  /// Returns true if physical keyboard is available.
  static bool get hasPhysicalKeyboard {
    return true;
  }
}
