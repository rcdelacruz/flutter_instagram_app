# Testing Guide

Comprehensive testing strategies for Flutter applications including unit tests, widget tests, integration tests, and golden tests.

## Overview

Testing is crucial for maintaining code quality and preventing regressions. Flutter provides excellent testing tools and frameworks for comprehensive test coverage.

## Test Types

### 1. Unit Tests

Test individual functions, methods, and classes in isolation.

```dart
// test/unit/user_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([ApiClient])
import 'user_service_test.mocks.dart';

void main() {
  group('UserService Tests', () {
    late UserService userService;
    late MockApiClient mockApiClient;
    
    setUp(() {
      mockApiClient = MockApiClient();
      userService = UserService(apiClient: mockApiClient);
    });
    
    test('should return user when API call is successful', () async {
      // Arrange
      final userData = {'id': '1', 'name': 'John Doe', 'email': 'john@example.com'};
      when(mockApiClient.get('/users/1')).thenAnswer((_) async => userData);
      
      // Act
      final user = await userService.getUser('1');
      
      // Assert
      expect(user.id, '1');
      expect(user.name, 'John Doe');
      expect(user.email, 'john@example.com');
      verify(mockApiClient.get('/users/1')).called(1);
    });
    
    test('should throw exception when API call fails', () async {
      // Arrange
      when(mockApiClient.get('/users/1')).thenThrow(Exception('Network error'));
      
      // Act & Assert
      expect(() => userService.getUser('1'), throwsException);
    });
  });
}
```

### 2. Widget Tests

Test individual widgets and their interactions.

```dart
// test/widget/login_form_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginForm Widget Tests', () {
    testWidgets('should show validation error for empty email', (tester) async {
      // Arrange
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: LoginForm()),
      ));
      
      // Act
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      // Assert
      expect(find.text('Email is required'), findsOneWidget);
    });
    
    testWidgets('should call onSubmit when form is valid', (tester) async {
      // Arrange
      bool submitted = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: LoginForm(
            onSubmit: (email, password) => submitted = true,
          ),
        ),
      ));
      
      // Act
      await tester.enterText(find.byKey(Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(Key('password_field')), 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      // Assert
      expect(submitted, isTrue);
    });
    
    testWidgets('should show loading indicator when submitting', (tester) async {
      // Arrange
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: LoginForm(
            onSubmit: (email, password) async {
              await Future.delayed(Duration(seconds: 1));
            },
          ),
        ),
      ));
      
      // Act
      await tester.enterText(find.byKey(Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(Key('password_field')), 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
```

### 3. Integration Tests

Test complete user flows and app behavior.

```dart
// integration_test/app_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:myapp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('App Integration Tests', () {
    testWidgets('complete login flow', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();
      
      // Navigate to login screen
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      
      // Enter credentials
      await tester.enterText(find.byKey(Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(Key('password_field')), 'password123');
      
      // Submit form
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();
      
      // Verify successful login
      expect(find.text('Welcome'), findsOneWidget);
    });
    
    testWidgets('create and delete post flow', (tester) async {
      // Assuming user is already logged in
      app.main();
      await tester.pumpAndSettle();
      
      // Navigate to create post
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      // Create post
      await tester.enterText(find.byKey(Key('post_content')), 'Test post content');
      await tester.tap(find.text('Post'));
      await tester.pumpAndSettle();
      
      // Verify post appears in feed
      expect(find.text('Test post content'), findsOneWidget);
      
      // Delete post
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      
      // Verify post is deleted
      expect(find.text('Test post content'), findsNothing);
    });
  });
}
```

### 4. Golden Tests

Test widget appearance and layout.

```dart
// test/golden/button_golden_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Button Golden Tests', () {
    testWidgets('primary button golden test', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {},
              child: Text('Primary Button'),
            ),
          ),
        ),
      ));
      
      await expectLater(
        find.byType(ElevatedButton),
        matchesGoldenFile('golden/primary_button.png'),
      );
    });
    
    testWidgets('button states golden test', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              ElevatedButton(
                onPressed: () {},
                child: Text('Enabled'),
              ),
              ElevatedButton(
                onPressed: null,
                child: Text('Disabled'),
              ),
            ],
          ),
        ),
      ));
      
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('golden/button_states.png'),
      );
    });
  });
}
```

## Testing Patterns

### 1. Test Utilities

```dart
// test/utils/test_utils.dart
class TestUtils {
  static Widget wrapWithMaterialApp(Widget widget) {
    return MaterialApp(
      home: Scaffold(body: widget),
    );
  }
  
  static Widget wrapWithProviders(Widget widget) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MockUserProvider()),
        ChangeNotifierProvider(create: (_) => MockThemeProvider()),
      ],
      child: wrapWithMaterialApp(widget),
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

### 2. Custom Matchers

```dart
// test/matchers/custom_matchers.dart
Matcher hasTextStyle(TextStyle expectedStyle) {
  return _HasTextStyle(expectedStyle);
}

class _HasTextStyle extends Matcher {
  final TextStyle expectedStyle;
  
  _HasTextStyle(this.expectedStyle);
  
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! Text) return false;
    
    final actualStyle = item.style;
    return actualStyle?.fontSize == expectedStyle.fontSize &&
           actualStyle?.fontWeight == expectedStyle.fontWeight &&
           actualStyle?.color == expectedStyle.color;
  }
  
  @override
  Description describe(Description description) {
    return description.add('has text style $expectedStyle');
  }
}

