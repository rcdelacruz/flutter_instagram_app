# Cross-Platform Design

Guide to creating consistent user experiences across iOS, Android, and Web platforms while respecting platform conventions.

## Overview

Cross-platform design in Flutter involves balancing consistency with platform-specific conventions. This guide covers adaptive design patterns, platform-specific widgets, and design system implementation.

## Platform Detection

### 1. Platform Utilities

```dart
// lib/utils/platform_utils.dart
import 'dart:io';
import 'package:flutter/foundation.dart';

class PlatformUtils {
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isWeb => kIsWeb;
  static bool get isMobile => isIOS || isAndroid;
  static bool get isDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
  
  static TargetPlatform get currentPlatform {
    if (kIsWeb) return TargetPlatform.android; // Default for web
    return defaultTargetPlatform;
  }
  
  static bool get supportsHapticFeedback => isIOS || isAndroid;
  static bool get supportsBiometrics => isIOS || isAndroid;
}
```

### 2. Platform-Aware Widgets

```dart
// lib/widgets/platform_widget.dart
abstract class PlatformWidget<I extends Widget, A extends Widget> extends StatelessWidget {
  const PlatformWidget({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isIOS) {
      return buildIOS(context);
    }
    return buildAndroid(context);
  }
  
  I buildIOS(BuildContext context);
  A buildAndroid(BuildContext context);
}

// Usage example
class PlatformButton extends PlatformWidget<CupertinoButton, ElevatedButton> {
  final String text;
  final VoidCallback onPressed;
  
  const PlatformButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);
  
  @override
  CupertinoButton buildIOS(BuildContext context) {
    return CupertinoButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
  
  @override
  ElevatedButton buildAndroid(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
```

## Navigation Patterns

### 1. Adaptive Navigation

```dart
// lib/widgets/adaptive_navigation.dart
class AdaptiveScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  
  const AdaptiveScaffold({
    Key? key,
    required this.body,
    required this.title,
    this.actions,
    this.floatingActionButton,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(title),
          trailing: actions != null ? Row(
            mainAxisSize: MainAxisSize.min,
            children: actions!,
          ) : null,
        ),
        child: SafeArea(child: body),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
```

### 2. Platform-Specific Routing

```dart
// lib/navigation/platform_route.dart
class PlatformRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final String? title;
  
  PlatformRoute({
    required this.child,
    this.title,
    RouteSettings? settings,
  }) : super(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (PlatformUtils.isIOS) {
        return CupertinoPageTransition(
          primaryRouteAnimation: animation,
          secondaryRouteAnimation: secondaryAnimation,
          child: child,
          linearTransition: false,
        );
      }
      
      return SlideTransition(
        position: animation.drive(
          Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.ease)),
        ),
        child: child,
      );
    },
  );
}

// Navigation helper
class PlatformNavigator {
  static Future<T?> push<T>(BuildContext context, Widget page, {String? title}) {
    return Navigator.of(context).push<T>(
      PlatformRoute<T>(child: page, title: title),
    );
  }
  
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.of(context).pop(result);
  }
}
```

## UI Components

### 1. Platform-Adaptive Dialogs

```dart
// lib/widgets/platform_dialog.dart
class PlatformDialog {
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

### 2. Platform-Adaptive Loading

```dart
// lib/widgets/platform_loading.dart
class PlatformLoading extends StatelessWidget {
  final double? size;
  final Color? color;
  
  const PlatformLoading({
    Key? key,
    this.size,
    this.color,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isIOS) {
      return CupertinoActivityIndicator(
        radius: size != null ? size! / 2 : 10.0,
        color: color,
      );
    }
    
    return SizedBox(
      width: size ?? 20.0,
      height: size ?? 20.0,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: color != null ? AlwaysStoppedAnimation(color) : null,
      ),
    );
  }
}
```

### 3. Platform-Adaptive Switch

```dart
// lib/widgets/platform_switch.dart
class PlatformSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;
  
  const PlatformSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
    this.activeColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isIOS) {
      return CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeColor: activeColor,
      );
    }
    
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: activeColor,
    );
  }
}
```

## Design System Integration

### 1. Platform-Aware Theme

```dart
// lib/theme/platform_theme.dart
class PlatformTheme {
  static ThemeData getTheme(BuildContext context) {
    if (PlatformUtils.isIOS) {
      return ThemeData(
        cupertinoOverrideTheme: const CupertinoThemeData(
          primaryColor: CupertinoColors.systemBlue,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: CupertinoColors.systemBlue,
        ),
      );
    }
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
      ),
    );
  }
  
  static CupertinoThemeData getCupertinoTheme() {
    return const CupertinoThemeData(
      primaryColor: CupertinoColors.systemBlue,
      brightness: Brightness.light,
    );
  }
}
```

### 2. Typography Adaptation

```dart
// lib/theme/platform_typography.dart
class PlatformTypography {
  static TextTheme getTextTheme(BuildContext context) {
    if (PlatformUtils.isIOS) {
      return const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          fontFamily: '.SF UI Display',
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          fontFamily: '.SF UI Display',
        ),
        bodyLarge: TextStyle(
          fontSize: 17,
          fontFamily: '.SF UI Text',
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          fontFamily: '.SF UI Text',
        ),
      );
    }
    
    return const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontFamily: 'Roboto',
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontFamily: 'Roboto',
      ),
    );
  }
}
```

## Platform-Specific Features

### 1. Haptic Feedback

```dart
// lib/services/haptic_service.dart
import 'package:flutter/services.dart';

