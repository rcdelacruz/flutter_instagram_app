# Analytics Implementation

Comprehensive guide to implementing analytics in Flutter applications for user behavior tracking and business insights.

## Overview

Analytics help you understand user behavior, track app performance, and make data-driven decisions. This guide covers multiple analytics solutions and best practices.

## Analytics Providers

### 1. Firebase Analytics (Recommended)

Google's free analytics solution with deep integration.

#### Setup

```yaml
# pubspec.yaml
dependencies:
  firebase_analytics: ^10.7.4
  firebase_core: ^2.24.2
```

```dart
// lib/services/analytics_service.dart
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver observer = 
      FirebaseAnalyticsObserver(analytics: _analytics);

  // Track screen views
  static Future<void> setCurrentScreen(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // Track custom events
  static Future<void> logEvent(String name, Map<String, dynamic> parameters) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  // Track user properties
  static Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  // Set user ID
  static Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }
}
```

#### Implementation

```dart
// Track screen navigation
class AnalyticsNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name != null) {
      AnalyticsService.setCurrentScreen(route.settings.name!);
    }
  }
}

// In main.dart
MaterialApp(
  navigatorObservers: [
    AnalyticsService.observer,
    AnalyticsNavigatorObserver(),
  ],
  // ... rest of app
)
```

### 2. Mixpanel

Advanced analytics with real-time data and user segmentation.

#### Setup

```yaml
# pubspec.yaml
dependencies:
  mixpanel_flutter: ^2.1.1
```

```dart
// lib/services/mixpanel_service.dart
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class MixpanelService {
  static Mixpanel? _mixpanel;

  static Future<void> initialize(String token) async {
    _mixpanel = await Mixpanel.init(token, trackAutomaticEvents: true);
  }

  static void track(String eventName, [Map<String, dynamic>? properties]) {
    _mixpanel?.track(eventName, properties: properties);
  }

  static void identify(String userId) {
    _mixpanel?.identify(userId);
  }

  static void setUserProperties(Map<String, dynamic> properties) {
    _mixpanel?.getPeople().set(properties);
  }

  static void flush() {
    _mixpanel?.flush();
  }
}
```

### 3. Amplitude

Product analytics focused on user journey and retention.

#### Setup

```yaml
# pubspec.yaml
dependencies:
  amplitude_flutter: ^3.16.2
```

```dart
// lib/services/amplitude_service.dart
import 'package:amplitude_flutter/amplitude.dart';

class AmplitudeService {
  static final Amplitude _amplitude = Amplitude.getInstance();

  static Future<void> initialize(String apiKey) async {
    await _amplitude.init(apiKey);
  }

  static void logEvent(String eventType, [Map<String, dynamic>? eventProperties]) {
    _amplitude.logEvent(eventType, eventProperties: eventProperties);
  }

  static void setUserId(String userId) {
    _amplitude.setUserId(userId);
  }

  static void setUserProperties(Map<String, dynamic> userProperties) {
    _amplitude.setUserProperties(userProperties);
  }
}
```

## Event Tracking Strategy

### 1. Core Events

```dart
class AnalyticsEvents {
  // User lifecycle
  static const String userSignUp = 'user_sign_up';
  static const String userLogin = 'user_login';
  static const String userLogout = 'user_logout';
  
  // Content interaction
  static const String postCreated = 'post_created';
  static const String postLiked = 'post_liked';
  static const String postShared = 'post_shared';
  static const String postCommented = 'post_commented';
  
  // Navigation
  static const String screenView = 'screen_view';
  static const String buttonTap = 'button_tap';
  
  // Business metrics
  static const String purchaseCompleted = 'purchase_completed';
  static const String subscriptionStarted = 'subscription_started';
}

class AnalyticsParameters {
  static const String userId = 'user_id';
  static const String screenName = 'screen_name';
  static const String postId = 'post_id';
  static const String category = 'category';
  static const String value = 'value';
  static const String currency = 'currency';
}
```

### 2. Event Implementation

```dart
// lib/services/analytics_manager.dart
class AnalyticsManager {
  static final List<AnalyticsProvider> _providers = [];

  static void initialize() {
    _providers.addAll([
      FirebaseAnalyticsProvider(),
      MixpanelProvider(),
      AmplitudeProvider(),
    ]);
  }

  static Future<void> track(String event, [Map<String, dynamic>? parameters]) async {
    for (final provider in _providers) {
      await provider.track(event, parameters);
    }
  }

  static Future<void> setUserProperty(String name, String value) async {
    for (final provider in _providers) {
      await provider.setUserProperty(name, value);
    }
  }

  static Future<void> setUserId(String userId) async {
    for (final provider in _providers) {
      await provider.setUserId(userId);
    }
  }
}

abstract class AnalyticsProvider {
  Future<void> track(String event, Map<String, dynamic>? parameters);
  Future<void> setUserProperty(String name, String value);
  Future<void> setUserId(String userId);
}
```

### 3. Automatic Tracking

