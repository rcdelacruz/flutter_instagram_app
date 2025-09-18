import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/app_config.dart';
import 'config/app_theme.dart';
import 'config/font_config.dart';
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
        // Comprehensive font fallbacks for missing characters
        textTheme: AppTheme.lightTheme.textTheme.apply(
          fontFamily: 'Inter',
          fontFamilyFallback: FontConfig.fontFallbacks,
        ),
        // Additional font configuration for specific components
        appBarTheme: AppTheme.lightTheme.appBarTheme.copyWith(
          titleTextStyle: FontConfig.createTextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
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
