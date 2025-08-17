// Copyright 2024 [Your Name or Company]. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore: dangling_library_doc_comments
/// This file centralizes all the text styles used throughout the application,
/// making it easy to maintain a consistent visual identity and theme.
/// It utilizes the `google_fonts` package to provide a rich and scalable
/// typography system.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A utility class that holds predefined [TextStyle]s for the application.
///
/// This class is not meant to be instantiated. It provides a set of static methods
/// to retrieve `TextStyle` objects for different typographic purposes, such as
/// titles, body text, and subtitles. This approach ensures that typography
/// remains consistent across the entire app.
class AppFonts {
  /// Returns the `TextStyle` for main titles.
  ///
  /// This style is bold and uses the Poppins font. It's designed for primary
  /// headings on screens and prominent sections.
  ///
  /// [fontSize] The size of the font. Defaults to 20.0.
  /// [color] The color of the text. Defaults to `Colors.black`.
  static TextStyle title({double fontSize = 20, Color color = Colors.black}) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  /// Returns the `TextStyle` for the main body of text.
  ///
  /// This style uses the Roboto font with a normal weight, optimized for
  /// readability in paragraphs and long-form content.
  ///
  /// [fontSize] The size of the font. Defaults to 17.0.
  /// [color] The color of the text. Defaults to `Colors.black`.
  static TextStyle body({double fontSize = 17, Color color = Colors.black}) {
    return GoogleFonts.roboto(
      fontSize: fontSize,
      fontWeight: FontWeight.normal,
      color: color,
    );
  }

  /// Returns the `TextStyle` for subtitles.
  ///
  /// This style uses the Raleway font with a medium weight. It's suitable for
  /// secondary headings or captions that require a slightly lighter emphasis
  /// than a main title.
  ///
  /// [fontSize] The size of the font. Defaults to 22.0.
  /// [color] The color of the text. Defaults to `Colors.black`.
  static TextStyle subtitle(
      {double fontSize = 22, Color color = Colors.black}) {
    return GoogleFonts.raleway(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  /// Returns the `TextStyle` for accent text.
  ///
  /// This style is bold and uses the decorative Cinzel font. It's intended
  /// for special text elements that need to draw attention, such as Pokémon
  /// names or other highlighted keywords.
  ///
  /// [fontSize] The size of the font. Defaults to 18.0.
  /// [color] The color of the text. Defaults to `Colors.black`.
  static TextStyle accent({double fontSize = 18, Color color = Colors.black}) {
    return GoogleFonts.cinzel(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }
}
