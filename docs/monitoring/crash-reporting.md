# Crash Reporting & Error Monitoring

Comprehensive guide to implementing crash reporting and error monitoring in Flutter applications.

## Overview

Crash reporting is essential for maintaining app stability and user experience. This guide covers setting up crash reporting, error monitoring, and analytics to track and resolve issues in production.

## Firebase Crashlytics Integration

### 1. Setup and Configuration

```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_crashlytics: ^3.4.8
  firebase_analytics: ^10.7.4

dev_dependencies:
  firebase_crashlytics_platform_interface: ^3.6.8
```

```dart
// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Enable crash reporting for release builds
  if (!kDebugMode) {
    // Pass all uncaught errors from the framework to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    
    // Pass all uncaught asynchronous errors to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
  
  runApp(MyApp());
}
```

### 2. Android Configuration

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<application>
    <!-- Crashlytics configuration -->
    <meta-data
        android:name="firebase_crashlytics_collection_enabled"
        android:value="true" />
    
    <!-- Disable automatic collection in debug builds -->
    <meta-data
        android:name="firebase_crashlytics_collection_enabled"
        android:value="false" />
</application>
```

```gradle
// android/app/build.gradle
apply plugin: 'com.google.firebase.crashlytics'

android {
    buildTypes {
        debug {
            manifestPlaceholders = [crashlyticsCollectionEnabled:"false"]
        }
        release {
            manifestPlaceholders = [crashlyticsCollectionEnabled:"true"]
        }
    }
}
```

### 3. iOS Configuration

```xml
<!-- ios/Runner/Info.plist -->
<dict>
    <!-- Crashlytics configuration -->
    <key>firebase_crashlytics_collection_enabled</key>
    <false/>
</dict>
```

## Crash Reporting Service

### 1. Centralized Error Handling

```dart
// lib/services/crash_reporting_service.dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class CrashReportingService {
  static FirebaseCrashlytics get _crashlytics => FirebaseCrashlytics.instance;
  
  // Initialize crash reporting
  static Future<void> initialize() async {
    if (kDebugMode) {
      // Disable crash reporting in debug mode
      await _crashlytics.setCrashlyticsCollectionEnabled(false);
    } else {
      await _crashlytics.setCrashlyticsCollectionEnabled(true);
    }
  }
  
  // Record non-fatal errors
  static Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    Map<String, dynamic>? context,
    bool fatal = false,
  }) async {
    if (kDebugMode) {
      print('Error: $exception');
      print('Stack trace: $stackTrace');
      return;
    }
    
    // Add context information
    if (context != null) {
      for (final entry in context.entries) {
        await _crashlytics.setCustomKey(entry.key, entry.value);
      }
    }
    
    await _crashlytics.recordError(
      exception,
      stackTrace,
      reason: reason,
      fatal: fatal,
    );
  }
  
  // Record Flutter errors
  static Future<void> recordFlutterError(FlutterErrorDetails details) async {
    if (kDebugMode) {
      FlutterError.presentError(details);
      return;
    }
    
    await _crashlytics.recordFlutterFatalError(details);
  }
  
  // Set user information
  static Future<void> setUserInfo({
    required String userId,
    String? email,
    String? name,
  }) async {
    await _crashlytics.setUserIdentifier(userId);
    
    if (email != null) {
      await _crashlytics.setCustomKey('user_email', email);
    }
    
    if (name != null) {
      await _crashlytics.setCustomKey('user_name', name);
    }
  }
  
  // Set custom keys for debugging
  static Future<void> setCustomKey(String key, dynamic value) async {
    await _crashlytics.setCustomKey(key, value);
  }
  
  // Log custom events
  static Future<void> log(String message) async {
    await _crashlytics.log(message);
  }
  
  // Force a crash (for testing)
  static void forceCrash() {
    if (kDebugMode) {
      throw Exception('Test crash from debug mode');
    }
    _crashlytics.crash();
  }
  
  // Check if crash reporting is enabled
  static Future<bool> isCrashlyticsCollectionEnabled() async {
    return await _crashlytics.isCrashlyticsCollectionEnabled();
  }
}
```

### 2. Error Boundary Widget

```dart
// lib/widgets/error_boundary.dart
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(FlutterErrorDetails)? errorBuilder;
  final void Function(FlutterErrorDetails)? onError;
  
  const ErrorBoundary({
    Key? key,
    required this.child,
    this.errorBuilder,
    this.onError,
  }) : super(key: key);
  
  @override
  _ErrorBoundaryState createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _errorDetails;
  
  @override
  void initState() {
    super.initState();
    
    // Set up error handling for this widget tree
    FlutterError.onError = (details) {
      setState(() {
        _errorDetails = details;
      });
      
      // Report to crash reporting service
      CrashReportingService.recordFlutterError(details);
      
      // Call custom error handler
      widget.onError?.call(details);
    };
  }
  
  @override
  Widget build(BuildContext context) {
    if (_errorDetails != null) {
      return widget.errorBuilder?.call(_errorDetails!) ?? _buildDefaultErrorWidget();
    }
    
    return widget.child;
  }
  
  Widget _buildDefaultErrorWidget() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'We\'re working to fix this issue.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorDetails = null;
                });
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Custom Error Tracking

