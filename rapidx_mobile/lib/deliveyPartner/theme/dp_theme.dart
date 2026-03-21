import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DPColors {
  // Primary
  static const Color deepBlue = Color(0xFF0F4C75); // Deep Blue/Teal base
  static const Color teal = Color(0xFF3282B8); // Accent Teal
  static const Color lightTeal = Color(0xFFBBE1FA); // Light Accent

  // Functional
  static const Color successGreen = Color(0xFF1BD100); // Success
  static const Color warningOrange = Color(0xFFEF6C00); // Warning/Alert
  static const Color errorRed = Color(0xFFC62828); // Error
  static const Color PickUpGreen = Color(0xFF0EED00); // Pick
  static const Color DropRed = Color(0xFFFF0000); // Drop

  // Neutral
  static const Color background = Color(
    0xFFF5F7FA,
  ); // Off-white/Light Grey background
  static const Color white = Colors.white;
  static const Color black = Color(0xFF1A1A1A);
  static const Color greyDark = Color(0xFF424242);
  static const Color greyMedium = Color(0xFF757575);
  static const Color greyLight = Color(0xFFE0E0E0);
  static const Color greyExtraLight = Color(0xFFF5F5F5);
  static const Color transparent = Colors.transparent;
}

class DPTheme {
  static ThemeData get themeData {
    return ThemeData(
      primaryColor: DPColors.deepBlue,
      scaffoldBackgroundColor: DPColors.background,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: DPColors.deepBlue,
        secondary: DPColors.teal,
        surface: DPColors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      useMaterial3: true,
    );
  }

  // Text Styles
  static TextStyle get h1 => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: DPColors.black,
  );

  static TextStyle get h2 => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: DPColors.black,
  );

  static TextStyle get h3 => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: DPColors.black,
  );

  static TextStyle get body => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: DPColors.greyDark,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: DPColors.greyMedium,
  );

  static TextStyle get buttonText => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: DPColors.white,
  );
}
