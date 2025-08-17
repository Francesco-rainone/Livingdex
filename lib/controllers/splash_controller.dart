import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A controller to manage the application's splash screen and initial loading sequence.
///
/// This class handles the logic for displaying a splash screen for a predefined
/// duration, simulating tasks like asset loading, initial data fetching, or
/// service initialization. Once the simulated loading is complete, it navigates
/// the user to the main part of the application (e.g., the home screen).
///
/// It extends [ChangeNotifier] to allow widgets to listen for changes, although
/// in this simple implementation, it doesn't notify any listeners. This pattern
/// is useful for more complex scenarios where the UI might need to update based
/// on the loading state.
class SplashController extends ChangeNotifier {
  /// Initiates the loading process and navigates to the home screen upon completion.
  ///
  /// This method simulates a loading delay using [Future.delayed]. After the delay,
  /// it checks if the associated widget (`context`) is still mounted in the widget tree
  /// to prevent errors. If the widget is still active, it uses [GoRouter] to
  /// navigate to the '/home' route, effectively transitioning from the splash
  /// screen to the application's main interface.
  ///
  /// [context] The [BuildContext] of the widget that initiates the loading,
  ///           used for navigation and safety checks.
  Future<void> load(BuildContext context) async {
    // Simulate an asynchronous operation, like fetching data or initializing services,
    // by waiting for a fixed duration.
    await Future.delayed(const Duration(milliseconds: 1750));

    // Before attempting to navigate, it's crucial to check if the widget's
    // BuildContext is still valid and mounted in the widget tree. This prevents
    // errors that can occur if the user navigates away or the widget is disposed
    // during the delay.
    if (context.mounted) {
      // Use GoRouter to navigate to the '/home' route, replacing the current
      // (splash) screen in the navigation stack.
      context.go('/home');
    }
  }
}
