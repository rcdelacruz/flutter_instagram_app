# Platform Channels

Comprehensive guide to implementing platform channels in Flutter for native iOS and Android integration.

## Overview

Platform channels enable communication between Flutter and native platform code (iOS/Android). This is essential for accessing platform-specific APIs and integrating with native libraries.

## Channel Types

### 1. MethodChannel

For invoking methods on the platform side.

```dart
// Flutter side
class BatteryService {
  static const platform = MethodChannel('com.example.app/battery');
  
  Future<String> getBatteryLevel() async {
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      return 'Battery level at $result%.';
    } on PlatformException catch (e) {
      return "Failed to get battery level: '${e.message}'.";
    }
  }
}
```

### 2. EventChannel

For streaming data from platform to Flutter.

```dart
// Flutter side
class LocationService {
  static const EventChannel _eventChannel = 
      EventChannel('com.example.app/location');
  
  Stream<LocationData> get locationStream {
    return _eventChannel.receiveBroadcastStream().map(
      (dynamic event) => LocationData.fromMap(event),
    );
  }
}
```

### 3. BasicMessageChannel

For basic message passing with custom codecs.

```dart
// Flutter side
class CustomMessageService {
  static const BasicMessageChannel<String> _channel =
      BasicMessageChannel('com.example.app/messages', StringCodec());
  
  Future<String> sendMessage(String message) async {
    final String reply = await _channel.send(message);
    return reply;
  }
}
```

## iOS Implementation

### MethodChannel Implementation

```swift
// iOS (Swift) - AppDelegate.swift
import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let batteryChannel = FlutterMethodChannel(name: "com.example.app/battery",
                                              binaryMessenger: controller.binaryMessenger)
    
    batteryChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      
      guard call.method == "getBatteryLevel" else {
        result(FlutterMethodNotImplemented)
        return
      }
      
      self.receiveBatteryLevel(result: result)
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func receiveBatteryLevel(result: FlutterResult) {
    let device = UIDevice.current
    device.isBatteryMonitoringEnabled = true
    
    if device.batteryState == UIDevice.BatteryState.unknown {
      result(FlutterError(code: "UNAVAILABLE",
                         message: "Battery level not available.",
                         details: nil))
    } else {
      result(Int(device.batteryLevel * 100))
    }
  }
}
```

### EventChannel Implementation

```swift
// iOS (Swift) - Location streaming
class LocationStreamHandler: NSObject, FlutterStreamHandler {
  private var locationManager: CLLocationManager?
  private var eventSink: FlutterEventSink?
  
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    
    locationManager = CLLocationManager()
    locationManager?.delegate = self
    locationManager?.requestWhenInUseAuthorization()
    locationManager?.startUpdatingLocation()
    
    return nil
  }
  
  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    locationManager?.stopUpdatingLocation()
    locationManager = nil
    eventSink = nil
    return nil
  }
}

extension LocationStreamHandler: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }
    
    let locationData = [
      "latitude": location.coordinate.latitude,
      "longitude": location.coordinate.longitude,
      "accuracy": location.horizontalAccuracy
    ]
    
    eventSink?(locationData)
  }
}
```

## Android Implementation

### MethodChannel Implementation

```kotlin
// Android (Kotlin) - MainActivity.kt
package com.example.app

import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.app/battery"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getBatteryLevel" -> {
                    val batteryLevel = getBatteryLevel()
                    if (batteryLevel != -1) {
                        result.success(batteryLevel)
                    } else {
                        result.error("UNAVAILABLE", "Battery level not available.", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getBatteryLevel(): Int {
        val batteryLevel: Int
        if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intent = ContextWrapper(applicationContext).registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            batteryLevel = intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100 / intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
        }
        return batteryLevel
    }
}
```

### EventChannel Implementation

```kotlin
// Android (Kotlin) - Location streaming
import io.flutter.plugin.common.EventChannel
import android.location.LocationManager
import android.location.LocationListener

class LocationStreamHandler : EventChannel.StreamHandler, LocationListener {
    private var locationManager: LocationManager? = null
    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        locationManager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
        
        try {
            locationManager?.requestLocationUpdates(
                LocationManager.GPS_PROVIDER,
                1000L, // minimum time interval
                1f,    // minimum distance
                this
            )
        } catch (e: SecurityException) {
            eventSink?.error("PERMISSION_DENIED", "Location permission not granted", null)
        }
    }

    override fun onCancel(arguments: Any?) {
        locationManager?.removeUpdates(this)
        locationManager = null
        eventSink = null
    }

    override fun onLocationChanged(location: Location) {
        val locationData = mapOf(
            "latitude" to location.latitude,
            "longitude" to location.longitude,
            "accuracy" to location.accuracy.toDouble()
        )
        eventSink?.success(locationData)
    }
}
```

## Advanced Patterns

### 1. Plugin Architecture

```dart
// Create a proper plugin structure
class CameraPlugin {
  static const MethodChannel _channel = MethodChannel('camera_plugin');
  
  static Future<String> takePicture() async {
    final String path = await _channel.invokeMethod('takePicture');
    return path;
  }
  
  static Future<void> setFlashMode(bool enabled) async {
    await _channel.invokeMethod('setFlashMode', {'enabled': enabled});
  }
}
```

