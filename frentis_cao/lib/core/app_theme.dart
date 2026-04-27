import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens extraídos do protótipo Figma
class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF34C759);
  static const Color primaryLight = Color(0xFF92E3A9);
  static const Color primarySoft = Color(0xFFA6FFBC);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color darkText = Color(0xFF263238);
  static const Color grey = Color(0xFF919191);
  static const Color greyLight = Color(0xFFB2B2B2);
  static const Color background = Color(0xFFF5F5F5);

  // M3 tokens from prototype
  static const Color onSurfaceVariant = Color(0xFF49454F);
  static const Color outline = Color(0xFF79747E);
  static const Color outlineVariant = Color(0xFFCAC4D0);
  static const Color surfaceDim = Color(0xFFDED8E1);
  static const Color border = Color(0xFFE0E0E0);
  static const Color progressBg = Color(0xFFDEDEDE);
  static const Color secondaryContainer = Color(0xFF4A4459);

  // Semantic
  static const Color error = Color(0xFFF24822);
  static const Color warning = Color(0xFFFFC727);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.white,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.white,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        surface: AppColors.white,
        onSurface: AppColors.darkText,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        error: AppColors.error,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        headlineMedium: GoogleFonts.inter(
          fontSize: 25,
          fontWeight: FontWeight.w700,
          height: 30 / 25,
          color: AppColors.darkText,
        ),
        titleMedium: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 24 / 16,
          letterSpacing: 0.15,
        ),
        bodyLarge: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 24 / 16,
          letterSpacing: 0.5,
          color: AppColors.onSurfaceVariant,
        ),
        bodyMedium: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 20 / 14,
          letterSpacing: 0.25,
          color: AppColors.black,
        ),
        labelLarge: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 20 / 14,
          letterSpacing: 0.1,
          color: AppColors.onSurfaceVariant,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          height: 13 / 11,
          color: AppColors.darkText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: GoogleFonts.roboto(
          fontSize: 16,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
