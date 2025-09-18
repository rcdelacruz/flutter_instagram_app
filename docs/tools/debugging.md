# Debugging Guide

Comprehensive guide to debugging Flutter applications using various tools and techniques.

## Overview

Effective debugging is crucial for Flutter development. This guide covers debugging tools, techniques, and best practices for identifying and fixing issues in your Flutter app.

## Flutter Inspector

### 1. Widget Inspector

The Flutter Inspector helps visualize the widget tree and debug layout issues.

```dart
// Enable inspector in debug mode
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Enable debug banner in debug mode
      debugShowCheckedModeBanner: true,
      home: HomeScreen(),
    );
  }
}
```

### 2. Layout Explorer

Use the Layout Explorer to understand widget constraints and sizing.

```dart
// Add debug information to widgets
class DebugContainer extends StatelessWidget {
  final Widget child;
  final String debugLabel;
  
  const DebugContainer({
    Key? key,
    required this.child,
    required this.debugLabel,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      // Add debug properties
      child: child,
    );
  }
  
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('debugLabel', debugLabel));
  }
}
```

## Debug Console

### 1. Print Debugging

```dart
// Basic print statements
void debugFunction() {
  print('Debug: Function called');
  print('Debug: Variable value = $variableValue');
}

// Conditional debugging
void conditionalDebug() {
  if (kDebugMode) {
    print('This only prints in debug mode');
  }
}

// Debug with stack trace
void debugWithStackTrace() {
  debugPrint('Error occurred');
  debugPrintStack(label: 'Stack trace:');
}
```

### 2. Logger Package

```dart
// lib/utils/logger.dart
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );
  
  static void debug(String message) {
    _logger.d(message);
  }
  
  static void info(String message) {
    _logger.i(message);
  }
  
  static void warning(String message) {
    _logger.w(message);
  }
  
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error, stackTrace);
  }
}

// Usage
AppLogger.debug('User logged in');
AppLogger.error('API call failed', error, stackTrace);
```

## Breakpoints and Debugging

### 1. Setting Breakpoints

```dart
// lib/services/user_service.dart
class UserService {
  Future<User> getUser(String id) async {
    // Set breakpoint here
    debugger(); // Programmatic breakpoint
    
    try {
      final response = await apiClient.get('/users/$id');
      
      // Set breakpoint here to inspect response
      final user = User.fromJson(response.data);
      return user;
    } catch (e) {
      // Set breakpoint here to debug errors
      throw Exception('Failed to get user: $e');
    }
  }
}
```

### 2. Conditional Breakpoints

```dart
// Break only when specific conditions are met
void processItems(List<Item> items) {
  for (int i = 0; i < items.length; i++) {
    final item = items[i];
    
    // Conditional breakpoint: break when item.id == 'specific-id'
    if (item.id == 'specific-id') {
      debugger(); // This will only break for specific item
    }
    
    processItem(item);
  }
}
```

## Performance Debugging

### 1. Performance Overlay

```dart
// Enable performance overlay
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Show performance overlay in debug mode
      showPerformanceOverlay: kDebugMode,
      home: HomeScreen(),
    );
  }
}
```

### 2. Timeline Debugging

```dart
// lib/utils/performance_utils.dart
import 'dart:developer' as developer;

class PerformanceUtils {
  static void timeFunction(String name, Function function) {
    final stopwatch = Stopwatch()..start();
    
    developer.Timeline.startSync(name);
    try {
      function();
    } finally {
      developer.Timeline.finishSync();
      stopwatch.stop();
      
      if (kDebugMode) {
        print('$name took ${stopwatch.elapsedMilliseconds}ms');
      }
    }
  }
  
  static Future<T> timeAsyncFunction<T>(String name, Future<T> Function() function) async {
    final stopwatch = Stopwatch()..start();
    
    developer.Timeline.startSync(name);
    try {
      return await function();
    } finally {
      developer.Timeline.finishSync();
      stopwatch.stop();
      
      if (kDebugMode) {
        print('$name took ${stopwatch.elapsedMilliseconds}ms');
      }
    }
  }
}

// Usage
PerformanceUtils.timeFunction('Heavy Calculation', () {
  // Heavy computation here
});

final result = await PerformanceUtils.timeAsyncFunction('API Call', () async {
  return await apiClient.getData();
});
```

