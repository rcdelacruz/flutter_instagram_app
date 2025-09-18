# Build Issues & Solutions

Comprehensive guide to resolving Flutter build issues across different platforms and environments.

## Overview

Build issues can occur at various stages of the Flutter development process. This guide provides systematic approaches to diagnose and resolve common build problems.

## Android Build Issues

### 1. Gradle Build Failures

#### Issue: Gradle Sync Failed

```bash
# Error message
FAILURE: Build failed with an exception.
* What went wrong:
Could not resolve all files for configuration ':app:debugCompileClasspath'.
```

**Diagnosis Steps:**

```bash
# Check Gradle version compatibility
cd android
./gradlew --version

# Check Flutter and Gradle compatibility
flutter doctor -v

# Clean and rebuild
./gradlew clean
cd ..
flutter clean
flutter pub get
```

**Solution:**

```gradle
// android/gradle/wrapper/gradle-wrapper.properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.0-all.zip

// android/build.gradle
buildscript {
    ext.kotlin_version = '1.9.10'
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}

// android/app/build.gradle
android {
    compileSdkVersion 34
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
    
    kotlinOptions {
        jvmTarget = '1.8'
    }
}
```

#### Issue: Dependency Resolution Conflicts

```bash
# Error message
Duplicate class found in modules
```

**Solution:**

```gradle
// android/app/build.gradle
android {
    configurations {
        all {
            exclude group: 'com.google.guava', module: 'listenablefuture'
        }
    }
}

dependencies {
    implementation 'androidx.core:core-ktx:1.12.0'
    implementation 'androidx.lifecycle:lifecycle-runtime-ktx:2.7.0'
    
    // Exclude conflicting dependencies
    implementation('com.some.library:library:1.0.0') {
        exclude group: 'conflicting.group', module: 'conflicting-module'
    }
}
```

#### Issue: Multidex Build Errors

```bash
# Error message
Cannot fit requested classes in a single dex file (# methods: 65536 > 65536)
```

**Solution:**

```gradle
// android/app/build.gradle
android {
    defaultConfig {
        multiDexEnabled true
    }
    
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}

dependencies {
    implementation 'androidx.multidex:multidex:2.0.1'
}
```

```kotlin
// android/app/src/main/kotlin/.../MainActivity.kt
import androidx.multidex.MultiDexApplication

class MainApplication : MultiDexApplication() {
    override fun onCreate() {
        super.onCreate()
    }
}
```

### 2. ProGuard/R8 Issues

#### Issue: Code Obfuscation Breaks App

```bash
# Error message
ClassNotFoundException or MethodNotFoundException in release build
```

**Solution:**

```proguard
# android/app/proguard-rules.pro

# Keep Flutter classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep your app's classes
-keep class com.yourapp.** { *; }

# Keep model classes (if using JSON serialization)
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep Retrofit interfaces
-keep,allowobfuscation,allowshrinking interface retrofit2.Call
-keep,allowobfuscation,allowshrinking class retrofit2.Response
-keep,allowobfuscation,allowshrinking class kotlin.coroutines.Continuation

# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Remove debug logs
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}
```

### 3. Signing Issues

#### Issue: Keystore Not Found

```bash
# Error message
Keystore file '/path/to/keystore.jks' not found for signing config 'release'.
```

**Solution:**

```bash
# Generate new keystore
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Create key.properties file
echo "storePassword=your_store_password" > android/key.properties
echo "keyPassword=your_key_password" >> android/key.properties
echo "keyAlias=upload" >> android/key.properties
echo "storeFile=../upload-keystore.jks" >> android/key.properties
```

```gradle
// android/app/build.gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

## iOS Build Issues

### 1. CocoaPods Issues

#### Issue: Pod Install Fails

```bash
# Error message
[!] Unable to find a specification for `dependency_name`
```

**Solution:**

```bash
# Clean CocoaPods cache
cd ios
rm -rf Pods
rm Podfile.lock
pod cache clean --all

# Update CocoaPods repository
pod repo update

# Install with verbose output
pod install --verbose

# For M1/M2 Macs
arch -x86_64 pod install

# Alternative: Use Rosetta terminal
arch -x86_64 /bin/bash
pod install
```

#### Issue: Minimum Deployment Target

```bash
# Error message
The iOS deployment target 'IPHONEOS_DEPLOYMENT_TARGET' is set to 8.0, but the range of supported deployment target versions is 11.0 to 17.0.99.
```

**Solution:**

```ruby
# ios/Podfile
platform :ios, '12.0'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
```

### 2. Xcode Build Issues

#### Issue: Code Signing Errors

```bash
# Error message
Code Sign error: No code signing identities found
```

**Solution:**

```bash
# Open Xcode project
open ios/Runner.xcworkspace

# In Xcode:
# 1. Select Runner project
# 2. Select Runner target
# 3. Go to Signing & Capabilities
# 4. Enable "Automatically manage signing"
# 5. Select your Apple Developer team

# Or configure manually in project.pbxproj
# Set DEVELOPMENT_TEAM = YOUR_TEAM_ID;
```

#### Issue: Swift Version Conflicts

```bash
# Error message
Module compiled with Swift 5.7 cannot be imported by the Swift 5.9 compiler
```

**Solution:**

```ruby
# ios/Podfile
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '5.9'
    end
  end
end
```

### 3. Simulator Issues

#### Issue: Simulator Not Found

```bash
# Error message
No iOS devices available
```

**Solution:**

```bash
# List available simulators
xcrun simctl list devices

