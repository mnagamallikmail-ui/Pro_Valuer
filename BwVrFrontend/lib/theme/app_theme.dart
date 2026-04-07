import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Color Palette ──────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1A1A2E); // Deep navy
  static const Color primaryLight = Color(0xFF16213E); // Lighter navy
  static const Color accent = Color(0xFF4F9CF9); // Electric blue
  static const Color accentDark = Color(0xFF2D7DEF); // Darker blue
  static const Color surface = Color(0xFFF8F9FA); // Near-white
  static const Color cardBg = Color(0xFFFFFFFF); // White cards
  static const Color textPrimary = Color(0xFF0D0D0D); // Near-black text
  static const Color textSecondary = Color(0xFF6B7280); // Gray text
  static const Color success = Color(0xFF10B981); // Emerald green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color danger = Color(0xFFEF4444); // Red
  static const Color border = Color(0xFFE5E7EB); // Light gray border
  static const Color sidebarBg = Color(0xFF0F172A); // Very deep navy
  static const Color sidebarActive = Color(0xFF1E293B); // Active sidebar item
  static const Color chipBlue = Color(0xFFEFF6FF); // Blue chip bg
  static const Color chipGreen = Color(0xFFECFDF5); // Green chip bg
  static const Color chipAmber = Color(0xFFFFFBEB); // Amber chip bg
  static const Color chipRed = Color(0xFFFEF2F2); // Red chip bg

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        primary: accent,
        surface: surface,
        background: surface,
      ),
      scaffoldBackgroundColor: surface,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: cardBg,
        foregroundColor: textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: border),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: danger),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
        hintStyle: const TextStyle(color: textSecondary, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: const BorderSide(color: accent),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      dividerColor: border,
      dividerTheme: const DividerThemeData(color: border, space: 1),
    );
  }
}
