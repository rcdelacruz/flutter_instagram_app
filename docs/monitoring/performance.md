# Performance Monitoring

Comprehensive guide to monitoring and optimizing Flutter application performance in production.

## Overview

Performance monitoring helps identify bottlenecks, track user experience metrics, and ensure optimal app performance. This guide covers tools, techniques, and best practices for monitoring Flutter app performance.

## Firebase Performance Monitoring

### 1. Setup and Configuration

```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_performance: ^0.9.3+8
  firebase_analytics: ^10.7.4

dev_dependencies:
  firebase_performance_platform_interface: ^0.1.4+8
```

```dart
// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_performance/firebase_performance.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Enable performance monitoring
  FirebasePerformance performance = FirebasePerformance.instance;
  await performance.setPerformanceCollectionEnabled(true);
  
  runApp(MyApp());
}
```

### 2. Custom Performance Traces

```dart
// lib/services/performance_service.dart
import 'package:firebase_performance/firebase_performance.dart';

class PerformanceService {
  static final FirebasePerformance _performance = FirebasePerformance.instance;
  static final Map<String, Trace> _activeTraces = {};
  
  // Start a custom trace
  static Future<void> startTrace(String traceName) async {
    final trace = _performance.newTrace(traceName);
    await trace.start();
    _activeTraces[traceName] = trace;
  }
  
  // Stop a custom trace
  static Future<void> stopTrace(String traceName) async {
    final trace = _activeTraces.remove(traceName);
    if (trace != null) {
      await trace.stop();
    }
  }
  
  // Add custom attributes to trace
  static Future<void> setTraceAttribute(
    String traceName,
    String attributeName,
    String value,
  ) async {
    final trace = _activeTraces[traceName];
    if (trace != null) {
      trace.setMetric(attributeName, int.tryParse(value) ?? 0);
    }
  }
  
  // Increment trace metric
  static Future<void> incrementTraceMetric(
    String traceName,
    String metricName,
    int value,
  ) async {
    final trace = _activeTraces[traceName];
    if (trace != null) {
      trace.incrementMetric(metricName, value);
    }
  }
  
  // Track app start time
  static Future<void> trackAppStartTime() async {
    final trace = _performance.newTrace('app_start');
    await trace.start();
    
    // This would be called when app is fully loaded
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await trace.stop();
    });
  }
  
  // Track screen load time
  static Future<void> trackScreenLoad(String screenName) async {
    final trace = _performance.newTrace('screen_load_$screenName');
    await trace.start();
    
    // Stop trace after a delay (or when screen is fully loaded)
    Future.delayed(const Duration(milliseconds: 500), () async {
      await trace.stop();
    });
  }
  
  // Track network request performance
  static Future<void> trackNetworkRequest({
    required String url,
    required String method,
    required int statusCode,
    required int requestSize,
    required int responseSize,
    required Duration duration,
  }) async {
    final httpMetric = _performance.newHttpMetric(url, HttpMethod.values.firstWhere(
      (m) => m.toString().split('.').last.toUpperCase() == method.toUpperCase(),
      orElse: () => HttpMethod.Get,
    ));
    
    httpMetric.requestPayloadSize = requestSize;
    httpMetric.responsePayloadSize = responseSize;
    httpMetric.httpResponseCode = statusCode;
    
    await httpMetric.start();
    
    // Simulate the request duration
    await Future.delayed(duration);
    
    await httpMetric.stop();
  }
}
```

## Custom Performance Monitoring

### 1. Frame Rate Monitoring

```dart
// lib/services/frame_rate_monitor.dart
class FrameRateMonitor {
  static final List<Duration> _frameTimes = [];
  static DateTime? _lastFrameTime;
  static int _frameCount = 0;
  static double _averageFps = 60.0;
  
  static void startMonitoring() {
    WidgetsBinding.instance.addPersistentFrameCallback(_onFrame);
  }
  
  static void stopMonitoring() {
    WidgetsBinding.instance.removePersistentFrameCallback(_onFrame);
  }
  
  static void _onFrame(Duration timestamp) {
    final now = DateTime.now();
    
    if (_lastFrameTime != null) {
      final frameDuration = now.difference(_lastFrameTime!);
      _frameTimes.add(frameDuration);
      
      // Keep only recent frame times (last 60 frames)
      if (_frameTimes.length > 60) {
        _frameTimes.removeAt(0);
      }
      
      // Calculate average FPS
      if (_frameTimes.isNotEmpty) {
        final averageFrameTime = _frameTimes.fold<Duration>(
          Duration.zero,
          (sum, duration) => sum + duration,
        ) ~/ _frameTimes.length;
        
        _averageFps = 1000.0 / averageFrameTime.inMilliseconds;
      }
      
      // Track poor performance
      if (_averageFps < 30) {
        PerformanceService.setTraceAttribute(
          'frame_rate_monitoring',
          'low_fps_detected',
          _averageFps.toString(),
        );
      }
    }
    
    _lastFrameTime = now;
    _frameCount++;
  }
  
  static double get averageFps => _averageFps;
  static int get frameCount => _frameCount;
  
  static Map<String, dynamic> getFrameRateMetrics() {
    return {
      'average_fps': _averageFps,
      'frame_count': _frameCount,
      'recent_frame_times': _frameTimes.map((d) => d.inMilliseconds).toList(),
    };
  }
}
```

