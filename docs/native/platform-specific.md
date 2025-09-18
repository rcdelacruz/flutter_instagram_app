# Platform-Specific Implementation

Comprehensive guide to implementing platform-specific features and handling differences between iOS, Android, and Web in Flutter applications.

## Overview

Platform-specific implementation allows you to leverage unique features of each platform while maintaining a shared codebase. This guide covers platform detection, conditional compilation, and native integrations.

## Platform Detection

### 1. Platform Utilities

```dart
// lib/utils/platform_utils.dart
import 'dart:io';
import 'package:flutter/foundation.dart';

class PlatformUtils {
  // Basic platform detection
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isWeb => kIsWeb;
  static bool get isMobile => isIOS || isAndroid;
  static bool get isDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
  
  // Detailed platform info
  static String get platformName {
    if (kIsWeb) return 'Web';
    return Platform.operatingSystem;
  }
  
  static String get platformVersion {
    if (kIsWeb) return 'Unknown';
    return Platform.operatingSystemVersion;
  }
  
  // Feature detection
  static bool get supportsHapticFeedback => isMobile;
  static bool get supportsBiometrics => isMobile;
  static bool get supportsNotifications => isMobile;
  static bool get supportsFileSystem => !isWeb;
  static bool get supportsCamera => isMobile;
  static bool get supportsLocation => isMobile;
  
  // UI capabilities
  static bool get hasPhysicalKeyboard => isDesktop;
  static bool get hasTouchScreen => isMobile || isWeb;
  static bool get supportsMultiWindow => isDesktop;
}
```

### 2. Conditional Compilation

```dart
// lib/config/platform_config.dart
class PlatformConfig {
  // API endpoints
  static String get baseUrl {
    if (kDebugMode) {
      if (PlatformUtils.isWeb) {
        return 'http://localhost:3000';
      } else if (PlatformUtils.isAndroid) {
        return 'http://10.0.2.2:3000'; // Android emulator
      } else {
        return 'http://localhost:3000'; // iOS simulator
      }
    }
    return 'https://api.yourapp.com';
  }
  
  // Storage paths
  static Future<String> get documentsPath async {
    if (PlatformUtils.isWeb) {
      return '/web-storage';
    }
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
  
  // App-specific configurations
  static Map<String, dynamic> get appConfig {
    return {
      'enableAnalytics': !kDebugMode,
      'enableCrashReporting': PlatformUtils.isMobile && !kDebugMode,
      'enablePushNotifications': PlatformUtils.isMobile,
      'maxImageSize': PlatformUtils.isMobile ? 1024 : 2048,
      'cacheSize': PlatformUtils.isMobile ? 50 : 100, // MB
    };
  }
}
```

## iOS-Specific Implementation

### 1. iOS Native Features

```dart
// lib/platform/ios/ios_features.dart
import 'package:flutter/services.dart';

class IOSFeatures {
  static const MethodChannel _channel = MethodChannel('ios_features');
  
  // Haptic feedback
  static Future<void> lightImpact() async {
    if (PlatformUtils.isIOS) {
      await HapticFeedback.lightImpact();
    }
  }
  
  static Future<void> mediumImpact() async {
    if (PlatformUtils.isIOS) {
      await HapticFeedback.mediumImpact();
    }
  }
  
  static Future<void> heavyImpact() async {
    if (PlatformUtils.isIOS) {
      await HapticFeedback.heavyImpact();
    }
  }
  
  // iOS-specific UI
  static Future<void> setStatusBarStyle(String style) async {
    if (PlatformUtils.isIOS) {
      try {
        await _channel.invokeMethod('setStatusBarStyle', {'style': style});
      } catch (e) {
        print('Failed to set status bar style: $e');
      }
    }
  }
  
  // iOS app settings
  static Future<void> openAppSettings() async {
    if (PlatformUtils.isIOS) {
      try {
        await _channel.invokeMethod('openAppSettings');
      } catch (e) {
        print('Failed to open app settings: $e');
      }
    }
  }
  
  // iOS-specific sharing
  static Future<void> shareWithActivityController(String text, {String? url}) async {
    if (PlatformUtils.isIOS) {
      try {
        await _channel.invokeMethod('shareWithActivityController', {
          'text': text,
          'url': url,
        });
      } catch (e) {
        print('Failed to share: $e');
      }
    }
  }
}
```

