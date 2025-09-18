# A/B Testing & Feature Flags

Comprehensive guide to implementing A/B testing and feature flags in Flutter applications for data-driven decision making.

## Overview

A/B testing allows you to compare different versions of features to determine which performs better. Feature flags enable controlled rollouts and quick feature toggles. This guide covers implementation strategies and best practices.

## Firebase Remote Config

### 1. Setup and Configuration

```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_remote_config: ^4.3.8
  firebase_analytics: ^10.7.4

dev_dependencies:
  firebase_remote_config_platform_interface: ^1.4.8
```

```dart
// lib/services/remote_config_service.dart
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class RemoteConfigService {
  static final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  // Initialize Remote Config
  static Future<void> initialize() async {
    try {
      // Set config settings
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      
      // Set default values
      await _remoteConfig.setDefaults(_getDefaultValues());
      
      // Fetch and activate
      await _remoteConfig.fetchAndActivate();
      
      print('Remote Config initialized successfully');
    } catch (e) {
      print('Failed to initialize Remote Config: $e');
    }
  }
  
  // Default configuration values
  static Map<String, dynamic> _getDefaultValues() {
    return {
      // Feature flags
      'enable_new_ui': false,
      'enable_dark_mode': true,
      'enable_push_notifications': true,
      'enable_social_login': false,
      
      // A/B test variants
      'button_color_variant': 'blue',
      'onboarding_flow_variant': 'standard',
      'pricing_display_variant': 'monthly',
      
      // Configuration values
      'max_upload_size_mb': 10,
      'api_timeout_seconds': 30,
      'cache_duration_hours': 24,
      'min_app_version': '1.0.0',
      
      // Content variations
      'welcome_message': 'Welcome to our app!',
      'cta_button_text': 'Get Started',
      'feature_announcement': '',
    };
  }
  
  // Get boolean feature flag
  static bool getFeatureFlag(String key) {
    return _remoteConfig.getBool(key);
  }
  
  // Get string configuration
  static String getString(String key) {
    return _remoteConfig.getString(key);
  }
  
  // Get integer configuration
  static int getInt(String key) {
    return _remoteConfig.getInt(key);
  }
  
  // Get double configuration
  static double getDouble(String key) {
    return _remoteConfig.getDouble(key);
  }
  
  // Force fetch latest config
  static Future<void> forceFetch() async {
    try {
      await _remoteConfig.fetch();
      await _remoteConfig.activate();
    } catch (e) {
      print('Failed to fetch remote config: $e');
    }
  }
  
  // Track feature flag usage
  static void trackFeatureFlagUsage(String flagName, bool value) {
    _analytics.logEvent(
      name: 'feature_flag_used',
      parameters: {
        'flag_name': flagName,
        'flag_value': value,
      },
    );
  }
  
  // Track A/B test variant
  static void trackABTestVariant(String testName, String variant) {
    _analytics.logEvent(
      name: 'ab_test_variant',
      parameters: {
        'test_name': testName,
        'variant': variant,
      },
    );
  }
}
```

### 2. Feature Flag Implementation

```dart
// lib/services/feature_flag_service.dart
class FeatureFlagService {
  // Check if feature is enabled
  static bool isFeatureEnabled(String featureName) {
    final isEnabled = RemoteConfigService.getFeatureFlag('enable_$featureName');
    
    // Track usage
    RemoteConfigService.trackFeatureFlagUsage('enable_$featureName', isEnabled);
    
    return isEnabled;
  }
  
  // Get A/B test variant
  static String getABTestVariant(String testName) {
    final variant = RemoteConfigService.getString('${testName}_variant');
    
    // Track variant assignment
    RemoteConfigService.trackABTestVariant(testName, variant);
    
    return variant;
  }
  
  // Feature-specific flags
  static bool get isNewUIEnabled => isFeatureEnabled('new_ui');
  static bool get isDarkModeEnabled => isFeatureEnabled('dark_mode');
  static bool get isPushNotificationsEnabled => isFeatureEnabled('push_notifications');
  static bool get isSocialLoginEnabled => isFeatureEnabled('social_login');
  
  // A/B test variants
  static String get buttonColorVariant => getABTestVariant('button_color');
  static String get onboardingFlowVariant => getABTestVariant('onboarding_flow');
  static String get pricingDisplayVariant => getABTestVariant('pricing_display');
  
  // Configuration values
  static int get maxUploadSizeMB => RemoteConfigService.getInt('max_upload_size_mb');
  static int get apiTimeoutSeconds => RemoteConfigService.getInt('api_timeout_seconds');
  static int get cacheDurationHours => RemoteConfigService.getInt('cache_duration_hours');
  static String get minAppVersion => RemoteConfigService.getString('min_app_version');
  
  // Content variations
  static String get welcomeMessage => RemoteConfigService.getString('welcome_message');
  static String get ctaButtonText => RemoteConfigService.getString('cta_button_text');
  static String get featureAnnouncement => RemoteConfigService.getString('feature_announcement');
}
```

