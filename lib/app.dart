import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/app_config.dart';
import 'config/app_theme.dart';
import 'utils/font_fallback_manager.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/home/main_tabs_screen.dart';
import 'screens/shared/splash_screen.dart';
import 'providers/auth_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: AppConfig.appName,
      theme: AppTheme.lightTheme.copyWith(
        // Apply comprehensive font fallbacks using FontFallbackManager
        textTheme: FontFallbackManager.applyFontFallbacks(AppTheme.lightTheme.textTheme),
        // Additional font configuration for specific components
        appBarTheme: AppTheme.lightTheme.appBarTheme.copyWith(
          titleTextStyle: FontFallbackManager.createTextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      // Suppress font-related debug messages
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
          child: child!,
        );
      },
      home: authState.when(
        data: (state) {
          if (state.session != null) {
            return const MainTabsScreen();
          } else {
            return const LoginScreen();
          }
        },
        loading: () => const SplashScreen(),
        error: (error, stack) => const LoginScreen(),
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/main': (context) => const MainTabsScreen(),
      },
    );
  }
}
