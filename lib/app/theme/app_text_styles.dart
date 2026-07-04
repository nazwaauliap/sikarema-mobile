import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextTheme get textTheme => GoogleFonts.poppinsTextTheme();

  static TextStyle get headlineLarge =>
      GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold);

  static TextStyle get headlineMedium =>
      GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600);

  static TextStyle get titleLarge =>
      GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600);

  static TextStyle get titleMedium =>
      GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500);

  static TextStyle get bodyLarge =>
      GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w400);

  static TextStyle get bodyMedium =>
      GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400);

  static TextStyle get labelMedium =>
      GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500);
}
