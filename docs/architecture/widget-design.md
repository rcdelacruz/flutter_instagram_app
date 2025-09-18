# Flutter Widget Design

Comprehensive guide to designing reusable, performant, and maintainable widgets in Flutter applications.

## Widget Design Principles

### 1. Single Responsibility

Each widget should have one clear purpose and responsibility.

```dart
// Good: Focused widget
class UserAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;
  final VoidCallback? onTap;
  
  const UserAvatar({
    super.key,
    required this.imageUrl,
    this.size = 40,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(imageUrl),
      ),
    );
  }
}

// Avoid: Widget doing too many things
class UserProfileSection extends StatelessWidget {
  // Too many responsibilities: avatar, name, bio, follow button, posts count
}
```

### 2. Composition Over Inheritance

Build complex widgets by composing simpler widgets.

```dart
// Good: Composition
class PostCard extends StatelessWidget {
  final Post post;
  
  const PostCard({super.key, required this.post});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostHeader(user: post.user, timestamp: post.createdAt),
          PostImage(imageUrl: post.imageUrl),
          PostActions(post: post),
          PostCaption(caption: post.caption),
          PostComments(comments: post.comments),
        ],
      ),
    );
  }
}

// Individual components
class PostHeader extends StatelessWidget {
  final User user;
  final DateTime timestamp;
  
  const PostHeader({super.key, required this.user, required this.timestamp});
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: UserAvatar(imageUrl: user.avatarUrl),
      title: Text(user.username),
      subtitle: Text(timeago.format(timestamp)),
      trailing: const Icon(Icons.more_vert),
    );
  }
}
```

### 3. Immutability

Design widgets to be immutable for better performance and predictability.

```dart
// Good: Immutable widget
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  
  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
  });
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
      ),
      child: Text(text),
    );
  }
}
```

## Widget Categories

### 1. Presentation Widgets

Pure UI widgets that display data without business logic.

```dart
class PostImage extends StatelessWidget {
  final String imageUrl;
  final double? aspectRatio;
  final BoxFit fit;
  
  const PostImage({
    super.key,
    required this.imageUrl,
    this.aspectRatio,
    this.fit = BoxFit.cover,
  });
  
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio ?? 1.0,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        placeholder: (context, url) => Container(
          color: Colors.grey[300],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        ),
      ),
    );
  }
}
```

### 2. Interactive Widgets

Widgets that handle user interactions and state changes.

```dart
class LikeButton extends StatefulWidget {
  final bool isLiked;
  final int likeCount;
  final ValueChanged<bool> onLikeChanged;
  
  const LikeButton({
    super.key,
    required this.isLiked,
    required this.likeCount,
    required this.onLikeChanged,
  });
  
  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _handleTap() {
    widget.onLikeChanged(!widget.isLiked);
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: IconButton(
                onPressed: _handleTap,
                icon: Icon(
                  widget.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: widget.isLiked ? Colors.red : null,
                ),
              ),
            );
          },
        ),
        Text('${widget.likeCount}'),
      ],
    );
  }
}
```

### 3. Layout Widgets

Widgets that organize and structure other widgets.

```dart
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= 800) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

class GridLayout extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double spacing;
  
  const GridLayout({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.spacing = 8.0,
  });
  
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}
```

## Performance Optimization

### 1. Use const Constructors

```dart
// Good: const constructor
class AppLogo extends StatelessWidget {
  const AppLogo({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const FlutterLogo(size: 100);
  }
}

// Usage
const AppLogo() // Widget won't rebuild unnecessarily
```

### 2. Implement RepaintBoundary

```dart
class ExpensiveWidget extends StatelessWidget {
  const ExpensiveWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: ComplexPainter(),
        child: const SizedBox(width: 200, height: 200),
      ),
    );
  }
}
```

### 3. Use Builder Widgets for Localized Rebuilds

```dart
class OptimizedCounter extends StatefulWidget {
  @override
  State<OptimizedCounter> createState() => _OptimizedCounterState();
}

class _OptimizedCounterState extends State<OptimizedCounter> {
  int _counter = 0;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('This text never rebuilds'),
        Builder(
          builder: (context) {
            // Only this part rebuilds when counter changes
            return Text('Counter: $_counter');
          },
        ),
        ElevatedButton(
          onPressed: () => setState(() => _counter++),
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
```

### 4. Lazy Loading with ListView.builder

```dart
class PostsList extends StatelessWidget {
  final List<Post> posts;
  
  const PostsList({super.key, required this.posts});
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        // Only builds visible items
        return PostCard(post: posts[index]);
      },
    );
  }
}
```

## Accessibility

### 1. Semantic Labels

```dart
class AccessibleButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  
  const AccessibleButton({
    super.key,
    required this.text,
    this.onPressed,
    this.semanticLabel,
  });
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? text,
      button: true,
      enabled: onPressed != null,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}
```

### 2. Focus Management

```dart
class SearchField extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  
  const SearchField({super.key, this.onChanged});
  
  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late FocusNode _focusNode;
  late TextEditingController _controller;
  
  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = TextEditingController();
  }
  
  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: InputDecoration(
        hintText: 'Search...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _controller.clear();
            widget.onChanged?.call('');
          },
        ),
      ),
      onChanged: widget.onChanged,
    );
  }
}
```

## Testing Widgets

### 1. Widget Tests

