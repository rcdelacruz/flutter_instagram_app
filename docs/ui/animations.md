# Animations

Comprehensive guide to creating smooth, performant animations in Flutter applications.

## Overview

Animations bring your Flutter app to life, providing visual feedback and enhancing user experience. This guide covers implicit animations, explicit animations, and advanced animation techniques.

## Animation Fundamentals

### 1. Animation Controller

```dart
// lib/widgets/animated_widget_example.dart
class AnimatedWidgetExample extends StatefulWidget {
  @override
  _AnimatedWidgetExampleState createState() => _AnimatedWidgetExampleState();
}

class _AnimatedWidgetExampleState extends State<AnimatedWidgetExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            width: 100,
            height: 100,
            color: Colors.blue,
          ),
        );
      },
    );
  }
}
```

## Implicit Animations

### 1. AnimatedContainer

```dart
// lib/widgets/animated_container_example.dart
class AnimatedContainerExample extends StatefulWidget {
  @override
  _AnimatedContainerExampleState createState() => _AnimatedContainerExampleState();
}

class _AnimatedContainerExampleState extends State<AnimatedContainerExample> {
  bool _isExpanded = false;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: _isExpanded ? 200 : 100,
        height: _isExpanded ? 200 : 100,
        decoration: BoxDecoration(
          color: _isExpanded ? Colors.red : Colors.blue,
          borderRadius: BorderRadius.circular(_isExpanded ? 20 : 10),
        ),
        child: const Center(
          child: Text('Tap me!', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
```

### 2. AnimatedOpacity

```dart
// lib/widgets/fade_transition_widget.dart
class FadeTransitionWidget extends StatefulWidget {
  final Widget child;
  final bool visible;
  
  const FadeTransitionWidget({
    Key? key,
    required this.child,
    required this.visible,
  }) : super(key: key);
  
  @override
  _FadeTransitionWidgetState createState() => _FadeTransitionWidgetState();
}

class _FadeTransitionWidgetState extends State<FadeTransitionWidget> {
  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: widget.visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: widget.child,
    );
  }
}
```

### 3. AnimatedPositioned

```dart
// lib/widgets/sliding_panel.dart
class SlidingPanel extends StatefulWidget {
  final Widget child;
  final bool isOpen;
  
  const SlidingPanel({
    Key? key,
    required this.child,
    required this.isOpen,
  }) : super(key: key);
  
  @override
  _SlidingPanelState createState() => _SlidingPanelState();
}

class _SlidingPanelState extends State<SlidingPanel> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          bottom: widget.isOpen ? 0 : -300,
          left: 0,
          right: 0,
          height: 300,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
```

## Explicit Animations

### 1. Custom Tween Animations

```dart
// lib/animations/custom_tween_animation.dart
class BouncingBall extends StatefulWidget {
  @override
  _BouncingBallState createState() => _BouncingBallState();
}

class _BouncingBallState extends State<BouncingBall>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 200.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut,
    ));
    
    _controller.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
```

### 2. Staggered Animations

```dart
// lib/animations/staggered_animation.dart
class StaggeredAnimation extends StatefulWidget {
  @override
  _StaggeredAnimationState createState() => _StaggeredAnimationState();
}

class _StaggeredAnimationState extends State<StaggeredAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.8, curve: Curves.easeIn),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.elasticOut),
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _startAnimation() {
    _controller.forward();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        'Animated!',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _startAnimation,
          child: const Text('Start Animation'),
        ),
      ],
    );
  }
}
```

## Page Transitions

### 1. Custom Page Route

```dart
// lib/animations/custom_page_route.dart
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Offset beginOffset;
  final Offset endOffset;
  
  SlidePageRoute({
    required this.child,
    this.beginOffset = const Offset(1.0, 0.0),
    this.endOffset = Offset.zero,
    RouteSettings? settings,
  }) : super(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: beginOffset,
          end: endOffset,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        )),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  
  FadePageRoute({
    required this.child,
    RouteSettings? settings,
  }) : super(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}
```

### 2. Hero Animations

