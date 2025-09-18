# Permissions Management

Comprehensive guide to handling permissions in Flutter applications across iOS, Android, and Web platforms.

## Overview

Permissions are essential for accessing device features like camera, location, storage, and notifications. This guide covers permission handling, best practices, and platform-specific implementations.

## Permission Setup

### 1. Permission Dependencies

```yaml
# pubspec.yaml
dependencies:
  permission_handler: ^11.0.1
  geolocator: ^9.0.2
  image_picker: ^1.0.4
  camera: ^0.10.5
  local_auth: ^2.1.6
```

### 2. Platform Configuration

#### iOS Configuration (ios/Runner/Info.plist)

```xml
<!-- Camera Permission -->
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take photos for posts</string>

<!-- Photo Library Permission -->
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to select images for posts</string>

<!-- Location Permission -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to show nearby content</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs location access to show nearby content</string>

<!-- Microphone Permission -->
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to record audio for posts</string>

<!-- Contacts Permission -->
<key>NSContactsUsageDescription</key>
<string>This app needs contacts access to find friends</string>

<!-- Notifications Permission -->
<key>NSUserNotificationUsageDescription</key>
<string>This app needs notification permission to send updates</string>

<!-- Biometric Permission -->
<key>NSFaceIDUsageDescription</key>
<string>This app uses Face ID for secure authentication</string>
```

#### Android Configuration (android/app/src/main/AndroidManifest.xml)

```xml
<!-- Internet Permission -->
<uses-permission android:name="android.permission.INTERNET" />

<!-- Camera Permission -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" android:required="false" />

<!-- Storage Permissions -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

<!-- Location Permissions -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<!-- Microphone Permission -->
<uses-permission android:name="android.permission.RECORD_AUDIO" />

<!-- Contacts Permission -->
<uses-permission android:name="android.permission.READ_CONTACTS" />

<!-- Notification Permission (Android 13+) -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

<!-- Biometric Permission -->
<uses-permission android:name="android.permission.USE_FINGERPRINT" />
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
```

## Permission Service

### 1. Permission Manager

```dart
// lib/services/permission_service.dart
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Check single permission
  static Future<bool> hasPermission(Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }
  
  // Request single permission
  static Future<bool> requestPermission(Permission permission) async {
    if (await hasPermission(permission)) {
      return true;
    }
    
    final status = await permission.request();
    return status.isGranted;
  }
  
  // Check multiple permissions
  static Future<Map<Permission, bool>> hasPermissions(List<Permission> permissions) async {
    final Map<Permission, bool> results = {};
    
    for (final permission in permissions) {
      results[permission] = await hasPermission(permission);
    }
    
    return results;
  }
  
  // Request multiple permissions
  static Future<Map<Permission, bool>> requestPermissions(List<Permission> permissions) async {
    final Map<Permission, bool> results = {};
    
    for (final permission in permissions) {
      results[permission] = await requestPermission(permission);
    }
    
    return results;
  }
  
  // Check if permission is permanently denied
  static Future<bool> isPermanentlyDenied(Permission permission) async {
    final status = await permission.status;
    return status.isPermanentlyDenied;
  }
  
  // Open app settings
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
```

### 2. Specific Permission Handlers

```dart
// lib/services/specific_permissions.dart
class CameraPermissionHandler {
  static Future<bool> requestCameraPermission() async {
    return await PermissionService.requestPermission(Permission.camera);
  }
  
  static Future<bool> hasCameraPermission() async {
    return await PermissionService.hasPermission(Permission.camera);
  }
  
  static Future<void> handleCameraPermission(BuildContext context) async {
    if (!await hasCameraPermission()) {
      final granted = await requestCameraPermission();
      
      if (!granted) {
        if (await PermissionService.isPermanentlyDenied(Permission.camera)) {
          _showPermissionDeniedDialog(context, 'Camera');
        } else {
          _showPermissionRequiredDialog(context, 'Camera');
        }
      }
    }
  }
  
  static void _showPermissionDeniedDialog(BuildContext context, String permission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permission Permission Required'),
        content: Text(
          '$permission permission is required for this feature. '
          'Please enable it in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              PermissionService.openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }
  
  static void _showPermissionRequiredDialog(BuildContext context, String permission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permission Permission Required'),
        content: Text('This app needs $permission permission to function properly.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class LocationPermissionHandler {
  static Future<bool> requestLocationPermission() async {
    return await PermissionService.requestPermission(Permission.location);
  }
  
  static Future<bool> hasLocationPermission() async {
    return await PermissionService.hasPermission(Permission.location);
  }
  
  static Future<LocationPermissionStatus> getLocationPermissionStatus() async {
    final status = await Permission.location.status;
    
    if (status.isGranted) return LocationPermissionStatus.granted;
    if (status.isDenied) return LocationPermissionStatus.denied;
    if (status.isPermanentlyDenied) return LocationPermissionStatus.permanentlyDenied;
    if (status.isRestricted) return LocationPermissionStatus.restricted;
    
    return LocationPermissionStatus.unknown;
  }
}

enum LocationPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  unknown,
}

class StoragePermissionHandler {
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Android 13+ uses different permissions
      if (await _isAndroid13OrHigher()) {
        return await PermissionService.requestPermissions([
          Permission.photos,
          Permission.videos,
        ]).then((results) => results.values.every((granted) => granted));
      } else {
        return await PermissionService.requestPermission(Permission.storage);
      }
    }
    
    // iOS uses photo library permission
    return await PermissionService.requestPermission(Permission.photos);
  }
  
  static Future<bool> hasStoragePermission() async {
    if (Platform.isAndroid) {
      if (await _isAndroid13OrHigher()) {
        final results = await PermissionService.hasPermissions([
          Permission.photos,
          Permission.videos,
        ]);
        return results.values.every((granted) => granted);
      } else {
        return await PermissionService.hasPermission(Permission.storage);
      }
    }
    
    return await PermissionService.hasPermission(Permission.photos);
  }
  
  static Future<bool> _isAndroid13OrHigher() async {
    if (!Platform.isAndroid) return false;
    
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt >= 33;
  }
}
```

