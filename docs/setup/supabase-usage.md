# Supabase Usage in Flutter

Comprehensive guide to using Supabase in Flutter applications, covering authentication, database operations, storage, and real-time features.

## Authentication

### 1. Authentication Service

```dart
// lib/core/services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Get auth state stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
    required String fullName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'username': username,
        'full_name': fullName,
      },
    );

    if (response.user != null) {
      // Create profile after successful signup
      await _createProfile(
        userId: response.user!.id,
        username: username,
        fullName: fullName,
      );
    }

    return response;
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.instagramapp.flutter://login-callback',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  // Create user profile
  Future<void> _createProfile({
    required String userId,
    required String username,
    required String fullName,
  }) async {
    await _client.from('profiles').insert({
      'id': userId,
      'username': username,
      'full_name': fullName,
    });
  }
}
```

### 2. Authentication Provider (Riverpod)

```dart
// lib/features/auth/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<AuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  return authService.authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (state) => state.session?.user,
    loading: () => null,
    error: (_, __) => null,
  );
});

// Auth state notifier for complex auth operations
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    state = AsyncValue.data(_authService.currentUser);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    required String fullName,
  }) async {
    state = const AsyncValue.loading();

    try {
      final response = await _authService.signUp(
        email: email,
        password: password,
        username: username,
        fullName: fullName,
      );

      if (response.user != null) {
        state = AsyncValue.data(response.user);
      } else {
        state = AsyncValue.error('Sign up failed', StackTrace.current);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    try {
      final response = await _authService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        state = AsyncValue.data(response.user);
      } else {
        state = AsyncValue.error('Sign in failed', StackTrace.current);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final authService = ref.read(authServiceProvider);
  return AuthNotifier(authService);
});
```

## Database Operations

### 1. Post Service

```dart
// lib/features/feed/services/post_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class PostService {
  final SupabaseClient _client = Supabase.instance.client;

  // Get feed posts
  Future<List<Map<String, dynamic>>> getFeedPosts({
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _client
        .from('posts')
        .select('''
          *,
          profiles:user_id (
            username,
            avatar_url,
            full_name
          ),
          likes (
            user_id
          ),
          comments (
            id,
            content,
            created_at,
            profiles:user_id (
              username,
              avatar_url
            )
          )
        ''')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return List<Map<String, dynamic>>.from(response);
  }

  // Create a new post
  Future<Map<String, dynamic>> createPost({
    required String imageUrl,
    required String caption,
    String? location,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _client
        .from('posts')
        .insert({
          'user_id': userId,
          'image_url': imageUrl,
          'caption': caption,
          'location': location,
        })
        .select()
        .single();

    return response;
  }

  // Like a post
  Future<void> likePost(String postId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _client.from('likes').insert({
      'user_id': userId,
      'post_id': postId,
    });
  }

  // Unlike a post
  Future<void> unlikePost(String postId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _client
        .from('likes')
        .delete()
        .eq('user_id', userId)
        .eq('post_id', postId);
  }

  // Add comment to post
  Future<Map<String, dynamic>> addComment({
    required String postId,
    required String content,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _client
        .from('comments')
        .insert({
          'user_id': userId,
          'post_id': postId,
          'content': content,
        })
        .select('''
          *,
          profiles:user_id (
            username,
            avatar_url
          )
        ''')
        .single();

    return response;
  }

  // Delete post
  Future<void> deletePost(String postId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _client
        .from('posts')
        .delete()
        .eq('id', postId)
        .eq('user_id', userId);
  }
}
```

### 2. User Service

