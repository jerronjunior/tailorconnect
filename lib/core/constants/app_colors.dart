import 'package:flutter/material.dart';

/// TailorConnect brand palette.
///
/// The identity is drawn from the tailoring world itself: deep indigo like
/// dyed suiting fabric, a warm "thread gold" accent inspired by brass
/// thimbles and measuring-tape markings, and chalk-white surfaces like a
/// cutting table.
abstract final class AppColors {
  // Brand
  static const Color indigo = Color(0xFF232E52); // dyed-suiting indigo
  static const Color indigoDeep = Color(0xFF16203D);
  static const Color threadGold = Color(0xFFC99B3F); // brass thimble accent
  static const Color threadGoldLight = Color(0xFFE3BE72);

  // Neutrals
  static const Color chalk = Color(0xFFF7F5F0); // cutting-table chalk white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF1B1D24);
  static const Color inkSoft = Color(0xFF5A5F6E);
  static const Color stitch = Color(0xFFE2DFD7); // hairline dividers

  // Dark mode
  static const Color darkBackground = Color(0xFF12141C);
  static const Color darkSurface = Color(0xFF1C1F2B);

  // Semantic
  static const Color success = Color(0xFF2E7D5B);
  static const Color error = Color(0xFFB3413B);
  static const Color warning = Color(0xFFC97E1D);
  static const Color info = Color(0xFF2E5D8F);

  // Gradients
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [indigo, indigoDeep],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [threadGoldLight, threadGold],
  );
}
