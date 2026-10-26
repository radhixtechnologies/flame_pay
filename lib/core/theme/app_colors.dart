import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Blue Palette
  static const Color primaryBlue = Color(0xFF0F4CC9);
  static const Color blueDark = Color(0xFF0A3A9E);
  static const Color blueLight = Color(0xFF2563EB);
  static const Color headerGradientStart = Color(0xFF1558D6);
  static const Color headerGradientEnd = Color(0xFF0A3A9E);

  // Navy text/headline
  static const Color navyText = Color(0xFF0A2A66);

  // Accent Orange & Flame Palette
  static const Color accentOrange = Color(0xFFFF6B00);
  static const Color orangeGradientStart = Color(0xFFFF8A00);
  static const Color orangeGradientEnd = Color(0xFFFF5A00);
  static const Color flameYellow = Color(0xFFFFC107);
  static const Color flameRed = Color(0xFFE8310C);

  // Surfaces & Backgrounds
  static const Color background = Color(0xFFF3F7FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE3EAF6);
  static const Color borderLight = Color(0xFFEDF2F9);

  // Typography Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF12B76A);
  static const Color successLight = Color(0xFFE6F8EF);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFE5383B);
  static const Color errorLight = Color(0xFFFFE9E9);

  // Icon Tile Tints (from reference)
  static const Color tintBlue = Color(0xFFE8F0FF);
  static const Color tintOrange = Color(0xFFFFF1E3);
  static const Color tintRed = Color(0xFFFFE9E9);
  static const Color tintGreen = Color(0xFFE6F8EF);
  static const Color tintPurple = Color(0xFFF1EAFE);
  static const Color tintTeal = Color(0xFFE3F7FA);

  // Gradients
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [headerGradientStart, headerGradientEnd],
  );

  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [orangeGradientStart, orangeGradientEnd],
  );

  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [headerGradientStart, primaryBlue],
  );

  static const LinearGradient flameWordmarkGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFF8A00), Color(0xFFE8310C)],
  );

  // Shadows
  static const BoxShadow softBlueShadow = BoxShadow(
    color: Color(0x140F4CC9),
    blurRadius: 20,
    offset: Offset(0, 6),
  );

  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x0F0F4CC9),
    blurRadius: 16,
    offset: Offset(0, 4),
  );

  static const BoxShadow buttonShadow = BoxShadow(
    color: Color(0x33FF6B00),
    blurRadius: 16,
    offset: Offset(0, 6),
  );
}
