import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// AppTheme — implements the "Valuation Emerald" design system.
/// Maintained static color constants for backward compatibility with existing screens.
class AppTheme {
  // ──────────────────────────────────────────────
  // Static color tokens (Required by existing screens)
  // ──────────────────────────────────────────────
  static const Color primary       = AppColors.primary;
  static const Color secondary     = AppColors.secondary;
  static const Color accent        = AppColors.accent;
  static const Color background    = AppColors.background;
  static const Color surface       = AppColors.surface;
  static const Color border        = AppColors.border;
  static const Color textPrimary   = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  // Semantic feedback colors
  static const Color success = AppColors.success;
  static const Color warning = AppColors.warning;
  static const Color error   = AppColors.error;
  static const Color danger  = AppColors.error;

  // Chip / badge backgrounds (Updated for Minimal Brand)
  static const Color cardBg    = AppColors.background; 
  static const Color chipBlue  = AppColors.structural; // Use structural as soft background
  static const Color chipGreen = Color(0xFFDCFCE7);
  static const Color chipAmber = Color(0xFFFEF9C3);
  static const Color chipRed   = Color(0xFFFEE2E2);

  // ──────────────────────────────────────────────
  // ThemeData Configuration
  // ──────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.montserrat().fontFamily,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: AppColors.textPrimary,
        surface: AppColors.background,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.border,
      ),
      
      textTheme: AppTypography.textTheme,

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.secondary,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background, // Pure White AppBar
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        shape: const Border(bottom: BorderSide(color: AppColors.border, width: 1)),
        titleTextStyle: AppTypography.heading3.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),

      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.structural, // Light Aqua Sidebar
        elevation: 0,
      ),

      cardTheme: CardThemeData(
        color: AppColors.background,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border), // Delicate border
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
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          backgroundColor: Colors.transparent,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: AppTypography.label.copyWith(color: AppColors.textPrimary),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
      ),

      dataTableTheme: DataTableThemeData(
        headingTextStyle: AppTypography.label.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 1.0,
        ),
        dataTextStyle: AppTypography.bodyMedium,
        headingRowColor: MaterialStateProperty.all(AppColors.surface),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      scrollbarTheme: ScrollbarThemeData(
        thumbColor: MaterialStateProperty.all(AppColors.textSecondary.withOpacity(0.2)),
        radius: const Radius.circular(10),
      ),
    );
  }
}
