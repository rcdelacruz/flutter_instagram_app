# Styling Systems

Comprehensive guide to creating consistent, maintainable styling systems in Flutter applications.

## Overview

A well-designed styling system ensures consistency across your Flutter app while making it easy to maintain and update visual elements. This guide covers theme management, design tokens, and component styling.

## Theme Architecture

### 1. Base Theme Structure

```dart
// lib/theme/app_theme.dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _lightColorScheme,
    textTheme: _textTheme,
    appBarTheme: _appBarTheme,
    elevatedButtonTheme: _elevatedButtonTheme,
    inputDecorationTheme: _inputDecorationTheme,
    cardTheme: _cardTheme,
  );
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _darkColorScheme,
    textTheme: _textTheme,
    appBarTheme: _appBarThemeDark,
    elevatedButtonTheme: _elevatedButtonTheme,
    inputDecorationTheme: _inputDecorationThemeDark,
    cardTheme: _cardThemeDark,
  );
}
```

### 2. Color System

```dart
// lib/theme/app_colors.dart
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryVariant = Color(0xFF1565C0);
  static const Color onPrimary = Color(0xFFFFFFFF);
  
  // Secondary colors
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryVariant = Color(0xFF018786);
  static const Color onSecondary = Color(0xFF000000);
  
  // Surface colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF000000);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  
  // Error colors
  static const Color error = Color(0xFFB00020);
  static const Color onError = Color(0xFFFFFFFF);
  
  // Neutral colors
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFEEEEEE);
  static const Color neutral300 = Color(0xFFE0E0E0);
  static const Color neutral400 = Color(0xFFBDBDBD);
  static const Color neutral500 = Color(0xFF9E9E9E);
  static const Color neutral600 = Color(0xFF757575);
  static const Color neutral700 = Color(0xFF616161);
  static const Color neutral800 = Color(0xFF424242);
  static const Color neutral900 = Color(0xFF212121);
  
  // Semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
}

// Color schemes
const ColorScheme _lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: AppColors.primary,
  onPrimary: AppColors.onPrimary,
  secondary: AppColors.secondary,
  onSecondary: AppColors.onSecondary,
  error: AppColors.error,
  onError: AppColors.onError,
  surface: AppColors.surface,
  onSurface: AppColors.onSurface,
);

const ColorScheme _darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: AppColors.primary,
  onPrimary: AppColors.onPrimary,
  secondary: AppColors.secondary,
  onSecondary: AppColors.onSecondary,
  error: AppColors.error,
  onError: AppColors.onError,
  surface: Color(0xFF121212),
  onSurface: Color(0xFFFFFFFF),
);
```

### 3. Typography System

```dart
// lib/theme/app_typography.dart
class AppTypography {
  static const String fontFamily = 'Inter';
  
  // Font weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  
  // Text styles
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: bold,
    height: 1.25,
    letterSpacing: -0.5,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 28,
    fontWeight: bold,
    height: 1.29,
    letterSpacing: -0.5,
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: 24,
    fontWeight: semiBold,
    height: 1.33,
    letterSpacing: -0.5,
  );
  
  static const TextStyle h4 = TextStyle(
    fontSize: 20,
    fontWeight: semiBold,
    height: 1.4,
    letterSpacing: -0.25,
  );
  
  static const TextStyle h5 = TextStyle(
    fontSize: 18,
    fontWeight: medium,
    height: 1.44,
    letterSpacing: -0.25,
  );
  
  static const TextStyle h6 = TextStyle(
    fontSize: 16,
    fontWeight: medium,
    height: 1.5,
    letterSpacing: -0.25,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: regular,
    height: 1.5,
    letterSpacing: 0,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: regular,
    height: 1.43,
    letterSpacing: 0,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: regular,
    height: 1.33,
    letterSpacing: 0.25,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: regular,
    height: 1.33,
    letterSpacing: 0.4,
  );
  
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: medium,
    height: 1.6,
    letterSpacing: 1.5,
  );
}

// Text theme
const TextTheme _textTheme = TextTheme(
  displayLarge: AppTypography.h1,
  displayMedium: AppTypography.h2,
  displaySmall: AppTypography.h3,
  headlineLarge: AppTypography.h4,
  headlineMedium: AppTypography.h5,
  headlineSmall: AppTypography.h6,
  bodyLarge: AppTypography.bodyLarge,
  bodyMedium: AppTypography.bodyMedium,
  bodySmall: AppTypography.bodySmall,
  labelLarge: AppTypography.caption,
  labelMedium: AppTypography.overline,
);
```

