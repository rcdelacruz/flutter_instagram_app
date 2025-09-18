# Authentication Implementation

Comprehensive guide to implementing secure authentication in Flutter applications using Supabase and other providers.

## Overview

Authentication is critical for user security and app functionality. This guide covers multiple authentication methods, security best practices, and implementation patterns.

## Supabase Authentication

### 1. Setup and Configuration

```yaml
# pubspec.yaml
dependencies:
  supabase_flutter: ^2.0.0
  crypto: ^3.0.3
```

```dart
// lib/services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;
  
  // Get current user
  static User? get currentUser => _client.auth.currentUser;
  
  // Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;
  
  // Auth state stream
  static Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
```

### 2. Email/Password Authentication

```dart
class EmailAuthService extends AuthService {
  // Sign up with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: metadata,
      );
      return response;
    } catch (e) {
      throw AuthException('Sign up failed: ${e.toString()}');
    }
  }

  // Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw AuthException('Sign in failed: ${e.toString()}');
    }
  }

  // Send password reset email
  static Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw AuthException('Password reset failed: ${e.toString()}');
    }
  }

  // Update password
  static Future<UserResponse> updatePassword(String newPassword) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return response;
    } catch (e) {
      throw AuthException('Password update failed: ${e.toString()}');
    }
  }
}
```

### 3. Social Authentication

```dart
class SocialAuthService extends AuthService {
  // Google Sign In
  static Future<AuthResponse> signInWithGoogle() async {
    try {
      final response = await _client.auth.signInWithOAuth(
        Provider.google,
        redirectTo: 'your-app://auth-callback',
      );
      return response;
    } catch (e) {
      throw AuthException('Google sign in failed: ${e.toString()}');
    }
  }

  // Apple Sign In
  static Future<AuthResponse> signInWithApple() async {
    try {
      final response = await _client.auth.signInWithOAuth(
        Provider.apple,
        redirectTo: 'your-app://auth-callback',
      );
      return response;
    } catch (e) {
      throw AuthException('Apple sign in failed: ${e.toString()}');
    }
  }

  // Facebook Sign In
  static Future<AuthResponse> signInWithFacebook() async {
    try {
      final response = await _client.auth.signInWithOAuth(
        Provider.facebook,
        redirectTo: 'your-app://auth-callback',
      );
      return response;
    } catch (e) {
      throw AuthException('Facebook sign in failed: ${e.toString()}');
    }
  }
}
```

### 4. Phone Authentication

```dart
class PhoneAuthService extends AuthService {
  // Send OTP to phone
  static Future<void> sendOTP(String phone) async {
    try {
      await _client.auth.signInWithOtp(phone: phone);
    } catch (e) {
      throw AuthException('OTP send failed: ${e.toString()}');
    }
  }

  // Verify OTP
  static Future<AuthResponse> verifyOTP({
    required String phone,
    required String token,
  }) async {
    try {
      final response = await _client.auth.verifyOTP(
        phone: phone,
        token: token,
        type: OtpType.sms,
      );
      return response;
    } catch (e) {
      throw AuthException('OTP verification failed: ${e.toString()}');
    }
  }
}
```

## Authentication State Management

### 1. Riverpod Implementation

```dart
// lib/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authStateProvider = StreamProvider<AuthState>((ref) {
  return AuthService.authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (state) => state.session?.user,
    loading: () => null,
    error: (_, __) => null,
  );
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  AuthNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    AuthService.authStateChanges.listen((authState) {
      state = AsyncValue.data(authState.session?.user);
    });
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await EmailAuthService.signIn(email: email, password: password);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> signUp(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await EmailAuthService.signUp(email: email, password: password);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> signOut() async {
    try {
      await AuthService.signOut();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier();
});
```

### 2. BLoC Implementation

```dart
// lib/blocs/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AuthEvent {}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;
  AuthSignInRequested(this.email, this.password);
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  AuthSignUpRequested(this.email, this.password);
}

class AuthSignOutRequested extends AuthEvent {}

abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    
    // Listen to auth state changes
    AuthService.authStateChanges.listen((authState) {
      if (authState.session?.user != null) {
        add(AuthUserChanged(authState.session!.user));
      } else {
        add(AuthUserChanged(null));
      }
    });
  }

  Future<void> _onSignInRequested(AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await EmailAuthService.signIn(email: event.email, password: event.password);
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
```

## UI Components

### 1. Login Screen

```dart
// lib/screens/login_screen.dart
class LoginScreen extends ConsumerStatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (previous, next) {
      next.when(
        data: (user) {
          if (user != null) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        },
        loading: () => setState(() => _isLoading = true),
        error: (error, _) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        },
      );
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Email is required';
                    if (!value!.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Password is required';
                    if (value!.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
                  child: _isLoading 
                    ? const CircularProgressIndicator()
                    : const Text('Sign In'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _signInWithGoogle,
                      icon: const Icon(Icons.login),
                      label: const Text('Google'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _signInWithApple,
                      icon: const Icon(Icons.apple),
                      label: const Text('Apple'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _signIn() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authNotifierProvider.notifier).signIn(
        _emailController.text,
        _passwordController.text,
      );
    }
  }

  void _signInWithGoogle() {
    // Implement Google sign in
  }

  void _signInWithApple() {
    // Implement Apple sign in
  }
}
```