// Usage
expect(find.text('Hello'), hasTextStyle(TextStyle(fontSize: 16)));
```

### 3. Page Object Model

```dart
// test/page_objects/login_page.dart
class LoginPageObject {
  final WidgetTester tester;
  
  LoginPageObject(this.tester);
  
  Finder get emailField => find.byKey(Key('email_field'));
  Finder get passwordField => find.byKey(Key('password_field'));
  Finder get loginButton => find.text('Sign In');
  Finder get errorMessage => find.byKey(Key('error_message'));
  
  Future<void> enterEmail(String email) async {
    await tester.enterText(emailField, email);
  }
  
  Future<void> enterPassword(String password) async {
    await tester.enterText(passwordField, password);
  }
  
  Future<void> tapLogin() async {
    await tester.tap(loginButton);
    await tester.pumpAndSettle();
  }
  
  Future<void> login(String email, String password) async {
    await enterEmail(email);
    await enterPassword(password);
    await tapLogin();
  }
  
  bool get hasErrorMessage => tester.any(errorMessage);
}

// Usage in tests
testWidgets('login with invalid credentials', (tester) async {
  await tester.pumpWidget(MyApp());
  
  final loginPage = LoginPageObject(tester);
  await loginPage.login('invalid@email.com', 'wrongpassword');
  
  expect(loginPage.hasErrorMessage, isTrue);
});
```

## Testing State Management

### 1. Testing Riverpod Providers

```dart
// test/providers/user_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserProvider Tests', () {
    test('should load user data', () async {
      final container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(MockUserRepository()),
        ],
      );
      
      final userNotifier = container.read(userProvider.notifier);
      await userNotifier.loadUser('123');
      
      final user = container.read(userProvider);
      expect(user.value?.id, '123');
    });
    
    test('should handle loading states', () async {
      final container = ProviderContainer();
      
      // Initial state should be loading
      expect(container.read(userProvider), const AsyncValue.loading());
      
      // After loading
      final userNotifier = container.read(userProvider.notifier);
      await userNotifier.loadUser('123');
      
      final user = container.read(userProvider);
      expect(user.hasValue, isTrue);
    });
  });
}
```

### 2. Testing BLoC

```dart
// test/blocs/auth_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthBloc Tests', () {
    late AuthBloc authBloc;
    late MockAuthRepository mockAuthRepository;
    
    setUp(() {
      mockAuthRepository = MockAuthRepository();
      authBloc = AuthBloc(authRepository: mockAuthRepository);
    });
    
    tearDown(() {
      authBloc.close();
    });
    
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when login succeeds',
      build: () {
        when(() => mockAuthRepository.login(any(), any()))
            .thenAnswer((_) async => User(id: '1', email: 'test@example.com'));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthLoginRequested('test@example.com', 'password')),
      expect: () => [
        AuthLoading(),
        AuthAuthenticated(User(id: '1', email: 'test@example.com')),
      ],
    );
    
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login fails',
      build: () {
        when(() => mockAuthRepository.login(any(), any()))
            .thenThrow(Exception('Login failed'));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthLoginRequested('test@example.com', 'password')),
      expect: () => [
        AuthLoading(),
        AuthError('Login failed'),
      ],
    );
  });
}
```

## Testing Best Practices

### 1. Test Organization

```dart
// test/test_config.dart
class TestConfig {
  static void setupTests() {
    // Global test setup
    setUpAll(() {
      // Initialize test environment
    });
    
    tearDownAll(() {
      // Cleanup after all tests
    });
  }
}

// Use groups to organize related tests
group('User Management', () {
  group('User Creation', () {
    test('should create user with valid data', () {});
    test('should reject invalid email', () {});
  });
  
  group('User Authentication', () {
    test('should authenticate with correct credentials', () {});
    test('should reject invalid credentials', () {});
  });
});
```

### 2. Test Data Management

```dart
// test/fixtures/test_data.dart
class TestData {
  static const validUser = User(
    id: '1',
    email: 'test@example.com',
    name: 'Test User',
  );
  
  static const invalidUser = User(
    id: '',
    email: 'invalid-email',
    name: '',
  );
  
  static List<Post> get samplePosts => [
    Post(id: '1', content: 'First post', userId: '1'),
    Post(id: '2', content: 'Second post', userId: '1'),
  ];
}
```

### 3. Mock Management

```dart
// test/mocks/mock_services.dart
class MockUserService extends Mock implements UserService {}
class MockApiClient extends Mock implements ApiClient {}
class MockStorageService extends Mock implements StorageService {}

// Create a mock factory
class MockFactory {
  static MockUserService createUserService() {
    final mock = MockUserService();
    when(mock.getCurrentUser()).thenReturn(TestData.validUser);
    return mock;
  }
}
```

## Test Coverage

### 1. Coverage Configuration

```yaml
# test/coverage_config.yaml
coverage:
  exclude:
    - '**/*.g.dart'
    - '**/*.freezed.dart'
    - '**/main.dart'
    - 'lib/generated/**'
```

### 2. Running Coverage

```bash
# Generate coverage report
flutter test --coverage

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# View coverage
open coverage/html/index.html
```

## Continuous Integration

### 1. GitHub Actions

```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      - run: flutter test integration_test/
```

### 2. Test Scripts

```bash
#!/bin/bash
# scripts/run_tests.sh

echo "Running unit tests..."
flutter test

echo "Running widget tests..."
flutter test test/widget/

echo "Running integration tests..."
flutter test integration_test/

echo "Generating coverage report..."
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

echo "Tests completed!"
```

Testing is an investment in code quality and developer confidence. Start with unit tests for business logic, add widget tests for UI components, and use integration tests for critical user flows.