### 2. iOS Configuration

```dart
// lib/platform/ios/ios_config.dart
class IOSConfig {
  // iOS-specific app configuration
  static const Map<String, dynamic> config = {
    'bundleId': 'com.yourapp.flutter',
    'appStoreId': '123456789',
    'teamId': 'ABCD123456',
    'urlScheme': 'yourapp',
  };
  
  // iOS permissions
  static const List<String> requiredPermissions = [
    'NSCameraUsageDescription',
    'NSPhotoLibraryUsageDescription',
    'NSLocationWhenInUseUsageDescription',
    'NSMicrophoneUsageDescription',
  ];
  
  // iOS capabilities
  static const List<String> capabilities = [
    'com.apple.developer.associated-domains',
    'com.apple.developer.in-app-payments',
    'aps-environment',
  ];
}
```

## Android-Specific Implementation

### 1. Android Native Features

```dart
// lib/platform/android/android_features.dart
import 'package:flutter/services.dart';

class AndroidFeatures {
  static const MethodChannel _channel = MethodChannel('android_features');
  
  // Android-specific navigation
  static Future<void> setSystemUIOverlayStyle({
    Color? statusBarColor,
    Color? navigationBarColor,
    bool? statusBarIconBrightness,
  }) async {
    if (PlatformUtils.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: statusBarColor,
        navigationBarColor: navigationBarColor,
        statusBarIconBrightness: statusBarIconBrightness != null 
            ? (statusBarIconBrightness ? Brightness.light : Brightness.dark)
            : null,
      ));
    }
  }
  
  // Android back button handling
  static Future<bool> handleBackButton() async {
    if (PlatformUtils.isAndroid) {
      try {
        return await _channel.invokeMethod('handleBackButton') ?? false;
      } catch (e) {
        print('Failed to handle back button: $e');
        return false;
      }
    }
    return false;
  }
  
  // Android-specific sharing
  static Future<void> shareWithIntent(String text, {String? mimeType}) async {
    if (PlatformUtils.isAndroid) {
      try {
        await _channel.invokeMethod('shareWithIntent', {
          'text': text,
          'mimeType': mimeType ?? 'text/plain',
        });
      } catch (e) {
        print('Failed to share: $e');
      }
    }
  }
  
  // Android app info
  static Future<Map<String, dynamic>?> getAppInfo() async {
    if (PlatformUtils.isAndroid) {
      try {
        return await _channel.invokeMethod('getAppInfo');
      } catch (e) {
        print('Failed to get app info: $e');
        return null;
      }
    }
    return null;
  }
}
```

### 2. Android Configuration

```dart
// lib/platform/android/android_config.dart
class AndroidConfig {
  // Android-specific app configuration
  static const Map<String, dynamic> config = {
    'packageName': 'com.yourapp.flutter',
    'versionCode': 1,
    'minSdkVersion': 21,
    'targetSdkVersion': 33,
    'compileSdkVersion': 33,
  };
  
  // Android permissions
  static const List<String> requiredPermissions = [
    'android.permission.INTERNET',
    'android.permission.CAMERA',
    'android.permission.READ_EXTERNAL_STORAGE',
    'android.permission.WRITE_EXTERNAL_STORAGE',
    'android.permission.ACCESS_FINE_LOCATION',
    'android.permission.ACCESS_COARSE_LOCATION',
  ];
  
  // Android features
  static const List<String> features = [
    'android.hardware.camera',
    'android.hardware.location',
    'android.hardware.location.gps',
  ];
}
```

## Web-Specific Implementation

### 1. Web Features