### 4. Spacing System

```dart
// lib/theme/app_spacing.dart
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
  
  // Semantic spacing
  static const double elementSpacing = sm;
  static const double sectionSpacing = lg;
  static const double pageSpacing = xl;
  
  // Edge insets
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);
  
  // Horizontal padding
  static const EdgeInsets horizontalXS = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLG = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXL = EdgeInsets.symmetric(horizontal: xl);
  
  // Vertical padding
  static const EdgeInsets verticalXS = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLG = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXL = EdgeInsets.symmetric(vertical: xl);
}
```

### 5. Border Radius System

```dart
// lib/theme/app_radius.dart
class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  
  // Border radius
  static const BorderRadius radiusXS = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius radiusSM = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius radiusMD = BorderRadius.all(Radius.circular(md));
  static const BorderRadius radiusLG = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius radiusXL = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius radiusXXL = BorderRadius.all(Radius.circular(xxl));
  
  // Circular radius
  static const BorderRadius circular = BorderRadius.all(Radius.circular(999));
}
```

## Component Themes

### 1. Button Themes

```dart
// lib/theme/component_themes/button_theme.dart
class AppButtonTheme {
  static ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: AppColors.onPrimary,
      backgroundColor: AppColors.primary,
      elevation: 2,
      shadowColor: AppColors.primary.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusMD,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      textStyle: AppTypography.bodyMedium.copyWith(
        fontWeight: AppTypography.semiBold,
      ),
    ),
  );
  
  static OutlinedButtonThemeData outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusMD,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      textStyle: AppTypography.bodyMedium.copyWith(
        fontWeight: AppTypography.semiBold,
      ),
    ),
  );
  
  static TextButtonThemeData textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      textStyle: AppTypography.bodyMedium.copyWith(
        fontWeight: AppTypography.semiBold,
      ),
    ),
  );
}
```

### 2. Input Themes

```dart
// lib/theme/component_themes/input_theme.dart
class AppInputTheme {
  static InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.neutral50,
    border: OutlineInputBorder(
      borderRadius: AppRadius.radiusMD,
      borderSide: const BorderSide(color: AppColors.neutral300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppRadius.radiusMD,
      borderSide: const BorderSide(color: AppColors.neutral300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppRadius.radiusMD,
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: AppRadius.radiusMD,
      borderSide: const BorderSide(color: AppColors.error),
    ),
    contentPadding: AppSpacing.paddingMD,
    labelStyle: AppTypography.bodyMedium.copyWith(
      color: AppColors.neutral600,
    ),
    hintStyle: AppTypography.bodyMedium.copyWith(
      color: AppColors.neutral500,
    ),
  );
}
```

### 3. Card Themes

```dart
// lib/theme/component_themes/card_theme.dart
class AppCardTheme {
  static CardTheme cardTheme = CardTheme(
    elevation: 2,
    shadowColor: AppColors.neutral900.withOpacity(0.1),
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.radiusLG,
    ),
    margin: AppSpacing.paddingMD,
  );
}
```

## Custom Styled Components

### 1. Styled Container

```dart
// lib/widgets/styled_container.dart
class StyledContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  
  const StyledContainer({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
    this.border,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? AppSpacing.paddingMD,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
        borderRadius: borderRadius ?? AppRadius.radiusMD,
        boxShadow: boxShadow,
        border: border,
      ),
      child: child,
    );
  }
}
```

### 2. Styled Text

