import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'config/font_config.dart';
import 'utils/font_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load all Noto fonts to prevent missing character warnings
  await CustomFontLoader.loadFonts();

  // Set system-wide font fallbacks to prevent missing character warnings
  await _configureFontFallbacks();

  // Initialize font configuration for missing characters
  await FontConfig.initialize();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Handle missing .env file gracefully
    debugPrint('Warning: .env file not found');
  }

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  } catch (e) {
    debugPrint('Warning: Supabase initialization failed: $e');
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// Configure system-wide font fallbacks
Future<void> _configureFontFallbacks() async {
  try {
    // Pre-load all Noto fonts to ensure they're available
    final fontLoaders = [
      _loadFontFamily('Noto Sans', 'assets/fonts/NotoSans-Regular.ttf'),
      _loadFontFamily('Noto Color Emoji', 'assets/fonts/NotoColorEmoji.ttf'),
      _loadFontFamily('Noto Sans CJK', 'assets/fonts/NotoSansCJK-Regular.ttc'),
    ];

    await Future.wait(fontLoaders);
    debugPrint('✅ All Noto fonts loaded successfully');
  } catch (e) {
    debugPrint('⚠️ Font loading error: $e');
  }
}

Future<void> _loadFontFamily(String family, String assetPath) async {
  try {
    final fontData = await rootBundle.load(assetPath);
    final fontLoader = FontLoader(family);
    fontLoader.addFont(Future.value(fontData));
    await fontLoader.load();
    debugPrint('✅ Loaded font: $family');
  } catch (e) {
    debugPrint('❌ Failed to load font $family: $e');
  }
}



class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            Text(
              'Instagram Clone',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Built with Flutter',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