### 3. Memory Debugging

```dart
// lib/utils/memory_utils.dart
import 'dart:developer' as developer;

class MemoryUtils {
  static void logMemoryUsage(String label) {
    if (kDebugMode) {
      final info = developer.Service.getIsolateID(Isolate.current);
      print('Memory usage at $label: ${info}');
    }
  }
  
  static void trackObjectCreation<T>(T object, String name) {
    if (kDebugMode) {
      print('Created $name: ${object.runtimeType}');
    }
  }
}
```

## Network Debugging

### 1. HTTP Interceptors

```dart
// lib/services/debug_interceptor.dart
class DebugInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('REQUEST[${options.method}] => PATH: ${options.path}');
      print('Headers: ${options.headers}');
      print('Data: ${options.data}');
    }
    super.onRequest(options, handler);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
      print('Data: ${response.data}');
    }
    super.onResponse(response, handler);
  }
  
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
      print('Message: ${err.message}');
    }
    super.onError(err, handler);
  }
}

// Add to Dio instance
final dio = Dio();
if (kDebugMode) {
  dio.interceptors.add(DebugInterceptor());
}
```

### 2. Network Inspector

```dart
// lib/utils/network_inspector.dart
class NetworkInspector {
  static void logRequest(String method, String url, Map<String, dynamic>? data) {
    if (kDebugMode) {
      print('🌐 $method $url');
      if (data != null) {
        print('📤 Request Data: ${jsonEncode(data)}');
      }
    }
  }
  
  static void logResponse(int statusCode, String url, dynamic data) {
    if (kDebugMode) {
      final emoji = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
      print('$emoji Response [$statusCode] $url');
      print('📥 Response Data: ${jsonEncode(data)}');
    }
  }
  
  static void logError(String url, dynamic error) {
    if (kDebugMode) {
      print('🚨 Network Error: $url');
      print('Error: $error');
    }
  }
}
```

## State Debugging

### 1. Riverpod Debugging

```dart
// lib/providers/debug_observer.dart
class DebugProviderObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    if (kDebugMode) {
      print('Provider ${provider.name ?? provider.runtimeType} updated');
      print('Previous: $previousValue');
      print('New: $newValue');
    }
  }
  
  @override
  void didDisposeProvider(ProviderBase provider, ProviderContainer container) {
    if (kDebugMode) {
      print('Provider ${provider.name ?? provider.runtimeType} disposed');
    }
  }
}

// Add to ProviderScope
ProviderScope(
  observers: [DebugProviderObserver()],
  child: MyApp(),
)
```

### 2. BLoC Debugging

```dart
// lib/blocs/debug_bloc_observer.dart
class DebugBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    if (kDebugMode) {
      print('BLoC Created: ${bloc.runtimeType}');
    }
  }
  
  @override
  void onEvent(BlocBase bloc, Object? event) {
    super.onEvent(bloc, event);
    if (kDebugMode) {
      print('BLoC Event: ${bloc.runtimeType} - $event');
    }
  }
  
  @override
  void onTransition(BlocBase bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (kDebugMode) {
      print('BLoC Transition: ${bloc.runtimeType}');
      print('Current State: ${transition.currentState}');
      print('Event: ${transition.event}');
      print('Next State: ${transition.nextState}');
    }
  }
  
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    if (kDebugMode) {
      print('BLoC Error: ${bloc.runtimeType} - $error');
      print('Stack Trace: $stackTrace');
    }
  }
}

// Set global observer
void main() {
  Bloc.observer = DebugBlocObserver();
  runApp(MyApp());
}
```

