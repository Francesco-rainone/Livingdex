// Copyright 2024 [Your Name or Company]. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Centralized text styles using Google Fonts.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Predefined [TextStyle]s for consistent app typography.
class AppFonts {
  /// Bold Poppins style for main headings.
  static TextStyle title({double fontSize = 20, Color color = Colors.black}) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  /// Regular Roboto style for body text.
  static TextStyle body({double fontSize = 17, Color color = Colors.black}) {
    return GoogleFonts.roboto(
      fontSize: fontSize,
      fontWeight: FontWeight.normal,
      color: color,
    );
  }

  /// Medium Raleway style for subtitles.
  static TextStyle subtitle(
      {double fontSize = 22, Color color = Colors.black}) {
    return GoogleFonts.raleway(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  /// Bold Cinzel style for accent/highlighted text.
  static TextStyle accent({double fontSize = 18, Color color = Colors.black}) {
    return GoogleFonts.cinzel(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }
}
