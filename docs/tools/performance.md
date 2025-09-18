# Performance Optimization

Comprehensive guide to optimizing Flutter application performance for smooth user experiences.

## Overview

Performance optimization is crucial for creating responsive Flutter applications. This guide covers profiling tools, optimization techniques, and best practices for maintaining high performance.

## Performance Profiling

### 1. Flutter Performance Tools

```dart
// lib/utils/performance_monitor.dart
import 'dart:developer' as developer;

class PerformanceMonitor {
  static void startTrace(String name) {
    developer.Timeline.startSync(name);
  }
  
  static void endTrace() {
    developer.Timeline.finishSync();
  }
  
  static Future<T> traceAsync<T>(String name, Future<T> Function() operation) async {
    developer.Timeline.startSync(name);
    try {
      return await operation();
    } finally {
      developer.Timeline.finishSync();
    }
  }
  
  static T traceSync<T>(String name, T Function() operation) {
    developer.Timeline.startSync(name);
    try {
      return operation();
    } finally {
      developer.Timeline.finishSync();
    }
  }
}

// Usage
final result = await PerformanceMonitor.traceAsync('API Call', () async {
  return await apiClient.getData();
});
```

### 2. Performance Overlay

```dart
// lib/main.dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Enable performance overlay in debug mode
      showPerformanceOverlay: kDebugMode,
      // Show semantic debugger
      showSemanticsDebugger: false,
      home: HomeScreen(),
    );
  }
}
```

### 3. Memory Profiling

```dart
// lib/utils/memory_profiler.dart
import 'dart:developer' as developer;

class MemoryProfiler {
  static void logMemoryUsage(String label) {
    if (kDebugMode) {
      developer.postEvent('memory_usage', {
        'label': label,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }
  
  static void trackAllocation(String objectType) {
    if (kDebugMode) {
      developer.postEvent('object_allocation', {
        'type': objectType,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }
}
```

## Widget Performance

### 1. Efficient Widget Building

```dart
// lib/widgets/optimized_list_item.dart
class OptimizedListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  
  const OptimizedListItem({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }
}
```

### 2. Const Constructors

```dart
// lib/widgets/performance_optimized_widgets.dart
class OptimizedContainer extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsets? padding;
  
  // Use const constructor
  const OptimizedContainer({
    Key? key,
    required this.child,
    this.color,
    this.padding,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      padding: padding,
      child: child,
    );
  }
}

// Usage with const
const OptimizedContainer(
  color: Colors.blue,
  padding: EdgeInsets.all(16.0),
  child: Text('Optimized Widget'),
)
```

### 3. Widget Separation

```dart
// lib/widgets/separated_widgets.dart
class ExpensiveWidget extends StatelessWidget {
  const ExpensiveWidget({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Expensive widget that doesn't need to rebuild
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.purple],
        ),
      ),
      child: const Text('Expensive Content'),
    );
  }
}

class ParentWidget extends StatefulWidget {
  @override
  _ParentWidgetState createState() => _ParentWidgetState();
}

class _ParentWidgetState extends State<ParentWidget> {
  int counter = 0;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Counter: $counter'),
        ElevatedButton(
          onPressed: () => setState(() => counter++),
          child: Text('Increment'),
        ),
        // Separate expensive widget to avoid rebuilds
        const ExpensiveWidget(),
      ],
    );
  }
}
```

## List Performance

### 1. Efficient List Building

```dart
// lib/widgets/optimized_list.dart
class OptimizedList extends StatelessWidget {
  final List<String> items;
  
  const OptimizedList({Key? key, required this.items}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // Use itemExtent for fixed-height items
      itemExtent: 60.0,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return RepaintBoundary(
          child: ListTile(
            key: ValueKey(item),
            title: Text(item),
          ),
        );
      },
    );
  }
}
```

### 2. Lazy Loading