```dart
// lib/platform/web/web_features.dart
import 'dart:html' as html;
import 'dart:js' as js;

class WebFeatures {
  // Web-specific navigation
  static void setPageTitle(String title) {
    if (PlatformUtils.isWeb) {
      html.document.title = title;
    }
  }
  
  // Web storage
  static void setLocalStorage(String key, String value) {
    if (PlatformUtils.isWeb) {
      html.window.localStorage[key] = value;
    }
  }
  
  static String? getLocalStorage(String key) {
    if (PlatformUtils.isWeb) {
      return html.window.localStorage[key];
    }
    return null;
  }
  
  // Web clipboard
  static Future<void> copyToClipboard(String text) async {
    if (PlatformUtils.isWeb) {
      try {
        await html.window.navigator.clipboard?.writeText(text);
      } catch (e) {
        // Fallback for older browsers
        _fallbackCopyToClipboard(text);
      }
    }
  }
  
  static void _fallbackCopyToClipboard(String text) {
    final textArea = html.TextAreaElement();
    textArea.value = text;
    html.document.body?.append(textArea);
    textArea.select();
    html.document.execCommand('copy');
    textArea.remove();
  }
  
  // Web download
  static void downloadFile(String content, String filename, {String mimeType = 'text/plain'}) {
    if (PlatformUtils.isWeb) {
      final blob = html.Blob([content], mimeType);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', filename)
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }
  
  // Web URL handling
  static void openUrl(String url, {bool newTab = true}) {
    if (PlatformUtils.isWeb) {
      html.window.open(url, newTab ? '_blank' : '_self');
    }
  }
  
  // Web analytics
  static void trackEvent(String event, Map<String, dynamic> parameters) {
    if (PlatformUtils.isWeb && !kDebugMode) {
      js.context.callMethod('gtag', ['event', event, js.JsObject.jsify(parameters)]);
    }
  }
}
```

### 2. Web Configuration

```dart
// lib/platform/web/web_config.dart
class WebConfig {
  // Web-specific configuration
  static const Map<String, dynamic> config = {
    'baseHref': '/',
    'title': 'Your Flutter App',
    'description': 'A Flutter web application',
    'keywords': 'flutter, web, app',
    'author': 'Your Name',
  };
  
  // Web meta tags
  static const Map<String, String> metaTags = {
    'viewport': 'width=device-width, initial-scale=1.0',
    'theme-color': '#2196F3',
    'apple-mobile-web-app-capable': 'yes',
    'apple-mobile-web-app-status-bar-style': 'default',
  };
  
  // PWA configuration
  static const Map<String, dynamic> pwaConfig = {
    'name': 'Your Flutter App',
    'short_name': 'FlutterApp',
    'start_url': '/',
    'display': 'standalone',
    'background_color': '#ffffff',
    'theme_color': '#2196F3',
  };
}
```

## Platform-Adaptive Widgets

### 1. Adaptive App Bar

```dart
// lib/widgets/adaptive_app_bar.dart
class AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  
  const AdaptiveAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isIOS) {
      return CupertinoNavigationBar(
        middle: Text(title),
        trailing: actions != null ? Row(
          mainAxisSize: MainAxisSize.min,
          children: actions!,
        ) : null,
        leading: leading,
        automaticallyImplyLeading: automaticallyImplyLeading,
      );
    }
    
    return AppBar(
      title: Text(title),
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      elevation: PlatformUtils.isWeb ? 1 : 4,
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
```

### 2. Adaptive Button

```dart
// lib/widgets/adaptive_button.dart
class AdaptiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final Color? color;
  
  const AdaptiveButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.color,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isIOS) {
      return CupertinoButton(
        onPressed: onPressed,
        color: isPrimary ? (color ?? CupertinoColors.activeBlue) : null,
        child: Text(text),
      );
    }
    
    if (isPrimary) {
      return ElevatedButton(
        onPressed: onPressed,
        style: color != null ? ElevatedButton.styleFrom(backgroundColor: color) : null,
        child: Text(text),
      );
    }
    
    return OutlinedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
```