### 2. Memory Usage Monitoring

```dart
// lib/services/memory_monitor.dart
import 'dart:developer' as developer;
import 'dart:io';

class MemoryMonitor {
  static Timer? _monitoringTimer;
  static final List<MemorySnapshot> _snapshots = [];
  
  static void startMonitoring({Duration interval = const Duration(seconds: 30)}) {
    _monitoringTimer = Timer.periodic(interval, (_) {
      _takeMemorySnapshot();
    });
  }
  
  static void stopMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
  }
  
  static void _takeMemorySnapshot() {
    final info = developer.Service.getIsolateMemoryUsage(
      developer.Service.getIsolateID(Isolate.current)!,
    );
    
    info.then((usage) {
      final snapshot = MemorySnapshot(
        timestamp: DateTime.now(),
        heapUsage: usage['heapUsage'] ?? 0,
        heapCapacity: usage['heapCapacity'] ?? 0,
        externalUsage: usage['externalUsage'] ?? 0,
      );
      
      _snapshots.add(snapshot);
      
      // Keep only recent snapshots (last 100)
      if (_snapshots.length > 100) {
        _snapshots.removeAt(0);
      }
      
      // Check for memory leaks
      _checkForMemoryLeaks();
    });
  }
  
  static void _checkForMemoryLeaks() {
    if (_snapshots.length < 10) return;
    
    final recent = _snapshots.takeLast(10).toList();
    final trend = _calculateMemoryTrend(recent);
    
    // If memory usage is consistently increasing
    if (trend > 0.1) {
      PerformanceService.setTraceAttribute(
        'memory_monitoring',
        'potential_memory_leak',
        trend.toString(),
      );
    }
  }
  
  static double _calculateMemoryTrend(List<MemorySnapshot> snapshots) {
    if (snapshots.length < 2) return 0.0;
    
    final first = snapshots.first.heapUsage;
    final last = snapshots.last.heapUsage;
    
    return (last - first) / first;
  }
  
  static List<MemorySnapshot> getMemorySnapshots() => List.from(_snapshots);
  
  static MemorySnapshot? getCurrentMemoryUsage() {
    return _snapshots.isNotEmpty ? _snapshots.last : null;
  }
}

class MemorySnapshot {
  final DateTime timestamp;
  final int heapUsage;
  final int heapCapacity;
  final int externalUsage;
  
  MemorySnapshot({
    required this.timestamp,
    required this.heapUsage,
    required this.heapCapacity,
    required this.externalUsage,
  });
  
  double get heapUtilization => heapCapacity > 0 ? heapUsage / heapCapacity : 0.0;
  int get totalUsage => heapUsage + externalUsage;
}
```

### 3. Network Performance Monitoring

