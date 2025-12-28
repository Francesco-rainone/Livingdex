import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../functionality/state.dart';

/// Settings screen with theme app preferences (theme toggle).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Card(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 400,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwitchListTile(
                      title: const Text('Dark Mode per i veri intenditori'),
                      value: context.watch<ThemeNotifier>().darkMode,
                      onChanged: (val) {
                        context.read<ThemeNotifier>().toggleDarkMode(val);
                      },
                    ),
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
