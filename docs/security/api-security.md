# API Security

Comprehensive guide to implementing secure API communication in Flutter applications.

## Overview

API security is crucial for protecting user data and preventing unauthorized access. This guide covers authentication, authorization, secure communication, and best practices for API security.

## Authentication & Authorization

### 1. JWT Token Management

```dart
// lib/services/auth_token_service.dart
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthTokenService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  
  // Store tokens securely
  static Future<void> storeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final secureStorage = FlutterSecureStorage();
    
    await Future.wait([
      secureStorage.write(key: _accessTokenKey, value: accessToken),
      secureStorage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }
  
  // Get access token
  static Future<String?> getAccessToken() async {
    final secureStorage = FlutterSecureStorage();
    return await secureStorage.read(key: _accessTokenKey);
  }
  
  // Get refresh token
  static Future<String?> getRefreshToken() async {
    final secureStorage = FlutterSecureStorage();
    return await secureStorage.read(key: _refreshTokenKey);
  }
  
  // Check if token is valid
  static Future<bool> isTokenValid() async {
    final token = await getAccessToken();
    if (token == null) return false;
    
    try {
      return !JwtDecoder.isExpired(token);
    } catch (e) {
      return false;
    }
  }
  
  // Get token expiry time
  static Future<DateTime?> getTokenExpiry() async {
    final token = await getAccessToken();
    if (token == null) return null;
    
    try {
      return JwtDecoder.getExpirationDate(token);
    } catch (e) {
      return null;
    }
  }
  
  // Clear all tokens
  static Future<void> clearTokens() async {
    final secureStorage = FlutterSecureStorage();
    
    await Future.wait([
      secureStorage.delete(key: _accessTokenKey),
      secureStorage.delete(key: _refreshTokenKey),
    ]);
  }
  
  // Extract user ID from token
  static Future<String?> getUserIdFromToken() async {
    final token = await getAccessToken();
    if (token == null) return null;
    
    try {
      final decodedToken = JwtDecoder.decode(token);
      return decodedToken['sub'] ?? decodedToken['user_id'];
    } catch (e) {
      return null;
    }
  }
}
```

### 2. API Interceptor for Authentication

```dart
// lib/services/auth_interceptor.dart
import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final AuthTokenService _tokenService;
  
  AuthInterceptor(this._dio, this._tokenService);
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Add access token to requests
    final token = await _tokenService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    // Add security headers
    options.headers['X-Requested-With'] = 'XMLHttpRequest';
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';
    
    handler.next(options);
  }
  
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized - token expired
    if (err.response?.statusCode == 401) {
      try {
        // Attempt to refresh token
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Retry the original request
          final response = await _retry(err.requestOptions);
          handler.resolve(response);
          return;
        }
      } catch (e) {
        // Refresh failed, redirect to login
        await _handleAuthFailure();
      }
    }
    
    handler.next(err);
  }
  
  Future<bool> _refreshToken() async {
    final refreshToken = await _tokenService.getRefreshToken();
    if (refreshToken == null) return false;
    
    try {
      final response = await _dio.post('/auth/refresh', data: {
        'refresh_token': refreshToken,
      });
      
      final newAccessToken = response.data['access_token'];
      final newRefreshToken = response.data['refresh_token'];
      
      await _tokenService.storeTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    // Add new token to retry request
    final token = await _tokenService.getAccessToken();
    if (token != null) {
      requestOptions.headers['Authorization'] = 'Bearer $token';
    }
    
    return _dio.fetch(requestOptions);
  }
  
  Future<void> _handleAuthFailure() async {
    // Clear tokens
    await _tokenService.clearTokens();
    
    // Navigate to login screen
    // This should be handled by your navigation service
    NavigationService.navigateToLogin();
  }
}
```

## Secure HTTP Communication

### 1. Certificate Pinning

