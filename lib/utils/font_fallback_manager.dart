import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FontFallbackManager {
  static bool _initialized = false;

  /// Initialize font fallback system to prevent missing character warnings
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Set up comprehensive font fallback at the engine level
      await _setupEngineFontFallbacks();

      // Pre-register all our Noto fonts
      await _registerNotoFonts();

      _initialized = true;
      debugPrint('✅ FontFallbackManager initialized successfully');
    } catch (e) {
      debugPrint('⚠️ FontFallbackManager initialization warning: $e');
      // Continue anyway - this is not critical for app functionality
    }
  }

  /// Set up font fallbacks at the Flutter engine level
  static Future<void> _setupEngineFontFallbacks() async {
    // This approach uses Flutter's internal font fallback system
    // by ensuring our fonts are properly registered with the engine

    const fontFamilies = [
      'Noto Sans',
      'Noto Color Emoji',
      'Noto Sans CJK',
    ];

    for (final family in fontFamilies) {
      try {
        // Register font family with the engine
        await _registerFontFamily(family);
      } catch (e) {
        debugPrint('Warning: Could not register font family $family: $e');
      }
    }
  }

  /// Register individual font family with Flutter engine
  static Future<void> _registerFontFamily(String family) async {
    try {
      // Create a temporary FontLoader to register the font with the engine
      final fontLoader = FontLoader(family);

      // Add the appropriate font file based on family name
      switch (family) {
        case 'Noto Sans':
          fontLoader.addFont(_loadFontAsset('assets/fonts/NotoSans-Regular.ttf'));
          break;
        case 'Noto Color Emoji':
          fontLoader.addFont(_loadFontAsset('assets/fonts/NotoColorEmoji.ttf'));
          break;
        case 'Noto Sans CJK':
          fontLoader.addFont(_loadFontAsset('assets/fonts/NotoSansCJK-Regular.ttc'));
          break;
      }

      await fontLoader.load();
      debugPrint('✅ Registered font family: $family');
    } catch (e) {
      debugPrint('❌ Failed to register font family $family: $e');
    }
  }

  /// Load font asset as Future of ByteData
  static Future<ByteData> _loadFontAsset(String assetPath) async {
    return await rootBundle.load(assetPath);
  }

  /// Register all Noto fonts with the engine
  static Future<void> _registerNotoFonts() async {
    final fontRegistrations = [
      _registerSpecificFont('Noto Sans', 'assets/fonts/NotoSans-Regular.ttf'),
      _registerSpecificFont('Noto Sans', 'assets/fonts/NotoSans-Medium.ttf'),
      _registerSpecificFont('Noto Sans', 'assets/fonts/NotoSans-Bold.ttf'),
      _registerSpecificFont('Noto Color Emoji', 'assets/fonts/NotoColorEmoji.ttf'),
      _registerSpecificFont('Noto Sans CJK', 'assets/fonts/NotoSansCJK-Regular.ttc'),
    ];

    await Future.wait(fontRegistrations);
  }

  /// Register a specific font file with the engine
  static Future<void> _registerSpecificFont(String family, String assetPath) async {
    try {
      final fontLoader = FontLoader(family);
      fontLoader.addFont(_loadFontAsset(assetPath));
      await fontLoader.load();
      debugPrint('✅ Loaded font: $assetPath for family: $family');
    } catch (e) {
      debugPrint('❌ Failed to load font $assetPath: $e');
    }
  }

  /// Get the comprehensive font fallback list
  static List<String> get fontFallbacks => const [
    'Inter',
    'Noto Sans',
    'Noto Color Emoji',
    'Noto Sans CJK',
    'Roboto',
    'SF Pro Text',
    'SF Pro Display',
    'Apple Color Emoji',
    'Segoe UI',
    'Segoe UI Emoji',
    'Segoe UI Symbol',
    'Arial Unicode MS',
    'Lucida Grande',
    'DejaVu Sans',
    'Liberation Sans',
    'Droid Sans',
    'Helvetica Neue',
    'Arial',
    'sans-serif',
  ];

  /// Create a TextStyle with comprehensive font fallbacks
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

  /// Apply font fallbacks to an entire TextTheme
  static TextTheme applyFontFallbacks(TextTheme textTheme) {
    return textTheme.copyWith(
      displayLarge: textTheme.displayLarge?.copyWith(fontFamilyFallback: fontFallbacks),
      displayMedium: textTheme.displayMedium?.copyWith(fontFamilyFallback: fontFallbacks),
      displaySmall: textTheme.displaySmall?.copyWith(fontFamilyFallback: fontFallbacks),
      headlineLarge: textTheme.headlineLarge?.copyWith(fontFamilyFallback: fontFallbacks),
      headlineMedium: textTheme.headlineMedium?.copyWith(fontFamilyFallback: fontFallbacks),
      headlineSmall: textTheme.headlineSmall?.copyWith(fontFamilyFallback: fontFallbacks),
      titleLarge: textTheme.titleLarge?.copyWith(fontFamilyFallback: fontFallbacks),
      titleMedium: textTheme.titleMedium?.copyWith(fontFamilyFallback: fontFallbacks),
      titleSmall: textTheme.titleSmall?.copyWith(fontFamilyFallback: fontFallbacks),
      bodyLarge: textTheme.bodyLarge?.copyWith(fontFamilyFallback: fontFallbacks),
      bodyMedium: textTheme.bodyMedium?.copyWith(fontFamilyFallback: fontFallbacks),
      bodySmall: textTheme.bodySmall?.copyWith(fontFamilyFallback: fontFallbacks),
      labelLarge: textTheme.labelLarge?.copyWith(fontFamilyFallback: fontFallbacks),
      labelMedium: textTheme.labelMedium?.copyWith(fontFamilyFallback: fontFallbacks),
      labelSmall: textTheme.labelSmall?.copyWith(fontFamilyFallback: fontFallbacks),
    );
  }
}
