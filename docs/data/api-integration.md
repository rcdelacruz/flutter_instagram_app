# API Integration

Comprehensive guide to integrating REST APIs and GraphQL in Flutter applications with proper error handling and caching.

## Overview

API integration is crucial for modern Flutter applications. This guide covers REST APIs, GraphQL, authentication, caching, and best practices for robust data fetching.

## HTTP Client Setup

### 1. Dio Configuration (Recommended)

```yaml
# pubspec.yaml
dependencies:
  dio: ^5.3.2
  pretty_dio_logger: ^1.3.1
  dio_cache_interceptor: ^3.4.2
```

```dart
// lib/services/api_client.dart
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiClient {
  static final Dio _dio = Dio();
  
  static void initialize() {
    _dio.options = BaseOptions(
      baseUrl: 'https://api.example.com',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    
    // Add interceptors
    _dio.interceptors.addAll([
      AuthInterceptor(),
      ErrorInterceptor(),
      if (kDebugMode) PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
      ),
    ]);
  }
  
  static Dio get instance => _dio;
}
```

### 2. Authentication Interceptor

```dart
// lib/interceptors/auth_interceptor.dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await TokenService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired, try to refresh
      final refreshed = await TokenService.refreshToken();
      if (refreshed) {
        // Retry the request
        final options = err.requestOptions;
        final token = await TokenService.getAccessToken();
        options.headers['Authorization'] = 'Bearer $token';
        
        try {
          final response = await ApiClient.instance.fetch(options);
          handler.resolve(response);
          return;
        } catch (e) {
          // Refresh failed, redirect to login
          AuthService.logout();
        }
      }
    }
    handler.next(err);
  }
}
```

### 3. Error Handling Interceptor

```dart
// lib/interceptors/error_interceptor.dart
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiError = _handleError(err);
    handler.next(DioException(
      requestOptions: err.requestOptions,
      error: apiError,
      type: err.type,
      response: err.response,
    ));
  }
  
  ApiError _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiError(
          code: 'TIMEOUT',
          message: 'Connection timeout. Please check your internet connection.',
        );
      
      case DioExceptionType.badResponse:
        return _handleHttpError(error.response!);
      
      case DioExceptionType.cancel:
        return ApiError(
          code: 'CANCELLED',
          message: 'Request was cancelled.',
        );
      
      default:
        return ApiError(
          code: 'UNKNOWN',
          message: 'An unexpected error occurred.',
        );
    }
  }
  
  ApiError _handleHttpError(Response response) {
    switch (response.statusCode) {
      case 400:
        return ApiError(
          code: 'BAD_REQUEST',
          message: 'Invalid request parameters.',
          details: response.data,
        );
      case 401:
        return ApiError(
          code: 'UNAUTHORIZED',
          message: 'Authentication required.',
        );
      case 403:
        return ApiError(
          code: 'FORBIDDEN',
          message: 'Access denied.',
        );
      case 404:
        return ApiError(
          code: 'NOT_FOUND',
          message: 'Resource not found.',
        );
      case 500:
        return ApiError(
          code: 'SERVER_ERROR',
          message: 'Internal server error.',
        );
      default:
        return ApiError(
          code: 'HTTP_ERROR',
          message: 'HTTP ${response.statusCode}: ${response.statusMessage}',
        );
    }
  }
}

class ApiError {
  final String code;
  final String message;
  final dynamic details;
  
  ApiError({
    required this.code,
    required this.message,
    this.details,
  });
}
```

## Repository Pattern

### 1. Abstract Repository

```dart
// lib/repositories/base_repository.dart
abstract class BaseRepository<T> {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<T> create(T item);
  Future<T> update(String id, T item);
  Future<void> delete(String id);
}
```

### 2. Concrete Implementation

```dart
// lib/repositories/user_repository.dart
class UserRepository implements BaseRepository<User> {
  final Dio _dio = ApiClient.instance;
  
  @override
  Future<List<User>> getAll() async {
    try {
      final response = await _dio.get('/users');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<User?> getById(String id) async {
    try {
      final response = await _dio.get('/users/$id');
      return User.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw _handleError(e);
    }
  }
  
  @override
  Future<User> create(User user) async {
    try {
      final response = await _dio.post('/users', data: user.toJson());
      return User.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<User> update(String id, User user) async {
    try {
      final response = await _dio.put('/users/$id', data: user.toJson());
      return User.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<void> delete(String id) async {
    try {
      await _dio.delete('/users/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Custom methods
  Future<List<User>> searchUsers(String query) async {
    try {
      final response = await _dio.get('/users/search', queryParameters: {
        'q': query,
        'limit': 20,
      });
      final List<dynamic> data = response.data['data'];
      return data.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  RepositoryException _handleError(dynamic error) {
    if (error is DioException && error.error is ApiError) {
      final apiError = error.error as ApiError;
      return RepositoryException(
        message: apiError.message,
        code: apiError.code,
        details: apiError.details,
      );
    }
    return RepositoryException(
      message: 'An unexpected error occurred',
      code: 'UNKNOWN',
    );
  }
}

class RepositoryException implements Exception {
  final String message;
  final String code;
  final dynamic details;
  
  RepositoryException({
    required this.message,
    required this.code,
    this.details,
  });
}
```

