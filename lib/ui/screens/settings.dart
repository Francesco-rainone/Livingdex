import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../functionality/state.dart';

/// A screen that displays application settings to the user.
///
/// This widget provides a user interface for modifying app-wide preferences,
/// such as toggling the theme. It uses the `provider` package to interact
/// with the application's state.
class SettingsScreen extends StatelessWidget {
  /// Creates a const instance of [SettingsScreen].
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The main layout is centered on the screen.
    return Center(
      child: Column(
        // Centers the content vertically within the column.
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Adds padding around the settings card for better visual spacing.
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Card(
              // Wraps the settings options in a Card for a clean, grouped look.
              child: ConstrainedBox(
                // Sets a maximum width for the card to ensure the layout looks
                // good on larger screens (e.g., tablets or desktops).
                constraints: const BoxConstraints(
                  maxWidth: 400,
                ),
                child: Column(
                  // Ensures the column only takes up as much vertical space as needed.
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// A switch tile for enabling or disabling dark mode.
                    SwitchListTile(
                      title: const Text('Dark Mode per i veri intenditori'),
                      // The value of the switch is tied to the `darkMode` property
                      // in `ThemeNotifier`. `context.watch` ensures that this widget
                      // rebuilds whenever the `darkMode` value changes.
                      value: context.watch<ThemeNotifier>().darkMode,
                      // When the switch is toggled, this callback is fired.
                      onChanged: (val) {
                        // It calls the `toggleDarkMode` method to update the app's
                        // theme state. `context.read` is used here because we are
                        // only dispatching an event and do not need to listen for changes
                        // within the callback itself.
                        context.read<ThemeNotifier>().toggleDarkMode(val);
                      },
                    ),
                    // A simple, non-interactive list tile, likely used for
                    // displaying a tagline or app information.
                    const ListTile(
                      title: Text(
                        'Fatta per sembrare fighi',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
