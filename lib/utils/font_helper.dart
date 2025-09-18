import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FontHelper {
  // Comprehensive font fallback list for missing characters
  static const List<String> fontFallbacks = [
    'Inter',
    'NotoSans',
    'NotoColorEmoji',
    'Roboto',
    'Noto Sans',
    'Noto Color Emoji',
    'Apple Color Emoji',
    'Segoe UI Emoji',
    'Segoe UI Symbol',
    'Arial Unicode MS',
    'Lucida Grande',
    'sans-serif',
  ];

  // Get text style with comprehensive fallbacks
  static TextStyle getTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // Predefined text styles with fallbacks
  static TextStyle get heading1 => getTextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get heading2 => getTextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get heading3 => getTextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get title => getTextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get subtitle => getTextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get body => getTextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get caption => getTextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get button => getTextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      );

  // Create a complete text theme with fallbacks
  static TextTheme createTextTheme({Color? primaryColor, Color? secondaryColor}) {
    final primary = primaryColor ?? const Color(0xFF262626);
    final secondary = secondaryColor ?? const Color(0xFF8E8E8E);

    return TextTheme(
      headlineLarge: getTextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: primary,
      ),
      headlineMedium: getTextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: primary,
      ),
      headlineSmall: getTextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleLarge: getTextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleMedium: getTextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      titleSmall: getTextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      bodyLarge: getTextStyle(
        fontSize: 16,
        color: primary,
      ),
      bodyMedium: getTextStyle(
        fontSize: 14,
        color: primary,
      ),
      bodySmall: getTextStyle(
        fontSize: 12,
        color: secondary,
      ),
      labelLarge: getTextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      labelMedium: getTextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
      labelSmall: getTextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
    );
  }
}
