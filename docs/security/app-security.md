# Application Security

Comprehensive guide to implementing security measures in Flutter applications to protect against common vulnerabilities and threats.

## Overview

Application security encompasses protecting the app from various threats including reverse engineering, tampering, data theft, and malicious attacks. This guide covers security best practices for Flutter apps.

## Code Obfuscation & Protection

### 1. Code Obfuscation

```bash
# Build with obfuscation enabled
flutter build apk --obfuscate --split-debug-info=build/debug-info
flutter build ios --obfuscate --split-debug-info=build/debug-info

# For release builds
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
flutter build ios --release --obfuscate --split-debug-info=build/debug-info
```

### 2. ProGuard Configuration (Android)

```proguard
# android/app/proguard-rules.pro

# Keep Flutter classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep app-specific classes
-keep class com.yourapp.** { *; }

# Obfuscate everything else
-obfuscate
-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*

# Remove debug information
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}
```

## Root/Jailbreak Detection

### 1. Root Detection Service

```dart
// lib/services/security_service.dart
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:device_info_plus/device_info_plus.dart';

class SecurityService {
  static Future<SecurityStatus> checkDeviceSecurity() async {
    final isJailbroken = await FlutterJailbreakDetection.jailbroken;
    final isDeveloperMode = await FlutterJailbreakDetation.developerMode;
    final isRealDevice = await FlutterJailbreakDetection.isRealDevice;
    
    return SecurityStatus(
      isJailbroken: isJailbroken,
      isDeveloperMode: isDeveloperMode,
      isRealDevice: isRealDevice,
      isSecure: !isJailbroken && !isDeveloperMode && isRealDevice,
    );
  }
  
  static Future<bool> isRunningOnEmulator() async {
    final deviceInfo = DeviceInfoPlugin();
    
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.isPhysicalDevice == false;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.isPhysicalDevice == false;
    }
    
    return false;
  }
  
  static Future<void> handleInsecureDevice(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Security Warning'),
        content: const Text(
          'This app cannot run on rooted/jailbroken devices or emulators '
          'for security reasons.',
        ),
        actions: [
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}

class SecurityStatus {
  final bool isJailbroken;
  final bool isDeveloperMode;
  final bool isRealDevice;
  final bool isSecure;
  
  const SecurityStatus({
    required this.isJailbroken,
    required this.isDeveloperMode,
    required this.isRealDevice,
    required this.isSecure,
  });
}
```

### 2. Security Guard Widget

```dart
// lib/widgets/security_guard.dart
class SecurityGuard extends StatefulWidget {
  final Widget child;
  final bool enforceSecurityChecks;
  
  const SecurityGuard({
    Key? key,
    required this.child,
    this.enforceSecurityChecks = true,
  }) : super(key: key);
  
  @override
  _SecurityGuardState createState() => _SecurityGuardState();
}

class _SecurityGuardState extends State<SecurityGuard> {
  bool _isSecure = false;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _checkSecurity();
  }
  
  Future<void> _checkSecurity() async {
    if (!widget.enforceSecurityChecks) {
      setState(() {
        _isSecure = true;
        _isLoading = false;
      });
      return;
    }
    
    try {
      final securityStatus = await SecurityService.checkDeviceSecurity();
      
      setState(() {
        _isSecure = securityStatus.isSecure;
        _isLoading = false;
      });
      
      if (!_isSecure) {
        await SecurityService.handleInsecureDevice(context);
      }
    } catch (e) {
      // If security check fails, assume secure in production
      setState(() {
        _isSecure = !kDebugMode;
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (!_isSecure) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.security,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Security Check Failed',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'This app cannot run on this device for security reasons.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => SystemNavigator.pop(),
                child: const Text('Exit'),
              ),
            ],
          ),
        ),
      );
    }
    
    return widget.child;
  }
}
```

## Biometric Authentication

### 1. Biometric Service

