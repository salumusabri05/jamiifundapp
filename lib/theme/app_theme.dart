import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData getTheme() {
    return ThemeData(
      primaryColor: const Color(0xFF8A2BE2), // Violet
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF8A2BE2),
        primary: const Color(0xFF8A2BE2),
        secondary: const Color(0xFF9400D3), // Purple
        background: Colors.white,
      ),
      textTheme: GoogleFonts.nunitoTextTheme(),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF8A2BE2),
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8A2BE2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }
}
