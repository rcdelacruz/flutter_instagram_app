# Flutter Testing Guide

Comprehensive testing strategy for Flutter applications covering unit tests, widget tests, integration tests, and testing best practices.

## Testing Pyramid

```
    /\
   /  \    E2E Tests (Few)
  /____\
 /      \   Integration Tests (Some)
/________\
\        /  Widget Tests (Many)
 \______/
  \    /    Unit Tests (Most)
   \__/
```

## 1. Unit Tests

Test individual functions, methods, and classes in isolation.

### Example: Testing a Service

```dart
// test/services/auth_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:flutter_instagram_app/core/services/auth_service.dart';

@GenerateMocks([SupabaseClient])
import 'auth_service_test.mocks.dart';

void main() {
  group('AuthService', () {
    late AuthService authService;
    late MockSupabaseClient mockClient;

    setUp(() {
      mockClient = MockSupabaseClient();
      authService = AuthService(client: mockClient);
    });

    test('should sign in user successfully', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      final mockResponse = AuthResponse(
        user: User(id: '123', email: email),
        session: Session(accessToken: 'token'),
      );

      when(mockClient.auth.signInWithPassword(
        email: email,
        password: password,
      )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await authService.signIn(
        email: email,
        password: password,
      );

      // Assert
      expect(result.user?.email, equals(email));
      verify(mockClient.auth.signInWithPassword(
        email: email,
        password: password,
      )).called(1);
    });

    test('should throw exception on sign in failure', () async {
      // Arrange
      when(mockClient.auth.signInWithPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(AuthException('Invalid credentials'));

      // Act & Assert
      expect(
        () => authService.signIn(
          email: 'test@example.com',
          password: 'wrong_password',
        ),
        throwsA(isA<AuthException>()),
      );
    });
  });
}
```

### Testing Providers (Riverpod)

```dart
// test/providers/auth_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('AuthProvider', () {
    test('should start with loading state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final authState = container.read(authNotifierProvider);
      expect(authState, isA<AsyncLoading>());
    });

    test('should update state on successful sign in', () async {
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(MockAuthService()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authNotifierProvider.notifier);

      await notifier.signIn(
        email: 'test@example.com',
        password: 'password123',
      );

      final state = container.read(authNotifierProvider);
      expect(state, isA<AsyncData>());
    });
  });
}
```

## 2. Widget Tests

Test individual widgets and their interactions.

### Example: Testing a Custom Widget

```dart
// test/widgets/app_button_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_instagram_app/shared/widgets/buttons/app_button.dart';

void main() {
  group('AppButton', () {
    testWidgets('should display text correctly', (tester) async {
      const buttonText = 'Test Button';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppButton(text: buttonText),
          ),
        ),
      );

      expect(find.text(buttonText), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Test Button',
              onPressed: () => wasPressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AppButton));
      expect(wasPressed, isTrue);
    });

    testWidgets('should show loading indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Test Button',
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Test Button'), findsNothing);
    });

    testWidgets('should be disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Test Button',
              onPressed: null,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });
  });
}
```

### Testing with Providers

```dart
// test/screens/home_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('HomeScreen', () {
    testWidgets('should display posts when loaded', (tester) async {
      final mockPosts = [
        Post(id: '1', caption: 'Test post 1'),
        Post(id: '2', caption: 'Test post 2'),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            postsProvider.overrideWith((ref) => AsyncData(mockPosts)),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      expect(find.text('Test post 1'), findsOneWidget);
      expect(find.text('Test post 2'), findsOneWidget);
    });

    testWidgets('should display loading indicator when loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            postsProvider.overrideWith((ref) => const AsyncLoading()),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
```

## 3. Integration Tests

Test complete user flows and app behavior.

### Example: Authentication Flow

```dart
// integration_test/auth_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_instagram_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow', () {
    testWidgets('should complete sign up flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to sign up
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Fill form
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.enterText(find.byKey(const Key('username_field')), 'testuser');

      // Submit form
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Verify success
      expect(find.text('Welcome'), findsOneWidget);
    });

    testWidgets('should complete sign in flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to sign in
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Fill credentials
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');

      // Submit
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify home screen
      expect(find.byKey(const Key('home_screen')), findsOneWidget);
    });
  });
}
```

## 4. Golden Tests

Test visual appearance of widgets.

```dart
// test/golden/button_golden_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppButton Golden Tests', () {
    testWidgets('primary button golden test', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AppButton(
                text: 'Primary Button',
                type: AppButtonType.primary,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(AppButton),
        matchesGoldenFile('golden/primary_button.png'),
      );
    });

    testWidgets('loading button golden test', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AppButton(
                text: 'Loading Button',
                isLoading: true,
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(AppButton),
        matchesGoldenFile('golden/loading_button.png'),
      );
    });
  });
}
```

## 5. Performance Tests

Test app performance and memory usage.

```dart
// test/performance/scroll_performance_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Performance Tests', () {
    testWidgets('should scroll smoothly through large list', (tester) async {
      final items = List.generate(1000, (index) => 'Item $index');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(items[index]),
              ),
            ),
          ),
        ),
      );

      // Measure scroll performance
      await tester.timedDrag(
        find.byType(ListView),
        const Offset(0, -500),
        const Duration(milliseconds: 300),
      );

      await tester.pumpAndSettle();

      // Verify no frame drops
      expect(tester.binding.hasScheduledFrame, isFalse);
    });
  });
}
```

## Test Utilities

### Custom Matchers

```dart
// test/utils/custom_matchers.dart
import 'package:flutter_test/flutter_test.dart';

Matcher hasErrorText(String text) => _HasErrorText(text);

class _HasErrorText extends Matcher {
  final String expectedText;

  _HasErrorText(this.expectedText);

  @override
  bool matches(item, Map matchState) {
    if (item is! Widget) return false;
    // Implementation to check error text
    return true;
  }

  @override
  Description describe(Description description) =>
      description.add('has error text "$expectedText"');
}
```

### Test Helpers

```dart
// test/utils/test_helpers.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TestHelpers {
  static Widget wrapWithMaterialApp(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  static Widget wrapWithProviders(
    Widget child, {
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: overrides,
      child: wrapWithMaterialApp(child),
    );
  }

  static Future<void> enterTextAndSettle(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }

  static Future<void> tapAndSettle(
    WidgetTester tester,
    Finder finder,
  ) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }
}
```

## Running Tests

### Commands

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/auth_service_test.dart

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/

# Run tests in watch mode
flutter test --watch

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
```

### Test Configuration

```yaml
# test/flutter_test_config.dart
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  setUpAll(() {
    // Global test setup
  });

  tearDownAll(() {
    // Global test cleanup
  });

  await testMain();
}
```

## Best Practices

1. **Follow AAA Pattern**: Arrange, Act, Assert
2. **Use descriptive test names**: Describe what the test does
3. **Test one thing at a time**: Keep tests focused
4. **Use mocks for external dependencies**: Isolate units under test
5. **Clean up resources**: Dispose controllers and streams
6. **Test edge cases**: Handle error scenarios
7. **Keep tests fast**: Avoid unnecessary delays
8. **Use golden tests for UI**: Catch visual regressions

## Next Steps

1. ✅ Set up your testing environment
2. ✅ Write unit tests for your services and providers
3. ✅ Create widget tests for your custom components
4. ✅ Add integration tests for critical user flows
5. ✅ Proceed to [Deployment Documentation](../deployment/deployment-guide.md)

Your Flutter testing strategy is now ready for comprehensive test coverage!