```dart
// lib/services/biometric_service.dart
import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  
  // Check if biometrics are available
  static Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }
  
  // Get available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }
  
  // Authenticate with biometrics
  static Future<bool> authenticateWithBiometrics({
    String localizedReason = 'Please authenticate to continue',
    bool useErrorDialogs = true,
    bool stickyAuth = false,
  }) async {
    try {
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: true,
        ),
      );
      
      return isAuthenticated;
    } catch (e) {
      return false;
    }
  }
  
  // Check if user has enrolled biometrics
  static Future<bool> hasEnrolledBiometrics() async {
    final availableBiometrics = await getAvailableBiometrics();
    return availableBiometrics.isNotEmpty;
  }
  
  // Get biometric type string
  static String getBiometricTypeString(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (types.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (types.contains(BiometricType.iris)) {
      return 'Iris';
    } else {
      return 'Biometric';
    }
  }
}
```

### 2. Biometric Authentication Widget

```dart
// lib/widgets/biometric_auth_widget.dart
class BiometricAuthWidget extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback? onFailure;
  final String title;
  final String subtitle;
  
  const BiometricAuthWidget({
    Key? key,
    required this.onSuccess,
    this.onFailure,
    this.title = 'Biometric Authentication',
    this.subtitle = 'Use your biometric to authenticate',
  }) : super(key: key);
  
  @override
  _BiometricAuthWidgetState createState() => _BiometricAuthWidgetState();
}

class _BiometricAuthWidgetState extends State<BiometricAuthWidget> {
  bool _isAuthenticating = false;
  String _biometricType = 'Biometric';
  
  @override
  void initState() {
    super.initState();
    _initializeBiometric();
  }
  
  Future<void> _initializeBiometric() async {
    final availableBiometrics = await BiometricService.getAvailableBiometrics();
    setState(() {
      _biometricType = BiometricService.getBiometricTypeString(availableBiometrics);
    });
  }
  
  Future<void> _authenticate() async {
    setState(() {
      _isAuthenticating = true;
    });
    
    try {
      final isAuthenticated = await BiometricService.authenticateWithBiometrics(
        localizedReason: 'Please verify your identity to continue',
      );
      
      if (isAuthenticated) {
        widget.onSuccess();
      } else {
        widget.onFailure?.call();
      }
    } catch (e) {
      widget.onFailure?.call();
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getBiometricIcon(),
              size: 64,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isAuthenticating ? null : _authenticate,
                child: _isAuthenticating
                    ? const CircularProgressIndicator()
                    : Text('Use $_biometricType'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getBiometricIcon() {
    switch (_biometricType) {
      case 'Face ID':
        return Icons.face;
      case 'Fingerprint':
        return Icons.fingerprint;
      default:
        return Icons.security;
    }
  }
}
```

## App Integrity & Tampering Detection

### 1. Integrity Checker

```dart
// lib/services/integrity_service.dart
import 'package:crypto/crypto.dart';

class IntegrityService {
  // Check app signature (Android)
  static Future<bool> verifyAppSignature() async {
    if (!Platform.isAndroid) return true;
    
    try {
      // This would require platform-specific implementation
      // to check the app's signing certificate
      return await _checkAndroidSignature();
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> _checkAndroidSignature() async {
    // Platform-specific implementation needed
    // This is a placeholder for the actual signature verification
    return true;
  }
  
  // Check if app is running in debug mode
  static bool isDebugMode() {
    return kDebugMode;
  }
  
  // Check for suspicious modifications
  static Future<bool> checkAppIntegrity() async {
    // Check if running on emulator
    final isEmulator = await SecurityService.isRunningOnEmulator();
    if (isEmulator && !kDebugMode) return false;
    
    // Check app signature
    final validSignature = await verifyAppSignature();
    if (!validSignature) return false;
    
    // Check for debugging tools
    final hasDebuggingTools = await _checkForDebuggingTools();
    if (hasDebuggingTools && !kDebugMode) return false;
    
    return true;
  }
  
  static Future<bool> _checkForDebuggingTools() async {
    // Check for common debugging tools and frameworks
    // This is a simplified check
    try {
      // Check for Frida, Xposed, etc.
      // Platform-specific implementation needed
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Generate app checksum
  static Future<String> generateAppChecksum() async {
    try {
      // Get app binary data and generate checksum
      // This requires platform-specific implementation
      final appData = await _getAppBinaryData();
      final digest = sha256.convert(appData);
      return digest.toString();
    } catch (e) {
      return '';
    }
  }
  
  static Future<List<int>> _getAppBinaryData() async {
    // Platform-specific implementation to get app binary
    // This is a placeholder
    return [];
  }
}
```

### 2. Anti-Tampering Measures

