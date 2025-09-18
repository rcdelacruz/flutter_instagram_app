# Common Issues & Solutions

Comprehensive troubleshooting guide for common Flutter development issues and their solutions.

## Overview

This guide covers the most frequently encountered issues in Flutter development, from setup problems to runtime errors, with step-by-step solutions and prevention strategies.

## Development Environment Issues

### 1. Flutter Doctor Issues

#### Issue: Flutter Doctor Shows Warnings

```bash
# Common flutter doctor output with issues
[✗] Android toolchain - develop for Android devices
    ✗ Unable to locate Android SDK
[✗] Xcode - develop for iOS and macOS
    ✗ Xcode installation is incomplete
[!] Android Studio (not installed)
```

**Solution:**

```bash
# Fix Android SDK issues
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Accept Android licenses
flutter doctor --android-licenses

# Install missing components
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

# For macOS/iOS development
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

#### Issue: CocoaPods Installation Problems

```bash
# Error message
CocoaPods not installed or not in valid state.
```

**Solution:**

```bash
# Install CocoaPods
sudo gem install cocoapods

# If using Homebrew Ruby (recommended)
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export GEM_HOME="$HOME/.gem/ruby/3.4.0"
export GEM_PATH="$GEM_HOME"
export PATH="$GEM_HOME/bin:$PATH"

gem install cocoapods
pod setup

# For M1/M2 Macs
sudo arch -x86_64 gem install ffi
arch -x86_64 pod install
```

### 2. Dependency Issues

#### Issue: Pub Get Fails

```yaml
# Error in pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  some_package: ^1.0.0  # Package not found or version conflict
```

**Solution:**

```bash
# Clear pub cache
flutter pub cache clean

# Get dependencies with verbose output
flutter pub get --verbose

# Resolve version conflicts
flutter pub deps
flutter pub upgrade

# Force refresh
rm pubspec.lock
flutter pub get
```

#### Issue: Version Conflicts

```bash
# Error message
Because myapp depends on package_a >=1.0.0 and package_b >=2.0.0 which depends on package_a <1.0.0, version solving failed.
```

**Solution:**

```yaml
# pubspec.yaml - Use dependency overrides
dependency_overrides:
  package_a: ^1.0.0

# Or specify exact versions
dependencies:
  package_a: 1.0.0
  package_b: 2.0.0
```

## Build Issues

### 1. Android Build Problems

#### Issue: Gradle Build Fails

```bash
# Common Gradle errors
FAILURE: Build failed with an exception.
* What went wrong:
Execution failed for task ':app:processReleaseResources'.
```

**Solution:**

```bash
# Clean and rebuild
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk

# Fix common Gradle issues
cd android
./gradlew --stop
./gradlew clean
./gradlew build --stacktrace
```

#### Issue: Multidex Issues

```bash
# Error message
Cannot fit requested classes in a single dex file
```

**Solution:**

```gradle
// android/app/build.gradle
android {
    defaultConfig {
        multiDexEnabled true
    }
}

dependencies {
    implementation 'androidx.multidex:multidex:2.0.1'
}
```

```dart
// lib/main.dart
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}
```

#### Issue: Keystore Problems

```bash
# Error message
Keystore file not found or invalid
```

**Solution:**

```bash
# Generate new keystore
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Verify keystore
keytool -list -v -keystore ~/upload-keystore.jks -alias upload

# Update key.properties
echo "storePassword=your_password" > android/key.properties
echo "keyPassword=your_password" >> android/key.properties
echo "keyAlias=upload" >> android/key.properties
echo "storeFile=../upload-keystore.jks" >> android/key.properties
```

### 2. iOS Build Problems

#### Issue: CocoaPods Integration

```bash
# Error message
[!] Unable to find a specification for dependency
```

**Solution:**

```bash
# Clean CocoaPods cache
cd ios
rm -rf Pods
rm Podfile.lock
pod cache clean --all
pod install

# Update CocoaPods
pod repo update
pod install --repo-update

# For M1/M2 Macs
arch -x86_64 pod install
```

#### Issue: Xcode Signing Issues

```bash
# Error message
Code signing error: No profiles for 'com.example.app' were found
```

**Solution:**

```bash
# Open Xcode and configure signing
open ios/Runner.xcworkspace