```dart
// lib/services/secure_http_client.dart
import 'package:dio_certificate_pinning/dio_certificate_pinning.dart';

class SecureHttpClient {
  static Dio createSecureClient() {
    final dio = Dio();
    
    // Add certificate pinning
    dio.interceptors.add(
      CertificatePinningInterceptor(
        allowedSHAFingerprints: [
          'SHA256:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=', // Your server's certificate fingerprint
        ],
      ),
    );
    
    // Configure timeouts
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);
    dio.options.sendTimeout = const Duration(seconds: 10);
    
    // Add security headers
    dio.options.headers.addAll({
      'X-Content-Type-Options': 'nosniff',
      'X-Frame-Options': 'DENY',
      'X-XSS-Protection': '1; mode=block',
    });
    
    return dio;
  }
}
```

### 2. Request Signing

```dart
// lib/services/request_signer.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class RequestSigner {
  final String _secretKey;
  
  RequestSigner(this._secretKey);
  
  // Sign request with HMAC
  String signRequest({
    required String method,
    required String path,
    required Map<String, dynamic> body,
    required int timestamp,
  }) {
    final payload = _createPayload(method, path, body, timestamp);
    final key = utf8.encode(_secretKey);
    final bytes = utf8.encode(payload);
    
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    
    return digest.toString();
  }
  
  String _createPayload(
    String method,
    String path,
    Map<String, dynamic> body,
    int timestamp,
  ) {
    final bodyString = body.isNotEmpty ? jsonEncode(body) : '';
    return '$method|$path|$bodyString|$timestamp';
  }
  
  // Verify response signature
  bool verifyResponse(String signature, String responseBody) {
    final key = utf8.encode(_secretKey);
    final bytes = utf8.encode(responseBody);
    
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    
    return digest.toString() == signature;
  }
}

// Interceptor for request signing
class RequestSigningInterceptor extends Interceptor {
  final RequestSigner _signer;
  
  RequestSigningInterceptor(this._signer);
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final signature = _signer.signRequest(
      method: options.method,
      path: options.path,
      body: options.data ?? {},
      timestamp: timestamp,
    );
    
    options.headers['X-Timestamp'] = timestamp.toString();
    options.headers['X-Signature'] = signature;
    
    handler.next(options);
  }
}
```

## Input Validation & Sanitization

### 1. Input Validator

```dart
// lib/utils/input_validator.dart
class InputValidator {
  // Email validation
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
  
  // Password strength validation
  static bool isStrongPassword(String password) {
    if (password.length < 8) return false;
    
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    final hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    return hasUppercase && hasLowercase && hasDigits && hasSpecialCharacters;
  }
  
  // Sanitize input to prevent XSS
  static String sanitizeInput(String input) {
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('&', '&amp;');
  }
  
  // Validate and sanitize URL
  static String? sanitizeUrl(String url) {
    try {
      final uri = Uri.parse(url);
      
      // Only allow HTTP and HTTPS
      if (!['http', 'https'].contains(uri.scheme)) {
        return null;
      }
      
      return uri.toString();
    } catch (e) {
      return null;
    }
  }
  
  // Validate file upload
  static bool isValidFileUpload(String filename, List<String> allowedExtensions) {
    final extension = filename.split('.').last.toLowerCase();
    return allowedExtensions.contains(extension);
  }
  
  // Check for SQL injection patterns
  static bool containsSqlInjection(String input) {
    final sqlPatterns = [
      r"(\b(SELECT|INSERT|UPDATE|DELETE|DROP|CREATE|ALTER|EXEC|UNION)\b)",
      r"(--|#|/\*|\*/)",
      r"(\b(OR|AND)\s+\d+\s*=\s*\d+)",
      r"(\'\s*(OR|AND)\s*\'\w*\'\s*=\s*\'\w*)",
    ];
    
    for (final pattern in sqlPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(input)) {
        return true;
      }
    }
    
    return false;
  }
}
```

### 2. Request Validation Interceptor

