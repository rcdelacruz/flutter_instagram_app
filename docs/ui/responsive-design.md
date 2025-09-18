# Responsive Design

Comprehensive guide to creating responsive Flutter applications that work seamlessly across different screen sizes and orientations.

## Overview

Responsive design ensures your Flutter app provides an optimal user experience across phones, tablets, desktops, and web browsers. This guide covers adaptive layouts, breakpoints, and responsive patterns.

## Screen Size Categories

### Device Breakpoints

```dart
// lib/utils/screen_utils.dart
class ScreenUtils {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;
  
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }
  
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return ScreenType.mobile;
    if (width < tabletBreakpoint) return ScreenType.tablet;
    return ScreenType.desktop;
  }
}

enum ScreenType { mobile, tablet, desktop }
```

## Responsive Widgets

### 1. Responsive Builder

```dart
// lib/widgets/responsive_builder.dart
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  
  const ResponsiveBuilder({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ScreenUtils.tabletBreakpoint) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= ScreenUtils.mobileBreakpoint) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

// Usage
ResponsiveBuilder(
  mobile: MobileLayout(),
  tablet: TabletLayout(),
  desktop: DesktopLayout(),
)
```

### 2. Responsive Grid

```dart
// lib/widgets/responsive_grid.dart
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  
  const ResponsiveGrid({
    Key? key,
    required this.children,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
        
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
            childAspectRatio: 1.0,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
  
  int _getCrossAxisCount(double width) {
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }
}
```

### 3. Adaptive Container

```dart
// lib/widgets/adaptive_container.dart
class AdaptiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? mobilePadding;
  final EdgeInsets? tabletPadding;
  final EdgeInsets? desktopPadding;
  
  const AdaptiveContainer({
    Key? key,
    required this.child,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    EdgeInsets padding;
    
    if (ScreenUtils.isDesktop(context)) {
      padding = desktopPadding ?? const EdgeInsets.all(24.0);
    } else if (ScreenUtils.isTablet(context)) {
      padding = tabletPadding ?? const EdgeInsets.all(16.0);
    } else {
      padding = mobilePadding ?? const EdgeInsets.all(12.0);
    }
    
    return Container(
      padding: padding,
      child: child,
    );
  }
}
```

## Layout Patterns

### 1. Adaptive Navigation

```dart
// lib/widgets/adaptive_navigation.dart
class AdaptiveNavigation extends StatelessWidget {
  final List<NavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  
  const AdaptiveNavigation({
    Key? key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (ScreenUtils.isDesktop(context)) {
      return NavigationRail(
        selectedIndex: selectedIndex,
        onDestinationSelected: onItemSelected,
        destinations: items.map((item) => NavigationRailDestination(
          icon: Icon(item.icon),
          label: Text(item.label),
        )).toList(),
      );
    } else {
      return BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemSelected,
        items: items.map((item) => BottomNavigationBarItem(
          icon: Icon(item.icon),
          label: item.label,
        )).toList(),
      );
    }
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  
  NavigationItem({required this.icon, required this.label});
}
```

### 2. Responsive App Bar

```dart
// lib/widgets/responsive_app_bar.dart
class ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  
  const ResponsiveAppBar({
    Key? key,
    required this.title,
    this.actions,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (ScreenUtils.isMobile(context)) {
      return AppBar(
        title: Text(title),
        actions: actions,
      );
    } else {
      return AppBar(
        title: Text(title),
        centerTitle: false,
        actions: [
          ...?actions,
          if (ScreenUtils.isDesktop(context))
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () {},
            ),
        ],
      );
    }
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
```

## Orientation Handling

### 1. Orientation Builder

```dart
// lib/widgets/orientation_builder.dart
class OrientationAwareWidget extends StatelessWidget {
  final Widget portrait;
  final Widget? landscape;
  
  const OrientationAwareWidget({
    Key? key,
    required this.portrait,
    this.landscape,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape) {
          return landscape ?? portrait;
        }
        return portrait;
      },
    );
  }
}
```

### 2. Adaptive List/Grid

```dart
// lib/widgets/adaptive_list_grid.dart
class AdaptiveListGrid extends StatelessWidget {
  final List<Widget> children;
  final ScrollController? controller;
  
  const AdaptiveListGrid({
    Key? key,
    required this.children,
    this.controller,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape && ScreenUtils.isTablet(context)) {
          return GridView.count(
            controller: controller,
            crossAxisCount: 2,
            children: children,
          );
        }
        return ListView(
          controller: controller,
          children: children,
        );
      },
    );
  }
}
```

## Typography Scaling

### 1. Responsive Text

