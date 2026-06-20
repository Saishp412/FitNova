import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Soft Beige / Minimalist Palette
  static Color background = Color(0xFFF9F8F4); // Soft Linen Beige
  static Color surface = Color(0xFFFFFFFF); // Pure White Cards
  static Color primaryAccent = Color(0xFF8B7D6B); // Elegant Taupe
  static Color secondaryAccent = Color(0xFFC7BCAE); // Light Taupe
  static Color textPrimary = Color(0xFF2C2A28); // Deep Warm Charcoal
  static Color textSecondary = Color(0xFF8F8A83); // Soft Warm Gray

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      primaryColor: primaryAccent,
      colorScheme: ColorScheme.light(
        primary: primaryAccent,
        secondary: secondaryAccent,
        surface: surface,
      ),
      textTheme: GoogleFonts.manropeTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.manrope(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 32),
        bodyLarge: GoogleFonts.manrope(color: textPrimary, fontSize: 16),
        bodyMedium: GoogleFonts.manrope(color: textSecondary, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAccent,
          foregroundColor: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: secondaryAccent, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: secondaryAccent, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryAccent, width: 2),
        ),
        hintStyle: TextStyle(color: textSecondary),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Color(0xFF1A1A1A), // Deep dark gray
      primaryColor: primaryAccent,
      colorScheme: ColorScheme.dark(
        primary: primaryAccent,
        secondary: secondaryAccent,
        surface: Color(0xFF2C2A28), // Dark surface
      ),
      textTheme: GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 32),
        bodyLarge: GoogleFonts.manrope(color: Colors.white, fontSize: 16),
        bodyMedium: GoogleFonts.manrope(color: textSecondary, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF2C2A28),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: textSecondary, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: textSecondary, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryAccent, width: 2),
        ),
        hintStyle: TextStyle(color: textSecondary),
      ),
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;

  bool get isDarkMode => themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