### 3. Adaptive Dialog

```dart
// lib/widgets/adaptive_dialog.dart
class AdaptiveDialog {
  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'OK',
    String cancelText = 'Cancel',
  }) {
    if (PlatformUtils.isIOS) {
      return showCupertinoDialog<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(true),
              isDefaultAction: true,
              child: Text(confirmText),
            ),
          ],
        ),
      );
    }
    
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}
```

## Platform Services

### 1. Platform Service Factory

```dart
// lib/services/platform_service_factory.dart
abstract class PlatformService {
  Future<void> initialize();
  Future<void> dispose();
}

class PlatformServiceFactory {
  static T create<T extends PlatformService>() {
    if (T == NotificationService) {
      if (PlatformUtils.isIOS) {
        return IOSNotificationService() as T;
      } else if (PlatformUtils.isAndroid) {
        return AndroidNotificationService() as T;
      } else {
        return WebNotificationService() as T;
      }
    }
    
    if (T == FileService) {
      if (PlatformUtils.isWeb) {
        return WebFileService() as T;
      } else {
        return MobileFileService() as T;
      }
    }
    
    throw UnsupportedError('Service $T not supported on this platform');
  }
}
```

### 2. Platform-Specific Services

```dart
// lib/services/notification_service.dart
abstract class NotificationService extends PlatformService {
  Future<void> showNotification(String title, String body);
  Future<bool> requestPermission();
}

class IOSNotificationService implements NotificationService {
  @override
  Future<void> initialize() async {
    // iOS-specific initialization
  }
  
  @override
  Future<void> showNotification(String title, String body) async {
    // iOS notification implementation
  }
  
  @override
  Future<bool> requestPermission() async {
    // iOS permission request
    return true;
  }
  
  @override
  Future<void> dispose() async {
    // iOS cleanup
  }
}

class AndroidNotificationService implements NotificationService {
  @override
  Future<void> initialize() async {
    // Android-specific initialization
  }
  
  @override
  Future<void> showNotification(String title, String body) async {
    // Android notification implementation
  }
  
  @override
  Future<bool> requestPermission() async {
    // Android permission request
    return true;
  }
  
  @override
  Future<void> dispose() async {
    // Android cleanup
  }
}

class WebNotificationService implements NotificationService {
  @override
  Future<void> initialize() async {
    // Web-specific initialization
  }
  
  @override
  Future<void> showNotification(String title, String body) async {
    // Web notification implementation
    if (PlatformUtils.isWeb) {
      html.Notification(title, body: body);
    }
  }
  
  @override
  Future<bool> requestPermission() async {
    // Web permission request
    if (PlatformUtils.isWeb) {
      final permission = await html.Notification.requestPermission();
      return permission == 'granted';
    }
    return false;
  }
  
  @override
  Future<void> dispose() async {
    // Web cleanup
  }
}
```

## Testing Platform-Specific Code

### 1. Platform Testing

```dart
// test/platform/platform_utils_test.dart
void main() {
  group('Platform Utils Tests', () {
    test('should detect platform correctly', () {
      // Note: In tests, platform detection might not work as expected
      // Use mocking for reliable tests
      
      expect(PlatformUtils.platformName, isNotEmpty);
      expect(PlatformUtils.supportsHapticFeedback, isA<bool>());
    });
    
    testWidgets('should show platform-appropriate widgets', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: AdaptiveButton(
          text: 'Test',
          onPressed: () {},
        ),
      ));
      
      // Verify correct widget type is shown
      if (PlatformUtils.isIOS) {
        expect(find.byType(CupertinoButton), findsOneWidget);
      } else {
        expect(find.byType(ElevatedButton), findsOneWidget);
      }
    });
  });
}
```

Platform-specific implementation allows you to provide the best user experience on each platform while maintaining code reusability. Always provide fallbacks and test thoroughly across platforms.