```dart
void main() {
  group('UserAvatar', () {
    testWidgets('should display user avatar', (tester) async {
      const imageUrl = 'https://example.com/avatar.jpg';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: UserAvatar(imageUrl: imageUrl),
        ),
      );
      
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byType(NetworkImage), findsOneWidget);
    });
    
    testWidgets('should handle tap events', (tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: UserAvatar(
            imageUrl: 'https://example.com/avatar.jpg',
            onTap: () => tapped = true,
          ),
        ),
      );
      
      await tester.tap(find.byType(UserAvatar));
      expect(tapped, isTrue);
    });
  });
}
```

### 2. Golden Tests

```dart
void main() {
  group('PostCard Golden Tests', () {
    testWidgets('should match golden file', (tester) async {
      final post = Post(
        id: '1',
        user: User(username: 'testuser'),
        imageUrl: 'https://example.com/image.jpg',
        caption: 'Test caption',
        createdAt: DateTime(2023, 1, 1),
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostCard(post: post),
          ),
        ),
      );
      
      await expectLater(
        find.byType(PostCard),
        matchesGoldenFile('post_card.png'),
      );
    });
  });
}
```

## Widget Patterns

### 1. Builder Pattern

```dart
class CustomDialog {
  String? title;
  String? content;
  List<Widget> actions = [];
  
  CustomDialog setTitle(String title) {
    this.title = title;
    return this;
  }
  
  CustomDialog setContent(String content) {
    this.content = content;
    return this;
  }
  
  CustomDialog addAction(Widget action) {
    actions.add(action);
    return this;
  }
  
  Widget build() {
    return AlertDialog(
      title: title != null ? Text(title!) : null,
      content: content != null ? Text(content!) : null,
      actions: actions,
    );
  }
}

// Usage
final dialog = CustomDialog()
    .setTitle('Confirm')
    .setContent('Are you sure?')
    .addAction(TextButton(
      onPressed: () {},
      child: const Text('Cancel'),
    ))
    .addAction(TextButton(
      onPressed: () {},
      child: const Text('OK'),
    ))
    .build();
```

### 2. Factory Pattern

```dart
abstract class ButtonFactory {
  static Widget primary({
    required String text,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      child: Text(text),
    );
  }
  
  static Widget secondary({
    required String text,
    required VoidCallback? onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
  
  static Widget danger({
    required String text,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      child: Text(text),
    );
  }
}
```

### 3. Mixin Pattern

```dart
mixin LoadingStateMixin<T extends StatefulWidget> on State<T> {
  bool _isLoading = false;
  
  bool get isLoading => _isLoading;
  
  void setLoading(bool loading) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
      });
    }
  }
  
  Widget buildWithLoading(Widget child) {
    return Stack(
      children: [
        child,
        if (_isLoading)
          Container(
            color: Colors.black26,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}

// Usage
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> with LoadingStateMixin {
  @override
  Widget build(BuildContext context) {
    return buildWithLoading(
      Scaffold(
        body: const Center(child: Text('Content')),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            setLoading(true);
            await Future.delayed(const Duration(seconds: 2));
            setLoading(false);
          },
          child: const Icon(Icons.refresh),
        ),
      ),
    );
  }
}
```

## Best Practices

### 1. Widget Naming

```dart
// Good: Descriptive names
class UserProfileHeader extends StatelessWidget {}
class PostActionButtons extends StatelessWidget {}
class CommentInputField extends StatelessWidget {}

// Avoid: Generic names
class Container extends StatelessWidget {} // Conflicts with Flutter's Container
class Widget extends StatelessWidget {} // Too generic
```

### 2. Parameter Validation

```dart
class ProgressBar extends StatelessWidget {
  final double progress;
  final Color? color;
  
  const ProgressBar({
    super.key,
    required this.progress,
    this.color,
  }) : assert(progress >= 0.0 && progress <= 1.0, 'Progress must be between 0.0 and 1.0');
  
  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: progress,
      backgroundColor: Colors.grey[300],
      valueColor: AlwaysStoppedAnimation<Color>(
        color ?? Theme.of(context).primaryColor,
      ),
    );
  }
}
```

### 3. Documentation

```dart
/// A customizable avatar widget that displays a user's profile image.
/// 
/// The [UserAvatar] widget displays a circular image with optional tap handling.
/// It supports network images with automatic fallback to a default avatar.
/// 
/// Example usage:
/// ```dart
/// UserAvatar(
///   imageUrl: 'https://example.com/avatar.jpg',
///   size: 50,
///   onTap: () => print('Avatar tapped'),
/// )
/// ```
class UserAvatar extends StatelessWidget {
  /// The URL of the user's avatar image.
  final String imageUrl;
  
  /// The diameter of the avatar. Defaults to 40.
  final double size;
  
  /// Callback function called when the avatar is tapped.
  final VoidCallback? onTap;
  
  const UserAvatar({
    super.key,
    required this.imageUrl,
    this.size = 40,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    // Implementation...
  }
}
```

## Next Steps

1. **Design your widget hierarchy** following composition principles
2. **Implement performance optimizations** for complex widgets
3. **Add accessibility features** to all interactive widgets
4. **Write comprehensive tests** for your custom widgets
5. **Proceed to [Supabase Integration](../data/supabase-integration.md)**

---

**Pro Tip**: Start with simple, focused widgets and compose them into more complex UI elements. This approach leads to better maintainability and reusability.
