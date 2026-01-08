import 'package:flutter/material.dart';

class AppTheme {
  // Dark Blue Gradient Colors (iPhone style)
  static const Color primaryDarkBlue = Color(0xFF0A1128);
  static const Color secondaryDarkBlue = Color(0xFF1C2951);
  static const Color accentBlue = Color(0xFF3E5C9A);
  static const Color lightBlue = Color(0xFF6B8DD6);
  
  // Glassmorphic colors
  static const Color glassWhite = Color(0x40FFFFFF);
  static const Color glassBorder = Color(0x80FFFFFF);
  
  // Text colors
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFFB0B0B0);
  static const Color textDark = Color(0xFF2C2C2C);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE57373);
  static const Color warning = Color(0xFFFFB74D);
  
  // Background gradient
  static LinearGradient get backgroundGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryDarkBlue,
      secondaryDarkBlue,
      accentBlue,
    ],
  );
  
  // Button gradient
  static LinearGradient get buttonGradient => LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      accentBlue,
      lightBlue,
    ],
  );
  
  // Theme data
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: accentBlue,
    scaffoldBackgroundColor: primaryDarkBlue,
    fontFamily: 'Poppins',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textWhite,
      ),
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textWhite,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: textWhite,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textGray,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: glassWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: glassBorder, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: glassBorder, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightBlue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );
}