### 1. Network Error Tracking

```dart
// lib/services/network_error_tracker.dart
class NetworkErrorTracker {
  static void trackApiError({
    required String endpoint,
    required int statusCode,
    required String method,
    String? errorMessage,
    Map<String, dynamic>? requestData,
  }) {
    final context = {
      'endpoint': endpoint,
      'status_code': statusCode,
      'method': method,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    if (requestData != null) {
      context['request_size'] = requestData.toString().length;
    }
    
    CrashReportingService.recordError(
      'API Error: $statusCode',
      StackTrace.current,
      reason: 'Network request failed: $method $endpoint',
      context: context,
    );
  }
  
  static void trackTimeoutError({
    required String endpoint,
    required Duration timeout,
    required String method,
  }) {
    CrashReportingService.recordError(
      'Timeout Error',
      StackTrace.current,
      reason: 'Request timeout: $method $endpoint',
      context: {
        'endpoint': endpoint,
        'timeout_seconds': timeout.inSeconds,
        'method': method,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
  
  static void trackConnectivityError({
    required String endpoint,
    required String method,
    required String errorType,
  }) {
    CrashReportingService.recordError(
      'Connectivity Error',
      StackTrace.current,
      reason: 'Network connectivity issue: $errorType',
      context: {
        'endpoint': endpoint,
        'method': method,
        'error_type': errorType,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
```

### 2. User Action Error Tracking

```dart
// lib/services/user_action_tracker.dart
class UserActionTracker {
  static void trackUserError({
    required String action,
    required String screen,
    String? errorMessage,
    Map<String, dynamic>? additionalData,
  }) {
    final context = {
      'user_action': action,
      'screen': screen,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    if (additionalData != null) {
      context.addAll(additionalData);
    }
    
    CrashReportingService.recordError(
      'User Action Error',
      StackTrace.current,
      reason: 'Error during user action: $action on $screen',
      context: context,
    );
  }
  
  static void trackFormError({
    required String formName,
    required String fieldName,
    required String errorType,
    String? errorMessage,
  }) {
    CrashReportingService.recordError(
      'Form Validation Error',
      StackTrace.current,
      reason: 'Form error: $errorType in $fieldName',
      context: {
        'form_name': formName,
        'field_name': fieldName,
        'error_type': errorType,
        'error_message': errorMessage,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
  
  static void trackNavigationError({
    required String fromRoute,
    required String toRoute,
    String? errorMessage,
  }) {
    CrashReportingService.recordError(
      'Navigation Error',
      StackTrace.current,
      reason: 'Navigation failed from $fromRoute to $toRoute',
      context: {
        'from_route': fromRoute,
        'to_route': toRoute,
        'error_message': errorMessage,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
```

## Performance Monitoring

### 1. Performance Metrics Tracking

```dart
// lib/services/performance_monitor.dart
class PerformanceMonitor {
  static final Map<String, DateTime> _startTimes = {};
  
  static void startTrace(String traceName) {
    _startTimes[traceName] = DateTime.now();
    CrashReportingService.log('Started trace: $traceName');
  }
  
  static void stopTrace(String traceName) {
    final startTime = _startTimes.remove(traceName);
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      
      CrashReportingService.setCustomKey('${traceName}_duration_ms', duration.inMilliseconds);
      CrashReportingService.log('Stopped trace: $traceName (${duration.inMilliseconds}ms)');
      
      // Track slow operations
      if (duration.inMilliseconds > 5000) {
        CrashReportingService.recordError(
          'Slow Operation',
          StackTrace.current,
          reason: 'Operation took longer than expected: $traceName',
          context: {
            'trace_name': traceName,
            'duration_ms': duration.inMilliseconds,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      }
    }
  }
  
  static void trackMemoryUsage() {
    // This would require platform-specific implementation
    // or use packages like process_info
  }
  
  static void trackAppLaunchTime(Duration launchTime) {
    CrashReportingService.setCustomKey('app_launch_time_ms', launchTime.inMilliseconds);
    
    if (launchTime.inSeconds > 10) {
      CrashReportingService.recordError(
        'Slow App Launch',
        StackTrace.current,
        reason: 'App took too long to launch',
        context: {
          'launch_time_ms': launchTime.inMilliseconds,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    }
  }
}
```

### 2. Widget Performance Tracking

