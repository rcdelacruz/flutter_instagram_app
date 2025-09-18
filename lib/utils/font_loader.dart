import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomFontLoader {
  static bool _fontsLoaded = false;

  static Future<void> loadFonts() async {
    if (_fontsLoaded) return;

    try {
      // Load all Noto fonts explicitly
      await Future.wait([
        _loadFont('Noto Sans', 'assets/fonts/NotoSans-Regular.ttf'),
        _loadFont('Noto Sans', 'assets/fonts/NotoSans-Medium.ttf'),
        _loadFont('Noto Sans', 'assets/fonts/NotoSans-Bold.ttf'),
        _loadFont('Noto Color Emoji', 'assets/fonts/NotoColorEmoji.ttf'),
        _loadFont('Noto Sans CJK', 'assets/fonts/NotoSansCJK-Regular.ttc'),
      ]);

      _fontsLoaded = true;
      debugPrint('✅ All Noto fonts loaded successfully');
    } catch (e) {
      debugPrint('❌ Error loading fonts: $e');
    }
  }

  static Future<void> _loadFont(String family, String asset) async {
    try {
      final fontData = await rootBundle.load(asset);
      final fontLoader = FontLoader(family);
      fontLoader.addFont(Future.value(fontData));
      await fontLoader.load();
      debugPrint('✅ Loaded: $family from $asset');
    } catch (e) {
      debugPrint('❌ Failed to load $family: $e');
    }
  }

  // Create a text style with proper fallbacks
  static TextStyle createTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontFamily: 'Inter',
      fontFamilyFallback: const [
        'Noto Sans',
        'Noto Color Emoji',
        'Noto Sans CJK',
        'Roboto',
        'Apple Color Emoji',
        'Segoe UI Emoji',
        'Arial Unicode MS',
        'sans-serif',
      ],
    );
  }

  // Apply font fallbacks to an existing TextTheme
  static TextTheme applyFontFallbacks(TextTheme textTheme) {
    const fallbacks = [
      'Noto Sans',
      'Noto Color Emoji',
      'Noto Sans CJK',
      'Roboto',
      'Apple Color Emoji',
      'Segoe UI Emoji',
      'Arial Unicode MS',
      'sans-serif',
    ];

    return textTheme.copyWith(
      displayLarge: textTheme.displayLarge?.copyWith(fontFamilyFallback: fallbacks),
      displayMedium: textTheme.displayMedium?.copyWith(fontFamilyFallback: fallbacks),
      displaySmall: textTheme.displaySmall?.copyWith(fontFamilyFallback: fallbacks),
      headlineLarge: textTheme.headlineLarge?.copyWith(fontFamilyFallback: fallbacks),
      headlineMedium: textTheme.headlineMedium?.copyWith(fontFamilyFallback: fallbacks),
      headlineSmall: textTheme.headlineSmall?.copyWith(fontFamilyFallback: fallbacks),
      titleLarge: textTheme.titleLarge?.copyWith(fontFamilyFallback: fallbacks),
      titleMedium: textTheme.titleMedium?.copyWith(fontFamilyFallback: fallbacks),
      titleSmall: textTheme.titleSmall?.copyWith(fontFamilyFallback: fallbacks),
      bodyLarge: textTheme.bodyLarge?.copyWith(fontFamilyFallback: fallbacks),
      bodyMedium: textTheme.bodyMedium?.copyWith(fontFamilyFallback: fallbacks),
      bodySmall: textTheme.bodySmall?.copyWith(fontFamilyFallback: fallbacks),
      labelLarge: textTheme.labelLarge?.copyWith(fontFamilyFallback: fallbacks),
      labelMedium: textTheme.labelMedium?.copyWith(fontFamilyFallback: fallbacks),
      labelSmall: textTheme.labelSmall?.copyWith(fontFamilyFallback: fallbacks),
    );
  }
}
