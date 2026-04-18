import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds & Surfaces
  static const Color background = Color(0xFFEAEAE6);     // Warm Pearl
  static const Color surface = Color(0xFFD9E0E3);        // Misty Gray

  // Primary Text, Headers & Icons
  static const Color primaryText = Color(0xFF5A7684);    // Medium Slate
  static const Color textPrimary = Color(0xFF5A7684);    // Alias for compatibility

  // Brand / Primary Action
  static const Color primary = Color(0xFFC4A495);        // Muted Clay

  // Secondary Elements & Muted Text
  static const Color accent = Color(0xFF88A0A8);         // Soft Teal
  static const Color textSecondary = Color(0xFF88A0A8);  // Alias for compatibility
  static const Color border = Color(0xFF88A0A8);         // Soft Teal

  // Semantic
  static const Color secondary = Color(0xFF88A0A8);      
  static const Color error = Color(0xFFC4A495);          // Using primary as error for softer look
  static const Color success = Color(0xFF5A7684);        // Using primaryText as success
  static const Color warning = Color(0xFFC4A495);
}