class HapticService {
  static Future<void> lightImpact() async {
    if (PlatformUtils.supportsHapticFeedback) {
      await HapticFeedback.lightImpact();
    }
  }
  
  static Future<void> mediumImpact() async {
    if (PlatformUtils.supportsHapticFeedback) {
      await HapticFeedback.mediumImpact();
    }
  }
  
  static Future<void> heavyImpact() async {
    if (PlatformUtils.supportsHapticFeedback) {
      await HapticFeedback.heavyImpact();
    }
  }
  
  static Future<void> selectionClick() async {
    if (PlatformUtils.supportsHapticFeedback) {
      await HapticFeedback.selectionClick();
    }
  }
}
```

### 2. Platform-Specific Icons

```dart
// lib/widgets/platform_icon.dart
class PlatformIcon extends StatelessWidget {
  final PlatformIconData iconData;
  final double? size;
  final Color? color;
  
  const PlatformIcon(
    this.iconData, {
    Key? key,
    this.size,
    this.color,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isIOS) {
      return Icon(
        iconData.ios,
        size: size,
        color: color,
      );
    }
    
    return Icon(
      iconData.android,
      size: size,
      color: color,
    );
  }
}

class PlatformIconData {
  final IconData ios;
  final IconData android;
  
  const PlatformIconData({
    required this.ios,
    required this.android,
  });
  
  // Common icons
  static const PlatformIconData home = PlatformIconData(
    ios: CupertinoIcons.home,
    android: Icons.home,
  );
  
  static const PlatformIconData settings = PlatformIconData(
    ios: CupertinoIcons.settings,
    android: Icons.settings,
  );
  
  static const PlatformIconData search = PlatformIconData(
    ios: CupertinoIcons.search,
    android: Icons.search,
  );
}
```

## Web Adaptations

### 1. Web-Specific Layouts

```dart
// lib/widgets/web_adaptive_layout.dart
class WebAdaptiveLayout extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  
  const WebAdaptiveLayout({
    Key? key,
    required this.child,
    this.maxWidth = 1200,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isWeb) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      );
    }
    
    return child;
  }
}
```

### 2. Mouse and Keyboard Support

```dart
// lib/widgets/web_enhanced_widget.dart
class WebEnhancedWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  
  const WebEnhancedWidget({
    Key? key,
    required this.child,
    this.onTap,
  }) : super(key: key);
  
  @override
  _WebEnhancedWidgetState createState() => _WebEnhancedWidgetState();
}

class _WebEnhancedWidgetState extends State<WebEnhancedWidget> {
  bool _isHovered = false;
  
  @override
  Widget build(BuildContext context) {
    if (!PlatformUtils.isWeb) {
      return GestureDetector(
        onTap: widget.onTap,
        child: widget.child,
      );
    }
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: _isHovered ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(),
          child: widget.child,
        ),
      ),
    );
  }
}
```

## Testing Cross-Platform Design

### 1. Platform Testing

```dart
// test/platform_widget_test.dart
void main() {
  group('Platform Widget Tests', () {
    testWidgets('should show iOS widget on iOS platform', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      
      await tester.pumpWidget(MaterialApp(
        home: PlatformButton(
          text: 'Test',
          onPressed: () {},
        ),
      ));
      
      expect(find.byType(CupertinoButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
      
      debugDefaultTargetPlatformOverride = null;
    });
    
    testWidgets('should show Android widget on Android platform', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      
      await tester.pumpWidget(MaterialApp(
        home: PlatformButton(
          text: 'Test',
          onPressed: () {},
        ),
      ));
      
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(CupertinoButton), findsNothing);
      
      debugDefaultTargetPlatformOverride = null;
    });
  });
}
```

## Best Practices

### 1. Consistent Behavior

```dart
// Ensure consistent behavior across platforms
class PlatformConsistentWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      ios: CupertinoButton(
        onPressed: _handlePress,
        child: Text('Button'),
      ),
      android: ElevatedButton(
        onPressed: _handlePress,
        child: Text('Button'),
      ),
    );
  }
  
  void _handlePress() {
    // Same behavior on both platforms
    HapticService.lightImpact();
    // Handle button press
  }
}
```

### 2. Performance Considerations

```dart
// Use platform detection sparingly
class OptimizedPlatformWidget extends StatelessWidget {
  static final bool _isIOS = PlatformUtils.isIOS;
  
  @override
  Widget build(BuildContext context) {
    // Cache platform detection result
    if (_isIOS) {
      return _buildIOSWidget();
    }
    return _buildAndroidWidget();
  }
}
```

Cross-platform design requires balancing consistency with platform conventions. Focus on creating familiar experiences while maintaining your app's unique identity.