### 2. Error Handling

```dart
class PlatformService {
  static const MethodChannel _channel = MethodChannel('platform_service');
  
  static Future<T> safeInvoke<T>(String method, [dynamic arguments]) async {
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } on PlatformException catch (e) {
      throw PlatformServiceException(
        code: e.code,
        message: e.message ?? 'Unknown platform error',
        details: e.details,
      );
    } catch (e) {
      throw PlatformServiceException(
        code: 'UNKNOWN_ERROR',
        message: e.toString(),
      );
    }
  }
}

class PlatformServiceException implements Exception {
  final String code;
  final String message;
  final dynamic details;
  
  PlatformServiceException({
    required this.code,
    required this.message,
    this.details,
  });
}
```

### 3. Type Safety

```dart
// Use proper data models
class LocationData {
  final double latitude;
  final double longitude;
  final double accuracy;
  
  LocationData({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
  });
  
  factory LocationData.fromMap(Map<dynamic, dynamic> map) {
    return LocationData(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      accuracy: (map['accuracy'] as num).toDouble(),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
    };
  }
}
```

## Testing Platform Channels

### Unit Testing

```dart
// test/platform_channel_test.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel channel = MethodChannel('com.example.app/battery');
  
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getBatteryLevel') {
        return 42;
      }
      return null;
    });
  });
  
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });
  
  test('getBatteryLevel', () async {
    final BatteryService service = BatteryService();
    final String result = await service.getBatteryLevel();
    expect(result, 'Battery level at 42%.');
  });
}
```

### Integration Testing

```dart
// integration_test/platform_channel_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Platform Channel Integration', () {
    testWidgets('battery level returns valid value', (tester) async {
      final service = BatteryService();
      final result = await service.getBatteryLevel();
      
      expect(result, contains('Battery level at'));
      expect(result, contains('%'));
    });
  });
}
```

## Best Practices

### 1. Channel Naming

```dart
// Use reverse domain notation
static const String channelName = 'com.yourcompany.yourapp/feature';
```

### 2. Method Naming

```dart
// Use clear, descriptive method names
await channel.invokeMethod('getUserLocation');
await channel.invokeMethod('startLocationUpdates');
await channel.invokeMethod('stopLocationUpdates');
```

### 3. Data Serialization

```dart
// Use consistent data formats
class ApiResponse {
  final bool success;
  final String? error;
  final Map<String, dynamic>? data;
  
  factory ApiResponse.fromMap(Map<dynamic, dynamic> map) {
    return ApiResponse(
      success: map['success'] as bool,
      error: map['error'] as String?,
      data: map['data'] as Map<String, dynamic>?,
    );
  }
}
```

### 4. Resource Management

```dart
// Properly dispose of resources
class LocationService {
  StreamSubscription? _subscription;
  
  void startListening() {
    _subscription = locationStream.listen((location) {
      // Handle location updates
    });
  }
  
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
```

## Common Use Cases

### 1. Device Information

```dart
// Get device-specific information
class DeviceInfo {
  static const MethodChannel _channel = MethodChannel('device_info');
  
  static Future<Map<String, String>> getDeviceInfo() async {
    final Map<dynamic, dynamic> info = await _channel.invokeMethod('getDeviceInfo');
    return Map<String, String>.from(info);
  }
}
```

### 2. Native UI Components

```dart
// Integrate native UI components
class NativeMapView extends StatefulWidget {
  @override
  _NativeMapViewState createState() => _NativeMapViewState();
}

class _NativeMapViewState extends State<NativeMapView> {
  static const String viewType = 'native_map_view';
  
  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return AndroidView(
        viewType: viewType,
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    } else if (Platform.isIOS) {
      return UiKitView(
        viewType: viewType,
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }
    return Text('Platform not supported');
  }
  
  void _onPlatformViewCreated(int id) {
    // Initialize platform view
  }
}
```

### 3. Background Processing

```dart
// Handle background tasks
class BackgroundService {
  static const MethodChannel _channel = MethodChannel('background_service');
  
  static Future<void> startBackgroundTask() async {
    await _channel.invokeMethod('startBackgroundTask');
  }
  
  static Future<void> stopBackgroundTask() async {
    await _channel.invokeMethod('stopBackgroundTask');
  }
}
```

## Troubleshooting

### Common Issues

1. **Channel not found**: Ensure channel names match exactly
2. **Method not implemented**: Check method name spelling
3. **Type casting errors**: Verify data types match expectations
4. **Permission errors**: Handle platform permissions properly

### Debugging Tips

```dart
// Add logging for debugging
class DebugChannel {
  static const MethodChannel _channel = MethodChannel('debug_channel');
  
  static Future<T> invokeMethod<T>(String method, [dynamic arguments]) async {
    print('Invoking method: $method with arguments: $arguments');
    try {
      final result = await _channel.invokeMethod<T>(method, arguments);
      print('Method result: $result');
      return result;
    } catch (e) {
      print('Method error: $e');
      rethrow;
    }
  }
}
```

Platform channels are powerful tools for accessing native functionality. Use them judiciously and always consider if existing plugins can meet your needs before implementing custom channels.