```dart
// lib/services/validation_interceptor.dart
class ValidationInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Validate request data
    if (options.data != null) {
      final validationResult = _validateRequestData(options.data);
      if (!validationResult.isValid) {
        handler.reject(
          DioError(
            requestOptions: options,
            error: 'Invalid request data: ${validationResult.errors.join(', ')}',
            type: DioErrorType.other,
          ),
        );
        return;
      }
    }
    
    // Validate query parameters
    if (options.queryParameters.isNotEmpty) {
      final validationResult = _validateQueryParameters(options.queryParameters);
      if (!validationResult.isValid) {
        handler.reject(
          DioError(
            requestOptions: options,
            error: 'Invalid query parameters: ${validationResult.errors.join(', ')}',
            type: DioErrorType.other,
          ),
        );
        return;
      }
    }
    
    handler.next(options);
  }
  
  ValidationResult _validateRequestData(dynamic data) {
    final errors = <String>[];
    
    if (data is Map<String, dynamic>) {
      for (final entry in data.entries) {
        if (entry.value is String) {
          final value = entry.value as String;
          
          // Check for SQL injection
          if (InputValidator.containsSqlInjection(value)) {
            errors.add('${entry.key} contains potentially malicious content');
          }
          
          // Check for excessive length
          if (value.length > 10000) {
            errors.add('${entry.key} exceeds maximum length');
          }
        }
      }
    }
    
    return ValidationResult(errors.isEmpty, errors);
  }
  
  ValidationResult _validateQueryParameters(Map<String, dynamic> params) {
    final errors = <String>[];
    
    for (final entry in params.entries) {
      final value = entry.value.toString();
      
      // Check for SQL injection
      if (InputValidator.containsSqlInjection(value)) {
        errors.add('${entry.key} contains potentially malicious content');
      }
      
      // Check for excessive length
      if (value.length > 1000) {
        errors.add('${entry.key} exceeds maximum length');
      }
    }
    
    return ValidationResult(errors.isEmpty, errors);
  }
}

class ValidationResult {
  final bool isValid;
  final List<String> errors;
  
  ValidationResult(this.isValid, this.errors);
}
```

## Rate Limiting & Throttling

### 1. Rate Limiter

```dart
// lib/services/rate_limiter.dart
class RateLimiter {
  final Map<String, List<DateTime>> _requests = {};
  final int _maxRequests;
  final Duration _timeWindow;
  
  RateLimiter({
    required int maxRequests,
    required Duration timeWindow,
  }) : _maxRequests = maxRequests,
       _timeWindow = timeWindow;
  
  bool canMakeRequest(String identifier) {
    final now = DateTime.now();
    final requests = _requests[identifier] ?? [];
    
    // Remove old requests outside the time window
    requests.removeWhere((time) => now.difference(time) > _timeWindow);
    
    // Check if under the limit
    if (requests.length < _maxRequests) {
      requests.add(now);
      _requests[identifier] = requests;
      return true;
    }
    
    return false;
  }
  
  Duration? getRetryAfter(String identifier) {
    final requests = _requests[identifier] ?? [];
    if (requests.isEmpty) return null;
    
    final oldestRequest = requests.first;
    final retryAfter = _timeWindow - DateTime.now().difference(oldestRequest);
    
    return retryAfter.isNegative ? null : retryAfter;
  }
  
  void reset(String identifier) {
    _requests.remove(identifier);
  }
}

// Rate limiting interceptor
class RateLimitingInterceptor extends Interceptor {
  final RateLimiter _rateLimiter;
  
  RateLimitingInterceptor(this._rateLimiter);
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final identifier = _getIdentifier(options);
    
    if (!_rateLimiter.canMakeRequest(identifier)) {
      final retryAfter = _rateLimiter.getRetryAfter(identifier);
      
      handler.reject(
        DioError(
          requestOptions: options,
          error: 'Rate limit exceeded. Retry after: ${retryAfter?.inSeconds}s',
          type: DioErrorType.other,
        ),
      );
      return;
    }
    
    handler.next(options);
  }
  
  String _getIdentifier(RequestOptions options) {
    // Use endpoint + user ID as identifier
    final userId = options.headers['X-User-ID'] ?? 'anonymous';
    return '${options.path}_$userId';
  }
}
```