```dart
// lib/widgets/analytics_wrapper.dart
class AnalyticsWrapper extends StatefulWidget {
  final Widget child;
  final String screenName;
  final Map<String, dynamic>? screenParameters;

  const AnalyticsWrapper({
    Key? key,
    required this.child,
    required this.screenName,
    this.screenParameters,
  }) : super(key: key);

  @override
  _AnalyticsWrapperState createState() => _AnalyticsWrapperState();
}

class _AnalyticsWrapperState extends State<AnalyticsWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsManager.track(AnalyticsEvents.screenView, {
        AnalyticsParameters.screenName: widget.screenName,
        ...?widget.screenParameters,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// Usage
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnalyticsWrapper(
      screenName: 'home',
      child: Scaffold(
        // ... screen content
      ),
    );
  }
}
```

## User Segmentation

### 1. User Properties

```dart
class UserAnalytics {
  static Future<void> setUserSegment(User user) async {
    await AnalyticsManager.setUserProperty('user_type', user.type);
    await AnalyticsManager.setUserProperty('subscription_status', user.subscriptionStatus);
    await AnalyticsManager.setUserProperty('registration_date', user.registrationDate.toIso8601String());
    await AnalyticsManager.setUserProperty('country', user.country);
    await AnalyticsManager.setUserProperty('app_version', await _getAppVersion());
  }

  static Future<void> updateEngagementLevel(int sessionCount, Duration totalTime) async {
    String engagementLevel;
    if (sessionCount > 50 && totalTime.inHours > 20) {
      engagementLevel = 'high';
    } else if (sessionCount > 10 && totalTime.inHours > 5) {
      engagementLevel = 'medium';
    } else {
      engagementLevel = 'low';
    }
    
    await AnalyticsManager.setUserProperty('engagement_level', engagementLevel);
  }
}
```

### 2. Cohort Analysis

```dart
class CohortAnalytics {
  static Future<void> trackRetention(String userId, int daysSinceInstall) async {
    await AnalyticsManager.track('retention_milestone', {
      'user_id': userId,
      'days_since_install': daysSinceInstall,
      'cohort_week': _getCohortWeek(),
    });
  }

  static String _getCohortWeek() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final weekNumber = ((now.difference(startOfYear).inDays) / 7).floor() + 1;
    return '${now.year}-W$weekNumber';
  }
}
```

## Funnel Analysis

### 1. Conversion Tracking

```dart
class FunnelAnalytics {
  static Future<void> trackSignupFunnel(String step, {Map<String, dynamic>? additionalData}) async {
    await AnalyticsManager.track('signup_funnel', {
      'step': step,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      ...?additionalData,
    });
  }

  static Future<void> trackPurchaseFunnel(String step, {required double value}) async {
    await AnalyticsManager.track('purchase_funnel', {
      'step': step,
      'value': value,
      'currency': 'USD',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
}

// Usage in signup flow
class SignupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              FunnelAnalytics.trackSignupFunnel('email_entered');
              // Navigate to next step
            },
            child: Text('Continue with Email'),
          ),
        ],
      ),
    );
  }
}
```

### 2. A/B Testing Integration

```dart
class ABTestAnalytics {
  static Future<void> trackExperiment(String experimentName, String variant) async {
    await AnalyticsManager.track('experiment_exposure', {
      'experiment_name': experimentName,
      'variant': variant,
    });
  }

  static Future<void> trackConversion(String experimentName, String variant, String goal) async {
    await AnalyticsManager.track('experiment_conversion', {
      'experiment_name': experimentName,
      'variant': variant,
      'goal': goal,
    });
  }
}
```

## Performance Analytics

### 1. App Performance

```dart
class PerformanceAnalytics {
  static Future<void> trackAppLaunchTime(Duration launchTime) async {
    await AnalyticsManager.track('app_launch_time', {
      'duration_ms': launchTime.inMilliseconds,
      'is_cold_start': await _isColdStart(),
    });
  }

  static Future<void> trackScreenLoadTime(String screenName, Duration loadTime) async {
    await AnalyticsManager.track('screen_load_time', {
      'screen_name': screenName,
      'duration_ms': loadTime.inMilliseconds,
    });
  }

  static Future<void> trackNetworkRequest(String endpoint, Duration responseTime, bool success) async {
    await AnalyticsManager.track('network_request', {
      'endpoint': endpoint,
      'response_time_ms': responseTime.inMilliseconds,
      'success': success,
    });
  }
}
```

### 2. User Experience Metrics

```dart
class UXAnalytics {
  static Future<void> trackUserFlow(String fromScreen, String toScreen, String action) async {
    await AnalyticsManager.track('user_flow', {
      'from_screen': fromScreen,
      'to_screen': toScreen,
      'action': action,
    });
  }

  static Future<void> trackErrorOccurrence(String errorType, String errorMessage, String screen) async {
    await AnalyticsManager.track('error_occurred', {
      'error_type': errorType,
      'error_message': errorMessage,
      'screen': screen,
    });
  }
}
```

## Privacy and Compliance

### 1. GDPR Compliance