```dart
// lib/widgets/responsive_text.dart
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double? mobileSize;
  final double? tabletSize;
  final double? desktopSize;
  
  const ResponsiveText(
    this.text, {
    Key? key,
    this.style,
    this.mobileSize,
    this.tabletSize,
    this.desktopSize,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    double fontSize;
    
    if (ScreenUtils.isDesktop(context)) {
      fontSize = desktopSize ?? 18.0;
    } else if (ScreenUtils.isTablet(context)) {
      fontSize = tabletSize ?? 16.0;
    } else {
      fontSize = mobileSize ?? 14.0;
    }
    
    return Text(
      text,
      style: (style ?? const TextStyle()).copyWith(fontSize: fontSize),
    );
  }
}
```

### 2. Adaptive Theme

```dart
// lib/theme/adaptive_theme.dart
class AdaptiveTheme {
  static ThemeData getTheme(BuildContext context) {
    final textScaleFactor = ScreenUtils.isDesktop(context) ? 1.1 : 1.0;
    
    return ThemeData(
      textTheme: Theme.of(context).textTheme.apply(
        fontSizeFactor: textScaleFactor,
      ),
      appBarTheme: AppBarTheme(
        toolbarHeight: ScreenUtils.isMobile(context) ? 56.0 : 64.0,
      ),
    );
  }
}
```

## Image Handling

### 1. Responsive Images

```dart
// lib/widgets/responsive_image.dart
class ResponsiveImage extends StatelessWidget {
  final String imagePath;
  final BoxFit? fit;
  
  const ResponsiveImage({
    Key? key,
    required this.imagePath,
    this.fit,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        String imageSuffix = '';
        
        if (constraints.maxWidth > 800) {
          imageSuffix = '@3x';
        } else if (constraints.maxWidth > 400) {
          imageSuffix = '@2x';
        }
        
        return Image.asset(
          '${imagePath}$imageSuffix.png',
          fit: fit ?? BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(imagePath, fit: fit ?? BoxFit.cover);
          },
        );
      },
    );
  }
}
```

## Testing Responsive Design

### 1. Device Preview

```dart
// lib/main.dart
import 'package:device_preview/device_preview.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      home: HomeScreen(),
    );
  }
}
```

### 2. Responsive Testing

```dart
// test/responsive_test.dart
void main() {
  group('Responsive Widget Tests', () {
    testWidgets('should show mobile layout on small screen', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      
      await tester.pumpWidget(MaterialApp(
        home: ResponsiveBuilder(
          mobile: Text('Mobile'),
          tablet: Text('Tablet'),
          desktop: Text('Desktop'),
        ),
      ));
      
      expect(find.text('Mobile'), findsOneWidget);
      expect(find.text('Tablet'), findsNothing);
      expect(find.text('Desktop'), findsNothing);
    });
    
    testWidgets('should show tablet layout on medium screen', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      
      await tester.pumpWidget(MaterialApp(
        home: ResponsiveBuilder(
          mobile: Text('Mobile'),
          tablet: Text('Tablet'),
          desktop: Text('Desktop'),
        ),
      ));
      
      expect(find.text('Tablet'), findsOneWidget);
    });
  });
}
```

## Best Practices

### 1. Performance Considerations

```dart
// Use const constructors where possible
const ResponsiveBuilder(
  mobile: const MobileWidget(),
  tablet: const TabletWidget(),
);

// Avoid rebuilding expensive widgets
class ExpensiveWidget extends StatelessWidget {
  const ExpensiveWidget({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return const SizedBox(); // Expensive widget content
  }
}
```

### 2. Accessibility

```dart
// Ensure touch targets are appropriately sized
class AccessibleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  
  const AccessibleButton({
    Key? key,
    required this.onPressed,
    required this.child,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final minSize = ScreenUtils.isMobile(context) ? 48.0 : 44.0;
    
    return SizedBox(
      width: minSize,
      height: minSize,
      child: ElevatedButton(
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
```

### 3. Consistent Spacing

```dart
// lib/theme/spacing.dart
class Spacing {
  static double xs(BuildContext context) => ScreenUtils.isMobile(context) ? 4.0 : 6.0;
  static double sm(BuildContext context) => ScreenUtils.isMobile(context) ? 8.0 : 12.0;
  static double md(BuildContext context) => ScreenUtils.isMobile(context) ? 16.0 : 20.0;
  static double lg(BuildContext context) => ScreenUtils.isMobile(context) ? 24.0 : 32.0;
  static double xl(BuildContext context) => ScreenUtils.isMobile(context) ? 32.0 : 48.0;
}
```

Responsive design is crucial for creating Flutter apps that work well across all devices. Start with mobile-first design and progressively enhance for larger screens.
