import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.red,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkText,
        surfaceVariant: AppColors.darkCard,
        onSurfaceVariant: AppColors.darkSubtext,
        outline: Colors.transparent,
      ),
      textTheme: TextTheme(
        bodyLarge: GoogleFonts.notoSans(color: AppColors.darkText),
        bodyMedium: GoogleFonts.notoSans(color: AppColors.darkText),
        labelMedium: GoogleFonts.notoSans(color: AppColors.darkHint),
      ),
      iconTheme: const IconThemeData(color: AppColors.darkText),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.red,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightText,
        surfaceVariant: AppColors.lightCard,
        onSurfaceVariant: AppColors.lightSubtext,
        outline: Colors.transparent,
      ),
      textTheme: TextTheme(
        bodyLarge: GoogleFonts.notoSans(color: AppColors.lightText),
        bodyMedium: GoogleFonts.notoSans(color: AppColors.lightText),
        labelMedium: GoogleFonts.notoSans(color: AppColors.lightSubtext),
      ),
      iconTheme: const IconThemeData(color: AppColors.lightText),
    );
  }
}
