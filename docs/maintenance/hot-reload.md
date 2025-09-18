# Hot Reload & Hot Restart

Comprehensive guide to Flutter's development features for rapid iteration and debugging.

## Overview

Flutter's hot reload and hot restart capabilities are among its most powerful features for development productivity. This guide covers how to use them effectively and troubleshoot common issues.

## Hot Reload

### What is Hot Reload?

Hot reload allows you to see changes in your code almost instantly without losing the current state of your app.

**Key Features**:
- Preserves app state
- Updates UI changes instantly
- Maintains navigation stack
- Keeps form data and scroll positions

### How to Use Hot Reload

```bash
# In terminal
r  # Press 'r' to hot reload

# In IDE
Ctrl+S (VS Code with auto-save)
Cmd+S (macOS)

# Flutter command
flutter run --hot
```

### What Hot Reload Can Update

✅ **Supported Changes**:
- Widget modifications
- UI layout changes
- Color and styling updates
- Text content changes
- Adding/removing widgets
- Method implementations

```dart
// Before hot reload
Container(
  color: Colors.blue,
  child: Text('Hello'),
)

// After hot reload - state preserved
Container(
  color: Colors.red,  // ✅ Updates instantly
  child: Text('Hello World'),  // ✅ Updates instantly
)
```

### What Hot Reload Cannot Update

❌ **Unsupported Changes**:
- Global variables and static fields
- Main method changes
- initState() modifications
- App lifecycle changes
- Native code changes

```dart
// These require hot restart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'New Title',  // ❌ Requires hot restart
      home: MyHomePage(),
    );
  }
}

// Global variables
String globalVar = 'new value';  // ❌ Requires hot restart

// Static fields
class Constants {
  static const String apiUrl = 'new-url';  // ❌ Requires hot restart
}
```

## Hot Restart

### What is Hot Restart?

Hot restart recompiles the app and restarts it, losing all state but applying all changes.

**Key Features**:
- Resets app state
- Applies all code changes
- Restarts from main()
- Clears navigation stack

### How to Use Hot Restart

```bash
# In terminal
R  # Press 'R' to hot restart

# In IDE
Ctrl+Shift+F5 (VS Code)
Cmd+Shift+F5 (macOS)

# Flutter command
flutter run --hot --hot-restart
```

### When to Use Hot Restart

Use hot restart when:
- Hot reload doesn't work
- Changing app initialization
- Modifying main() method
- Updating global variables
- Adding new dependencies
- Changing app configuration

```dart
// Changes that require hot restart
void main() {
  runApp(MyApp());  // ✅ Hot restart needed
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,  // ✅ Hot restart needed
      theme: ThemeData(
        primarySwatch: Colors.blue,  // ✅ Hot restart needed
      ),
      home: MyHomePage(),
    );
  }
}
```

## Advanced Hot Reload Techniques

### 1. Preserving State During Development

```dart
class CounterWidget extends StatefulWidget {
  @override
  _CounterWidgetState createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Counter: $_counter'),
        ElevatedButton(
          onPressed: () => setState(() => _counter++),
          child: Text('Increment'),
        ),
        // Add new widgets here - counter state preserved! ✅
        ElevatedButton(
          onPressed: () => setState(() => _counter--),
          child: Text('Decrement'),
        ),
      ],
    );
  }
}
```

### 2. Using Debugger with Hot Reload

```dart
class DebugWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Add breakpoints here
    debugger();  // ✅ Works with hot reload
    
    return Container(
      child: Text('Debug me!'),
    );
  }
}
```

### 3. Hot Reload with State Management

```dart
// Riverpod - state preserved during hot reload
final counterProvider = StateProvider<int>((ref) => 0);

class CounterScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterProvider);
    
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text('Count: $counter'),  // ✅ State preserved
            ElevatedButton(
              onPressed: () => ref.read(counterProvider.notifier).state++,
              child: Text('Increment'),
            ),
            // Add new UI here - state preserved! ✅
          ],
        ),
      ),
    );
  }
}
```

## Troubleshooting Hot Reload

### 1. Hot Reload Not Working

**Common Causes**:
- Syntax errors in code
- Compilation errors
- IDE not connected to Flutter process

**Solutions**:
```bash
# Check for errors
flutter analyze

# Restart Flutter process
flutter run

# Clear cache
flutter clean
flutter pub get
```

### 2. State Not Preserving

**Problem**: App state resets during hot reload

**Solutions**:
```dart
// Use StatefulWidget for local state
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  String _data = 'preserved';  // ✅ Preserved during hot reload
  
  @override
  Widget build(BuildContext context) {
    return Text(_data);
  }
}

// Avoid global variables
String globalData = 'reset';  // ❌ Reset during hot reload
```