```dart
// lib/features/profile/services/user_service.dart
class UserService {
  final SupabaseClient _client = Supabase.instance.client;

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    return response;
  }

  // Update user profile
  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    String? username,
    String? fullName,
    String? bio,
    String? website,
    String? avatarUrl,
  }) async {
    final updates = <String, dynamic>{};

    if (username != null) updates['username'] = username;
    if (fullName != null) updates['full_name'] = fullName;
    if (bio != null) updates['bio'] = bio;
    if (website != null) updates['website'] = website;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    updates['updated_at'] = DateTime.now().toIso8601String();

    final response = await _client
        .from('profiles')
        .update(updates)
        .eq('id', userId)
        .select()
        .single();

    return response;
  }

  // Follow user
  Future<void> followUser(String userId) async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) throw Exception('User not authenticated');

    await _client.from('follows').insert({
      'follower_id': currentUserId,
      'following_id': userId,
    });
  }

  // Unfollow user
  Future<void> unfollowUser(String userId) async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) throw Exception('User not authenticated');

    await _client
        .from('follows')
        .delete()
        .eq('follower_id', currentUserId)
        .eq('following_id', userId);
  }

  // Check if following user
  Future<bool> isFollowing(String userId) async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) return false;

    final response = await _client
        .from('follows')
        .select()
        .eq('follower_id', currentUserId)
        .eq('following_id', userId)
        .maybeSingle();

    return response != null;
  }

  // Get user's followers
  Future<List<Map<String, dynamic>>> getFollowers(String userId) async {
    final response = await _client
        .from('follows')
        .select('''
          profiles:follower_id (
            id,
            username,
            full_name,
            avatar_url
          )
        ''')
        .eq('following_id', userId);

    return List<Map<String, dynamic>>.from(response);
  }

  // Get user's following
  Future<List<Map<String, dynamic>>> getFollowing(String userId) async {
    final response = await _client
        .from('follows')
        .select('''
          profiles:following_id (
            id,
            username,
            full_name,
            avatar_url
          )
        ''')
        .eq('follower_id', userId);

    return List<Map<String, dynamic>>.from(response);
  }
}
```

## Storage Operations

### 1. Storage Service

```dart
// lib/core/services/storage_service.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final SupabaseClient _client = Supabase.instance.client;

  // Upload avatar image
  Future<String> uploadAvatar(XFile imageFile) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final bytes = await imageFile.readAsBytes();
    final fileExt = path.extension(imageFile.name);
    final fileName = '$userId/avatar$fileExt';

    await _client.storage.from('avatars').uploadBinary(
      fileName,
      bytes,
      fileOptions: const FileOptions(
        cacheControl: '3600',
        upsert: true,
      ),
    );

    return _client.storage.from('avatars').getPublicUrl(fileName);
  }

  // Upload post image
  Future<String> uploadPostImage(XFile imageFile) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final bytes = await imageFile.readAsBytes();
    final fileExt = path.extension(imageFile.name);
    final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}$fileExt';

    await _client.storage.from('posts').uploadBinary(
      fileName,
      bytes,
      fileOptions: const FileOptions(
        cacheControl: '3600',
        upsert: false,
      ),
    );

    return _client.storage.from('posts').getPublicUrl(fileName);
  }

  // Upload story image
  Future<String> uploadStoryImage(XFile imageFile) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final bytes = await imageFile.readAsBytes();
    final fileExt = path.extension(imageFile.name);
    final fileName = '$userId/story_${DateTime.now().millisecondsSinceEpoch}$fileExt';

    await _client.storage.from('stories').uploadBinary(
      fileName,
      bytes,
      fileOptions: const FileOptions(
        cacheControl: '3600',
        upsert: false,
      ),
    );

    return _client.storage.from('stories').getPublicUrl(fileName);
  }

  // Delete file from storage
  Future<void> deleteFile(String bucket, String fileName) async {
    await _client.storage.from(bucket).remove([fileName]);
  }

  // Get file URL
  String getPublicUrl(String bucket, String fileName) {
    return _client.storage.from(bucket).getPublicUrl(fileName);
  }
}
```

## Real-time Features

### 1. Real-time Service

