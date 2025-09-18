# Build Configuration

Comprehensive guide to configuring Flutter builds for different environments, platforms, and deployment scenarios.

## Overview

Build configuration involves setting up different build variants, managing environment variables, configuring signing, and optimizing builds for production. This guide covers all aspects of Flutter build configuration.

## Build Variants & Flavors

### 1. Android Build Flavors

```gradle
// android/app/build.gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.yourapp.flutter"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }
    
    flavorDimensions "environment"
    
    productFlavors {
        development {
            dimension "environment"
            applicationIdSuffix ".dev"
            versionNameSuffix "-dev"
            resValue "string", "app_name", "YourApp Dev"
            buildConfigField "String", "API_BASE_URL", '"https://dev-api.yourapp.com"'
            buildConfigField "String", "SUPABASE_URL", '"https://dev-project.supabase.co"'
            buildConfigField "boolean", "ENABLE_LOGGING", "true"
        }
        
        staging {
            dimension "environment"
            applicationIdSuffix ".staging"
            versionNameSuffix "-staging"
            resValue "string", "app_name", "YourApp Staging"
            buildConfigField "String", "API_BASE_URL", '"https://staging-api.yourapp.com"'
            buildConfigField "String", "SUPABASE_URL", '"https://staging-project.supabase.co"'
            buildConfigField "boolean", "ENABLE_LOGGING", "true"
        }
        
        production {
            dimension "environment"
            resValue "string", "app_name", "YourApp"
            buildConfigField "String", "API_BASE_URL", '"https://api.yourapp.com"'
            buildConfigField "String", "SUPABASE_URL", '"https://prod-project.supabase.co"'
            buildConfigField "boolean", "ENABLE_LOGGING", "false"
        }
    }
    
    buildTypes {
        debug {
            debuggable true
            minifyEnabled false
            shrinkResources false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
        
        release {
            debuggable false
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
            
            signingConfig signingConfigs.release
        }
    }
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
}
```

### 2. iOS Build Configurations

```ruby
# ios/Flutter/Release.xcconfig
#include "Generated.xcconfig"

// Environment-specific configurations
API_BASE_URL=https://api.yourapp.com
SUPABASE_URL=https://prod-project.supabase.co
ENABLE_LOGGING=NO

// App configuration
PRODUCT_BUNDLE_IDENTIFIER=com.yourapp.flutter
PRODUCT_NAME=YourApp
```

```ruby
# ios/Flutter/Debug.xcconfig
#include "Generated.xcconfig"

// Environment-specific configurations
API_BASE_URL=https://dev-api.yourapp.com
SUPABASE_URL=https://dev-project.supabase.co
ENABLE_LOGGING=YES

// App configuration
PRODUCT_BUNDLE_IDENTIFIER=com.yourapp.flutter.dev
PRODUCT_NAME=YourApp Dev
```

### 3. Flutter Build Configuration

```dart
// lib/config/build_config.dart
class BuildConfig {
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
  
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://dev-api.yourapp.com',
  );
  
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://dev-project.supabase.co',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );
  
  static const bool enableLogging = bool.fromEnvironment(
    'ENABLE_LOGGING',
    defaultValue: true,
  );
  
  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: false,
  );
  
  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'YourApp',
  );
  
  static const String buildNumber = String.fromEnvironment(
    'BUILD_NUMBER',
    defaultValue: '1',
  );
  
  static const String versionName = String.fromEnvironment(
    'VERSION_NAME',
    defaultValue: '1.0.0',
  );
  
  // Computed properties
  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';
  static bool get isStaging => environment == 'staging';
  static bool get isDebug => !isProduction;
}
```

## Environment Variables

### 1. Environment File Management

```bash
# .env.development
ENVIRONMENT=development
API_BASE_URL=https://dev-api.yourapp.com
SUPABASE_URL=https://dev-project.supabase.co
SUPABASE_ANON_KEY=your_dev_anon_key
ENABLE_LOGGING=true
ENABLE_ANALYTICS=false
APP_NAME=YourApp Dev
```

