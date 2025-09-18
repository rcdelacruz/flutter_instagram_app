# CI/CD Pipeline

Comprehensive guide to setting up Continuous Integration and Continuous Deployment pipelines for Flutter applications.

## Overview

CI/CD pipelines automate the build, test, and deployment process, ensuring consistent and reliable releases. This guide covers GitHub Actions, GitLab CI, and other popular CI/CD platforms.

## GitHub Actions

### 1. Basic Flutter Workflow

```yaml
# .github/workflows/flutter.yml
name: Flutter CI/CD

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.35.0'
        channel: 'stable'
    
    - name: Get dependencies
      run: flutter pub get
    
    - name: Verify formatting
      run: dart format --output=none --set-exit-if-changed .
    
    - name: Analyze project source
      run: flutter analyze
    
    - name: Run tests
      run: flutter test --coverage
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: coverage/lcov.info

  build-android:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.35.0'
        channel: 'stable'
    
    - name: Setup Java
      uses: actions/setup-java@v3
      with:
        distribution: 'zulu'
        java-version: '17'
    
    - name: Get dependencies
      run: flutter pub get
    
    - name: Decode keystore
      run: |
        echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/app/keystore.jks
    
    - name: Create key.properties
      run: |
        echo "storePassword=${{ secrets.KEYSTORE_PASSWORD }}" > android/key.properties
        echo "keyPassword=${{ secrets.KEY_PASSWORD }}" >> android/key.properties
        echo "keyAlias=${{ secrets.KEY_ALIAS }}" >> android/key.properties
        echo "storeFile=keystore.jks" >> android/key.properties
    
    - name: Build APK
      run: flutter build apk --release
    
    - name: Build App Bundle
      run: flutter build appbundle --release
    
    - name: Upload APK
      uses: actions/upload-artifact@v3
      with:
        name: release-apk
        path: build/app/outputs/flutter-apk/app-release.apk
    
    - name: Upload App Bundle
      uses: actions/upload-artifact@v3
      with:
        name: release-aab
        path: build/app/outputs/bundle/release/app-release.aab

  build-ios:
    needs: test
    runs-on: macos-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.35.0'
        channel: 'stable'
    
    - name: Get dependencies
      run: flutter pub get
    
    - name: Install CocoaPods
      run: |
        cd ios
        pod install
    
    - name: Build iOS
      run: |
        flutter build ios --release --no-codesign
    
    - name: Upload iOS build
      uses: actions/upload-artifact@v3
      with:
        name: ios-build
        path: build/ios/iphoneos/Runner.app

  deploy-android:
    needs: build-android
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Download App Bundle
      uses: actions/download-artifact@v3
      with:
        name: release-aab
    
    - name: Deploy to Play Store
      uses: r0adkll/upload-google-play@v1
      with:
        serviceAccountJsonPlainText: ${{ secrets.GOOGLE_PLAY_SERVICE_ACCOUNT }}
        packageName: com.yourapp.flutter
        releaseFiles: app-release.aab
        track: internal
        status: completed
```

### 2. Advanced Workflow with Matrix Strategy

```yaml
# .github/workflows/flutter-matrix.yml
name: Flutter Matrix Build

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        flutter-version: ['3.35.0', '3.34.0']
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: ${{ matrix.flutter-version }}
        channel: 'stable'
    
    - name: Get dependencies
      run: flutter pub get
    
    - name: Run tests
      run: flutter test
    
    - name: Build (Linux)
      if: matrix.os == 'ubuntu-latest'
      run: |
        sudo apt-get update -y
        sudo apt-get install -y ninja-build libgtk-3-dev
        flutter config --enable-linux-desktop
        flutter build linux
    
    - name: Build (macOS)
      if: matrix.os == 'macos-latest'
      run: |
        flutter config --enable-macos-desktop
        flutter build macos
    
    - name: Build (Windows)
      if: matrix.os == 'windows-latest'
      run: |
        flutter config --enable-windows-desktop
        flutter build windows

  integration-test:
    runs-on: macos-latest
    strategy:
      matrix:
        device:
          - "iPhone 15 Pro (17.0)"
          - "iPad Pro (12.9-inch) (6th generation) (17.0)"
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.35.0'
        channel: 'stable'
    
    - name: Get dependencies
      run: flutter pub get
    
    - name: Start iOS Simulator
      run: |
        xcrun simctl boot "${{ matrix.device }}" || true
    
    - name: Run integration tests
      run: flutter test integration_test/
```

## GitLab CI

### 1. GitLab CI Configuration

