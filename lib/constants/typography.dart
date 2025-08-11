import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // Heading styles
  static TextStyle get h1 => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -1,
      );
  
  static TextStyle get h2 => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      );
  
  static TextStyle get h3 => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      );
  
  static TextStyle get h4 => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      );
  
  // Body styles
  static TextStyle get body1 => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.normal,
      );
  
  static TextStyle get body2 => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      );
  
  // Caption styles
  static TextStyle get caption => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.normal,
      );
  
  // Button styles
  static TextStyle get button => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );
  
  // Subtitle styles
  static TextStyle get subtitle1 => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );
  
  static TextStyle get subtitle2 => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      );
  
  // Helper function to apply color to text styles
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
}
