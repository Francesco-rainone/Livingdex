/* 
This code assumes no camera access and always has physical keyboardfor demo 
purposes. Please use native OS APIs to determine if the device has certain
capabilities. See flutter.dev/adaptive for additional guidance.
*/

/// A class that provides mock data about device capabilities.
///
/// IMPORTANT: This implementation is for demonstration purposes only.
/// It hardcodes capability values rather than querying the actual device.
/// In a production environment, you should replace this with a robust solution
/// that uses native platform APIs to determine device features accurately.
/// For example, you could use packages like `device_info_plus` or `camera`
/// to get real hardware information.
class Capabilities {
  /// Checks if the device has a camera.
  ///
  /// In this mock implementation, it always returns `true`.
  static bool get hasCamera {
    return true;
  }

  /// Checks if the device has a physical keyboard.
  ///
  /// In this mock implementation, it always returns `true`.
  static bool get hasPhysicalKeyboard {
    return true;
  }
}