```dart
// lib/services/network_performance_monitor.dart
class NetworkPerformanceMonitor {
  static final List<NetworkMetric> _metrics = [];
  
  static void trackRequest({
    required String url,
    required String method,
    required DateTime startTime,
    required DateTime endTime,
    required int statusCode,
    required int requestSize,
    required int responseSize,
    String? errorMessage,
  }) {
    final metric = NetworkMetric(
      url: url,
      method: method,
      startTime: startTime,
      endTime: endTime,
      statusCode: statusCode,
      requestSize: requestSize,
      responseSize: responseSize,
      errorMessage: errorMessage,
    );
    
    _metrics.add(metric);
    
    // Keep only recent metrics (last 1000)
    if (_metrics.length > 1000) {
      _metrics.removeAt(0);
    }
    
    // Track to Firebase Performance
    PerformanceService.trackNetworkRequest(
      url: url,
      method: method,
      statusCode: statusCode,
      requestSize: requestSize,
      responseSize: responseSize,
      duration: endTime.difference(startTime),
    );
    
    // Check for slow requests
    final duration = endTime.difference(startTime);
    if (duration.inSeconds > 10) {
      PerformanceService.setTraceAttribute(
        'slow_network_request',
        'url',
        url,
      );
    }
  }
  
  static List<NetworkMetric> getNetworkMetrics() => List.from(_metrics);
  
  static Map<String, dynamic> getNetworkPerformanceStats() {
    if (_metrics.isEmpty) return {};
    
    final durations = _metrics.map((m) => m.duration.inMilliseconds).toList();
    final successfulRequests = _metrics.where((m) => m.statusCode < 400).length;
    final failedRequests = _metrics.length - successfulRequests;
    
    return {
      'total_requests': _metrics.length,
      'successful_requests': successfulRequests,
      'failed_requests': failedRequests,
      'success_rate': successfulRequests / _metrics.length,
      'average_duration_ms': durations.fold(0, (sum, d) => sum + d) / durations.length,
      'max_duration_ms': durations.fold(0, (max, d) => d > max ? d : max),
      'min_duration_ms': durations.fold(durations.first, (min, d) => d < min ? d : min),
    };
  }
}

class NetworkMetric {
  final String url;
  final String method;
  final DateTime startTime;
  final DateTime endTime;
  final int statusCode;
  final int requestSize;
  final int responseSize;
  final String? errorMessage;
  
  NetworkMetric({
    required this.url,
    required this.method,
    required this.startTime,
    required this.endTime,
    required this.statusCode,
    required this.requestSize,
    required this.responseSize,
    this.errorMessage,
  });
  
  Duration get duration => endTime.difference(startTime);
  bool get isSuccessful => statusCode >= 200 && statusCode < 400;
  double get throughput => responseSize / duration.inMilliseconds; // bytes per ms
}
```

## User Experience Monitoring

### 1. App Launch Time Tracking

```dart
// lib/services/app_launch_tracker.dart
class AppLaunchTracker {
  static DateTime? _appStartTime;
  static DateTime? _firstFrameTime;
  static DateTime? _appReadyTime;
  
  static void markAppStart() {
    _appStartTime = DateTime.now();
  }
  
  static void markFirstFrame() {
    _firstFrameTime = DateTime.now();
    
    if (_appStartTime != null) {
      final timeToFirstFrame = _firstFrameTime!.difference(_appStartTime!);
      
      PerformanceService.setTraceAttribute(
        'app_launch',
        'time_to_first_frame_ms',
        timeToFirstFrame.inMilliseconds.toString(),
      );
    }
  }
  
  static void markAppReady() {
    _appReadyTime = DateTime.now();
    
    if (_appStartTime != null) {
      final totalLaunchTime = _appReadyTime!.difference(_appStartTime!);
      
      PerformanceService.setTraceAttribute(
        'app_launch',
        'total_launch_time_ms',
        totalLaunchTime.inMilliseconds.toString(),
      );
      
      // Track slow app launches
      if (totalLaunchTime.inSeconds > 5) {
        PerformanceService.setTraceAttribute(
          'slow_app_launch',
          'launch_time_ms',
          totalLaunchTime.inMilliseconds.toString(),
        );
      }
    }
  }
  
  static Map<String, int?> getLaunchMetrics() {
    return {
      'time_to_first_frame_ms': _firstFrameTime != null && _appStartTime != null
          ? _firstFrameTime!.difference(_appStartTime!).inMilliseconds
          : null,
      'total_launch_time_ms': _appReadyTime != null && _appStartTime != null
          ? _appReadyTime!.difference(_appStartTime!).inMilliseconds
          : null,
    };
  }
}
```

### 2. Screen Performance Tracking

```dart
// lib/services/screen_performance_tracker.dart
class ScreenPerformanceTracker {
  static final Map<String, DateTime> _screenStartTimes = {};
  static final Map<String, ScreenMetrics> _screenMetrics = {};
  
  static void trackScreenStart(String screenName) {
    _screenStartTimes[screenName] = DateTime.now();
    PerformanceService.startTrace('screen_$screenName');
  }
  
  static void trackScreenReady(String screenName) {
    final startTime = _screenStartTimes[screenName];
    if (startTime != null) {
      final loadTime = DateTime.now().difference(startTime);
      
      _screenMetrics[screenName] = ScreenMetrics(
        screenName: screenName,
        loadTime: loadTime,
        timestamp: DateTime.now(),
      );
      
      PerformanceService.setTraceAttribute(
        'screen_$screenName',
        'load_time_ms',
        loadTime.inMilliseconds.toString(),
      );
      
      PerformanceService.stopTrace('screen_$screenName');
      
      // Track slow screen loads
      if (loadTime.inSeconds > 3) {
        PerformanceService.setTraceAttribute(
          'slow_screen_load',
          'screen_name',
          screenName,
        );
      }
    }
  }
  
  static void trackScreenExit(String screenName) {
    final startTime = _screenStartTimes.remove(screenName);
    if (startTime != null) {
      final sessionTime = DateTime.now().difference(startTime);
      
      PerformanceService.setTraceAttribute(
        'screen_session_$screenName',
        'session_time_ms',
        sessionTime.inMilliseconds.toString(),
      );
    }
  }
  
  static Map<String, ScreenMetrics> getScreenMetrics() => Map.from(_screenMetrics);
  
  static ScreenMetrics? getScreenMetric(String screenName) => _screenMetrics[screenName];
}

class ScreenMetrics {
  final String screenName;
  final Duration loadTime;
  final DateTime timestamp;
  
  ScreenMetrics({
    required this.screenName,
    required this.loadTime,
    required this.timestamp,
  });
}
```

