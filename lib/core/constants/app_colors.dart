import 'package:flutter/material.dart';

/// TailorConnect Premium Luxury palette.
abstract final class AppColors {
  // Brand - Deep Charcoal & Gold
  static const Color primaryDark = Color(0xFF101216);
  static const Color primaryLight = Color(0xFFF9F9F9);
  
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color goldAccentLight = Color(0xFFF3E5AB);
  static const Color silverAccent = Color(0xFFB0B0B0);

  // Background & Surfaces (Dark Theme focus)
  static const Color darkBackground = Color(0xFF0A0C10);
  static const Color darkSurface = Color(0xFF14171F);
  static const Color darkSurfaceHighlight = Color(0xFF1D212C);
  
  // Neutrals
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFFF5F5F5);
  static const Color textDarkMuted = Color(0xFFA0A5B1);
  static const Color textLight = Color(0xFF111111);
  static const Color textLightMuted = Color(0xFF666666);
  
  static const Color stitch = Color(0xFF303645); // hairline dividers in dark mode
  static const Color stitchLight = Color(0xFFE2DFD7);

  // Semantic
  static const Color success = Color(0xFF2E7D5B);
  static const Color error = Color(0xFFB3413B);
  static const Color warning = Color(0xFFC97E1D);
  static const Color info = Color(0xFF2E5D8F);

  // Gradients for Luxury Buttons & 3D feel
  static const LinearGradient luxuryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE6C875), Color(0xFFD4AF37), Color(0xFFAA8012)],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1D27), Color(0xFF14171F)],
  );
}
