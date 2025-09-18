# Flutter Environment Setup

Complete guide to setting up your Flutter development environment for building production-grade applications.

## Prerequisites

### System Requirements

**macOS:**
- macOS 10.14 (Mojave) or later
- Xcode 12.0 or later
- CocoaPods 1.10.0 or later

**Windows:**
- Windows 10 64-bit or later
- Visual Studio 2019 or later (for Windows development)

**Linux:**
- 64-bit distribution
- Required libraries for development

### Hardware Requirements

- **RAM**: 8GB minimum, 16GB recommended
- **Storage**: 10GB free space minimum
- **Processor**: Intel i5 or equivalent

## Flutter SDK Installation

### Option 1: Using Package Managers (Recommended)

**macOS (Homebrew):**
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Flutter
brew install --cask flutter

# Add to PATH (add to ~/.zshrc or ~/.bash_profile)
export PATH="$PATH:/opt/homebrew/bin/flutter/bin"
```

**Windows (Chocolatey):**
```powershell
# Install Chocolatey if not already installed
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install Flutter
choco install flutter
```

**Linux (Snap):**
```bash
sudo snap install flutter --classic
```

### Option 2: Manual Installation

1. **Download Flutter SDK**
   - Visit [flutter.dev](https://flutter.dev/docs/get-started/install)
   - Download the appropriate SDK for your platform

2. **Extract and Setup PATH**
   ```bash
   # Extract to desired location
   cd ~/development
   unzip ~/Downloads/flutter_macos_3.35.4-stable.zip
   
   # Add to PATH
   export PATH="$PATH:`pwd`/flutter/bin"
   ```

3. **Verify Installation**
   ```bash
   flutter --version
   flutter doctor
   ```

## IDE Setup

### Visual Studio Code (Recommended)

1. **Install VS Code**
   - Download from [code.visualstudio.com](https://code.visualstudio.com/)

2. **Install Flutter Extensions**
   ```bash
   # Essential extensions
   code --install-extension Dart-Code.flutter
   code --install-extension Dart-Code.dart-code
   
   # Recommended extensions
   code --install-extension ms-vscode.vscode-json
   code --install-extension bradlc.vscode-tailwindcss
   code --install-extension usernamehw.errorlens
   code --install-extension ms-vscode.vscode-typescript-next
   ```

3. **Configure VS Code Settings**
   ```json
   {
     "dart.flutterSdkPath": "/path/to/flutter",
     "dart.previewFlutterUiGuides": true,
     "dart.previewFlutterUiGuidesCustomTracking": true,
     "editor.formatOnSave": true,
     "editor.codeActionsOnSave": {
       "source.fixAll": true
     },
     "dart.lineLength": 120
   }
   ```

### Android Studio

1. **Install Android Studio**
   - Download from [developer.android.com](https://developer.android.com/studio)

2. **Install Flutter Plugin**
   - Go to Preferences → Plugins
   - Search for "Flutter" and install
   - Restart Android Studio

## Platform Setup

### Android Development

1. **Install Android Studio**
   - Follow the installation wizard
   - Install Android SDK, Platform-Tools, and Build-Tools

2. **Configure Android SDK**
   ```bash
   # Add to ~/.zshrc or ~/.bash_profile
   export ANDROID_HOME=$HOME/Library/Android/sdk
   export PATH=$PATH:$ANDROID_HOME/emulator
   export PATH=$PATH:$ANDROID_HOME/tools
   export PATH=$PATH:$ANDROID_HOME/tools/bin
   export PATH=$PATH:$ANDROID_HOME/platform-tools
   ```

3. **Accept Android Licenses**
   ```bash
   flutter doctor --android-licenses
   ```

4. **Create Android Emulator**
   ```bash
   # List available system images
   avdmanager list
   
   # Create emulator
   avdmanager create avd -n flutter_emulator -k "system-images;android-33;google_apis;x86_64"
   
   # Start emulator
   emulator -avd flutter_emulator
   ```

### iOS Development (macOS only)

1. **Install Xcode**
   - Download from Mac App Store
   - Install Xcode Command Line Tools:
     ```bash
     sudo xcode-select --install
     ```

2. **Configure Xcode**
   ```bash
   # Open Xcode and accept license
   sudo xcodebuild -license accept
   
   # Install iOS Simulator
   sudo xcodebuild -downloadPlatform iOS
   ```

3. **Install CocoaPods**
   ```bash
   sudo gem install cocoapods
   ```

4. **Setup iOS Simulator**
   ```bash
   # List available simulators
   xcrun simctl list devices
   
   # Open iOS Simulator
   open -a Simulator
   ```

## Development Tools

### Git Configuration

```bash
# Configure Git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Set default branch name
git config --global init.defaultBranch main

# Configure line endings
git config --global core.autocrlf input  # macOS/Linux
git config --global core.autocrlf true   # Windows
```

### Package Managers

**macOS (Homebrew):**
```bash
# Install useful development tools
brew install git
brew install --cask sourcetree
brew install --cask postman
```

**Windows (Chocolatey):**
```powershell
# Install useful development tools
choco install git
choco install sourcetree
choco install postman
```

## Verification

### Run Flutter Doctor

```bash
flutter doctor -v
```

Expected output should show:
- ✅ Flutter (Channel stable, version 3.35.4)
- ✅ Android toolchain
- ✅ Xcode (macOS only)
- ✅ VS Code or Android Studio
- ✅ Connected device

### Create Test Project

```bash
# Create a test project
flutter create test_app
cd test_app

# Run the app
flutter run
```

## Troubleshooting

### Common Issues

**Flutter command not found:**
```bash
# Check PATH
echo $PATH

# Add Flutter to PATH
export PATH="$PATH:/path/to/flutter/bin"
```

**Android licenses not accepted:**
```bash
flutter doctor --android-licenses
```

**iOS development issues:**
```bash
# Reset iOS Simulator
xcrun simctl erase all

# Reinstall CocoaPods
sudo gem uninstall cocoapods
sudo gem install cocoapods
```

**Permission issues (macOS):**
```bash
# Fix permissions
sudo chown -R $(whoami) /usr/local/lib/node_modules
```

## Performance Optimization

### Development Settings

```bash
# Enable web support (if needed)
flutter config --enable-web

# Disable analytics (optional)
flutter config --no-analytics

# Set up pre-compilation
flutter config --enable-native-assets
```

### IDE Performance

**VS Code:**
- Disable unnecessary extensions
- Increase memory limit in settings
- Use workspace-specific settings

**Android Studio:**
- Increase heap size in studio.vmoptions
- Disable unused plugins
- Use hardware acceleration

## Next Steps

After completing the environment setup:

1. ✅ Verify all tools are working with `flutter doctor`
2. ✅ Create a test project and run it
3. ✅ Set up your preferred IDE with Flutter extensions
4. ✅ Configure version control (Git)
5. ✅ Proceed to [Project Structure](project-structure.md)

Your Flutter development environment is now ready for building production-grade applications!