```dart
// lib/core/services/realtime_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeService {
  final SupabaseClient _client = Supabase.instance.client;
  RealtimeChannel? _channel;

  // Subscribe to post changes
  void subscribeToPostChanges({
    required Function(Map<String, dynamic>) onInsert,
    required Function(Map<String, dynamic>) onUpdate,
    required Function(Map<String, dynamic>) onDelete,
  }) {
    _channel = _client
        .channel('posts_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'posts',
          callback: (payload) => onInsert(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'posts',
          callback: (payload) => onUpdate(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'posts',
          callback: (payload) => onDelete(payload.oldRecord),
        )
        .subscribe();
  }

  // Subscribe to likes changes for a specific post
  void subscribeToLikesChanges({
    required String postId,
    required Function(Map<String, dynamic>) onLike,
    required Function(Map<String, dynamic>) onUnlike,
  }) {
    _channel = _client
        .channel('likes_changes_$postId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'likes',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'post_id',
            value: postId,
          ),
          callback: (payload) => onLike(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'likes',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'post_id',
            value: postId,
          ),
          callback: (payload) => onUnlike(payload.oldRecord),
        )
        .subscribe();
  }

  // Subscribe to comments changes for a specific post
  void subscribeToCommentsChanges({
    required String postId,
    required Function(Map<String, dynamic>) onNewComment,
  }) {
    _channel = _client
        .channel('comments_changes_$postId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'comments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'post_id',
            value: postId,
          ),
          callback: (payload) => onNewComment(payload.newRecord),
        )
        .subscribe();
  }

  // Unsubscribe from changes
  void unsubscribe() {
    _channel?.unsubscribe();
    _channel = null;
  }
}
```

## Error Handling

### 1. Supabase Error Handler

```dart
// lib/core/utils/supabase_error_handler.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseErrorHandler {
  static String getErrorMessage(Object error) {
    if (error is PostgrestException) {
      switch (error.code) {
        case '23505':
          return 'This item already exists';
        case '23503':
          return 'Referenced item does not exist';
        case '42501':
          return 'Permission denied';
        default:
          return error.message;
      }
    } else if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return 'Invalid email or password';
        case 'Email not confirmed':
          return 'Please check your email and confirm your account';
        case 'User already registered':
          return 'An account with this email already exists';
        default:
          return error.message;
      }
    } else if (error is StorageException) {
      switch (error.statusCode) {
        case '413':
          return 'File too large';
        case '415':
          return 'Unsupported file type';
        default:
          return error.message;
      }
    }

    return 'An unexpected error occurred';
  }
}
```

## Best Practices

### 1. Connection Management

```dart
// Check connection before operations
Future<bool> isConnected() async {
  try {
    await Supabase.instance.client.from('profiles').select('id').limit(1);
    return true;
  } catch (e) {
    return false;
  }
}
```

### 2. Offline Support

```dart
// Cache data locally for offline support
class CacheService {
  static const String _postsKey = 'cached_posts';

  static Future<void> cachePosts(List<Map<String, dynamic>> posts) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(posts);
    await prefs.setString(_postsKey, jsonString);
  }

  static Future<List<Map<String, dynamic>>> getCachedPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_postsKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.cast<Map<String, dynamic>>();
    }
    return [];
  }
}
```

### 3. Performance Optimization

```dart
// Use pagination for large datasets
Future<List<Map<String, dynamic>>> getPaginatedPosts({
  int page = 0,
  int pageSize = 20,
}) async {
  final offset = page * pageSize;

  return await _client
      .from('posts')
      .select()
      .range(offset, offset + pageSize - 1)
      .order('created_at', ascending: false);
}

// Use select to limit returned fields
Future<List<Map<String, dynamic>>> getPostsMinimal() async {
  return await _client
      .from('posts')
      .select('id, image_url, likes_count, comments_count')
      .order('created_at', ascending: false);
}
```

## Next Steps

1. ✅ Implement authentication flow in your Flutter app
2. ✅ Set up database operations for your features
3. ✅ Configure storage for image uploads
4. ✅ Add real-time features for better UX
5. ✅ Proceed to [UI/UX Documentation](../ui/design-systems.md)

Your Supabase integration is now ready for production use!