```bash
# .env.staging
ENVIRONMENT=staging
API_BASE_URL=https://staging-api.yourapp.com
SUPABASE_URL=https://staging-project.supabase.co
SUPABASE_ANON_KEY=your_staging_anon_key
ENABLE_LOGGING=true
ENABLE_ANALYTICS=true
APP_NAME=YourApp Staging
```

```bash
# .env.production
ENVIRONMENT=production
API_BASE_URL=https://api.yourapp.com
SUPABASE_URL=https://prod-project.supabase.co
SUPABASE_ANON_KEY=your_prod_anon_key
ENABLE_LOGGING=false
ENABLE_ANALYTICS=true
APP_NAME=YourApp
```

### 2. Environment Loader

```dart
// lib/config/environment_loader.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvironmentLoader {
  static Future<void> load() async {
    const environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
    
    try {
      await dotenv.load(fileName: '.env.$environment');
    } catch (e) {
      // Fallback to default environment file
      await dotenv.load(fileName: '.env.development');
    }
  }
  
  static String get(String key, {String defaultValue = ''}) {
    return dotenv.env[key] ?? 
           const String.fromEnvironment(key, defaultValue: '') ??
           defaultValue;
  }
  
  static bool getBool(String key, {bool defaultValue = false}) {
    final value = get(key).toLowerCase();
    return value == 'true' || value == '1';
  }
  
  static int getInt(String key, {int defaultValue = 0}) {
    return int.tryParse(get(key)) ?? defaultValue;
  }
}
```

## Build Scripts

### 1. Cross-Platform Build Script

```bash
#!/bin/bash
# scripts/build.sh

set -e

# Default values
ENVIRONMENT="development"
PLATFORM="android"
BUILD_TYPE="debug"
OUTPUT_DIR="build/outputs"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -e|--environment)
      ENVIRONMENT="$2"
      shift 2
      ;;
    -p|--platform)
      PLATFORM="$2"
      shift 2
      ;;
    -t|--type)
      BUILD_TYPE="$2"
      shift 2
      ;;
    -o|--output)
      OUTPUT_DIR="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [OPTIONS]"
      echo "Options:"
      echo "  -e, --environment  Environment (development, staging, production)"
      echo "  -p, --platform     Platform (android, ios, web, linux, macos, windows)"
      echo "  -t, --type         Build type (debug, release)"
      echo "  -o, --output       Output directory"
      echo "  -h, --help         Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

echo "Building for:"
echo "  Environment: $ENVIRONMENT"
echo "  Platform: $PLATFORM"
echo "  Build Type: $BUILD_TYPE"
echo "  Output: $OUTPUT_DIR"

# Load environment variables
if [ -f ".env.$ENVIRONMENT" ]; then
  export $(cat .env.$ENVIRONMENT | xargs)
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Build based on platform
case $PLATFORM in
  android)
    if [ "$BUILD_TYPE" = "release" ]; then
      flutter build appbundle --release \
        --dart-define=ENVIRONMENT=$ENVIRONMENT \
        --dart-define-from-file=.env.$ENVIRONMENT
      
      flutter build apk --release \
        --dart-define=ENVIRONMENT=$ENVIRONMENT \
        --dart-define-from-file=.env.$ENVIRONMENT
      
      # Copy outputs
      cp build/app/outputs/bundle/release/app-release.aab "$OUTPUT_DIR/"
      cp build/app/outputs/flutter-apk/app-release.apk "$OUTPUT_DIR/"
    else
      flutter build apk --debug \
        --dart-define=ENVIRONMENT=$ENVIRONMENT \
        --dart-define-from-file=.env.$ENVIRONMENT
      
      cp build/app/outputs/flutter-apk/app-debug.apk "$OUTPUT_DIR/"
    fi
    ;;
    
  ios)
    cd ios && pod install && cd ..
    
    if [ "$BUILD_TYPE" = "release" ]; then
      flutter build ios --release \
        --dart-define=ENVIRONMENT=$ENVIRONMENT \
        --dart-define-from-file=.env.$ENVIRONMENT
    else
      flutter build ios --debug \
        --dart-define=ENVIRONMENT=$ENVIRONMENT \
        --dart-define-from-file=.env.$ENVIRONMENT
    fi
    ;;
    
  web)
    flutter build web --release \
      --dart-define=ENVIRONMENT=$ENVIRONMENT \
      --dart-define-from-file=.env.$ENVIRONMENT
    
    # Copy web build
    cp -r build/web "$OUTPUT_DIR/"
    ;;
    
  linux)
    flutter build linux --release \
      --dart-define=ENVIRONMENT=$ENVIRONMENT \
      --dart-define-from-file=.env.$ENVIRONMENT
    
    # Package Linux app
    tar -czf "$OUTPUT_DIR/linux-app.tar.gz" -C build/linux/x64/release/bundle .
    ;;
    
  macos)
    flutter build macos --release \
      --dart-define=ENVIRONMENT=$ENVIRONMENT \
      --dart-define-from-file=.env.$ENVIRONMENT
    
    # Create DMG (requires create-dmg)
    if command -v create-dmg &> /dev/null; then
      create-dmg \
        --volname "YourApp" \
        --window-pos 200 120 \
        --window-size 600 300 \
        --icon-size 100 \
        --icon "YourApp.app" 175 120 \
        --hide-extension "YourApp.app" \
        --app-drop-link 425 120 \
        "$OUTPUT_DIR/YourApp.dmg" \
        "build/macos/Build/Products/Release/"
    fi
    ;;
    
  windows)
    flutter build windows --release \
      --dart-define=ENVIRONMENT=$ENVIRONMENT \
      --dart-define-from-file=.env.$ENVIRONMENT
    
    # Create ZIP archive
    cd build/windows/runner/Release && zip -r "../../../../$OUTPUT_DIR/windows-app.zip" . && cd ../../../..
    ;;
    
  *)
    echo "Unsupported platform: $PLATFORM"
    exit 1
    ;;
esac

echo "Build completed successfully!"
echo "Output directory: $OUTPUT_DIR"
```

