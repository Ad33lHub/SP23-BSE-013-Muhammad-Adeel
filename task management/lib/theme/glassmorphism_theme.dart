import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlassmorphismTheme {
  // Color Palette - Dark with neon accents
  static const Color darkBackground = Color(0xFF0A0E27);
  static const Color darkSurface = Color(0xFF141B2D);
  static const Color neonBlue = Color(0xFF00D9FF);
  static const Color neonPurple = Color(0xFFB026FF);
  static const Color neonCyan = Color(0xFF00F5FF);
  static const Color accentBlue = Color(0xFF4A90E2);
  static const Color accentPurple = Color(0xFF9B59B6);
  
  // Glass colors
  static const Color glassWhite = Color(0x40FFFFFF);
  static const Color glassDark = Color(0x40000000);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4A90E2),
      Color(0xFF9B59B6),
      Color(0xFF00D9FF),
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00D9FF),
      Color(0xFFB026FF),
    ],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0A0E27),
      Color(0xFF1A1F3A),
      Color(0xFF0F1429),
    ],
  );

  // Theme Data
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      
      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: neonBlue,
        secondary: neonPurple,
        tertiary: neonCyan,
        surface: darkSurface,
        error: Color(0xFFFF6B6B),
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onError: Colors.white,
      ),
      
      // Text Theme
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Colors.white70,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: Colors.white60,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.white60,
        ),
      ),
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.transparent,
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: glassWhite, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: glassWhite.withOpacity(0.3), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: neonBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: GoogleFonts.inter(
          color: Colors.white38,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.inter(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: neonBlue,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: Colors.white,
        size: 24,
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: glassWhite.withOpacity(0.1),
        thickness: 1,
        space: 1,
      ),
    );
  }
}

// Glass effect blur value
const double glassBlur = 30.0;

// Glass opacity
const double glassOpacity = 0.15;

// Border radius
const double glassRadius = 20.0;

// Shadow
const List<BoxShadow> glassShadow = [
  BoxShadow(
    color: Color(0x40000000),
    blurRadius: 20,
    offset: Offset(0, 10),
  ),
];

const List<BoxShadow> neonShadow = [
  BoxShadow(
    color: Color(0x4000D9FF),
    blurRadius: 20,
    spreadRadius: 2,
    offset: Offset(0, 0),
  ),
];