### 2. Auth Guard

```dart
// lib/widgets/auth_guard.dart
class AuthGuard extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;

  const AuthGuard({
    Key? key,
    required this.child,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    
    if (isAuthenticated) {
      return child;
    }
    
    return fallback ?? const LoginScreen();
  }
}

// Usage
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthGuard(
        child: HomeScreen(),
        fallback: LoginScreen(),
      ),
    );
  }
}
```

## Security Best Practices

### 1. Token Management

```dart
// lib/services/token_service.dart
class TokenService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  // Store tokens securely
  static Future<void> storeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await SecureStorage.write(_accessTokenKey, accessToken);
    await SecureStorage.write(_refreshTokenKey, refreshToken);
  }

  // Get access token
  static Future<String?> getAccessToken() async {
    return await SecureStorage.read(_accessTokenKey);
  }

  // Refresh token if needed
  static Future<String?> refreshAccessToken() async {
    final refreshToken = await SecureStorage.read(_refreshTokenKey);
    if (refreshToken == null) return null;

    try {
      final response = await _client.auth.refreshSession(refreshToken);
      if (response.session != null) {
        await storeTokens(
          accessToken: response.session!.accessToken,
          refreshToken: response.session!.refreshToken!,
        );
        return response.session!.accessToken;
      }
    } catch (e) {
      // Refresh failed, user needs to re-authenticate
      await clearTokens();
    }
    return null;
  }

  // Clear tokens on logout
  static Future<void> clearTokens() async {
    await SecureStorage.delete(_accessTokenKey);
    await SecureStorage.delete(_refreshTokenKey);
  }
}
```

### 2. Secure Storage

```dart
// lib/services/secure_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: IOSAccessibility.first_unlock_this_device,
    ),
  );

  static Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  static Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
```

### 3. Biometric Authentication

```dart
// lib/services/biometric_service.dart
import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  static Future<bool> isAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> authenticate({
    required String reason,
    bool biometricOnly = false,
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedFallbackTitle: 'Use PIN',
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Biometric authentication required',
            cancelButton: 'Cancel',
          ),
          IOSAuthMessages(
            cancelButton: 'Cancel',
          ),
        ],
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }
}
```

## Session Management

### 1. Session Persistence

```dart
// lib/services/session_service.dart
class SessionService {
  static const String _sessionKey = 'user_session';

  static Future<void> saveSession(Session session) async {
    final sessionData = {
      'access_token': session.accessToken,
      'refresh_token': session.refreshToken,
      'expires_at': session.expiresAt,
      'user': session.user.toJson(),
    };
    
    await SecureStorage.write(_sessionKey, jsonEncode(sessionData));
  }

  static Future<Session?> loadSession() async {
    final sessionJson = await SecureStorage.read(_sessionKey);
    if (sessionJson == null) return null;

    try {
      final sessionData = jsonDecode(sessionJson);
      return Session.fromJson(sessionData);
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearSession() async {
    await SecureStorage.delete(_sessionKey);
  }
}
```

### 2. Auto-logout

```dart
// lib/services/auto_logout_service.dart
class AutoLogoutService {
  static Timer? _timer;
  static const Duration _timeoutDuration = Duration(minutes: 30);

  static void startTimer() {
    _resetTimer();
  }

  static void _resetTimer() {
    _timer?.cancel();
    _timer = Timer(_timeoutDuration, () {
      _logout();
    });
  }

  static void resetTimer() {
    if (_timer?.isActive ?? false) {
      _resetTimer();
    }
  }

  static void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  static void _logout() {
    // Perform logout
    AuthService.signOut();
  }
}

// Usage in app lifecycle
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AutoLogoutService.startTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      AutoLogoutService.resetTimer();
    } else if (state == AppLifecycleState.paused) {
      AutoLogoutService.stopTimer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AutoLogoutService.stopTimer();
    super.dispose();
  }
}
```

## Testing Authentication

### 1. Unit Tests

```dart
// test/auth_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  group('AuthService Tests', () {
    late MockSupabaseClient mockClient;

    setUp(() {
      mockClient = MockSupabaseClient();
    });

    test('should sign in user with valid credentials', () async {
      // Arrange
      when(mockClient.auth.signInWithPassword(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => AuthResponse(
        session: Session(
          accessToken: 'token',
          refreshToken: 'refresh',
          expiresAt: DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch,
          user: User(id: '123', email: 'test@example.com'),
        ),
      ));

      // Act
      final result = await EmailAuthService.signIn(
        email: 'test@example.com',
        password: 'password123',
      );

      // Assert
      expect(result.session?.user.email, 'test@example.com');
    });
  });
}
```

### 2. Widget Tests

```dart
// test/login_screen_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginScreen Tests', () {
    testWidgets('should show validation error for invalid email', (tester) async {
      await tester.pumpWidget(MaterialApp(home: LoginScreen()));

      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.text('Invalid email'), findsOneWidget);
    });
  });
}
```

Authentication is the foundation of app security. Implement it carefully, test thoroughly, and always follow security best practices to protect your users' data.
