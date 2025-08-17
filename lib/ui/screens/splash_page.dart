import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/splash_controller.dart';

/// A widget that displays a splash screen.
///
/// This is the initial page shown to the user when the app starts. It remains
/// on-screen while the application performs necessary initialization tasks,
/// such as checking authentication, loading configuration, or fetching initial data.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

/// Manages the state for the [SplashPage].
class _SplashPageState extends State<SplashPage> {
  /// Called when this object is inserted into the tree.
  ///
  /// This method is used to kick off the application's initialization process.
  @override
  void initState() {
    super.initState();
    // We use `addPostFrameCallback` to ensure that our initialization logic,
    // which may involve navigation, runs *after* the first frame has been painted.
    // Attempting to navigate before the widget is fully built can lead to errors.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Access the SplashController via Provider to trigger the loading process.
      // The controller is responsible for handling the business logic of what
      // needs to be loaded and where to navigate upon completion.
      context.read<SplashController>().load(context);
    });
  }

  /// Builds the user interface for the splash screen.
  ///
  /// The UI provides visual feedback to the user, indicating that the app is
  /// loading in the background. It consists of the application logo and a
  /// circular progress indicator.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Set the background color to match the app's primary icon theme color
      // for a consistent look and feel.
      backgroundColor: Theme.of(context).primaryIconTheme.color,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display the application logo.
              Image.asset(
                'lib/assets/images/logo_definitivo.png',
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 24),
              // Show a loading indicator to signify that background work is happening.
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