## A/B Testing Framework

### 1. A/B Test Manager

```dart
// lib/services/ab_test_manager.dart
class ABTestManager {
  static final Map<String, ABTest> _activeTests = {};
  static final Map<String, String> _userVariants = {};
  
  // Initialize A/B tests
  static Future<void> initialize() async {
    await _loadActiveTests();
    await _assignUserToVariants();
  }
  
  // Load active tests from remote config
  static Future<void> _loadActiveTests() async {
    _activeTests.clear();
    
    // Define active A/B tests
    _activeTests['button_color_test'] = ABTest(
      name: 'button_color_test',
      variants: ['blue', 'green', 'red'],
      weights: [0.33, 0.33, 0.34],
      isActive: true,
    );
    
    _activeTests['onboarding_flow_test'] = ABTest(
      name: 'onboarding_flow_test',
      variants: ['standard', 'simplified', 'gamified'],
      weights: [0.4, 0.3, 0.3],
      isActive: FeatureFlagService.isFeatureEnabled('onboarding_ab_test'),
    );
    
    _activeTests['pricing_display_test'] = ABTest(
      name: 'pricing_display_test',
      variants: ['monthly', 'yearly', 'lifetime'],
      weights: [0.5, 0.3, 0.2],
      isActive: true,
    );
  }
  
  // Assign user to variants
  static Future<void> _assignUserToVariants() async {
    final userId = await _getUserId();
    
    for (final test in _activeTests.values) {
      if (test.isActive) {
        final variant = _assignVariant(test, userId);
        _userVariants[test.name] = variant;
        
        // Track assignment
        RemoteConfigService.trackABTestVariant(test.name, variant);
      }
    }
  }
  
  // Get user variant for a test
  static String getVariant(String testName) {
    return _userVariants[testName] ?? 'control';
  }
  
  // Check if user is in specific variant
  static bool isInVariant(String testName, String variant) {
    return getVariant(testName) == variant;
  }
  
  // Assign variant based on user ID and test weights
  static String _assignVariant(ABTest test, String userId) {
    final hash = userId.hashCode.abs();
    final bucket = (hash % 100) / 100.0;
    
    double cumulativeWeight = 0.0;
    for (int i = 0; i < test.variants.length; i++) {
      cumulativeWeight += test.weights[i];
      if (bucket <= cumulativeWeight) {
        return test.variants[i];
      }
    }
    
    return test.variants.last;
  }
  
  // Get user ID (from auth service or device ID)
  static Future<String> _getUserId() async {
    // This would typically come from your auth service
    // For anonymous users, use device ID or generate stable ID
    return 'user_123'; // Placeholder
  }
  
  // Track conversion event
  static void trackConversion(String testName, String eventName, {Map<String, dynamic>? parameters}) {
    final variant = getVariant(testName);
    
    FirebaseAnalytics.instance.logEvent(
      name: 'ab_test_conversion',
      parameters: {
        'test_name': testName,
        'variant': variant,
        'event_name': eventName,
        ...parameters ?? {},
      },
    );
  }
  
  // Get all active tests
  static Map<String, String> getAllVariants() {
    return Map.from(_userVariants);
  }
}

class ABTest {
  final String name;
  final List<String> variants;
  final List<double> weights;
  final bool isActive;
  
  ABTest({
    required this.name,
    required this.variants,
    required this.weights,
    required this.isActive,
  }) : assert(variants.length == weights.length);
}
```

### 2. A/B Test Widgets

