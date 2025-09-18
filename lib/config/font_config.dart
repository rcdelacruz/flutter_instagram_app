import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FontConfig {
  // Initialize font configuration to handle missing characters
  static Future<void> initialize() async {
    // Ensure fonts are loaded before app starts
    await _loadFonts();
    
    // Configure font fallbacks at the engine level
    _configureFontFallbacks();
  }

  static Future<void> _loadFonts() async {
    try {
      // Pre-load critical fonts to ensure they're available
      await Future.wait([
        _loadFont('assets/fonts/NotoSans-Regular.ttf'),
        _loadFont('assets/fonts/NotoSans-Bold.ttf'),
        _loadFont('assets/fonts/NotoColorEmoji.ttf'),
      ]);
    } catch (e) {
      // If font loading fails, continue with system fonts
      debugPrint('Font loading warning: $e');
    }
  }

  static Future<void> _loadFont(String fontPath) async {
    try {
      final fontData = await rootBundle.load(fontPath);
      final fontLoader = FontLoader(fontPath.split('/').last.split('.').first);
      fontLoader.addFont(Future.value(fontData));
      await fontLoader.load();
    } catch (e) {
      debugPrint('Failed to load font $fontPath: $e');
    }
  }

  static void _configureFontFallbacks() {
    // This ensures that when Flutter can't find a character in the primary font,
    // it will fall back to the specified fonts in order
    // Note: This is handled by the MaterialApp fontFamilyFallback configuration
  }

  // Get comprehensive font fallback list
  static List<String> get fontFallbacks => const [
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
    'DejaVu Sans',
    'Liberation Sans',
    'sans-serif',
  ];

  // Create a text style with comprehensive fallbacks
  static TextStyle createTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    String? fontFamily,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontFamily: fontFamily ?? 'Inter',
      fontFamilyFallback: fontFallbacks,
    );
  }
}
