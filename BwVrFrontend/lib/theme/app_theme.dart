import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  // Compatibility static constants for screens that reference them directly
  static const Color primary       = AppColors.primary;
  static const Color secondary     = AppColors.secondary;
  static const Color accent        = AppColors.accent;
  static const Color background    = AppColors.background;
  static const Color surface       = AppColors.surface;
  static const Color border        = AppColors.border;
  static const Color textPrimary   = AppColors.primaryText;
  static const Color textSecondary = AppColors.accent;

  static const Color success = AppColors.success;
  static const Color warning = AppColors.warning;
  static const Color danger  = AppColors.error;
  static const Color error   = AppColors.error;

  static const Color cardBg    = AppColors.background;
  static const Color chipGreen = AppColors.success;
  static const Color chipBlue  = AppColors.surface;
  static const Color chipAmber = AppColors.warning;
  static const Color chipRed   = AppColors.error;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.background,
        secondary: AppColors.secondary,
        onSecondary: AppColors.background,
        surface: AppColors.background,
        onSurface: AppColors.primaryText,
        // ignore: deprecated_member_use
        background: AppColors.background,
        // ignore: deprecated_member_use
        onBackground: AppColors.primaryText,
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.border,
      ),
      textTheme: AppTypography.textTheme,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.primaryText,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'Montserrat',
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.background,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.subheading.copyWith(color: Colors.white),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryText,
          backgroundColor: AppColors.background,
          side: const BorderSide(color: AppColors.primaryText, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.subheading,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryText, width: 2),
        ),
        labelStyle: AppTypography.label.copyWith(color: AppColors.primaryText),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.accent),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.background,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.border, width: 2),
        ),
      ),
      
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1.5,
      ),
    );
  }
}
