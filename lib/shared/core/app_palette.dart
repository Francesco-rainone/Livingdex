/// App color palette for consistent theming.
import 'package:flutter/material.dart';

/// Black-based MaterialColor swatch for theming.
const primaryColor = MaterialColor(
  0xff000000,
  <int, Color>{
    50: Color(0xffe0e0e0),
    100: Color(0xffb3b3b3),
    200: Color(0xff808080),
    300: Color(0xff4d4d4d),
    400: Color(0xff262626),
    500: Color(0xff000000),
    600: Color(0xff000000),
    700: Color(0xff000000),
    800: Color(0xff000000),
    900: Color(0xff000000),
  },
);

/// Centralized color constants for the app.
class AppPalette {
  /// Primary brand color (green).
  static const primaryColor = Color(0xFF4CAF50);

  /// Secondary accent color (blue).
  static const secondaryColor = Color(0xFF2196F3);

  /// Default screen background (white).
  static const backgroundColor = Color(0xFFFFFFFF);

  /// Standard text color (dark).
  static const textColor = Color(0xFF212121);

  /// Card/surface background (light grey).
  static const cardColor = Color(0xFFE0E0E0);
}
