class AppConfig {
  static const String appName = 'Flutter Rork App';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'A production-grade Flutter Instagram clone';
  
  // API Configuration
  static const int apiTimeout = 30000;
  static const int maxRetries = 3;
  
  // UI Configuration
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
  static const int animationDuration = 300;
  
  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashlytics = true;
  static const bool enablePushNotifications = true;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;
  
  // Image Configuration
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
  
  // Cache Configuration
  static const int cacheMaxAge = 3600; // 1 hour
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
}