## Permission Widgets

### 1. Permission Guard Widget

```dart
// lib/widgets/permission_guard.dart
class PermissionGuard extends StatefulWidget {
  final Permission permission;
  final Widget child;
  final Widget? fallback;
  final String? permissionName;
  final String? description;
  
  const PermissionGuard({
    Key? key,
    required this.permission,
    required this.child,
    this.fallback,
    this.permissionName,
    this.description,
  }) : super(key: key);
  
  @override
  _PermissionGuardState createState() => _PermissionGuardState();
}

class _PermissionGuardState extends State<PermissionGuard> {
  bool _hasPermission = false;
  bool _isLoading = true;
  bool _isPermanentlyDenied = false;
  
  @override
  void initState() {
    super.initState();
    _checkPermission();
  }
  
  Future<void> _checkPermission() async {
    final hasPermission = await PermissionService.hasPermission(widget.permission);
    final isPermanentlyDenied = await PermissionService.isPermanentlyDenied(widget.permission);
    
    setState(() {
      _hasPermission = hasPermission;
      _isPermanentlyDenied = isPermanentlyDenied;
      _isLoading = false;
    });
  }
  
  Future<void> _requestPermission() async {
    final granted = await PermissionService.requestPermission(widget.permission);
    
    setState(() {
      _hasPermission = granted;
    });
    
    if (!granted) {
      await _checkPermission(); // Check if permanently denied
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_hasPermission) {
      return widget.child;
    }
    
    return widget.fallback ?? _buildPermissionRequest();
  }
  
  Widget _buildPermissionRequest() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getPermissionIcon(),
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '${widget.permissionName ?? 'Permission'} Required',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.description ?? 
              'This feature requires ${widget.permissionName?.toLowerCase() ?? 'permission'} access.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_isPermanentlyDenied)
              ElevatedButton(
                onPressed: () => PermissionService.openAppSettings(),
                child: const Text('Open Settings'),
              )
            else
              ElevatedButton(
                onPressed: _requestPermission,
                child: const Text('Grant Permission'),
              ),
          ],
        ),
      ),
    );
  }
  
  IconData _getPermissionIcon() {
    switch (widget.permission) {
      case Permission.camera:
        return Icons.camera_alt;
      case Permission.location:
        return Icons.location_on;
      case Permission.microphone:
        return Icons.mic;
      case Permission.photos:
        return Icons.photo_library;
      case Permission.contacts:
        return Icons.contacts;
      default:
        return Icons.security;
    }
  }
}
```

### 2. Permission Status Widget

```dart
// lib/widgets/permission_status_widget.dart
class PermissionStatusWidget extends StatefulWidget {
  final List<Permission> permissions;
  
  const PermissionStatusWidget({
    Key? key,
    required this.permissions,
  }) : super(key: key);
  
  @override
  _PermissionStatusWidgetState createState() => _PermissionStatusWidgetState();
}

class _PermissionStatusWidgetState extends State<PermissionStatusWidget> {
  Map<Permission, PermissionStatus> _permissionStatuses = {};
  
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }
  
  Future<void> _checkPermissions() async {
    final Map<Permission, PermissionStatus> statuses = {};
    
    for (final permission in widget.permissions) {
      statuses[permission] = await permission.status;
    }
    
    setState(() {
      _permissionStatuses = statuses;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Permission Status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...widget.permissions.map((permission) {
              final status = _permissionStatuses[permission];
              return _buildPermissionRow(permission, status);
            }).toList(),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _checkPermissions,
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPermissionRow(Permission permission, PermissionStatus? status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            _getPermissionIcon(permission),
            size: 20,
            color: _getStatusColor(status),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(_getPermissionName(permission)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getStatusText(status),
              style: TextStyle(
                color: _getStatusColor(status),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getPermissionIcon(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return Icons.camera_alt;
      case Permission.location:
        return Icons.location_on;
      case Permission.microphone:
        return Icons.mic;
      case Permission.photos:
        return Icons.photo_library;
      case Permission.contacts:
        return Icons.contacts;
      case Permission.notification:
        return Icons.notifications;
      default:
        return Icons.security;
    }
  }
  
  String _getPermissionName(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return 'Camera';
      case Permission.location:
        return 'Location';
      case Permission.microphone:
        return 'Microphone';
      case Permission.photos:
        return 'Photos';
      case Permission.contacts:
        return 'Contacts';
      case Permission.notification:
        return 'Notifications';
      default:
        return permission.toString().split('.').last;
    }
  }
  
  Color _getStatusColor(PermissionStatus? status) {
    switch (status) {
      case PermissionStatus.granted:
        return Colors.green;
      case PermissionStatus.denied:
        return Colors.orange;
      case PermissionStatus.permanentlyDenied:
        return Colors.red;
      case PermissionStatus.restricted:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
  
  String _getStatusText(PermissionStatus? status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Granted';
      case PermissionStatus.denied:
        return 'Denied';
      case PermissionStatus.permanentlyDenied:
        return 'Blocked';
      case PermissionStatus.restricted:
        return 'Restricted';
      default:
        return 'Unknown';
    }
  }
}
```

