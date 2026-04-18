import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextStyle get base => GoogleFonts.montserrat(
        color: AppColors.primaryText,
        height: 1.4,
      );

  static TextStyle get heading1 => base.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700, // Bold
        letterSpacing: -0.5,
      );

  static TextStyle get heading2 => base.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700, // Bold
      );

  static TextStyle get heading3 => base.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600, // Semi-Bold
      );

  static TextStyle get subheading => base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600, // Semi-Bold
      );

  static TextStyle get bodyLarge => base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500, // Medium/Semi-Bold
      );

  static TextStyle get bodyMedium => base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500, // Medium/Semi-Bold
      );

  static TextStyle get label => base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600, // Semi-Bold
        color: AppColors.accent,
      );

  static TextTheme get textTheme => TextTheme(
        displayLarge: heading1,
        displayMedium: heading2,
        displaySmall: heading3,
        headlineMedium: subheading,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        labelLarge: label,
      );
}
