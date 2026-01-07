import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF322ed4),
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  static const Color primary = Color(0xFF322ed4);
  static const Color secendory = Color(0xFFeaa3fb);
  static const Color black = Color(0xFF000000);
  static const Color white = Color.fromARGB(255, 255, 255, 255);
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color successGreen = Color(0xFF00C853);
  static const Color warningYellow = Color(0xFFFFF3CD);

  // Gradient colors for login page
  static const Color gradientStart = Color(0xFF6C5CE7); // Purple
  static const Color gradientEnd = Color(0xFFA29BF2); // Light purple-blue
  static const Color gradientButtonStart = Color(0xFF6C5CE7); // Purple
  static const Color gradientButtonEnd = Color(0xFFEAA3FB); // Pink-purple

  // Text colors
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textLight = Color(0xFFB2BEC3);

  // Background colors
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF5F6FA);

  // Border colors
  static const Color borderLight = Color(0xFFDFE6E9);
}