```yaml
# .gitlab-ci.yml
stages:
  - test
  - build
  - deploy

variables:
  FLUTTER_VERSION: "3.35.0"

before_script:
  - apt-get update -qq && apt-get install -y -qq git curl unzip
  - git clone https://github.com/flutter/flutter.git -b stable --depth 1
  - export PATH="$PATH:`pwd`/flutter/bin"
  - flutter doctor -v
  - flutter pub get

test:
  stage: test
  script:
    - flutter analyze
    - flutter test --coverage
  coverage: '/lines......: \d+\.\d+\%/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura.xml

build_android:
  stage: build
  script:
    - echo "$KEYSTORE_BASE64" | base64 -d > android/app/keystore.jks
    - echo "storePassword=$KEYSTORE_PASSWORD" > android/key.properties
    - echo "keyPassword=$KEY_PASSWORD" >> android/key.properties
    - echo "keyAlias=$KEY_ALIAS" >> android/key.properties
    - echo "storeFile=keystore.jks" >> android/key.properties
    - flutter build apk --release
    - flutter build appbundle --release
  artifacts:
    paths:
      - build/app/outputs/flutter-apk/app-release.apk
      - build/app/outputs/bundle/release/app-release.aab
    expire_in: 1 week
  only:
    - main

build_ios:
  stage: build
  tags:
    - macos
  script:
    - cd ios && pod install
    - flutter build ios --release --no-codesign
  artifacts:
    paths:
      - build/ios/iphoneos/Runner.app
    expire_in: 1 week
  only:
    - main

deploy_android:
  stage: deploy
  script:
    - echo "Deploying to Google Play Store"
    # Add your deployment script here
  dependencies:
    - build_android
  only:
    - main
  when: manual
```

## Fastlane Integration

### 1. Android Fastlane

```ruby
# android/fastlane/Fastfile
default_platform(:android)

platform :android do
  desc "Build and deploy to Google Play Store"
  lane :deploy do
    # Build the app
    sh("cd .. && flutter build appbundle --release")
    
    # Upload to Play Store
    upload_to_play_store(
      track: 'internal',
      aab: '../build/app/outputs/bundle/release/app-release.aab',
      skip_upload_apk: true,
      skip_upload_metadata: false,
      skip_upload_images: false,
      skip_upload_screenshots: false
    )
  end
  
  desc "Build and deploy to Firebase App Distribution"
  lane :distribute do
    # Build APK
    sh("cd .. && flutter build apk --release")
    
    # Upload to Firebase App Distribution
    firebase_app_distribution(
      app: ENV["FIREBASE_APP_ID"],
      apk_path: "../build/app/outputs/flutter-apk/app-release.apk",
      groups: "testers",
      release_notes: "New build from CI/CD pipeline"
    )
  end
  
  desc "Run tests"
  lane :test do
    sh("cd .. && flutter test")
  end
end
```

### 2. iOS Fastlane

```ruby
# ios/fastlane/Fastfile
default_platform(:ios)

platform :ios do
  desc "Build and deploy to App Store"
  lane :deploy do
    # Setup certificates and provisioning profiles
    setup_ci if ENV['CI']
    
    match(
      type: "appstore",
      readonly: true
    )
    
    # Build the app
    sh("cd .. && flutter build ios --release")
    
    # Build and upload to App Store
    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "Runner",
      export_method: "app-store",
      export_options: {
        provisioningProfiles: {
          "com.yourapp.flutter" => "match AppStore com.yourapp.flutter"
        }
      }
    )
    
    upload_to_app_store(
      skip_metadata: false,
      skip_screenshots: false,
      submit_for_review: false
    )
  end
  
  desc "Build and deploy to TestFlight"
  lane :beta do
    setup_ci if ENV['CI']
    
    match(
      type: "appstore",
      readonly: true
    )
    
    sh("cd .. && flutter build ios --release")
    
    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "Runner",
      export_method: "app-store"
    )
    
    upload_to_testflight(
      skip_waiting_for_build_processing: true
    )
  end
end
```

## Docker Integration

### 1. Dockerfile for Flutter

```dockerfile
# Dockerfile
FROM cirrusci/flutter:stable

WORKDIR /app

# Copy pubspec files
COPY pubspec.* ./

# Get dependencies
RUN flutter pub get

# Copy source code
COPY . .

# Build the app
RUN flutter build web --release

# Use nginx to serve the web app
FROM nginx:alpine
COPY --from=0 /app/build/web /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### 2. Docker Compose for Development

```yaml
# docker-compose.yml
version: '3.8'

services:
  flutter-app:
    build: .
    ports:
      - "8080:80"
    environment:
      - NODE_ENV=production
    
  flutter-dev:
    image: cirrusci/flutter:stable
    volumes:
      - .:/app
    working_dir: /app
    ports:
      - "3000:3000"
    command: flutter run -d web-server --web-port 3000 --web-hostname 0.0.0.0