```dart
// lib/widgets/styled_text.dart
class StyledText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? color;
  final FontWeight? fontWeight;
  final double? fontSize;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  
  const StyledText(
    this.text, {
    Key? key,
    this.style,
    this.color,
    this.fontWeight,
    this.fontSize,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);
  
  // Named constructors for common text styles
  const StyledText.h1(
    this.text, {
    Key? key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = AppTypography.h1,
       fontWeight = null,
       fontSize = null,
       super(key: key);
  
  const StyledText.h2(
    this.text, {
    Key? key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = AppTypography.h2,
       fontWeight = null,
       fontSize = null,
       super(key: key);
  
  const StyledText.body(
    this.text, {
    Key? key,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = AppTypography.bodyMedium,
       fontSize = null,
       super(key: key);
  
  const StyledText.caption(
    this.text, {
    Key? key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = AppTypography.caption,
       fontWeight = null,
       fontSize = null,
       super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final effectiveStyle = (style ?? AppTypography.bodyMedium).copyWith(
      color: color,
      fontWeight: fontWeight,
      fontSize: fontSize,
    );
    
    return Text(
      text,
      style: effectiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
```

## Theme Extensions

### 1. Custom Theme Extension

```dart
// lib/theme/custom_theme_extension.dart
@immutable
class CustomThemeExtension extends ThemeExtension<CustomThemeExtension> {
  final Color? brandColor;
  final Color? successColor;
  final Color? warningColor;
  final Color? infoColor;
  final double? customSpacing;
  
  const CustomThemeExtension({
    this.brandColor,
    this.successColor,
    this.warningColor,
    this.infoColor,
    this.customSpacing,
  });
  
  @override
  CustomThemeExtension copyWith({
    Color? brandColor,
    Color? successColor,
    Color? warningColor,
    Color? infoColor,
    double? customSpacing,
  }) {
    return CustomThemeExtension(
      brandColor: brandColor ?? this.brandColor,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      infoColor: infoColor ?? this.infoColor,
      customSpacing: customSpacing ?? this.customSpacing,
    );
  }
  
  @override
  CustomThemeExtension lerp(ThemeExtension<CustomThemeExtension>? other, double t) {
    if (other is! CustomThemeExtension) {
      return this;
    }
    
    return CustomThemeExtension(
      brandColor: Color.lerp(brandColor, other.brandColor, t),
      successColor: Color.lerp(successColor, other.successColor, t),
      warningColor: Color.lerp(warningColor, other.warningColor, t),
      infoColor: Color.lerp(infoColor, other.infoColor, t),
      customSpacing: lerpDouble(customSpacing, other.customSpacing, t),
    );
  }
  
  static const light = CustomThemeExtension(
    brandColor: AppColors.primary,
    successColor: AppColors.success,
    warningColor: AppColors.warning,
    infoColor: AppColors.info,
    customSpacing: 20.0,
  );
  
  static const dark = CustomThemeExtension(
    brandColor: AppColors.primary,
    successColor: AppColors.success,
    warningColor: AppColors.warning,
    infoColor: AppColors.info,
    customSpacing: 20.0,
  );
}

// Usage
extension CustomThemeExtensionGetter on ThemeData {
  CustomThemeExtension get customTheme =>
      extension<CustomThemeExtension>() ?? CustomThemeExtension.light;
}
```

## Responsive Styling

### 1. Responsive Values

```dart
// lib/theme/responsive_values.dart
class ResponsiveValues {
  static double getSpacing(BuildContext context, {
    double mobile = AppSpacing.md,
    double tablet = AppSpacing.lg,
    double desktop = AppSpacing.xl,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1024) return desktop;
    if (screenWidth > 600) return tablet;
    return mobile;
  }
  
  static double getFontSize(BuildContext context, {
    double mobile = 14,
    double tablet = 16,
    double desktop = 18,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1024) return desktop;
    if (screenWidth > 600) return tablet;
    return mobile;
  }
}
```

## Theme Management

### 1. Theme Provider

```dart
// lib/providers/theme_provider.dart
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;
  
  void setThemeMode(ThemeMode themeMode) {
    _themeMode = themeMode;
    notifyListeners();
    _saveThemeMode(themeMode);
  }
  
  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }
  
  Future<void> _saveThemeMode(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', themeMode.toString());
  }
  
  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString('theme_mode');
    if (themeModeString != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == themeModeString,
        orElse: () => ThemeMode.system,
      );
      notifyListeners();
    }
  }
}
```

A well-structured styling system is the foundation of a maintainable Flutter app. Invest time in setting up consistent design tokens and component themes early in your project.