# Create new simulator if needed
xcrun simctl create "iPhone 15 Pro" "iPhone 15 Pro" "iOS 17.0"

# Boot simulator
xcrun simctl boot "iPhone 15 Pro"

# Open Simulator app
open -a Simulator

# Reset simulator if corrupted
xcrun simctl erase "iPhone 15 Pro"
```

## Web Build Issues

### 1. Compilation Errors

#### Issue: Web Compilation Fails

```bash
# Error message
Failed to compile application for the Web.
```

**Solution:**

```bash
# Clean web build
flutter clean
flutter pub get

# Build with verbose output
flutter build web --verbose

# Check for web-incompatible packages
flutter pub deps | grep -E "(dart:io|dart:isolate)"

# Use web-compatible alternatives
# Replace dart:io with universal_io
# Replace dart:isolate with web workers
```

#### Issue: CORS Errors in Development

```bash
# Error message
Access to fetch at 'https://api.example.com' from origin 'http://localhost:port' has been blocked by CORS policy
```

**Solution:**

```bash
# Run with CORS disabled (development only)
flutter run -d chrome --web-browser-flag "--disable-web-security"

# Or configure your API server to allow CORS
# Add appropriate headers:
# Access-Control-Allow-Origin: *
# Access-Control-Allow-Methods: GET, POST, PUT, DELETE
# Access-Control-Allow-Headers: Content-Type, Authorization
```

### 2. Asset Loading Issues

#### Issue: Assets Not Loading in Web

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/images/
    - assets/fonts/
```

**Solution:**

```dart
// Use proper asset paths for web
class WebAssets {
  static String getAssetPath(String assetPath) {
    if (kIsWeb) {
      return 'assets/$assetPath';
    }
    return assetPath;
  }
}

// Usage
Image.asset(WebAssets.getAssetPath('images/logo.png'))
```

## Desktop Build Issues

### 1. Linux Build Issues

#### Issue: Missing Dependencies

```bash
# Error message
CMake Error: Could not find a package configuration file provided by "PkgConfig"
```

**Solution:**

```bash
# Install required dependencies
sudo apt-get update
sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev

# Enable Linux desktop
flutter config --enable-linux-desktop

# Build for Linux
flutter build linux
```

### 2. Windows Build Issues

#### Issue: Visual Studio Build Tools Missing

```bash
# Error message
Visual Studio build tools not found
```

**Solution:**

```bash
# Install Visual Studio Build Tools
# Download from: https://visualstudio.microsoft.com/downloads/

# Or install Visual Studio Community with C++ workload

# Enable Windows desktop
flutter config --enable-windows-desktop

# Build for Windows
flutter build windows
```

### 3. macOS Build Issues

#### Issue: macOS Entitlements

```bash
# Error message
App Sandbox not enabled
```

**Solution:**

```xml
<!-- macos/Runner/DebugProfile.entitlements -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>
</dict>
</plist>
```

## Build Optimization Issues

### 1. Large App Size

#### Issue: APK/IPA Too Large

**Analysis:**

```bash
# Analyze APK size
flutter build apk --analyze-size

# Analyze app bundle
flutter build appbundle --analyze-size

# Check asset sizes
find assets -type f -exec ls -lh {} \; | sort -k5 -hr
```

**Solution:**

```yaml
# pubspec.yaml - Optimize assets
flutter:
  assets:
    - assets/images/2.0x/  # Only include necessary resolutions
    - assets/images/3.0x/
  
  # Use vector graphics when possible
  # Compress images before adding to assets
```

```gradle
// android/app/build.gradle - Enable R8 and resource shrinking
android {
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
    
    // Split APKs by ABI
    splits {
        abi {
            enable true
            reset()
            include 'x86', 'x86_64', 'arm64-v8a', 'armeabi-v7a'
            universalApk false
        }
    }
}
```

### 2. Slow Build Times

#### Issue: Long Build Duration

**Solution:**

```bash
# Enable Gradle daemon
echo "org.gradle.daemon=true" >> ~/.gradle/gradle.properties
echo "org.gradle.parallel=true" >> ~/.gradle/gradle.properties
echo "org.gradle.configureondemand=true" >> ~/.gradle/gradle.properties

# Increase Gradle memory
echo "org.gradle.jvmargs=-Xmx4g -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8" >> ~/.gradle/gradle.properties

# Use build cache
flutter config --build-dir=build
```

## Debugging Build Issues

### 1. Verbose Build Output

```bash
# Flutter verbose build
flutter build apk --verbose
flutter build ios --verbose
flutter build web --verbose

# Gradle verbose build
cd android
./gradlew assembleRelease --stacktrace --info

# Xcode verbose build
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -configuration Release -destination generic/platform=iOS build -verbose
```

### 2. Build Analysis Tools

```bash
# Flutter build analysis
flutter analyze
flutter test
flutter doctor -v

# Android build analysis
cd android
./gradlew build --scan

# iOS build analysis
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner analyze
```

### 3. Common Build Commands

```bash
# Clean everything
flutter clean
cd android && ./gradlew clean && cd ..
cd ios && rm -rf Pods && pod install && cd ..

# Reset Flutter
flutter channel stable
flutter upgrade
flutter doctor

# Reset development environment
rm -rf ~/.gradle/caches
rm -rf ~/.pub-cache
flutter pub cache repair
```

Remember to always backup your project before making significant build configuration changes, and test builds on different devices and environments to ensure compatibility.
