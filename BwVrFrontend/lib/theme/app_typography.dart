import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  // Primary Font: Montserrat
  static TextStyle get base => GoogleFonts.montserrat(
        color: AppColors.textPrimary,
        height: 1.5,
      );

  // Headers & AppBars: Semi-Bold (600)
  static TextStyle get heading1 => base.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      );

  static TextStyle get heading2 => base.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      );

  static TextStyle get heading3 => base.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      );

  // Body Text & Data Tables: Regular (400)
  static TextStyle get subheading => base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600, // For subsection headers
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodyMedium => base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );
      
  static TextStyle get bodySmall => base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get label => base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  static TextTheme get textTheme => TextTheme(
        displayLarge: heading1,
        displayMedium: heading2,
        displaySmall: heading3,
        headlineMedium: subheading,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        labelLarge: label,
      ).apply(
        fontFamily: GoogleFonts.montserrat().fontFamily,
      );
}
