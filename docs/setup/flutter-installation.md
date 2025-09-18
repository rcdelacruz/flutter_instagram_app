# Flutter Installation Guide

Complete guide for installing Flutter and setting up your development environment for the Instagram Clone project.

## Overview

This guide will help you install Flutter and set up your development environment on macOS, Windows, and Linux. Follow the steps for your operating system to get started with Flutter development.

## Prerequisites

### System Requirements

**macOS**:
- macOS 10.14 (Mojave) or later
- Disk space: 2.8 GB (does not include disk space for IDE/tools)
- Tools: bash, curl, file, git 2.x, mkdir, rm, unzip, which, zip

**Windows**:
- Windows 10 or later (64-bit), x86-64 based
- Disk space: 1.64 GB (does not include disk space for IDE/tools)
- Tools: PowerShell 5.0 or newer, Git for Windows 2.x

**Linux**:
- 64-bit distribution
- Disk space: 600 MB (does not include disk space for IDE/tools)
- Tools: bash, curl, file, git 2.x, mkdir, rm, unzip, which, xz-utils, zip, libglu1-mesa

## macOS Installation

### Step 1: Download Flutter SDK

1. Download the latest stable Flutter SDK:
   ```bash
   cd ~/development
   curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.35.0-stable.zip
   unzip flutter_macos_3.35.0-stable.zip
   ```

2. Add Flutter to your PATH:
   ```bash
   export PATH="$PATH:`pwd`/flutter/bin"
   ```

3. Make the PATH change permanent:
   ```bash
   echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zshrc
   source ~/.zshrc
   ```

### Step 2: Install Xcode

