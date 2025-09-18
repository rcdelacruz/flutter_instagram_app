# Flutter Deployment Guide

Comprehensive guide for deploying Flutter applications to various platforms including iOS, Android, and Web.

## Pre-deployment Checklist

### 1. Code Quality
- [ ] All tests passing
- [ ] Code coverage > 80%
- [ ] No linting errors
- [ ] Performance optimized
- [ ] Security review completed

### 2. Configuration
- [ ] Environment variables configured
- [ ] API endpoints updated for production
- [ ] Analytics and crash reporting enabled
- [ ] App icons and splash screens added
- [ ] App metadata updated

### 3. Platform-Specific
- [ ] iOS: Certificates and provisioning profiles
- [ ] Android: Signing keys and Play Console setup
- [ ] Web: Hosting platform configured

## Android Deployment

### 1. App Signing

Create a keystore for release builds:

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Configure signing in `android/app/build.gradle`:

```gradle
android {
    ...
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
            minifyEnabled true
            useProguard true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

Create `android/key.properties`:

```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<location of the key store file>
```

### 2. Build Release APK/AAB

```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release

# Build with specific flavor
flutter build appbundle --release --flavor production
```

### 3. Google Play Store Deployment

1. **Create Play Console Account**
2. **Upload App Bundle**
3. **Configure Store Listing**
4. **Set up Release Management**
5. **Submit for Review**

### 4. Automated Deployment with GitHub Actions

```yaml
# .github/workflows/android-deploy.yml
name: Android Deploy

on:
  push:
    tags:
      - 'v*'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Java
        uses: actions/setup-java@v3
        with:
          distribution: 'zulu'
          java-version: '11'

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.35.0'

      - name: Get dependencies
        run: flutter pub get

      - name: Run tests
        run: flutter test

      - name: Build AAB
        run: flutter build appbundle --release

      - name: Upload to Play Store
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.SERVICE_ACCOUNT_JSON }}
          packageName: com.instagramapp.flutter
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: production
```

## iOS Deployment

### 1. Xcode Configuration

Open `ios/Runner.xcworkspace` in Xcode and configure:

- **Bundle Identifier**: Unique identifier for your app
- **Team**: Your Apple Developer Team
- **Deployment Target**: Minimum iOS version
- **App Icons**: Add all required icon sizes
- **Launch Screen**: Configure launch screen

### 2. Code Signing

Configure automatic signing in Xcode or manual signing:

```bash
# For manual signing, update ios/Runner.xcodeproj/project.pbxproj
DEVELOPMENT_TEAM = YOUR_TEAM_ID;
CODE_SIGN_STYLE = Manual;
PROVISIONING_PROFILE_SPECIFIER = "Your Provisioning Profile";
```

### 3. Build and Archive

```bash
# Build for iOS
flutter build ios --release

# Create archive in Xcode
# Product > Archive

# Or use command line
xcodebuild -workspace ios/Runner.xcworkspace \
           -scheme Runner \
           -configuration Release \
           -destination generic/platform=iOS \
           -archivePath build/Runner.xcarchive \
           archive
```

### 4. App Store Deployment

1. **Upload to App Store Connect**
2. **Configure App Information**
3. **Add Screenshots and Metadata**
4. **Submit for Review**

### 5. Automated iOS Deployment

```yaml
# .github/workflows/ios-deploy.yml
name: iOS Deploy

on:
  push:
    tags:
      - 'v*'

jobs:
  deploy:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.35.0'

      - name: Install dependencies
        run: flutter pub get

      - name: Run tests
        run: flutter test

      - name: Build iOS
        run: flutter build ios --release --no-codesign

      - name: Build and upload to App Store
        uses: yukiarrr/ios-build-action@v1.4.0
        with:
          project-path: ios/Runner.xcodeproj
          p12-base64: ${{ secrets.P12_BASE64 }}
          mobileprovision-base64: ${{ secrets.MOBILEPROVISION_BASE64 }}
          code-signing-identity: 'iPhone Distribution'
          team-id: ${{ secrets.TEAM_ID }}
          workspace-path: ios/Runner.xcworkspace
```

## Web Deployment

### 1. Build for Web

```bash
# Build web app
flutter build web --release

# Build with specific base href
flutter build web --base-href "/my-app/"

