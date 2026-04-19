import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextStyle get base => GoogleFonts.inter(
        color: AppColors.primaryText,
        height: 1.5,
      );

  static TextStyle get headingBase => GoogleFonts.plusJakartaSans(
        color: AppColors.primaryText,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get heading1 => headingBase.copyWith(
        fontSize: 32,
        letterSpacing: -0.5,
      );

  static TextStyle get heading2 => headingBase.copyWith(
        fontSize: 24,
      );

  static TextStyle get heading3 => headingBase.copyWith(
        fontSize: 20,
      );

  static TextStyle get subheading => headingBase.copyWith(
        fontSize: 16,
      );

  static TextStyle get bodyLarge => base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get bodyMedium => base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get label => base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
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
      );
}