## Data Models

### 1. Model with JSON Serialization

```dart
// lib/models/user.dart
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String name;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  
  User({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
  
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
```

### 2. API Response Wrapper

```dart
// lib/models/api_response.dart
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? errors;
  final PaginationMeta? meta;
  
  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
    this.meta,
  });
  
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);
  
  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);
}

@JsonSerializable()
class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  
  PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });
  
  factory PaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$PaginationMetaFromJson(json);
  Map<String, dynamic> toJson() => _$PaginationMetaToJson(this);
}
```

## Caching Strategy

### 1. HTTP Cache with Dio

```dart
// lib/services/cache_service.dart
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

class CacheService {
  static CacheOptions get defaultCacheOptions => CacheOptions(
    store: MemCacheStore(),
    policy: CachePolicy.request,
    hitCacheOnErrorExcept: [401, 403],
    maxStale: const Duration(days: 7),
    priority: CachePriority.normal,
    cipher: null,
    keyBuilder: CacheOptions.defaultCacheKeyBuilder,
    allowPostMethod: false,
  );
  
  static CacheOptions get longTermCache => CacheOptions(
    store: HiveCacheStore(null),
    policy: CachePolicy.cacheFirst,
    maxStale: const Duration(days: 30),
    priority: CachePriority.high,
  );
  
  static CacheOptions get shortTermCache => CacheOptions(
    store: MemCacheStore(),
    policy: CachePolicy.refreshForceCache,
    maxStale: const Duration(minutes: 5),
    priority: CachePriority.low,
  );
}

// Usage in repository
class CachedUserRepository extends UserRepository {
  @override
  Future<List<User>> getAll() async {
    final response = await _dio.get(
      '/users',
      options: CacheService.shortTermCache.toOptions(),
    );
    final List<dynamic> data = response.data['data'];
    return data.map((json) => User.fromJson(json)).toList();
  }
}
```

### 2. Custom Cache Implementation

```dart
// lib/services/custom_cache.dart
class CustomCache<T> {
  final Map<String, CacheEntry<T>> _cache = {};
  final Duration defaultTtl;
  
  CustomCache({this.defaultTtl = const Duration(minutes: 5)});
  
  void put(String key, T value, {Duration? ttl}) {
    final expiry = DateTime.now().add(ttl ?? defaultTtl);
    _cache[key] = CacheEntry(value, expiry);
  }
  
  T? get(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    
    if (DateTime.now().isAfter(entry.expiry)) {
      _cache.remove(key);
      return null;
    }
    
    return entry.value;
  }
  
  void remove(String key) {
    _cache.remove(key);
  }
  
  void clear() {
    _cache.clear();
  }
  
  bool containsKey(String key) {
    final entry = _cache[key];
    if (entry == null) return false;
    
    if (DateTime.now().isAfter(entry.expiry)) {
      _cache.remove(key);
      return false;
    }
    
    return true;
  }
}

class CacheEntry<T> {
  final T value;
  final DateTime expiry;
  
  CacheEntry(this.value, this.expiry);
}
```

## GraphQL Integration

### 1. GraphQL Setup

```yaml
# pubspec.yaml
dependencies:
  graphql_flutter: ^5.1.2
```

```dart
// lib/services/graphql_client.dart
import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLService {
  static GraphQLClient? _client;
  
  static void initialize() {
    final HttpLink httpLink = HttpLink('https://api.example.com/graphql');
    
    final AuthLink authLink = AuthLink(
      getToken: () async {
        final token = await TokenService.getAccessToken();
        return token != null ? 'Bearer $token' : null;
      },
    );
    
    final Link link = authLink.concat(httpLink);
    
    _client = GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: link,
    );
  }
  
  static GraphQLClient get client {
    if (_client == null) {
      throw Exception('GraphQL client not initialized');
    }
    return _client!;
  }
}
```

### 2. GraphQL Queries