## Error Handling & Logging

### 1. Secure Error Handler

```dart
// lib/services/secure_error_handler.dart
class SecureErrorHandler {
  static void handleApiError(DioError error) {
    // Log error securely (without sensitive data)
    final sanitizedError = _sanitizeError(error);
    _logError(sanitizedError);
    
    // Show user-friendly error message
    final userMessage = _getUserFriendlyMessage(error);
    _showErrorToUser(userMessage);
  }
  
  static Map<String, dynamic> _sanitizeError(DioError error) {
    return {
      'type': error.type.toString(),
      'statusCode': error.response?.statusCode,
      'path': error.requestOptions.path,
      'method': error.requestOptions.method,
      'timestamp': DateTime.now().toIso8601String(),
      // Don't log sensitive headers or data
    };
  }
  
  static void _logError(Map<String, dynamic> error) {
    // Log to secure logging service
    if (kDebugMode) {
      print('API Error: $error');
    } else {
      // Send to crash reporting service
      FirebaseCrashlytics.instance.recordError(
        error,
        null,
        fatal: false,
      );
    }
  }
  
  static String _getUserFriendlyMessage(DioError error) {
    switch (error.response?.statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Authentication required. Please log in.';
      case 403:
        return 'Access denied. You don\'t have permission for this action.';
      case 404:
        return 'The requested resource was not found.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
  
  static void _showErrorToUser(String message) {
    // Show error message to user through your UI framework
    // This could be a snackbar, dialog, or toast
  }
}
```

## Security Testing

### 1. API Security Tests

```dart
// test/security/api_security_test.dart
void main() {
  group('API Security Tests', () {
    late MockDio mockDio;
    late AuthInterceptor authInterceptor;
    
    setUp(() {
      mockDio = MockDio();
      authInterceptor = AuthInterceptor(mockDio, AuthTokenService());
    });
    
    test('should add authorization header to requests', () async {
      // Arrange
      when(AuthTokenService.getAccessToken()).thenAnswer((_) async => 'test_token');
      
      final options = RequestOptions(path: '/test');
      final handler = MockRequestInterceptorHandler();
      
      // Act
      await authInterceptor.onRequest(options, handler);
      
      // Assert
      expect(options.headers['Authorization'], 'Bearer test_token');
      verify(handler.next(options)).called(1);
    });
    
    test('should handle 401 errors by refreshing token', () async {
      // Arrange
      final error = DioError(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 401,
          requestOptions: RequestOptions(path: '/test'),
        ),
        type: DioErrorType.response,
      );
      
      when(AuthTokenService.getRefreshToken()).thenAnswer((_) async => 'refresh_token');
      when(mockDio.post('/auth/refresh', data: anyNamed('data')))
          .thenAnswer((_) async => Response(
                data: {
                  'access_token': 'new_access_token',
                  'refresh_token': 'new_refresh_token',
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: '/auth/refresh'),
              ));
      
      final handler = MockErrorInterceptorHandler();
      
      // Act
      await authInterceptor.onError(error, handler);
      
      // Assert
      verify(AuthTokenService.storeTokens(
        accessToken: 'new_access_token',
        refreshToken: 'new_refresh_token',
      )).called(1);
    });
    
    test('should validate input for SQL injection', () {
      // Test cases
      final testCases = [
        {'input': "'; DROP TABLE users; --", 'expected': true},
        {'input': "normal input", 'expected': false},
        {'input': "1' OR '1'='1", 'expected': true},
        {'input': "SELECT * FROM users", 'expected': true},
      ];
      
      for (final testCase in testCases) {
        final result = InputValidator.containsSqlInjection(testCase['input'] as String);
        expect(result, testCase['expected'], reason: 'Failed for input: ${testCase['input']}');
      }
    });
  });
}
```

API security requires multiple layers of protection. Implement authentication, validate all inputs, use HTTPS with certificate pinning, and monitor for suspicious activity.