## Performance Dashboard

### 1. Performance Metrics Widget

```dart
// lib/widgets/performance_dashboard.dart
class PerformanceDashboard extends StatefulWidget {
  @override
  _PerformanceDashboardState createState() => _PerformanceDashboardState();
}

class _PerformanceDashboardState extends State<PerformanceDashboard> {
  Timer? _updateTimer;
  
  @override
  void initState() {
    super.initState();
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }
  
  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    
    return Scaffold(
      appBar: AppBar(title: const Text('Performance Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFrameRateSection(),
            const SizedBox(height: 16),
            _buildMemorySection(),
            const SizedBox(height: 16),
            _buildNetworkSection(),
            const SizedBox(height: 16),
            _buildLaunchMetricsSection(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFrameRateSection() {
    final metrics = FrameRateMonitor.getFrameRateMetrics();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Frame Rate', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Average FPS: ${metrics['average_fps']?.toStringAsFixed(1) ?? 'N/A'}'),
            Text('Frame Count: ${metrics['frame_count']}'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMemorySection() {
    final snapshot = MemoryMonitor.getCurrentMemoryUsage();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Memory Usage', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (snapshot != null) ...[
              Text('Heap Usage: ${(snapshot.heapUsage / 1024 / 1024).toStringAsFixed(1)} MB'),
              Text('Heap Capacity: ${(snapshot.heapCapacity / 1024 / 1024).toStringAsFixed(1)} MB'),
              Text('Utilization: ${(snapshot.heapUtilization * 100).toStringAsFixed(1)}%'),
            ] else
              const Text('No memory data available'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNetworkSection() {
    final stats = NetworkPerformanceMonitor.getNetworkPerformanceStats();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Network Performance', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (stats.isNotEmpty) ...[
              Text('Total Requests: ${stats['total_requests']}'),
              Text('Success Rate: ${(stats['success_rate'] * 100).toStringAsFixed(1)}%'),
              Text('Avg Duration: ${stats['average_duration_ms']?.toStringAsFixed(0)} ms'),
            ] else
              const Text('No network data available'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLaunchMetricsSection() {
    final metrics = AppLaunchTracker.getLaunchMetrics();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Launch Metrics', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Time to First Frame: ${metrics['time_to_first_frame_ms'] ?? 'N/A'} ms'),
            Text('Total Launch Time: ${metrics['total_launch_time_ms'] ?? 'N/A'} ms'),
          ],
        ),
      ),
    );
  }
}
```

### 2. Performance Overlay

```dart
// lib/widgets/performance_overlay.dart
class PerformanceOverlay extends StatefulWidget {
  final Widget child;
  
  const PerformanceOverlay({Key? key, required this.child}) : super(key: key);
  
  @override
  _PerformanceOverlayState createState() => _PerformanceOverlayState();
}

class _PerformanceOverlayState extends State<PerformanceOverlay> {
  bool _showOverlay = false;
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showOverlay && kDebugMode)
          Positioned(
            top: 100,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'FPS: ${FrameRateMonitor.averageFps.toStringAsFixed(1)}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Text(
                    'Memory: ${_getMemoryUsage()}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        if (kDebugMode)
          Positioned(
            bottom: 100,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              onPressed: () => setState(() => _showOverlay = !_showOverlay),
              child: Icon(_showOverlay ? Icons.visibility_off : Icons.visibility),
            ),
          ),
      ],
    );
  }
  
  String _getMemoryUsage() {
    final snapshot = MemoryMonitor.getCurrentMemoryUsage();
    if (snapshot != null) {
      return '${(snapshot.heapUsage / 1024 / 1024).toStringAsFixed(1)} MB';
    }
    return 'N/A';
  }
}
```

Performance monitoring is crucial for maintaining optimal user experience. Implement comprehensive monitoring, track key metrics, and use the data to identify and resolve performance bottlenecks proactively.
