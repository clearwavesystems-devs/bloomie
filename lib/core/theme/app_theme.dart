import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.creamBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryPink,
        primary: AppColors.primaryPink,
        secondary: AppColors.lavender,
        surface: AppColors.creamBg,
      ),
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        displayLarge: GoogleFonts.baloo2(
          color: AppColors.textDark,
          fontWeight: FontWeight.w800,
        ),
        displayMedium: GoogleFonts.baloo2(
          color: AppColors.textDark,
          fontWeight: FontWeight.w800,
        ),
        headlineMedium: GoogleFonts.baloo2(
          color: AppColors.textDark,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: GoogleFonts.baloo2(
          color: AppColors.textDark,
          fontWeight: FontWeight.w700,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textDark),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryPink,
        brightness: Brightness.dark,
      ),
    );
  }
}
