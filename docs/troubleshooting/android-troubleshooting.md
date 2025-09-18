# Android Troubleshooting Guide

Common Android development issues and solutions for Flutter projects.

## Build Issues

### 1. Gradle Build Failures

**Problem**: `FAILURE: Build failed with an exception`

**Solutions**:
```bash
# Clean and rebuild
flutter clean
cd android
./gradlew clean
cd ..
flutter build apk

# Update Gradle wrapper
cd android
./gradlew wrapper --gradle-version=8.0
```

### 2. Dependency Conflicts

**Problem**: `Duplicate class` or `More than one file was found with OS independent path`

**Solution**:
```gradle
// android/app/build.gradle
android {
    packagingOptions {
        pickFirst '**/libc++_shared.so'
        pickFirst '**/libjsc.so'
        exclude 'META-INF/DEPENDENCIES'
        exclude 'META-INF/LICENSE'
        exclude 'META-INF/LICENSE.txt'
        exclude 'META-INF/NOTICE'
        exclude 'META-INF/NOTICE.txt'
    }
}
```

### 3. Minimum SDK Version Issues

**Problem**: `uses-sdk:minSdkVersion 16 cannot be smaller than version 21`

**Solution**:
```gradle
// android/app/build.gradle
android {
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
        compileSdkVersion 34
    }
}
```

## Runtime Issues

### 1. App Crashes on Launch

**Problem**: App crashes immediately after launch

**Debugging**:
```bash
# Check device logs
flutter logs

# Run with verbose logging
flutter run --verbose

# Check Android logcat
adb logcat | grep flutter
```

### 2. Permission Issues

**Problem**: Permissions not working on Android

**Solution**:
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

### 3. Network Security Issues

**Problem**: Network requests fail on Android 9+

**Solution**:
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<application
    android:usesCleartextTraffic="true"
    android:networkSecurityConfig="@xml/network_security_config">
    
<!-- android/app/src/main/res/xml/network_security_config.xml -->
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">your-api-domain.com</domain>
    </domain-config>
</network-security-config>
```

## Performance Issues

### 1. Slow Build Times

**Solutions**:
```gradle
// android/gradle.properties
org.gradle.jvmargs=-Xmx4g -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8
org.gradle.parallel=true
org.gradle.configureondemand=true
org.gradle.daemon=true
android.useAndroidX=true
android.enableJetifier=true
```

### 2. Large APK Size

**Solutions**:
```bash
# Build with tree shaking
flutter build apk --release --tree-shake-icons

# Build app bundle
flutter build appbundle --release

# Analyze APK size
flutter build apk --analyze-size
```

## Device-Specific Issues

### 1. Emulator Issues

**Problem**: Android emulator not starting or slow

**Solutions**:
```bash
# List available emulators
flutter emulators

# Start specific emulator
flutter emulators --launch Pixel_4_API_30

# Create new emulator
avdmanager create avd -n test_emulator -k "system-images;android-30;google_apis;x86_64"
```

### 2. Physical Device Issues

**Problem**: Device not detected

**Solutions**:
```bash
# Check device connection
adb devices

# Enable USB debugging on device
# Settings > Developer options > USB debugging

# Install ADB drivers (Windows)
# Download from Android SDK Manager
```

## Common Error Messages

### 1. "Could not resolve all artifacts"

**Solution**:
```gradle
// android/build.gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://jitpack.io' }
    }
}
```

### 2. "Execution failed for task ':app:processDebugResources'"

**Solution**:
```bash
# Clean and rebuild
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
flutter build apk
```

### 3. "Android license status unknown"

**Solution**:
```bash
# Accept Android licenses
flutter doctor --android-licenses
```

## Quick Fixes

### Reset Everything
```bash
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
flutter run
```

### Update Dependencies
```bash
flutter pub upgrade
cd android
./gradlew wrapper --gradle-version=latest
```

### Check Configuration
```bash
flutter doctor -v
flutter config --android-sdk /path/to/android/sdk
```
