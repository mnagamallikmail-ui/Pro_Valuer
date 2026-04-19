import 'package:flutter/material.dart';

class AppColors {
  // Base Colors
  static const Color background = Color(0xFFFAFAF8); // Soft Ivory
  static const Color surface = Color(0xFFF1F1ED);    // Warm Cloud
  static const Color border = Color(0xFFE4E4E1);     // Linen Gray

  // Brand / Accents
  static const Color primary = Color(0xFFE7D8C9);    // Blush Beige
  static const Color secondary = Color(0xFFCFE1D6);  // Pastel Sage
  static const Color accent = Color(0xFFDDEAF6);     // Soft Sky

  // Text
  static const Color textPrimary = Color(0xFF5C5F62);   // Warm Slate
  static const Color textSecondary = Color(0xFF7A7D80); // Ash Gray

  // Feedback Colors (Derived from palette where possible, kept subtle)
  static const Color success = Color(0xFFCFE1D6); // Same as secondary
  static const Color error = Color(0xFFF6DDE0);   // Subtle pastel red
  static const Color warning = Color(0xFFF6EFDD); // Subtle pastel amber
}
