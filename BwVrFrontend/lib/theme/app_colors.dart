import 'package:flutter/material.dart';

class AppColors {
  // Base Colors
  static const Color background = Color(0xFFFFFFFF);     // Pure White
  static const Color surface = Color(0xFFF8FAFC);        // Very light background for contrast
  static const Color structural = Color(0xFFF0F4F8);     // Structural Light Aqua for Sidebar/Search
  static const Color border = Color(0xFFE2E8F0);         // Delicate 1px border

  // Brand / Accents
  static const Color primary = Color(0xFF1E57A4);    // Primary Blue
  static const Color secondary = Color(0xFFFABB1F);  // Gold (Call-to-Action)
  static const Color accent = Color(0xFFFABB1F);     // Gold Accent

  // Text
  static const Color textPrimary = Color(0xFF0F2D54);   // Deep Navy Body Text
  static const Color textSecondary = Color(0xFF64748B); // Slate-600 for subtext

  // Feedback Colors
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color error = Color(0xFFEF4444);   // Red
  static const Color warning = Color(0xFFF59E0B); // Amber
}