```dart
// lib/widgets/lazy_list.dart
class LazyList extends StatefulWidget {
  @override
  _LazyListState createState() => _LazyListState();
}

class _LazyListState extends State<LazyList> {
  final List<String> items = [];
  bool isLoading = false;
  final ScrollController scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    loadInitialItems();
    scrollController.addListener(onScroll);
  }
  
  void loadInitialItems() {
    setState(() {
      items.addAll(List.generate(20, (index) => 'Item $index'));
    });
  }
  
  void onScroll() {
    if (scrollController.position.pixels >= 
        scrollController.position.maxScrollExtent - 200) {
      loadMoreItems();
    }
  }
  
  Future<void> loadMoreItems() async {
    if (isLoading) return;
    
    setState(() => isLoading = true);
    
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));
    
    setState(() {
      final startIndex = items.length;
      items.addAll(List.generate(20, (index) => 'Item ${startIndex + index}'));
      isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: items.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == items.length) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return ListTile(
          title: Text(items[index]),
        );
      },
    );
  }
  
  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
```

### 3. Virtual Scrolling

```dart
// lib/widgets/virtual_scroll_list.dart
class VirtualScrollList extends StatelessWidget {
  final List<String> items;
  final double itemHeight;
  
  const VirtualScrollList({
    Key? key,
    required this.items,
    this.itemHeight = 60.0,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemExtent: itemHeight,
      itemCount: items.length,
      cacheExtent: itemHeight * 10, // Cache 10 items
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: Container(
            height: itemHeight,
            child: ListTile(
              title: Text(items[index]),
            ),
          ),
        );
      },
    );
  }
}
```

## Image Performance

### 1. Image Optimization

```dart
// lib/widgets/optimized_image.dart
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  
  const OptimizedImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      // Use caching
      cacheWidth: width?.round(),
      cacheHeight: height?.round(),
      // Loading and error builders
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return SizedBox(
          width: width,
          height: height,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: Icon(Icons.error),
        );
      },
    );
  }
}
```

### 2. Image Caching

```dart
// lib/services/image_cache_service.dart
class ImageCacheService {
  static final Map<String, ui.Image> _cache = {};
  
  static Future<ui.Image?> getCachedImage(String url) async {
    if (_cache.containsKey(url)) {
      return _cache[url];
    }
    
    try {
      final response = await http.get(Uri.parse(url));
      final bytes = response.bodyBytes;
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      
      _cache[url] = frame.image;
      return frame.image;
    } catch (e) {
      return null;
    }
  }
  
  static void clearCache() {
    _cache.clear();
  }
  
  static void removeCachedImage(String url) {
    _cache.remove(url);
  }
}
```

## Animation Performance

### 1. Efficient Animations

```dart
// lib/widgets/optimized_animation.dart
class OptimizedAnimation extends StatefulWidget {
  @override
  _OptimizedAnimationState createState() => _OptimizedAnimationState();
}

class _OptimizedAnimationState extends State<OptimizedAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;
  
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Transform.scale(
            scale: animation.value,
            child: child,
          );
        },
        // Use child parameter to avoid rebuilding static content
        child: Container(
          width: 100,
          height: 100,
          color: Colors.blue,
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
```

### 2. Animation Optimization

```dart
// lib/utils/animation_utils.dart
class AnimationUtils {
  // Use Transform instead of changing widget properties
  static Widget createOptimizedTransition({
    required Widget child,
    required Animation<double> animation,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(animation.value * 100, 0),
          child: child,
        );
      },
      child: child,
    );
  }
  
  // Batch animations to reduce rebuilds
  static Widget createBatchedAnimation({
    required Widget child,
    required Animation<double> scaleAnimation,
    required Animation<double> opacityAnimation,
  }) {
    return AnimatedBuilder(
      animation: Listenable.merge([scaleAnimation, opacityAnimation]),
      builder: (context, _) {
        return Transform.scale(
          scale: scaleAnimation.value,
          child: Opacity(
            opacity: opacityAnimation.value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
```

## State Management Performance

### 1. Efficient State Updates

```dart
// lib/providers/optimized_provider.dart
class OptimizedProvider extends ChangeNotifier {
  List<String> _items = [];
  bool _isLoading = false;
  
  List<String> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  
  // Batch updates to reduce notifications
  void updateItems(List<String> newItems) {
    _items = newItems;
    _isLoading = false;
    // Single notification for multiple changes
    notifyListeners();
  }
  
  // Use specific update methods
  void addItem(String item) {
    _items.add(item);
    notifyListeners();
  }
  
  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }
}
```