```

## Environment Management

### 1. Environment Configuration

```dart
// lib/config/environment.dart
enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  static const Environment _environment = Environment.values.firstWhere(
    (env) => env.name == String.fromEnvironment('ENVIRONMENT', defaultValue: 'development'),
    orElse: () => Environment.development,
  );
  
  static Environment get environment => _environment;
  
  static String get apiBaseUrl {
    switch (_environment) {
      case Environment.development:
        return 'https://dev-api.yourapp.com';
      case Environment.staging:
        return 'https://staging-api.yourapp.com';
      case Environment.production:
        return 'https://api.yourapp.com';
    }
  }
  
  static String get supabaseUrl {
    switch (_environment) {
      case Environment.development:
        return 'https://dev-project.supabase.co';
      case Environment.staging:
        return 'https://staging-project.supabase.co';
      case Environment.production:
        return 'https://prod-project.supabase.co';
    }
  }
  
  static String get supabaseAnonKey {
    switch (_environment) {
      case Environment.development:
        return const String.fromEnvironment('SUPABASE_ANON_KEY_DEV');
      case Environment.staging:
        return const String.fromEnvironment('SUPABASE_ANON_KEY_STAGING');
      case Environment.production:
        return const String.fromEnvironment('SUPABASE_ANON_KEY_PROD');
    }
  }
  
  static bool get isProduction => _environment == Environment.production;
  static bool get isDevelopment => _environment == Environment.development;
  static bool get isStaging => _environment == Environment.staging;
}
```

### 2. Build Scripts

```bash
#!/bin/bash
# scripts/build.sh

set -e

ENVIRONMENT=${1:-development}
PLATFORM=${2:-android}

echo "Building for environment: $ENVIRONMENT, platform: $PLATFORM"

# Set environment variables
export ENVIRONMENT=$ENVIRONMENT

case $PLATFORM in
  android)
    if [ "$ENVIRONMENT" = "production" ]; then
      flutter build appbundle --release --dart-define=ENVIRONMENT=$ENVIRONMENT
    else
      flutter build apk --debug --dart-define=ENVIRONMENT=$ENVIRONMENT
    fi
    ;;
  ios)
    if [ "$ENVIRONMENT" = "production" ]; then
      flutter build ios --release --dart-define=ENVIRONMENT=$ENVIRONMENT
    else
      flutter build ios --debug --dart-define=ENVIRONMENT=$ENVIRONMENT
    fi
    ;;
  web)
    flutter build web --release --dart-define=ENVIRONMENT=$ENVIRONMENT
    ;;
  *)
    echo "Unknown platform: $PLATFORM"
    exit 1
    ;;
esac

echo "Build completed successfully!"
```

## Automated Testing in CI/CD

### 1. Test Configuration

```yaml
# .github/workflows/test.yml
name: Automated Testing

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.35.0'
    
    - name: Get dependencies
      run: flutter pub get
    
    - name: Run unit tests
      run: flutter test --coverage
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        file: coverage/lcov.info

  widget-tests:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.35.0'
    
    - name: Get dependencies
      run: flutter pub get
    
    - name: Run widget tests
      run: flutter test test/widget_test/
    
    - name: Generate golden files
      run: flutter test --update-goldens test/golden_test/

  integration-tests:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.35.0'
    
    - name: Get dependencies
      run: flutter pub get
    
    - name: Start iOS Simulator
      run: |
        xcrun simctl boot "iPhone 15 Pro" || true
    
    - name: Run integration tests
      run: flutter test integration_test/
```

## Deployment Strategies

### 1. Blue-Green Deployment

```yaml
# .github/workflows/blue-green-deploy.yml
name: Blue-Green Deployment

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.35.0'
    
    - name: Build web app
      run: flutter build web --release
    
    - name: Deploy to staging (Green)
      run: |
        # Deploy to green environment
        aws s3 sync build/web/ s3://your-app-green/
        aws cloudfront create-invalidation --distribution-id $GREEN_DISTRIBUTION_ID --paths "/*"
    
    - name: Run smoke tests
      run: |
        # Run smoke tests against green environment
        curl -f https://green.yourapp.com/health || exit 1
    
    - name: Switch traffic to green
      run: |
        # Switch traffic from blue to green
        aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --change-batch file://switch-to-green.json
    
    - name: Update blue environment
      run: |
        # Update blue environment for next deployment
        aws s3 sync build/web/ s3://your-app-blue/
        aws cloudfront create-invalidation --distribution-id $BLUE_DISTRIBUTION_ID --paths "/*"
```

### 2. Canary Deployment

```yaml
# .github/workflows/canary-deploy.yml
name: Canary Deployment

on:
  push:
    branches: [ main ]

jobs:
  canary-deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Build and deploy canary
      run: |
        flutter build web --release
        # Deploy to canary environment (5% traffic)
        aws s3 sync build/web/ s3://your-app-canary/
    
    - name: Monitor canary metrics
      run: |
        # Monitor error rates, response times, etc.
        python scripts/monitor_canary.py
    
    - name: Promote to production
      if: success()
      run: |
        # If canary is healthy, promote to production
        aws s3 sync build/web/ s3://your-app-prod/
        # Gradually increase traffic: 5% -> 25% -> 50% -> 100%
```

CI/CD pipelines ensure consistent, reliable, and automated deployments. Implement comprehensive testing, environment management, and deployment strategies to maintain high-quality releases.