## Permission Flows

### 1. Camera Permission Flow

```dart
// lib/flows/camera_permission_flow.dart
class CameraPermissionFlow {
  static Future<bool> requestCameraAccess(BuildContext context) async {
    // Check if already granted
    if (await CameraPermissionHandler.hasCameraPermission()) {
      return true;
    }
    
    // Show explanation dialog first
    final shouldRequest = await _showPermissionExplanation(context);
    if (!shouldRequest) return false;
    
    // Request permission
    final granted = await CameraPermissionHandler.requestCameraPermission();
    
    if (!granted) {
      // Check if permanently denied
      if (await PermissionService.isPermanentlyDenied(Permission.camera)) {
        await _showPermanentlyDeniedDialog(context);
      }
    }
    
    return granted;
  }
  
  static Future<bool> _showPermissionExplanation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Access'),
        content: const Text(
          'This app needs camera access to take photos for your posts. '
          'Your photos are only stored locally and shared when you choose to post them.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Not Now'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Allow'),
          ),
        ],
      ),
    ) ?? false;
  }
  
  static Future<void> _showPermanentlyDeniedDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission Blocked'),
        content: const Text(
          'Camera permission has been permanently denied. '
          'Please enable it in app settings to use this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              PermissionService.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
```

### 2. Location Permission Flow

```dart
// lib/flows/location_permission_flow.dart
class LocationPermissionFlow {
  static Future<bool> requestLocationAccess(BuildContext context, {
    bool showRationale = true,
  }) async {
    // Check current status
    final status = await LocationPermissionHandler.getLocationPermissionStatus();
    
    switch (status) {
      case LocationPermissionStatus.granted:
        return true;
      
      case LocationPermissionStatus.denied:
        if (showRationale) {
          final shouldRequest = await _showLocationRationale(context);
          if (!shouldRequest) return false;
        }
        return await LocationPermissionHandler.requestLocationPermission();
      
      case LocationPermissionStatus.permanentlyDenied:
        await _showLocationPermanentlyDenied(context);
        return false;
      
      case LocationPermissionStatus.restricted:
        await _showLocationRestricted(context);
        return false;
      
      default:
        return false;
    }
  }
  
  static Future<bool> _showLocationRationale(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Access'),
        content: const Text(
          'This app uses your location to show nearby content and improve your experience. '
          'Your location data is not shared with third parties.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Deny'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Allow'),
          ),
        ],
      ),
    ) ?? false;
  }
  
  static Future<void> _showLocationPermanentlyDenied(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'Location access has been permanently denied. '
          'Please enable it in app settings to use location features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              PermissionService.openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }
  
  static Future<void> _showLocationRestricted(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Restricted'),
        content: const Text(
          'Location access is restricted on this device. '
          'This may be due to parental controls or device management policies.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
```

## Testing Permissions

### 1. Permission Testing

```dart
// test/permissions/permission_service_test.dart
void main() {
  group('Permission Service Tests', () {
    test('should check permission status correctly', () async {
      // Mock permission status
      when(Permission.camera.status).thenAnswer((_) async => PermissionStatus.granted);
      
      final hasPermission = await PermissionService.hasPermission(Permission.camera);
      expect(hasPermission, isTrue);
    });
    
    test('should request permission correctly', () async {
      when(Permission.camera.status).thenAnswer((_) async => PermissionStatus.denied);
      when(Permission.camera.request()).thenAnswer((_) async => PermissionStatus.granted);
      
      final granted = await PermissionService.requestPermission(Permission.camera);
      expect(granted, isTrue);
    });
  });
}
```

Proper permission handling is crucial for user trust and app functionality. Always explain why permissions are needed and provide graceful fallbacks when permissions are denied.