```dart
// lib/widgets/ab_test_widget.dart
class ABTestWidget extends StatelessWidget {
  final String testName;
  final Map<String, Widget> variants;
  final Widget? fallback;
  
  const ABTestWidget({
    Key? key,
    required this.testName,
    required this.variants,
    this.fallback,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final variant = ABTestManager.getVariant(testName);
    
    return variants[variant] ?? fallback ?? const SizedBox.shrink();
  }
}

// Usage example
class ExampleABTestUsage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ABTestWidget(
      testName: 'button_color_test',
      variants: {
        'blue': ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          onPressed: () => _handleButtonPress('blue'),
          child: const Text('Get Started'),
        ),
        'green': ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () => _handleButtonPress('green'),
          child: const Text('Get Started'),
        ),
        'red': ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => _handleButtonPress('red'),
          child: const Text('Get Started'),
        ),
      },
      fallback: ElevatedButton(
        onPressed: () => _handleButtonPress('control'),
        child: const Text('Get Started'),
      ),
    );
  }
  
  void _handleButtonPress(String variant) {
    // Track conversion
    ABTestManager.trackConversion(
      'button_color_test',
      'button_clicked',
      parameters: {'variant': variant},
    );
    
    // Handle button press
    print('Button pressed: $variant');
  }
}
```

## Feature Toggle Implementation

### 1. Feature Toggle Widget

```dart
// lib/widgets/feature_toggle.dart
class FeatureToggle extends StatelessWidget {
  final String featureName;
  final Widget enabledChild;
  final Widget? disabledChild;
  final bool trackUsage;
  
  const FeatureToggle({
    Key? key,
    required this.featureName,
    required this.enabledChild,
    this.disabledChild,
    this.trackUsage = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isEnabled = FeatureFlagService.isFeatureEnabled(featureName);
    
    if (trackUsage) {
      // Track feature visibility
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FirebaseAnalytics.instance.logEvent(
          name: 'feature_visibility',
          parameters: {
            'feature_name': featureName,
            'is_enabled': isEnabled,
          },
        );
      });
    }
    
    if (isEnabled) {
      return enabledChild;
    } else {
      return disabledChild ?? const SizedBox.shrink();
    }
  }
}

// Usage example
class ExampleFeatureToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Standard feature toggle
        FeatureToggle(
          featureName: 'new_ui',
          enabledChild: const NewUIComponent(),
          disabledChild: const OldUIComponent(),
        ),
        
        // Feature toggle without fallback
        FeatureToggle(
          featureName: 'social_login',
          enabledChild: const SocialLoginButtons(),
        ),
        
        // Conditional feature with custom logic
        if (FeatureFlagService.isPushNotificationsEnabled)
          const NotificationSettings(),
      ],
    );
  }
}
```

### 2. Gradual Rollout

```dart
// lib/services/gradual_rollout_service.dart
class GradualRolloutService {
  // Check if user is in rollout percentage
  static bool isUserInRollout(String featureName, double percentage) {
    if (percentage >= 1.0) return true;
    if (percentage <= 0.0) return false;
    
    final userId = _getUserId();
    final hash = '$featureName$userId'.hashCode.abs();
    final bucket = (hash % 100) / 100.0;
    
    return bucket <= percentage;
  }
  
  // Get rollout percentage from remote config
  static double getRolloutPercentage(String featureName) {
    return RemoteConfigService.getDouble('${featureName}_rollout_percentage');
  }
  
  // Check if feature is enabled for user with gradual rollout
  static bool isFeatureEnabledWithRollout(String featureName) {
    final isGloballyEnabled = FeatureFlagService.isFeatureEnabled(featureName);
    if (!isGloballyEnabled) return false;
    
    final rolloutPercentage = getRolloutPercentage(featureName);
    return isUserInRollout(featureName, rolloutPercentage);
  }
  
  static String _getUserId() {
    // Get user ID from auth service or device ID
    return 'user_123'; // Placeholder
  }
}
```

## Analytics and Reporting

### 1. A/B Test Analytics

```dart
// lib/services/ab_test_analytics.dart
class ABTestAnalytics {
  // Track test exposure
  static void trackTestExposure(String testName, String variant) {
    FirebaseAnalytics.instance.logEvent(
      name: 'ab_test_exposure',
      parameters: {
        'test_name': testName,
        'variant': variant,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
  
  // Track conversion events
  static void trackConversion({
    required String testName,
    required String variant,
    required String conversionEvent,
    double? value,
    Map<String, dynamic>? additionalParameters,
  }) {
    FirebaseAnalytics.instance.logEvent(
      name: 'ab_test_conversion',
      parameters: {
        'test_name': testName,
        'variant': variant,
        'conversion_event': conversionEvent,
        'conversion_value': value,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        ...additionalParameters ?? {},
      },
    );
  }
  
  // Track user engagement
  static void trackEngagement({
    required String testName,
    required String variant,
    required String engagementType,
    Duration? duration,
    Map<String, dynamic>? metadata,
  }) {
    FirebaseAnalytics.instance.logEvent(
      name: 'ab_test_engagement',
      parameters: {
        'test_name': testName,
        'variant': variant,
        'engagement_type': engagementType,
        'duration_seconds': duration?.inSeconds,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        ...metadata ?? {},
      },
    );
  }
  
  // Track funnel steps
  static void trackFunnelStep({
    required String testName,
    required String variant,
    required String funnelStep,
    required int stepNumber,
    Map<String, dynamic>? stepData,
  }) {
    FirebaseAnalytics.instance.logEvent(
      name: 'ab_test_funnel_step',
      parameters: {
        'test_name': testName,
        'variant': variant,
        'funnel_step': funnelStep,
        'step_number': stepNumber,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        ...stepData ?? {},
      },
    );
  }
}
```