```dart
// lib/graphql/queries.dart
class GraphQLQueries {
  static const String getUsers = '''
    query GetUsers(\$limit: Int, \$offset: Int) {
      users(limit: \$limit, offset: \$offset) {
        id
        email
        name
        avatarUrl
        createdAt
        updatedAt
      }
    }
  ''';
  
  static const String getUserById = '''
    query GetUser(\$id: ID!) {
      user(id: \$id) {
        id
        email
        name
        avatarUrl
        posts {
          id
          title
          content
          createdAt
        }
      }
    }
  ''';
  
  static const String createUser = '''
    mutation CreateUser(\$input: CreateUserInput!) {
      createUser(input: \$input) {
        id
        email
        name
        avatarUrl
      }
    }
  ''';
}

// lib/repositories/graphql_user_repository.dart
class GraphQLUserRepository {
  final GraphQLClient _client = GraphQLService.client;
  
  Future<List<User>> getUsers({int limit = 20, int offset = 0}) async {
    final QueryOptions options = QueryOptions(
      document: gql(GraphQLQueries.getUsers),
      variables: {'limit': limit, 'offset': offset},
      fetchPolicy: FetchPolicy.cacheAndNetwork,
    );
    
    final QueryResult result = await _client.query(options);
    
    if (result.hasException) {
      throw GraphQLException(result.exception!);
    }
    
    final List<dynamic> usersData = result.data!['users'];
    return usersData.map((json) => User.fromJson(json)).toList();
  }
  
  Future<User> createUser(CreateUserInput input) async {
    final MutationOptions options = MutationOptions(
      document: gql(GraphQLQueries.createUser),
      variables: {'input': input.toJson()},
    );
    
    final QueryResult result = await _client.mutate(options);
    
    if (result.hasException) {
      throw GraphQLException(result.exception!);
    }
    
    return User.fromJson(result.data!['createUser']);
  }
}

class GraphQLException implements Exception {
  final OperationException exception;
  
  GraphQLException(this.exception);
  
  String get message {
    if (exception.graphqlErrors.isNotEmpty) {
      return exception.graphqlErrors.first.message;
    }
    if (exception.linkException != null) {
      return exception.linkException.toString();
    }
    return 'Unknown GraphQL error';
  }
}
```

## File Upload

### 1. Multipart File Upload

```dart
// lib/services/upload_service.dart
class UploadService {
  final Dio _dio = ApiClient.instance;
  
  Future<String> uploadFile(File file, {
    String? fileName,
    Function(int, int)? onProgress,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName ?? file.path.split('/').last,
      ),
    });
    
    try {
      final response = await _dio.post(
        '/upload',
        data: formData,
        onSendProgress: onProgress,
      );
      
      return response.data['url'];
    } catch (e) {
      throw UploadException('Failed to upload file: ${e.toString()}');
    }
  }
  
  Future<List<String>> uploadMultipleFiles(
    List<File> files, {
    Function(int, int)? onProgress,
  }) async {
    final formData = FormData();
    
    for (int i = 0; i < files.length; i++) {
      formData.files.add(MapEntry(
        'files',
        await MultipartFile.fromFile(
          files[i].path,
          filename: files[i].path.split('/').last,
        ),
      ));
    }
    
    try {
      final response = await _dio.post(
        '/upload/multiple',
        data: formData,
        onSendProgress: onProgress,
      );
      
      return List<String>.from(response.data['urls']);
    } catch (e) {
      throw UploadException('Failed to upload files: ${e.toString()}');
    }
  }
}

class UploadException implements Exception {
  final String message;
  UploadException(this.message);
}
```

## Testing API Integration

### 1. Mock HTTP Client

```dart
// test/mocks/mock_dio.dart
import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';

class MockDio extends Mock implements Dio {}

// test/repositories/user_repository_test.dart
void main() {
  group('UserRepository Tests', () {
    late MockDio mockDio;
    late UserRepository repository;
    
    setUp(() {
      mockDio = MockDio();
      repository = UserRepository();
      // Inject mock dio
    });
    
    test('should return users when API call is successful', () async {
      // Arrange
      final mockResponse = Response(
        data: {
          'data': [
            {'id': '1', 'email': 'test@example.com', 'name': 'Test User'}
          ]
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/users'),
      );
      
      when(mockDio.get('/users')).thenAnswer((_) async => mockResponse);
      
      // Act
      final users = await repository.getAll();
      
      // Assert
      expect(users, isA<List<User>>());
      expect(users.length, 1);
      expect(users.first.email, 'test@example.com');
    });
  });
}
```

### 2. Integration Tests

```dart
// integration_test/api_integration_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('API Integration Tests', () {
    setUpAll(() {
      ApiClient.initialize();
    });
    
    testWidgets('should fetch users from real API', (tester) async {
      final repository = UserRepository();
      final users = await repository.getAll();
      
      expect(users, isNotEmpty);
      expect(users.first, isA<User>());
    });
  });
}
```

API integration is fundamental to modern app development. Follow these patterns for robust, maintainable, and testable API integration in your Flutter applications.