```dart
// lib/services/anti_tampering_service.dart
class AntiTamperingService {
  static const String _expectedChecksum = 'your_app_checksum_here';
  
  // Verify app hasn't been modified
  static Future<bool> verifyAppIntegrity() async {
    final currentChecksum = await IntegrityService.generateAppChecksum();
    return currentChecksum == _expectedChecksum;
  }
  
  // Check for hooking frameworks
  static Future<bool> detectHooking() async {
    try {
      // Check for common hooking frameworks
      final hasXposed = await _checkForXposed();
      final hasFrida = await _checkForFrida();
      final hasSubstrate = await _checkForSubstrate();
      
      return hasXposed || hasFrida || hasSubstrate;
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> _checkForXposed() async {
    // Check for Xposed framework
    try {
      // Platform-specific implementation
      return false;
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> _checkForFrida() async {
    // Check for Frida framework
    try {
      // Look for Frida-related files and processes
      return false;
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> _checkForSubstrate() async {
    // Check for Substrate framework (iOS)
    try {
      // Platform-specific implementation
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Runtime application self-protection
  static void enableRASP() {
    // Implement runtime protection measures
    _enableAntiDebugging();
    _enableAntiHooking();
    _enableIntegrityChecks();
  }
  
  static void _enableAntiDebugging() {
    // Implement anti-debugging measures
    if (kDebugMode) return;
    
    // Check for debugger attachment
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_isDebuggerAttached()) {
        SystemNavigator.pop();
      }
    });
  }
  
  static bool _isDebuggerAttached() {
    // Platform-specific debugger detection
    return false;
  }
  
  static void _enableAntiHooking() {
    // Implement anti-hooking measures
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (await detectHooking()) {
        SystemNavigator.pop();
      }
    });
  }
  
  static void _enableIntegrityChecks() {
    // Periodic integrity checks
    Timer.periodic(const Duration(minutes: 5), (timer) async {
      if (!await verifyAppIntegrity()) {
        SystemNavigator.pop();
      }
    });
  }
}
```

## Secure Communication

### 1. Certificate Pinning

```dart
// lib/services/certificate_pinning_service.dart
import 'package:dio_certificate_pinning/dio_certificate_pinning.dart';

class CertificatePinningService {
  static Dio createPinnedClient() {
    final dio = Dio();
    
    // Add certificate pinning interceptor
    dio.interceptors.add(
      CertificatePinningInterceptor(
        allowedSHAFingerprints: [
          // Add your server's certificate fingerprints
          'SHA256:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
          'SHA256:BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=',
        ],
      ),
    );
    
    return dio;
  }
  
  // Verify certificate manually
  static bool verifyCertificate(X509Certificate cert) {
    final fingerprint = _getCertificateFingerprint(cert);
    final allowedFingerprints = [
      'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
      'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=',
    ];
    
    return allowedFingerprints.contains(fingerprint);
  }
  
  static String _getCertificateFingerprint(X509Certificate cert) {
    final bytes = cert.der;
    final digest = sha256.convert(bytes);
    return base64.encode(digest.bytes);
  }
}
```

## Security Testing

### 1. Security Test Suite

```dart
// test/security/security_test.dart
void main() {
  group('Security Tests', () {
    test('should detect insecure device', () async {
      // Mock jailbroken device
      when(FlutterJailbreakDetection.jailbroken).thenAnswer((_) async => true);
      
      final securityStatus = await SecurityService.checkDeviceSecurity();
      expect(securityStatus.isSecure, isFalse);
    });
    
    test('should verify app integrity', () async {
      final isIntact = await IntegrityService.checkAppIntegrity();
      expect(isIntact, isTrue);
    });
    
    test('should detect debugging tools', () async {
      final hasDebuggingTools = await AntiTamperingService.detectHooking();
      expect(hasDebuggingTools, isFalse);
    });
    
    test('should validate certificate pinning', () {
      final mockCert = MockX509Certificate();
      when(mockCert.der).thenReturn([1, 2, 3, 4, 5]);
      
      final isValid = CertificatePinningService.verifyCertificate(mockCert);
      expect(isValid, isA<bool>());
    });
  });
}
```

Application security requires a multi-layered approach. Implement multiple security measures, regularly update them, and always assume that determined attackers will find ways to bypass individual protections.