### 2. Test Results Dashboard

```dart
// lib/widgets/ab_test_dashboard.dart
class ABTestDashboard extends StatefulWidget {
  @override
  _ABTestDashboardState createState() => _ABTestDashboardState();
}

class _ABTestDashboardState extends State<ABTestDashboard> {
  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    
    return Scaffold(
      appBar: AppBar(title: const Text('A/B Test Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActiveTestsSection(),
            const SizedBox(height: 16),
            _buildFeatureFlagsSection(),
            const SizedBox(height: 16),
            _buildUserVariantsSection(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActiveTestsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Active A/B Tests', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...ABTestManager.getAllVariants().entries.map((entry) {
              return ListTile(
                title: Text(entry.key),
                trailing: Chip(label: Text(entry.value)),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureFlagsSection() {
    final flags = [
      'new_ui',
      'dark_mode',
      'push_notifications',
      'social_login',
    ];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Feature Flags', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...flags.map((flag) {
              final isEnabled = FeatureFlagService.isFeatureEnabled(flag);
              return ListTile(
                title: Text(flag),
                trailing: Switch(
                  value: isEnabled,
                  onChanged: null, // Read-only in this dashboard
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUserVariantsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User Variants', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Button Color: ${ABTestManager.getVariant('button_color_test')}'),
            Text('Onboarding: ${ABTestManager.getVariant('onboarding_flow_test')}'),
            Text('Pricing: ${ABTestManager.getVariant('pricing_display_test')}'),
          ],
        ),
      ),
    );
  }
}
```

## Best Practices

### 1. Test Planning

```dart
// lib/models/ab_test_plan.dart
class ABTestPlan {
  final String name;
  final String hypothesis;
  final String primaryMetric;
  final List<String> secondaryMetrics;
  final double minimumDetectableEffect;
  final double statisticalPower;
  final Duration plannedDuration;
  final int minimumSampleSize;
  
  ABTestPlan({
    required this.name,
    required this.hypothesis,
    required this.primaryMetric,
    required this.secondaryMetrics,
    required this.minimumDetectableEffect,
    required this.statisticalPower,
    required this.plannedDuration,
    required this.minimumSampleSize,
  });
}
```

### 2. Statistical Significance

```dart
// lib/utils/statistical_utils.dart
class StatisticalUtils {
  // Calculate statistical significance
  static double calculatePValue(int controlConversions, int controlTotal, 
                                int treatmentConversions, int treatmentTotal) {
    // Simplified z-test for proportions
    final p1 = controlConversions / controlTotal;
    final p2 = treatmentConversions / treatmentTotal;
    final pooledP = (controlConversions + treatmentConversions) / (controlTotal + treatmentTotal);
    
    final se = sqrt(pooledP * (1 - pooledP) * (1/controlTotal + 1/treatmentTotal));
    final z = (p2 - p1) / se;
    
    // This is a simplified calculation - use proper statistical libraries in production
    return 2 * (1 - _normalCDF(z.abs()));
  }
  
  static double _normalCDF(double x) {
    // Simplified normal CDF approximation
    return 0.5 * (1 + _erf(x / sqrt(2)));
  }
  
  static double _erf(double x) {
    // Simplified error function approximation
    final a1 = 0.254829592;
    final a2 = -0.284496736;
    final a3 = 1.421413741;
    final a4 = -1.453152027;
    final a5 = 1.061405429;
    final p = 0.3275911;
    
    final sign = x < 0 ? -1 : 1;
    x = x.abs();
    
    final t = 1.0 / (1.0 + p * x);
    final y = 1.0 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * exp(-x * x);
    
    return sign * y;
  }
}
```

A/B testing and feature flags enable data-driven development and safe feature rollouts. Implement proper tracking, statistical analysis, and gradual rollout strategies to make informed product decisions.