### 2. Version Management Script

```bash
#!/bin/bash
# scripts/version.sh

set -e

VERSION_FILE="pubspec.yaml"
CURRENT_VERSION=$(grep "version:" $VERSION_FILE | sed 's/version: //' | tr -d ' ')

case $1 in
  major)
    NEW_VERSION=$(echo $CURRENT_VERSION | awk -F. '{print ($1+1)".0.0"}')
    ;;
  minor)
    NEW_VERSION=$(echo $CURRENT_VERSION | awk -F. '{print $1".".($2+1)".0"}')
    ;;
  patch)
    NEW_VERSION=$(echo $CURRENT_VERSION | awk -F. '{print $1"."$2".".($3+1)}')
    ;;
  *)
    if [ -n "$1" ]; then
      NEW_VERSION=$1
    else
      echo "Usage: $0 {major|minor|patch|x.y.z}"
      echo "Current version: $CURRENT_VERSION"
      exit 1
    fi
    ;;
esac

echo "Updating version from $CURRENT_VERSION to $NEW_VERSION"

# Update pubspec.yaml
sed -i.bak "s/version: $CURRENT_VERSION/version: $NEW_VERSION/" $VERSION_FILE
rm $VERSION_FILE.bak

# Update iOS version
if [ -f "ios/Runner/Info.plist" ]; then
  /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $NEW_VERSION" ios/Runner/Info.plist
  BUILD_NUMBER=$(echo $NEW_VERSION | tr -d '.')
  /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NUMBER" ios/Runner/Info.plist
fi

# Update Android version
if [ -f "android/app/build.gradle" ]; then
  VERSION_CODE=$(echo $NEW_VERSION | tr -d '.' | sed 's/^0*//')
  sed -i.bak "s/versionCode [0-9]*/versionCode $VERSION_CODE/" android/app/build.gradle
  sed -i.bak "s/versionName \".*\"/versionName \"$NEW_VERSION\"/" android/app/build.gradle
  rm android/app/build.gradle.bak
fi

echo "Version updated to $NEW_VERSION"
```

