// This file defines the color palette for the application, ensuring a consistent
// look and feel across all UI components.

import 'package:flutter/material.dart';

/// A MaterialColor swatch based on shades of black.
///
/// MaterialColor is a special type of color that defines a primary color and its
/// various shades (from 50 to 900). This is useful for Flutter's theming system,
/// as some widgets will automatically use different shades for different states
/// (e.g., a button's splash color).
const primaryColor = MaterialColor(
  0xff000000, // The primary value of the swatch, which is black.
  <int, Color>{
    50: Color(0xffe0e0e0), // Lightest shade
    100: Color(0xffb3b3b3),
    200: Color(0xff808080),
    300: Color(0xff4d4d4d),
    400: Color(0xff262626),
    500: Color(0xff000000), // The default shade
    600: Color(0xff000000),
    700: Color(0xff000000),
    800: Color(0xff000000),
    900: Color(0xff000000), // Darkest shade
  },
);

/// A utility class that holds the primary color constants for the application.
///
/// Using a dedicated class for the app's palette helps in maintaining
/// a consistent color scheme. It centralizes all color definitions, making it
/// easy to update or re-brand the application's look and feel in the future.
/// This class is not meant to be instantiated; its properties should be accessed
/// statically (e.g., `AppPalette.primaryColor`).
class AppPalette {
  /// The main brand color, used for primary UI elements like app bars and buttons.
  static const primaryColor = Color(0xFF4CAF50); // Vibrant green

  /// An accent color used for secondary UI elements, such as floating action buttons
  /// or highlighting selected text.
  static const secondaryColor = Color(0xFF2196F3); // Deep blue

  /// The default background color for most screens and layouts.
  static const backgroundColor = Color(0xFFFFFFFF); // White background

  /// The standard color for text content, ensuring readability against the background.
  static const textColor = Color(0xFF212121); // Dark text

  /// The background color for surface elements like cards, dialogs, and sheets.
  /// It provides a subtle elevation effect against the main background.
  static const cardColor = Color(0xFFE0E0E0); // Light grey for cards
}