1. Install Xcode from the App Store or Apple Developer site
2. Configure Xcode command-line tools:
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   ```

3. Accept the Xcode license:
   ```bash
   sudo xcodebuild -license accept
   ```

### Step 3: Install CocoaPods

```bash
sudo gem install cocoapods
```

### Step 4: Set up iOS Simulator

1. Open Xcode
2. Go to Xcode > Preferences > Components
3. Install an iOS Simulator

## Windows Installation

### Step 1: Download Flutter SDK

1. Download the Flutter SDK from [flutter.dev](https://docs.flutter.dev/get-started/install/windows)
2. Extract the zip file to `C:\src\flutter`
3. Add Flutter to your PATH:
   - Search for "Environment Variables" in Windows search
   - Click "Environment Variables"
   - Under "User variables", find "Path" and click "Edit"
   - Click "New" and add `C:\src\flutter\bin`

### Step 2: Install Android Studio

1. Download and install [Android Studio](https://developer.android.com/studio)
2. Start Android Studio and go through the setup wizard
3. Install the Flutter and Dart plugins:
   - File > Settings > Plugins
   - Search for "Flutter" and install
   - Restart Android Studio

### Step 3: Set up Android Emulator

1. Open Android Studio
2. Go to Tools > AVD Manager
3. Click "Create Virtual Device"
4. Select a device and system image
5. Click "Finish"

## Linux Installation

### Step 1: Download Flutter SDK

1. Download the Flutter SDK:
   ```bash
   cd ~/development
   wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.35.0-stable.tar.xz
   tar xf flutter_linux_3.35.0-stable.tar.xz
   ```

2. Add Flutter to your PATH:
   ```bash
   export PATH="$PATH:`pwd`/flutter/bin"
   echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.bashrc
   source ~/.bashrc
   ```

### Step 2: Install Dependencies

```bash
sudo apt-get update
sudo apt-get install curl git unzip xz-utils zip libglu1-mesa
```

### Step 3: Install Android Studio

1. Download Android Studio from the official website
2. Extract and run:
   ```bash
   sudo tar -xzf android-studio-*.tar.gz -C /opt/
   /opt/android-studio/bin/studio.sh
   ```

## Development Environment Setup

### Install Visual Studio Code (Recommended)

1. Download and install [VS Code](https://code.visualstudio.com/)
2. Install Flutter extension:
   - Open VS Code
   - Go to Extensions (Ctrl+Shift+X)
   - Search for "Flutter" and install
   - This will also install the Dart extension

### Configure VS Code for Flutter

1. Open Command Palette (Ctrl+Shift+P)
2. Type "Flutter: New Project"
3. Select "Application"
4. Choose a location and project name

## Verify Installation

Run Flutter doctor to check your installation:

```bash
flutter doctor
```

You should see output similar to:
```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.35.0, on macOS 14.0 23A344 darwin-arm64, locale en-US)
[✓] Android toolchain - develop for Android devices (Android SDK version 34.0.0)
[✓] Xcode - develop for iOS and macOS (Xcode 15.0)
[✓] Chrome - develop for the web
[✓] Android Studio (version 2023.1)
[✓] VS Code (version 1.84.0)
[✓] Connected device (3 available)
[✓] Network resources
```

### Fix Common Issues

**Android License Issues**:
```bash
flutter doctor --android-licenses
```

**iOS Development Setup**:
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

**CocoaPods Issues on macOS**:
```bash
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export GEM_HOME="$HOME/.gem/ruby/3.4.0"
export GEM_PATH="$GEM_HOME"
export PATH="$GEM_HOME/bin:$PATH"
gem install cocoapods
```

## Create Your First Flutter App

Test your installation by creating a new Flutter app:

```bash
flutter create my_first_app
cd my_first_app
flutter run
```

## Device Setup

### iOS Device (macOS only)

1. Connect your iOS device via USB
2. Trust the computer on your device
3. In Xcode, go to Window > Devices and Simulators
4. Select your device and click "Use for Development"

### Android Device

1. Enable Developer Options on your Android device:
   - Go to Settings > About phone
   - Tap "Build number" 7 times
2. Enable USB Debugging:
   - Go to Settings > Developer options
   - Enable "USB debugging"
3. Connect your device via USB
4. Accept the USB debugging prompt

## Updating Flutter

Keep Flutter up to date:

```bash
flutter upgrade
```

Check for updates:
```bash
flutter --version
```

## IDE Configuration

### Android Studio Setup

1. Install Flutter and Dart plugins
2. Configure SDK paths:
   - File > Project Structure > SDKs
   - Add Flutter SDK path
3. Set up emulator:
   - Tools > AVD Manager
   - Create Virtual Device

### VS Code Setup

1. Install extensions:
   - Flutter
   - Dart
   - Flutter Widget Snippets (optional)
   - Awesome Flutter Snippets (optional)

2. Configure settings.json:
   ```json
   {
     "dart.flutterSdkPath": "/path/to/flutter",
     "dart.previewFlutterUiGuides": true,
     "dart.previewFlutterUiGuidesCustomTracking": true
   }
   ```

## Next Steps

After successful installation:

1. **Clone the Instagram Clone Project**:
   ```bash
   git clone https://github.com/rcdelacruz/flutter_instagram_app.git
   cd flutter_instagram_app
   flutter pub get
   ```

2. **Set up Supabase**: Follow the [Supabase Setup Guide](supabase-setup.md)

3. **Start Development**: Begin with the [Self-Paced Training Guide](../training/self-paced-training-guide.md)

## Troubleshooting

### Common Issues

**Flutter command not found**:
- Ensure Flutter is in your PATH
- Restart your terminal/IDE

**Android SDK not found**:
- Install Android Studio
- Run `flutter doctor --android-licenses`

**iOS build issues**:
- Update Xcode to latest version
- Run `pod install` in ios/ directory

**Permission denied errors**:
- Check file permissions
- Use `sudo` if necessary (not recommended for Flutter SDK)

### Getting Help

- [Flutter Documentation](https://docs.flutter.dev/)
- [Flutter Community](https://flutter.dev/community)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
- [Flutter Discord](https://discord.gg/flutter)

## Additional Resources

- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
- [Flutter Samples](https://github.com/flutter/samples)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Material Design Guidelines](https://material.io/design)

Your Flutter development environment is now ready!
