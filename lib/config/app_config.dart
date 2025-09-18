class AppConfig {
  static const String appName = 'Instagram Clone';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const int apiTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;
  
  // UI Configuration
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  
  // Image Configuration
  static const int maxImageSizeMB = 10;
  static const int imageQuality = 85;
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Cache Configuration
  static const int cacheExpirationHours = 24;
  static const int maxCacheSize = 100; // Number of items
  
  // Social Features
  static const int maxCaptionLength = 2200;
  static const int maxBioLength = 150;
  static const int maxUsernameLength = 30;
  static const int minUsernameLength = 3;
  
  // Security
  static const int minPasswordLength = 6;
  static const int maxLoginAttempts = 5;
  static const int lockoutDurationMinutes = 15;
  
  // Development flags
  static const bool enableDebugMode = true;
  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = false;
}