## Code Signing

### 1. Android Signing Configuration

```properties
# android/key.properties
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=your_key_alias
storeFile=../keystore.jks
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

### 2. iOS Signing Configuration

```bash
#!/bin/bash
# scripts/ios-signing.sh

# Setup code signing for iOS
security create-keychain -p "$KEYCHAIN_PASSWORD" build.keychain
security default-keychain -s build.keychain
security unlock-keychain -p "$KEYCHAIN_PASSWORD" build.keychain

# Import certificates
security import "$CERTIFICATE_PATH" -k build.keychain -P "$CERTIFICATE_PASSWORD" -T /usr/bin/codesign
security import "$PROVISIONING_PROFILE_PATH" -k build.keychain

# Set key partition list
security set-key-partition-list -S apple-tool:,apple: -s -k "$KEYCHAIN_PASSWORD" build.keychain
```

## Build Optimization

### 1. Android Optimization

```gradle
// android/app/build.gradle
android {
    buildTypes {
        release {
            // Enable code shrinking
            minifyEnabled true
            shrinkResources true
            
            // Enable ProGuard
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
            
            // Enable R8 full mode
            android.enableR8.fullMode = true
        }
    }
    
    // Enable multidex for large apps
    defaultConfig {
        multiDexEnabled true
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

### 2. Flutter Build Optimization

```bash
# Build with optimizations
flutter build apk --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --tree-shake-icons \
  --dart-define=flutter.inspector.structuredErrors=false

# Web optimization
flutter build web --release \
  --web-renderer canvaskit \
  --dart-define=flutter.web.canvaskit.url=https://unpkg.com/canvaskit-wasm@0.33.0/bin/ \
  --tree-shake-icons
```

### 3. Asset Optimization

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
  
  # Generate different resolutions
  generate: true

# Asset optimization script
find assets/images -name "*.png" -exec pngquant --force --ext .png {} \;
find assets/images -name "*.jpg" -exec jpegoptim --max=85 {} \;
```

## Build Monitoring

### 1. Build Metrics Collection

```dart
// lib/utils/build_metrics.dart
class BuildMetrics {
  static void recordBuildInfo() {
    final buildInfo = {
      'environment': BuildConfig.environment,
      'version': BuildConfig.versionName,
      'buildNumber': BuildConfig.buildNumber,
      'buildTime': DateTime.now().toIso8601String(),
      'platform': Platform.operatingSystem,
      'isDebug': kDebugMode,
    };
    
    // Send to analytics
    if (BuildConfig.enableAnalytics) {
      AnalyticsService.track('app_build_info', buildInfo);
    }
  }
}
```

### 2. Build Validation

```bash
#!/bin/bash
# scripts/validate-build.sh

set -e

echo "Validating build..."

# Check if required files exist
if [ ! -f "build/app/outputs/bundle/release/app-release.aab" ]; then
  echo "Error: AAB file not found"
  exit 1
fi

# Validate APK
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
  aapt dump badging build/app/outputs/flutter-apk/app-release.apk | grep "package:"
  echo "APK validation passed"
fi

# Check file sizes
AAB_SIZE=$(stat -f%z build/app/outputs/bundle/release/app-release.aab 2>/dev/null || stat -c%s build/app/outputs/bundle/release/app-release.aab)
MAX_SIZE=$((50 * 1024 * 1024)) # 50MB

if [ $AAB_SIZE -gt $MAX_SIZE ]; then
  echo "Warning: AAB size ($AAB_SIZE bytes) exceeds recommended limit"
fi

echo "Build validation completed"
```

Build configuration is crucial for managing different environments, optimizing performance, and ensuring consistent deployments. Implement proper environment management, signing, and optimization strategies for production-ready builds.