# Or use automatic signing in Xcode:
# 1. Select Runner project
# 2. Select Runner target
# 3. Go to Signing & Capabilities
# 4. Enable "Automatically manage signing"
# 5. Select your team
```

#### Issue: iOS Simulator Not Found

```bash
# Error message
No iOS devices available
```

**Solution:**

```bash
# List available simulators
xcrun simctl list devices

# Create new simulator
xcrun simctl create "iPhone 15 Pro" "iPhone 15 Pro" "iOS 17.0"

# Boot simulator
xcrun simctl boot "iPhone 15 Pro"

# Open Simulator app
open -a Simulator
```

## Runtime Issues

### 1. State Management Problems

#### Issue: setState Called After Dispose

```dart
// Error message
setState() called after dispose()
```

**Solution:**

```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  bool _mounted = true;
  
  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }
  
  void updateState() {
    if (_mounted) {
      setState(() {
        // Update state
      });
    }
  }
  
  // Alternative approach
  void updateStateSafe() {
    if (mounted) {
      setState(() {
        // Update state
      });
    }
  }
}
```

#### Issue: Memory Leaks

```dart
// Problem: Not disposing controllers
class BadWidget extends StatefulWidget {
  @override
  _BadWidgetState createState() => _BadWidgetState();
}

class _BadWidgetState extends State<BadWidget> {
  late AnimationController _controller;
  late StreamSubscription _subscription;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _subscription = someStream.listen((data) {
      // Handle data
    });
  }
  
  // Missing dispose method!
}
```

**Solution:**

```dart
class GoodWidget extends StatefulWidget {
  @override
  _GoodWidgetState createState() => _GoodWidgetState();
}

class _GoodWidgetState extends State<GoodWidget> with TickerProviderStateMixin {
  late AnimationController _controller;
  late StreamSubscription _subscription;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _subscription = someStream.listen((data) {
      // Handle data
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _subscription.cancel();
    super.dispose();
  }
}
```

### 2. Performance Issues

#### Issue: Excessive Widget Rebuilds

```dart
// Problem: Rebuilding entire widget tree
class BadPerformanceWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpensiveWidget(), // Rebuilds unnecessarily
        AnotherExpensiveWidget(),
      ],
    );
  }
}
```

**Solution:**

```dart
// Solution: Use const constructors and extract widgets
class GoodPerformanceWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _ExpensiveWidget(), // const constructor
        _AnotherExpensiveWidget(),
      ],
    );
  }
}

class _ExpensiveWidget extends StatelessWidget {
  const _ExpensiveWidget();
  
  @override
  Widget build(BuildContext context) {
    return Container(
      // Expensive widget content
    );
  }
}
```

#### Issue: Large Lists Performance

```dart
// Problem: Using Column for large lists
Widget badList() {
  return Column(
    children: List.generate(1000, (index) => ListTile(
      title: Text('Item $index'),
    )),
  );
}
```

**Solution:**

```dart
// Solution: Use ListView.builder
Widget goodList() {
  return ListView.builder(
    itemCount: 1000,
    itemBuilder: (context, index) {
      return ListTile(
        title: Text('Item $index'),
      );
    },
  );
}

// For complex lists, use ListView.separated
Widget separatedList() {
  return ListView.separated(
    itemCount: 1000,
    separatorBuilder: (context, index) => const Divider(),
    itemBuilder: (context, index) {
      return ListTile(
        title: Text('Item $index'),
      );
    },
  );
}
```

## Network Issues

### 1. HTTP Request Problems

#### Issue: Certificate Verification Failed

```dart
// Error message
HandshakeException: Handshake error in client
```

**Solution:**

```dart
// For development only - NOT for production
import 'dart:io';

class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  if (kDebugMode) {
    HttpOverrides.global = DevHttpOverrides();
  }
  runApp(MyApp());
}

// Production solution: Use proper certificates
import 'package:dio/dio.dart';
import 'package:dio_certificate_pinning/dio_certificate_pinning.dart';

final dio = Dio();
dio.interceptors.add(
  CertificatePinningInterceptor(
    allowedSHAFingerprints: ['YOUR_CERTIFICATE_FINGERPRINT'],
  ),
);
```

#### Issue: Timeout Errors

```dart
// Error message
SocketException: OS Error: Connection timed out
```

**Solution:**

```dart
import 'package:dio/dio.dart';

final dio = Dio(BaseOptions(
  connectTimeout: Duration(seconds: 10),
  receiveTimeout: Duration(seconds: 10),
  sendTimeout: Duration(seconds: 10),
));

