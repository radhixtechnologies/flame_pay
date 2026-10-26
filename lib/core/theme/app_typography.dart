import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  // Headlines & Titles (Poppins)
  static TextStyle display = GoogleFonts.poppins(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: AppColors.navyText,
    height: 1.25,
  );

  static TextStyle h1 = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.navyText,
    height: 1.3,
  );

  static TextStyle h2 = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.navyText,
    height: 1.35,
  );

  static TextStyle title = GoogleFonts.poppins(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Body & Labels (Inter)
  static TextStyle body = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle bodyBold = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static TextStyle micro = GoogleFonts.inter(
    fontSize: 10.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  // Buttons (Poppins)
  static TextStyle button = GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
    letterSpacing: 0.3,
  );
}
