import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Manages splash screen timing and navigation to home.
class SplashController extends ChangeNotifier {
  /// Waits for splash duration then navigates to '/home' if context is mounted.
  Future<void> load(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 1750));

    if (context.mounted) {
      context.go('/home');
    }
  }
}