### 3. Hot Reload Slow

**Optimization Tips**:
```dart
// Avoid expensive operations in build()
class OptimizedWidget extends StatelessWidget {
  // ✅ Compute expensive data outside build
  static final expensiveData = _computeExpensiveData();
  
  @override
  Widget build(BuildContext context) {
    return Text(expensiveData);
  }
  
  static String _computeExpensiveData() {
    // Expensive computation here
    return 'result';
  }
}

// Use const constructors
class ConstWidget extends StatelessWidget {
  const ConstWidget({Key? key}) : super(key: key);  // ✅ const constructor
  
  @override
  Widget build(BuildContext context) {
    return const Text('Constant widget');  // ✅ const widget
  }
}
```

## IDE Integration

### VS Code

```json
// .vscode/settings.json
{
  "dart.flutterHotReloadOnSave": "always",
  "dart.hotReloadOnSave": "always",
  "files.autoSave": "afterDelay",
  "files.autoSaveDelay": 1000
}
```

**Useful Shortcuts**:
- `Ctrl+F5`: Start without debugging
- `F5`: Start with debugging
- `Ctrl+Shift+F5`: Hot restart
- `Ctrl+F10`: Hot reload

### Android Studio

**Settings**:
- Enable "Perform hot reload on save"
- Enable "Format code on save"
- Set auto-save delay

**Shortcuts**:
- `Ctrl+\`: Hot reload
- `Ctrl+Shift+\`: Hot restart
- `Shift+F10`: Run
- `Shift+F9`: Debug

## Best Practices

### 1. Structure Code for Hot Reload

```dart
// ✅ Good: Separate widgets for better hot reload
class UserProfile extends StatelessWidget {
  final User user;
  
  const UserProfile({Key? key, required this.user}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UserAvatar(user: user),      // ✅ Separate widget
        UserDetails(user: user),     // ✅ Separate widget
        UserActions(user: user),     // ✅ Separate widget
      ],
    );
  }
}

// ❌ Avoid: Large monolithic widgets
class MonolithicWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 100+ lines of widget code
        // Hot reload becomes slow
      ],
    );
  }
}
```

### 2. Use Development-Only Code

```dart
class DebugHelper {
  static void logBuildTime(String widgetName) {
    if (kDebugMode) {  // ✅ Only in debug mode
      print('Building $widgetName at ${DateTime.now()}');
    }
  }
}

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DebugHelper.logBuildTime('MyWidget');  // ✅ Debug info
    
    return Container(
      // Widget implementation
    );
  }
}
```

### 3. Handle Hot Reload in State

```dart
class SmartWidget extends StatefulWidget {
  @override
  _SmartWidgetState createState() => _SmartWidgetState();
}

class _SmartWidgetState extends State<SmartWidget> {
  String _data = '';
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  @override
  void reassemble() {
    super.reassemble();
    // Called during hot reload
    if (kDebugMode) {
      print('Hot reload detected');
      // Optionally refresh data
      _loadData();
    }
  }
  
  void _loadData() {
    // Load data logic
  }
  
  @override
  Widget build(BuildContext context) {
    return Text(_data);
  }
}
```

## Performance Monitoring

### 1. Hot Reload Metrics

```dart
class HotReloadMetrics {
  static final Stopwatch _stopwatch = Stopwatch();
  
  static void startBuildTimer() {
    if (kDebugMode) {
      _stopwatch.reset();
      _stopwatch.start();
    }
  }
  
  static void endBuildTimer(String widgetName) {
    if (kDebugMode) {
      _stopwatch.stop();
      print('$widgetName build time: ${_stopwatch.elapsedMilliseconds}ms');
    }
  }
}

class MonitoredWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    HotReloadMetrics.startBuildTimer();
    
    final widget = Container(
      // Widget implementation
    );
    
    HotReloadMetrics.endBuildTimer('MonitoredWidget');
    return widget;
  }
}
```

### 2. Memory Usage During Development

```dart
import 'dart:developer' as developer;

class MemoryMonitor {
  static void logMemoryUsage() {
    if (kDebugMode) {
      developer.log('Memory usage: ${_getMemoryUsage()}');
    }
  }
  
  static String _getMemoryUsage() {
    // Implementation depends on platform
    return 'Memory info';
  }
}
```

## Conclusion

Hot reload and hot restart are powerful tools that significantly speed up Flutter development. Understanding when and how to use each feature effectively can dramatically improve your development workflow.

**Key Takeaways**:
- Use hot reload for UI changes and state preservation
- Use hot restart for structural and configuration changes
- Structure your code to maximize hot reload effectiveness
- Monitor performance during development
- Leverage IDE integrations for the best experience

Master these tools to become a more productive Flutter developer!