```dart
class PrivacyAnalytics {
  static bool _analyticsEnabled = true;

  static void setAnalyticsEnabled(bool enabled) {
    _analyticsEnabled = enabled;
    if (!enabled) {
      _clearUserData();
    }
  }

  static bool get isAnalyticsEnabled => _analyticsEnabled;

  static Future<void> _clearUserData() async {
    // Clear user data from all analytics providers
    for (final provider in _providers) {
      await provider.clearUserData();
    }
  }

  static Future<void> trackWithConsent(String event, [Map<String, dynamic>? parameters]) async {
    if (_analyticsEnabled) {
      await AnalyticsManager.track(event, parameters);
    }
  }
}
```

### 2. Data Anonymization

```dart
class AnonymizedAnalytics {
  static String _hashUserId(String userId) {
    // Use a one-way hash for user ID
    return sha256.convert(utf8.encode(userId)).toString();
  }

  static Map<String, dynamic> _sanitizeParameters(Map<String, dynamic> parameters) {
    final sanitized = Map<String, dynamic>.from(parameters);
    
    // Remove or hash sensitive data
    if (sanitized.containsKey('email')) {
      sanitized['email'] = _hashEmail(sanitized['email']);
    }
    
    if (sanitized.containsKey('phone')) {
      sanitized.remove('phone'); // Remove entirely
    }
    
    return sanitized;
  }
}
```

## Testing Analytics

### 1. Debug Mode

```dart
class DebugAnalytics {
  static bool _debugMode = kDebugMode;

  static Future<void> track(String event, [Map<String, dynamic>? parameters]) async {
    if (_debugMode) {
      print('Analytics Event: $event');
      print('Parameters: $parameters');
    }
    
    if (!_debugMode) {
      await AnalyticsManager.track(event, parameters);
    }
  }
}
```

### 2. Analytics Testing

```dart
// test/analytics_test.dart
class MockAnalyticsProvider extends Mock implements AnalyticsProvider {}

void main() {
  group('Analytics Tests', () {
    late MockAnalyticsProvider mockProvider;

    setUp(() {
      mockProvider = MockAnalyticsProvider();
      AnalyticsManager.addProvider(mockProvider);
    });

    test('should track user signup event', () async {
      await AnalyticsManager.track(AnalyticsEvents.userSignUp, {
        'method': 'email',
        'user_id': 'test_user_123',
      });

      verify(mockProvider.track(AnalyticsEvents.userSignUp, any)).called(1);
    });
  });
}
```

## Best Practices

### 1. Event Naming Convention

```dart
// Use consistent naming patterns
class EventNaming {
  // Format: object_action
  static const String postCreated = 'post_created';
  static const String postDeleted = 'post_deleted';
  static const String userRegistered = 'user_registered';
  
  // Use snake_case for consistency
  static const String screenViewed = 'screen_viewed';
  static const String buttonClicked = 'button_clicked';
}
```

### 2. Parameter Standardization

```dart
class StandardParameters {
  // Always include these when relevant
  static const String timestamp = 'timestamp';
  static const String userId = 'user_id';
  static const String sessionId = 'session_id';
  static const String appVersion = 'app_version';
  static const String platform = 'platform';
}
```

### 3. Batch Processing

```dart
class BatchAnalytics {
  static final List<AnalyticsEvent> _eventQueue = [];
  static Timer? _batchTimer;

  static void queueEvent(String name, Map<String, dynamic>? parameters) {
    _eventQueue.add(AnalyticsEvent(name, parameters));
    
    _batchTimer?.cancel();
    _batchTimer = Timer(Duration(seconds: 5), _flushEvents);
  }

  static Future<void> _flushEvents() async {
    if (_eventQueue.isNotEmpty) {
      final events = List<AnalyticsEvent>.from(_eventQueue);
      _eventQueue.clear();
      
      for (final event in events) {
        await AnalyticsManager.track(event.name, event.parameters);
      }
    }
  }
}
```

## Reporting and Dashboards

### 1. Custom Metrics

```dart
class CustomMetrics {
  static Future<void> trackDAU(String userId) async {
    await AnalyticsManager.track('daily_active_user', {
      'user_id': userId,
      'date': DateTime.now().toIso8601String().split('T')[0],
    });
  }

  static Future<void> trackSessionDuration(Duration duration) async {
    await AnalyticsManager.track('session_duration', {
      'duration_seconds': duration.inSeconds,
      'duration_category': _categorizeDuration(duration),
    });
  }

  static String _categorizeDuration(Duration duration) {
    if (duration.inMinutes < 1) return 'very_short';
    if (duration.inMinutes < 5) return 'short';
    if (duration.inMinutes < 15) return 'medium';
    if (duration.inMinutes < 30) return 'long';
    return 'very_long';
  }
}
```

### 2. Real-time Monitoring

```dart
class RealTimeAnalytics {
  static Future<void> trackCriticalEvent(String event, Map<String, dynamic> data) async {
    // Send to real-time monitoring
    await AnalyticsManager.track(event, {
      ...data,
      'priority': 'high',
      'real_time': true,
    });
    
    // Also send to alerting system if needed
    if (_isCriticalError(event)) {
      await _sendAlert(event, data);
    }
  }
}
```

Analytics implementation should be planned carefully to provide actionable insights while respecting user privacy. Start with core events and gradually expand based on your specific business needs.