```dart
// lib/widgets/hero_animation_example.dart
class HeroAnimationExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hero Animation')),
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const DetailScreen(),
              ),
            );
          },
          child: Hero(
            tag: 'hero-image',
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'Tap me!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  const DetailScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail')),
      body: Center(
        child: Hero(
          tag: 'hero-image',
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                'Expanded!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

## List Animations

### 1. AnimatedList

```dart
// lib/widgets/animated_list_example.dart
class AnimatedListExample extends StatefulWidget {
  @override
  _AnimatedListExampleState createState() => _AnimatedListExampleState();
}

class _AnimatedListExampleState extends State<AnimatedListExample> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<String> _items = ['Item 1', 'Item 2', 'Item 3'];
  
  void _addItem() {
    final index = _items.length;
    _items.insert(index, 'Item ${index + 1}');
    _listKey.currentState?.insertItem(index);
  }
  
  void _removeItem(int index) {
    final removedItem = _items.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildItem(removedItem, animation),
    );
  }
  
  Widget _buildItem(String item, Animation<double> animation) {
    return SlideTransition(
      position: animation.drive(
        Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ),
      ),
      child: Card(
        child: ListTile(
          title: Text(item),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _removeItem(_items.indexOf(item)),
          ),
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animated List')),
      body: AnimatedList(
        key: _listKey,
        initialItemCount: _items.length,
        itemBuilder: (context, index, animation) {
          return _buildItem(_items[index], animation);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

## Performance Optimization

### 1. Animation Performance Tips

```dart
// lib/widgets/optimized_animation.dart
class OptimizedAnimation extends StatefulWidget {
  @override
  _OptimizedAnimationState createState() => _OptimizedAnimationState();
}

class _OptimizedAnimationState extends State<OptimizedAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Use RepaintBoundary to isolate repaints
    _animation = _controller.drive(Tween<double>(begin: 0.0, end: 1.0));
  }
  
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: _animation.value,
            child: child,
          );
        },
        // Use child parameter to avoid rebuilding static content
        child: const ExpensiveWidget(),
      ),
    );
  }
}

class ExpensiveWidget extends StatelessWidget {
  const ExpensiveWidget({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Expensive widget that doesn't need to rebuild
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.purple],
        ),
      ),
    );
  }
}
```

### 2. Animation Utilities

```dart
// lib/utils/animation_utils.dart
class AnimationUtils {
  static Animation<T> createDelayedAnimation<T>({
    required AnimationController controller,
    required Tween<T> tween,
    double delay = 0.0,
    Curve curve = Curves.easeInOut,
  }) {
    final start = delay;
    final end = 1.0;
    
    return tween.animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(start, end, curve: curve),
      ),
    );
  }
  
  static void staggeredAnimation({
    required List<AnimationController> controllers,
    required Duration staggerDelay,
    bool reverse = false,
  }) {
    for (int i = 0; i < controllers.length; i++) {
      final delay = reverse 
        ? staggerDelay * (controllers.length - 1 - i)
        : staggerDelay * i;
      
      Timer(delay, () {
        controllers[i].forward();
      });
    }
  }
}
```

## Testing Animations

### 1. Animation Testing

```dart
// test/animation_test.dart
void main() {
  group('Animation Tests', () {
    testWidgets('should animate scale from 0 to 1', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: AnimatedWidgetExample(),
      ));
      
      // Find the animated widget
      final animatedWidget = find.byType(AnimatedWidgetExample);
      expect(animatedWidget, findsOneWidget);
      
      // Trigger animation
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();
      
      // Test animation at different points
      await tester.pump(const Duration(milliseconds: 500));
      // Add assertions for intermediate state
      
      await tester.pump(const Duration(milliseconds: 1000));
      // Add assertions for final state
    });
  });
}
```

## Best Practices

### 1. Animation Guidelines

```dart
// Follow Material Design motion principles
class MaterialMotion {
  static const Duration shortDuration = Duration(milliseconds: 150);
  static const Duration mediumDuration = Duration(milliseconds: 300);
  static const Duration longDuration = Duration(milliseconds: 500);
  
  static const Curve standardCurve = Curves.easeInOut;
  static const Curve accelerateCurve = Curves.easeIn;
  static const Curve decelerateCurve = Curves.easeOut;
}
```

### 2. Memory Management

```dart
// Always dispose animation controllers
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}

// Use SingleTickerProviderStateMixin for single animations
// Use TickerProviderStateMixin for multiple animations
```

Animations should enhance user experience without overwhelming it. Use them purposefully to guide attention and provide feedback.
