# iOS Troubleshooting Guide

Comprehensive troubleshooting guide for common iOS development issues in Flutter projects.

## Development Environment Issues

### 1. Xcode Command Line Tools

**Problem**: `xcode-select: error: tool 'xcodebuild' requires Xcode`

**Solution**:
```bash
# Install Xcode Command Line Tools
sudo xcode-select --install

# Verify installation
xcode-select -p

# If needed, reset the path
sudo xcode-select --reset
```

### 2. CocoaPods Issues

**Problem**: `CocoaPods not installed` or version conflicts

**Solution**:
```bash
# Check Ruby version (should be 2.7+)
ruby --version

# Install CocoaPods
sudo gem install cocoapods

# If using Homebrew Ruby
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export GEM_HOME="$HOME/.gem/ruby/3.4.0"
export GEM_PATH="$GEM_HOME"
export PATH="$GEM_HOME/bin:$PATH"
gem install cocoapods

# Update CocoaPods repo
pod repo update

# Clean and reinstall pods
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
```

### 3. iOS Simulator Issues

**Problem**: Simulator not launching or app not installing

**Solution**:
```bash
# Reset simulator
xcrun simctl erase all

# List available simulators
xcrun simctl list devices

# Boot specific simulator
xcrun simctl boot "iPhone 14 Pro"

# Install app manually
xcrun simctl install booted path/to/app.app
```

## Build Issues

### 1. Archive Build Failures

**Problem**: Build succeeds in debug but fails in release/archive

**Solution**:
```bash
# Clean build folder
flutter clean
cd ios
rm -rf build/
xcodebuild clean -workspace Runner.xcworkspace -scheme Runner

# Rebuild
flutter build ios --release
```

**Common Xcode Settings**:
- Set `ENABLE_BITCODE = NO` in Build Settings
- Ensure `iOS Deployment Target` matches your minimum version
- Check `Code Signing` settings

### 2. Dependency Conflicts

**Problem**: `The iOS deployment target 'IPHONEOS_DEPLOYMENT_TARGET' is set to 8.0`

**Solution**:
```ruby
# ios/Podfile
platform :ios, '11.0'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
    end
  end
end
```

### 3. Swift Version Issues

**Problem**: `Module compiled with Swift X.X cannot be imported by the Swift Y.Y compiler`

**Solution**:
```ruby
# ios/Podfile
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '5.0'
    end
  end
end
```

## Code Signing Issues

### 1. Provisioning Profile Problems

**Problem**: `No provisioning profile found` or `Code signing error`

**Solution**:
1. **Automatic Signing** (Recommended for development):
   - Open `ios/Runner.xcworkspace` in Xcode
   - Select Runner target
   - Enable "Automatically manage signing"
   - Select your development team

2. **Manual Signing**:
   - Create App ID in Apple Developer Portal
   - Create Development/Distribution certificates
   - Create Provisioning Profiles
   - Download and install profiles

### 2. Certificate Issues

**Problem**: `Certificate has expired` or `No valid signing identity`

**Solution**:
```bash
# List certificates
security find-identity -v -p codesigning

# Delete expired certificates from Keychain
# Open Keychain Access > Certificates > Delete expired ones

# Download new certificates from Apple Developer Portal
```

### 3. Team ID Issues

**Problem**: `No account for team` or `Team ID not found`

**Solution**:
```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleIdentifier</key>
<string>com.yourteam.yourapp</string>

<!-- ios/Runner.xcodeproj/project.pbxproj -->
DEVELOPMENT_TEAM = YOUR_TEAM_ID;
```

## Runtime Issues

### 1. App Crashes on Launch

**Problem**: App crashes immediately after launch on device

**Debugging Steps**:
```bash
# Check device logs
flutter logs

# Run with verbose logging
flutter run --verbose

# Check Xcode console for crash logs
# Window > Devices and Simulators > Select device > View Device Logs
```

**Common Causes**:
- Missing Info.plist permissions
- Incorrect bundle identifier
- Missing required frameworks

### 2. Network Issues

**Problem**: Network requests fail on iOS but work on Android

**Solution**:
```xml
<!-- ios/Runner/Info.plist -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
    <!-- Or for specific domains -->
    <key>NSExceptionDomains</key>
    <dict>
        <key>your-api-domain.com</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
    </dict>
</dict>
```

### 3. Permission Issues

**Problem**: Camera, location, or other permissions not working

**Solution**:
```xml
<!-- ios/Runner/Info.plist -->
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take photos</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to show nearby places</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to select images</string>

<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to record audio</string>
```

## Performance Issues

### 1. Slow Build Times

**Problem**: iOS builds take too long

**Solutions**:
```bash
# Enable parallel builds in Xcode
# Build Settings > Build Options > Enable "Parallelize Build"

# Use build cache
flutter build ios --build-shared-framework

# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData
```

### 2. Large App Size

**Problem**: iOS app size is too large

**Solutions**:
```bash
# Build with tree shaking
flutter build ios --release --tree-shake-icons

# Analyze app size
flutter build ios --analyze-size

# Use app bundle
# Enable in Xcode: Build Settings > Enable App Slicing
```