// Add retry interceptor
dio.interceptors.add(
  RetryInterceptor(
    dio: dio,
    logPrint: print,
    retries: 3,
    retryDelays: [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 3),
    ],
  ),
);
```

### 2. API Integration Issues

#### Issue: JSON Parsing Errors

```dart
// Error message
type 'Null' is not a subtype of type 'String'
```

**Solution:**

```dart
// Problem: Not handling null values
class BadUser {
  final String name;
  final String email;
  
  BadUser.fromJson(Map<String, dynamic> json)
    : name = json['name'],  // Can be null
      email = json['email']; // Can be null
}

// Solution: Handle null values properly
class GoodUser {
  final String name;
  final String email;
  
  GoodUser.fromJson(Map<String, dynamic> json)
    : name = json['name'] ?? '',
      email = json['email'] ?? '';
  
  // Or use null-aware operators
  factory GoodUser.fromJsonSafe(Map<String, dynamic> json) {
    return GoodUser(
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
}

// Use json_annotation for better handling
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class User {
  @JsonKey(defaultValue: '')
  final String name;
  
  @JsonKey(defaultValue: '')
  final String email;
  
  User({required this.name, required this.email});
  
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```

## Platform-Specific Issues

### 1. Android Issues

#### Issue: Permission Denied

```bash
# Error message
PlatformException(PERMISSION_DENIED, Permission denied, null)
```

**Solution:**

```dart
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestPermission() async {
  final status = await Permission.camera.request();
  
  if (status.isGranted) {
    return true;
  } else if (status.isPermanentlyDenied) {
    // Show dialog to open app settings
    await openAppSettings();
  }
  
  return false;
}

// Check permission before using
Future<void> useCamera() async {
  if (await requestPermission()) {
    // Use camera
  } else {
    // Show error message
  }
}
```

#### Issue: Back Button Handling

```dart
// Problem: App exits unexpectedly
class BadBackButtonHandling extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(), // No back button handling
    );
  }
}
```

**Solution:**

```dart
class GoodBackButtonHandling extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle back button press
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Exit App'),
            content: Text('Do you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes'),
              ),
            ],
          ),
        );
        
        return shouldPop ?? false;
      },
      child: Scaffold(
        body: Container(),
      ),
    );
  }
}
```

### 2. iOS Issues

#### Issue: Safe Area Problems

```dart
// Problem: Content hidden behind notch/home indicator
class BadSafeArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('This might be hidden'), // Behind notch
        ],
      ),
    );
  }
}
```

**Solution:**

```dart
class GoodSafeArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Text('This is visible'), // Properly positioned
          ],
        ),
      ),
    );
  }
}

// Or use MediaQuery for custom handling
class CustomSafeArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
          top: padding.top,
          bottom: padding.bottom,
        ),
        child: Column(
          children: [
            Text('Custom safe area handling'),
          ],
        ),
      ),
    );
  }
}
```

## Debugging Strategies

### 1. Debug Tools

```dart
// Enable debug logging
import 'package:flutter/foundation.dart';

void debugLog(String message) {
  if (kDebugMode) {
    print('DEBUG: $message');
  }
}

// Use debugPrint for large outputs
void debugLargeOutput(String message) {
  debugPrint(message);
}

// Use Flutter Inspector
// In VS Code: Ctrl+Shift+P -> "Flutter: Open Widget Inspector"
// In Android Studio: Flutter Inspector tab
```

### 2. Performance Debugging

```dart
// Profile widget rebuilds
import 'package:flutter/rendering.dart';

void main() {
  // Enable performance overlay
  debugProfileBuildsEnabled = true;
  
  runApp(MyApp());
}

// Use performance overlay
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      showPerformanceOverlay: kDebugMode,
      home: MyHomePage(),
    );
  }
}
```

### 3. Common Debug Commands

```bash
# Flutter debugging commands
flutter logs                    # View device logs
flutter analyze                # Static analysis
flutter test                   # Run tests
flutter doctor -v              # Detailed doctor output
flutter clean                  # Clean build cache
flutter pub deps               # Show dependency tree
flutter pub outdated           # Check for updates

# Device debugging
adb logcat                     # Android logs
xcrun simctl spawn booted log  # iOS simulator logs
```

Remember to always check the official Flutter documentation and GitHub issues for the latest solutions to common problems. Many issues have been encountered and solved by the community.