```dart
// lib/widgets/performance_tracked_widget.dart
class PerformanceTrackedWidget extends StatefulWidget {
  final Widget child;
  final String widgetName;
  
  const PerformanceTrackedWidget({
    Key? key,
    required this.child,
    required this.widgetName,
  }) : super(key: key);
  
  @override
  _PerformanceTrackedWidgetState createState() => _PerformanceTrackedWidgetState();
}

class _PerformanceTrackedWidgetState extends State<PerformanceTrackedWidget> {
  late DateTime _buildStartTime;
  
  @override
  void initState() {
    super.initState();
    PerformanceMonitor.startTrace('${widget.widgetName}_init');
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    PerformanceMonitor.stopTrace('${widget.widgetName}_init');
  }
  
  @override
  Widget build(BuildContext context) {
    _buildStartTime = DateTime.now();
    
    return widget.child;
  }
  
  @override
  void didUpdateWidget(PerformanceTrackedWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    final buildDuration = DateTime.now().difference(_buildStartTime);
    
    if (buildDuration.inMilliseconds > 100) {
      CrashReportingService.recordError(
        'Slow Widget Build',
        StackTrace.current,
        reason: 'Widget build took too long: ${widget.widgetName}',
        context: {
          'widget_name': widget.widgetName,
          'build_duration_ms': buildDuration.inMilliseconds,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    }
  }
  
  @override
  void dispose() {
    PerformanceMonitor.stopTrace('${widget.widgetName}_lifecycle');
    super.dispose();
  }
}
```

## Error Analytics Dashboard

### 1. Error Metrics Collection

```dart
// lib/services/error_analytics.dart
class ErrorAnalytics {
  static final Map<String, int> _errorCounts = {};
  static final List<ErrorEvent> _recentErrors = [];
  
  static void recordErrorEvent({
    required String errorType,
    required String errorMessage,
    required String screen,
    Map<String, dynamic>? metadata,
  }) {
    final event = ErrorEvent(
      type: errorType,
      message: errorMessage,
      screen: screen,
      timestamp: DateTime.now(),
      metadata: metadata ?? {},
    );
    
    _recentErrors.add(event);
    _errorCounts[errorType] = (_errorCounts[errorType] ?? 0) + 1;
    
    // Keep only recent errors (last 100)
    if (_recentErrors.length > 100) {
      _recentErrors.removeAt(0);
    }
    
    // Send to crash reporting
    CrashReportingService.recordError(
      errorType,
      StackTrace.current,
      reason: errorMessage,
      context: {
        'screen': screen,
        'error_count': _errorCounts[errorType],
        ...metadata ?? {},
      },
    );
  }
  
  static Map<String, int> getErrorCounts() => Map.from(_errorCounts);
  
  static List<ErrorEvent> getRecentErrors() => List.from(_recentErrors);
  
  static void clearErrorHistory() {
    _errorCounts.clear();
    _recentErrors.clear();
  }
}

class ErrorEvent {
  final String type;
  final String message;
  final String screen;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  
  ErrorEvent({
    required this.type,
    required this.message,
    required this.screen,
    required this.timestamp,
    required this.metadata,
  });
}
```

### 2. Error Reporting Widget

```dart
// lib/widgets/error_report_widget.dart
class ErrorReportWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    
    return FloatingActionButton(
      mini: true,
      onPressed: () => _showErrorReport(context),
      child: const Icon(Icons.bug_report),
    );
  }
  
  void _showErrorReport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error Report'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              Text('Error Counts:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: ErrorAnalytics.getErrorCounts().entries.map((entry) {
                    return ListTile(
                      title: Text(entry.key),
                      trailing: Text('${entry.value}'),
                    );
                  }).toList(),
                ),
              ),
              const Divider(),
              Text('Recent Errors:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: ErrorAnalytics.getRecentErrors().map((error) {
                    return ListTile(
                      title: Text(error.type),
                      subtitle: Text(error.message),
                      trailing: Text(error.screen),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ErrorAnalytics.clearErrorHistory();
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
```

## Testing Crash Reporting

### 1. Crash Testing

```dart
// lib/utils/crash_test_utils.dart
class CrashTestUtils {
  static void testCrashReporting() {
    if (kDebugMode) {
      print('Testing crash reporting...');
      
      // Test non-fatal error
      CrashReportingService.recordError(
        'Test Error',
        StackTrace.current,
        reason: 'Testing crash reporting system',
        context: {'test': true},
      );
      
      // Test custom key
      CrashReportingService.setCustomKey('test_key', 'test_value');
      
      // Test log
      CrashReportingService.log('Test log message');
      
      print('Crash reporting test completed');
    }
  }
  
  static void testFatalCrash() {
    if (kDebugMode) {
      throw Exception('Test fatal crash');
    }
    CrashReportingService.forceCrash();
  }
}
```

### 2. Error Simulation

```dart
// lib/utils/error_simulator.dart
class ErrorSimulator {
  static void simulateNetworkError() {
    NetworkErrorTracker.trackApiError(
      endpoint: '/api/test',
      statusCode: 500,
      method: 'GET',
      errorMessage: 'Simulated server error',
    );
  }
  
  static void simulateUserError() {
    UserActionTracker.trackUserError(
      action: 'button_tap',
      screen: 'test_screen',
      errorMessage: 'Simulated user action error',
    );
  }
  
  static void simulatePerformanceIssue() {
    PerformanceMonitor.startTrace('slow_operation');
    
    // Simulate slow operation
    Future.delayed(const Duration(seconds: 6), () {
      PerformanceMonitor.stopTrace('slow_operation');
    });
  }
}
```

Crash reporting and error monitoring are essential for maintaining app quality. Implement comprehensive error tracking, monitor performance metrics, and use the data to continuously improve your application's stability and user experience.