### 3. Memory Issues

**Problem**: App crashes due to memory pressure

**Debugging**:
```dart
// Monitor memory usage
import 'dart:developer' as developer;

void checkMemoryUsage() {
  developer.log('Memory usage: ${ProcessInfo.currentRss ~/ 1024 ~/ 1024} MB');
}

// Use memory profiler in Xcode
// Product > Profile > Allocations
```

## App Store Issues

### 1. Upload Failures

**Problem**: `Invalid binary` or upload errors

**Common Solutions**:
- Ensure all required icons are present
- Check Info.plist for required keys
- Verify bundle identifier matches App Store Connect
- Use Application Loader or Xcode Organizer

### 2. Rejection Issues

**Problem**: App rejected during review

**Common Reasons**:
- Missing privacy policy
- Incomplete App Store information
- UI/UX issues
- Crash on reviewer's device

**Prevention**:
```xml
<!-- ios/Runner/Info.plist -->
<!-- Add all required usage descriptions -->
<key>NSUserTrackingUsageDescription</key>
<string>This app uses tracking to provide personalized ads</string>
```

### 3. TestFlight Issues

**Problem**: TestFlight build not appearing

**Solutions**:
- Check build processing status in App Store Connect
- Ensure compliance with export regulations
- Verify all required metadata is complete

## Device-Specific Issues

### 1. iPhone X+ Layout Issues

**Problem**: UI not adapting to notch/safe areas

**Solution**:
```dart
// Use SafeArea widget
SafeArea(
  child: Scaffold(
    body: YourContent(),
  ),
)

// Or use MediaQuery for custom handling
Widget build(BuildContext context) {
  final padding = MediaQuery.of(context).padding;
  return Container(
    padding: EdgeInsets.only(
      top: padding.top,
      bottom: padding.bottom,
    ),
    child: YourContent(),
  );
}
```

### 2. iPad Layout Issues

**Problem**: App doesn't look good on iPad

**Solution**:
```dart
// Responsive design
Widget build(BuildContext context) {
  final isTablet = MediaQuery.of(context).size.width > 600;
  
  return isTablet 
    ? TabletLayout()
    : PhoneLayout();
}

// Support iPad multitasking
// ios/Runner/Info.plist
<key>UIRequiresFullScreen</key>
<false/>
```

### 3. iOS Version Compatibility

**Problem**: App crashes on older iOS versions

**Solution**:
```dart
// Check iOS version at runtime
import 'dart:io';

bool get isIOS13OrLater {
  if (!Platform.isIOS) return false;
  final version = Platform.operatingSystemVersion;
  // Parse version string and compare
  return true; // Implement version comparison
}

// Use conditional features
if (isIOS13OrLater) {
  // Use iOS 13+ features
} else {
  // Fallback for older versions
}
```

## Debugging Tools

### 1. Xcode Debugger

```bash
# Run with Xcode debugger attached
flutter run --debug

# Set breakpoints in native code
# Open ios/Runner.xcworkspace
# Set breakpoints in AppDelegate.swift or other native files
```

### 2. Instruments

```bash
# Profile with Instruments
flutter build ios --profile
# Open Xcode > Product > Profile
# Choose appropriate instrument (Allocations, Time Profiler, etc.)
```

### 3. Console Logs

```dart
// Add logging for iOS-specific issues
import 'dart:developer' as developer;
import 'dart:io';

void logIOS(String message) {
  if (Platform.isIOS) {
    developer.log(message, name: 'iOS');
  }
}
```

## Prevention Strategies

### 1. Continuous Integration

```yaml
# .github/workflows/ios.yml
name: iOS Build
on: [push, pull_request]
jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter build ios --no-codesign
```

### 2. Automated Testing

```dart
// integration_test/ios_specific_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('iOS Specific Tests', () {
    testWidgets('should handle iOS permissions', (tester) async {
      // Test iOS-specific functionality
    });
  });
}
```

### 3. Regular Maintenance

```bash
# Weekly maintenance script
#!/bin/bash
flutter clean
flutter pub get
cd ios
pod repo update
pod install
cd ..
flutter doctor
```

## Quick Reference

### Common Commands
```bash
# Clean everything
flutter clean && cd ios && rm -rf Pods Podfile.lock && pod install

# Reset simulator
xcrun simctl erase all

# View device logs
flutter logs

# Build for release
flutter build ios --release

# Archive in Xcode
# Product > Archive
```

### Useful Xcode Shortcuts
- `⌘ + Shift + K`: Clean Build Folder
- `⌘ + B`: Build
- `⌘ + R`: Run
- `⌘ + .`: Stop
- `⌘ + Shift + O`: Open Quickly

### Key Files to Check
- `ios/Podfile`: CocoaPods configuration
- `ios/Runner/Info.plist`: App configuration
- `ios/Runner.xcodeproj/project.pbxproj`: Xcode project settings
- `ios/Runner/AppDelegate.swift`: App lifecycle

Remember to always test on real devices before releasing, as simulator behavior can differ from actual device behavior.