# Build with web renderer
flutter build web --web-renderer canvaskit
```

### 2. Firebase Hosting

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Initialize Firebase
firebase init hosting

# Deploy
firebase deploy
```

Firebase configuration (`firebase.json`):

```json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

### 3. GitHub Pages

```yaml
# .github/workflows/web-deploy.yml
name: Web Deploy

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.35.0'

      - name: Get dependencies
        run: flutter pub get

      - name: Build web
        run: flutter build web --base-href "/flutter_instagram_app/"

      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build/web
```

## Environment Configuration

### 1. Build Flavors

Configure different environments:

```dart
// lib/core/config/environment.dart
enum Environment { development, staging, production }

class EnvironmentConfig {
  static Environment get environment {
    const env = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
    switch (env) {
      case 'staging':
        return Environment.staging;
      case 'production':
        return Environment.production;
      default:
        return Environment.development;
    }
  }

  static String get apiBaseUrl {
    switch (environment) {
      case Environment.development:
        return 'https://dev-api.example.com';
      case Environment.staging:
        return 'https://staging-api.example.com';
      case Environment.production:
        return 'https://api.example.com';
    }
  }
}
```

Build with environment:

```bash
flutter build apk --release --dart-define=ENVIRONMENT=production
```

### 2. Secrets Management

Use environment variables for sensitive data:

```dart
// lib/core/config/secrets.dart
class Secrets {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
}
```

## Performance Optimization

### 1. Code Splitting

```dart
// Use deferred imports for large features
import 'package:flutter/material.dart';
import 'heavy_feature.dart' deferred as heavy;

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await heavy.loadLibrary();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => heavy.HeavyFeatureScreen()),
        );
      },
      child: Text('Load Heavy Feature'),
    );
  }
}
```

### 2. Asset Optimization

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/images/

  # Use different resolutions
  assets:
    - assets/images/logo.png
    - assets/images/2.0x/logo.png
    - assets/images/3.0x/logo.png
```

### 3. Build Optimization

```bash
# Enable tree shaking
flutter build apk --release --tree-shake-icons

# Optimize bundle size
flutter build appbundle --release --obfuscate --split-debug-info=debug-info/

# Analyze bundle size
flutter build apk --analyze-size
```

## Monitoring and Analytics

### 1. Crash Reporting

```dart
// lib/core/services/crash_service.dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class CrashService {
  static void initialize() {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  static void recordError(dynamic error, StackTrace? stack) {
    FirebaseCrashlytics.instance.recordError(error, stack);
  }
}
```

### 2. Performance Monitoring

```dart
// lib/core/services/performance_service.dart
import 'package:firebase_performance/firebase_performance.dart';

class PerformanceService {
  static Future<T> trace<T>(String name, Future<T> Function() operation) async {
    final trace = FirebasePerformance.instance.newTrace(name);
    await trace.start();

    try {
      final result = await operation();
      trace.setMetric('success', 1);
      return result;
    } catch (e) {
      trace.setMetric('error', 1);
      rethrow;
    } finally {
      await trace.stop();
    }
  }
}
```

## Security Considerations

### 1. Code Obfuscation

```bash
flutter build apk --release --obfuscate --split-debug-info=debug-info/
```

### 2. Certificate Pinning

```dart
// lib/core/network/certificate_pinning.dart
import 'package:dio_certificate_pinning/dio_certificate_pinning.dart';

class NetworkService {
  static Dio createDio() {
    final dio = Dio();

    dio.interceptors.add(
      CertificatePinningInterceptor(
        allowedSHAFingerprints: ['SHA256:XXXXXX'],
      ),
    );

    return dio;
  }
}
```

## Post-Deployment

### 1. Monitoring

- Set up crash reporting alerts
- Monitor app performance metrics
- Track user analytics
- Monitor API usage and errors

### 2. Updates

- Plan regular updates
- Use staged rollouts
- Monitor update adoption
- Maintain backward compatibility

### 3. Maintenance

- Regular security updates
- Performance optimizations
- Bug fixes and improvements
- Feature updates based on user feedback

## Next Steps

1. ✅ Configure your deployment pipelines
2. ✅ Set up monitoring and analytics
3. ✅ Plan your release strategy
4. ✅ Monitor post-deployment metrics
5. ✅ Your Flutter app is ready for production!

Your Flutter deployment strategy is now ready for reliable, automated releases!
