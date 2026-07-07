import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  // Default to Dark Theme for luxury look
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.goldAccent,
      brightness: brightness,
      primary: AppColors.goldAccent,
      secondary: AppColors.silverAccent,
      error: AppColors.error,
      surface: isDark ? AppColors.darkSurface : AppColors.surface,
    );

    final textTheme = _textTheme(
      base: isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      color: isDark ? AppColors.textDark : AppColors.textLight,
      softColor: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor:
          isDark ? AppColors.darkBackground : AppColors.primaryLight,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? AppColors.textDark : AppColors.textLight,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontFamily: GoogleFonts.playfairDisplay().fontFamily,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 8,
        shadowColor: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
          side: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.05) : AppColors.stitchLight,
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkSurfaceHighlight : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.md,
        ),
        border: _fieldBorder(isDark ? Colors.transparent : AppColors.stitchLight),
        enabledBorder: _fieldBorder(isDark ? Colors.transparent : AppColors.stitchLight),
        focusedBorder: _fieldBorder(AppColors.goldAccent, width: 1.5),
        errorBorder: _fieldBorder(AppColors.error),
        focusedErrorBorder: _fieldBorder(AppColors.error, width: 1.5),
        hintStyle: TextStyle(
          color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          backgroundColor: AppColors.goldAccent,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: AppColors.goldAccent.withOpacity(0.5),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusButton),
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        selectedItemColor: AppColors.goldAccent,
        unselectedItemColor: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
        elevation: 20,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static OutlineInputBorder _fieldBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusField),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static TextTheme _textTheme({
    required TextTheme base,
    required Color color,
    required Color softColor,
  }) {
    final display = GoogleFonts.playfairDisplayTextTheme(base);
    final body = GoogleFonts.interTextTheme(base);

    return body.copyWith(
      displayLarge: display.displayLarge?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
      displayMedium: display.displayMedium?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: display.headlineMedium?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: display.headlineSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: body.titleLarge?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: body.bodyLarge?.copyWith(color: color),
      bodyMedium: body.bodyMedium?.copyWith(color: softColor),
      labelLarge: body.labelLarge?.copyWith(color: color),
    );
  }
}
