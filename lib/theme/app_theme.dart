import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Application theme and pastel color palette for Pastel Sky Weather.
class AppTheme {
  AppTheme._();

  // Pastel Blue & Pink Palette
  static const Color pastelBlueLight = Color(0xFFD8EEFF);
  static const Color pastelBlue = Color(0xFFA9D6FF);
  static const Color pastelBlueDeep = Color(0xFF7CB9F7);

  static const Color pastelPinkLight = Color(0xFFFFE0EE);
  static const Color pastelPink = Color(0xFFFFB5D8);
  static const Color pastelPinkDeep = Color(0xFFF48FB1);

  static const Color cloudWhite = Color(0xFFFFFCFE);
  static const Color softLavender = Color(0xFFF2E8FF);
  static const Color textPrimary = Color(0xFF332D41);
  static const Color textSecondary = Color(0xFF6A5F7D);
  static const Color textMuted = Color(0xFF968BA8);

  static const LinearGradient mainBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFCDE9FF),
      Color(0xFFE6E6FA),
      Color(0xFFFFD8EA),
    ],
    stops: [0.0, 0.52, 1.0],
  );

  static const LinearGradient heroCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFB5DEFF),
      Color(0xFFDDC8F8),
      Color(0xFFFFC1DF),
    ],
  );

  static const LinearGradient searchHeaderGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF9ED0FF),
      Color(0xFFFFB6D9),
    ],
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: pastelBlueDeep,
        primary: const Color(0xFF6BAEEB),
        secondary: const Color(0xFFF08BB8),
        surface: cloudWhite,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: pastelBlueLight,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.nunito(
          fontSize: 64,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: -1.5,
        ),
        headlineMedium: GoogleFonts.nunito(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.nunito(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: textSecondary,
        ),
        labelLarge: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: textPrimary,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: cloudWhite.withValues(alpha: 0.85),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cloudWhite.withValues(alpha: 0.92),
        hintStyle: GoogleFonts.nunito(
          color: textMuted,
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: pastelBlue.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: pastelPinkDeep,
            width: 2,
          ),
        ),
      ),
    );
  }
}