## Error Handling and Debugging

### 1. Global Error Handling

```dart
// lib/utils/error_handler.dart
class ErrorHandler {
  static void initialize() {
    // Catch Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      if (kDebugMode) {
        FlutterError.presentError(details);
      } else {
        // Log to crash reporting service
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      }
    };
    
    // Catch async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      if (kDebugMode) {
        print('Async Error: $error');
        print('Stack Trace: $stack');
      } else {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      }
      return true;
    };
  }
}
```

### 2. Custom Error Widget

```dart
// lib/widgets/debug_error_widget.dart
class DebugErrorWidget extends StatelessWidget {
  final FlutterErrorDetails errorDetails;
  
  const DebugErrorWidget({
    Key? key,
    required this.errorDetails,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.red.shade100,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'An error occurred',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            if (kDebugMode) ...[
              Text(
                errorDetails.exception.toString(),
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    errorDetails.stack.toString(),
                    style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Set custom error widget
void main() {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return DebugErrorWidget(errorDetails: details);
  };
  runApp(MyApp());
}
```

## Platform-Specific Debugging

### 1. iOS Debugging

```dart
// lib/utils/ios_debug.dart
class IOSDebug {
  static void enableDebugLogging() {
    if (Platform.isIOS && kDebugMode) {
      // Enable iOS-specific debugging
      print('iOS Debug mode enabled');
    }
  }
  
  static void logViewControllerLifecycle(String event) {
    if (Platform.isIOS && kDebugMode) {
      print('iOS ViewController: $event');
    }
  }
}
```

### 2. Android Debugging

```dart
// lib/utils/android_debug.dart
class AndroidDebug {
  static void enableDebugLogging() {
    if (Platform.isAndroid && kDebugMode) {
      // Enable Android-specific debugging
      print('Android Debug mode enabled');
    }
  }
  
  static void logActivityLifecycle(String event) {
    if (Platform.isAndroid && kDebugMode) {
      print('Android Activity: $event');
    }
  }
}
```

## Debug Tools and Commands

### 1. Flutter Commands

```bash
# Debug build
flutter run --debug

# Profile build
flutter run --profile

# Enable verbose logging
flutter run --verbose

# Debug specific device
flutter run -d <device-id>

# Hot reload
r

# Hot restart
R

# Debug inspector
w

# Performance overlay
P
```

### 2. Debug Utilities

```dart
// lib/utils/debug_utils.dart
class DebugUtils {
  static void dumpWidget(Widget widget) {
    if (kDebugMode) {
      debugDumpApp();
    }
  }
  
  static void dumpRenderTree() {
    if (kDebugMode) {
      debugDumpRenderTree();
    }
  }
  
  static void dumpLayerTree() {
    if (kDebugMode) {
      debugDumpLayerTree();
    }
  }
  
  static void printWidgetTree(BuildContext context) {
    if (kDebugMode) {
      context.visitAncestorElements((element) {
        print('Widget: ${element.widget.runtimeType}');
        return true;
      });
    }
  }
}
```

## Best Practices

### 1. Debug Configuration

```dart
// lib/config/debug_config.dart
class DebugConfig {
  static const bool enableNetworkLogging = true;
  static const bool enableStateLogging = true;
  static const bool enablePerformanceLogging = false;
  
  static bool get isDebugMode => kDebugMode;
  
  static void log(String message, {String? tag}) {
    if (isDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      print('$prefix$message');
    }
  }
}
```

### 2. Conditional Debugging

```dart
// Only include debug code in debug builds
if (kDebugMode) {
  // Debug-only code
  print('Debug information');
  debugger();
}

// Use assert for debug-only checks
assert(() {
  print('This only runs in debug mode');
  return true;
}());
```

Effective debugging requires the right tools and techniques. Use the Flutter Inspector for UI issues, breakpoints for logic problems, and logging for understanding app flow.