### 2. Selective Rebuilds

```dart
// lib/widgets/selective_rebuild.dart
class SelectiveRebuildWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Only rebuild when counter changes
        Consumer<CounterProvider>(
          builder: (context, counter, child) {
            return Text('Counter: ${counter.value}');
          },
        ),
        // Static widget that never rebuilds
        const StaticWidget(),
        // Only rebuild when user changes
        Selector<UserProvider, String>(
          selector: (context, userProvider) => userProvider.user.name,
          builder: (context, userName, child) {
            return Text('User: $userName');
          },
        ),
      ],
    );
  }
}
```

## Network Performance

### 1. Request Optimization

```dart
// lib/services/optimized_api_client.dart
class OptimizedApiClient {
  final Dio _dio;
  final Map<String, dynamic> _cache = {};
  
  OptimizedApiClient() : _dio = Dio() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add caching headers
        options.headers['Cache-Control'] = 'max-age=300';
        handler.next(options);
      },
    ));
  }
  
  Future<T> get<T>(
    String path, {
    bool useCache = true,
    Duration cacheDuration = const Duration(minutes: 5),
  }) async {
    final cacheKey = path;
    
    if (useCache && _cache.containsKey(cacheKey)) {
      final cachedData = _cache[cacheKey];
      if (DateTime.now().difference(cachedData['timestamp']) < cacheDuration) {
        return cachedData['data'] as T;
      }
    }
    
    final response = await _dio.get(path);
    
    if (useCache) {
      _cache[cacheKey] = {
        'data': response.data,
        'timestamp': DateTime.now(),
      };
    }
    
    return response.data as T;
  }
}
```

### 2. Image Loading Optimization

```dart
// lib/widgets/progressive_image.dart
class ProgressiveImage extends StatefulWidget {
  final String imageUrl;
  final String? thumbnailUrl;
  
  const ProgressiveImage({
    Key? key,
    required this.imageUrl,
    this.thumbnailUrl,
  }) : super(key: key);
  
  @override
  _ProgressiveImageState createState() => _ProgressiveImageState();
}

class _ProgressiveImageState extends State<ProgressiveImage> {
  bool _isFullImageLoaded = false;
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Show thumbnail first
        if (widget.thumbnailUrl != null)
          Image.network(
            widget.thumbnailUrl!,
            fit: BoxFit.cover,
          ),
        // Load full image
        Image.network(
          widget.imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              _isFullImageLoaded = true;
              return child;
            }
            return Container();
          },
        ),
      ],
    );
  }
}
```

## Performance Testing

### 1. Performance Benchmarks

```dart
// test/performance/widget_performance_test.dart
void main() {
  group('Widget Performance Tests', () {
    testWidgets('list scrolling performance', (tester) async {
      final items = List.generate(1000, (index) => 'Item $index');
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: OptimizedList(items: items),
        ),
      ));
      
      // Measure scroll performance
      final stopwatch = Stopwatch()..start();
      
      await tester.fling(
        find.byType(ListView),
        const Offset(0, -500),
        1000,
      );
      
      await tester.pumpAndSettle();
      stopwatch.stop();
      
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
  });
}
```

### 2. Memory Leak Detection

```dart
// test/performance/memory_test.dart
void main() {
  group('Memory Tests', () {
    test('should not leak memory', () async {
      final initialMemory = _getMemoryUsage();
      
      // Create and dispose widgets multiple times
      for (int i = 0; i < 100; i++) {
        final widget = ExpensiveWidget();
        // Simulate widget lifecycle
        await Future.delayed(Duration.zero);
      }
      
      // Force garbage collection
      await Future.delayed(Duration(seconds: 1));
      
      final finalMemory = _getMemoryUsage();
      final memoryIncrease = finalMemory - initialMemory;
      
      expect(memoryIncrease, lessThan(1024 * 1024)); // Less than 1MB
    });
  });
}

int _getMemoryUsage() {
  // Platform-specific memory usage implementation
  return 0; // Placeholder
}
```

Performance optimization is an ongoing process. Profile regularly, optimize bottlenecks, and always measure the impact of your optimizations.
