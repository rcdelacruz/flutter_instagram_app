# Supabase Integration

Comprehensive guide to integrating Supabase as the backend service for Flutter applications, covering authentication, database operations, real-time features, and storage.

## Overview

Supabase is an open-source Firebase alternative that provides a complete backend solution with PostgreSQL database, authentication, real-time subscriptions, and storage. This guide covers full integration with Flutter.

## Setup and Configuration

### 1. Project Setup

```yaml
# pubspec.yaml
dependencies:
  supabase_flutter: ^2.3.4
  supabase: ^2.2.2

dev_dependencies:
  supabase_test_helpers: ^0.4.0
```

```dart
// lib/config/supabase_config.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key',
  );
  
  static const String supabaseServiceKey = String.fromEnvironment(
    'SUPABASE_SERVICE_KEY',
    defaultValue: 'your-service-key',
  );
  
  // Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: kDebugMode,
    );
  }
  
  // Get Supabase client
  static SupabaseClient get client => Supabase.instance.client;
  
  // Get current user
  static User? get currentUser => client.auth.currentUser;
  
  // Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;
}
```

### 2. Environment Configuration

```bash
# .env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_KEY=your-service-key
```

```dart
// lib/main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseConfig.initialize();
  
  runApp(MyApp());
}
```

## Authentication Service

### 1. Authentication Manager

```dart
// lib/services/supabase_auth_service.dart
class SupabaseAuthService {
  static final SupabaseClient _client = SupabaseConfig.client;
  
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
      
      if (response.user != null) {
        await _createUserProfile(response.user!, metadata);
      }
      
      return response;
    } catch (e) {
      throw AuthException('Sign up failed: $e');
    }
  }
  
  // Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw AuthException('Sign in failed: $e');
    }
  }
  
  // Sign in with OAuth provider
  static Future<bool> signInWithOAuth(OAuthProvider provider) async {
    try {
      await _client.auth.signInWithOAuth(
        provider,
        redirectTo: 'your-app://auth-callback',
      );
      return true;
    } catch (e) {
      throw AuthException('OAuth sign in failed: $e');
    }
  }
  
  // Sign out
  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw AuthException('Sign out failed: $e');
    }
  }
  
  // Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'your-app://reset-password',
      );
    } catch (e) {
      throw AuthException('Password reset failed: $e');
    }
  }
  
  // Update password
  static Future<UserResponse> updatePassword(String newPassword) async {
    try {
      return await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw AuthException('Password update failed: $e');
    }
  }
  
  // Get current session
  static Session? getCurrentSession() {
    return _client.auth.currentSession;
  }
  
  // Listen to auth state changes
  static Stream<AuthState> get authStateChanges {
    return _client.auth.onAuthStateChange;
  }
  
  // Create user profile after signup
  static Future<void> _createUserProfile(
    User user,
    Map<String, dynamic>? metadata,
  ) async {
    try {
      await _client.from('profiles').insert({
        'id': user.id,
        'email': user.email,
        'username': metadata?['username'] ?? user.email?.split('@').first,
        'display_name': metadata?['display_name'] ?? '',
        'bio': metadata?['bio'] ?? '',
        'avatar_url': user.userMetadata?['avatar_url'],
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to create user profile: $e');
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  
  @override
  String toString() => 'AuthException: $message';
}
```

### 2. User Profile Service

```dart
// lib/services/user_profile_service.dart
class UserProfileService {
  static final SupabaseClient _client = SupabaseConfig.client;
  
  // Get user profile
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      
      return response;
    } catch (e) {
      print('Failed to get user profile: $e');
      return null;
    }
  }
  
  // Update user profile
  static Future<void> updateUserProfile({
    required String userId,
    String? username,
    String? displayName,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (username != null) updates['username'] = username;
      if (displayName != null) updates['display_name'] = displayName;
      if (bio != null) updates['bio'] = bio;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      
      await _client
          .from('profiles')
          .update(updates)
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
  
  // Search users
  static Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final response = await _client
          .from('profiles')
          .select('id, username, display_name, avatar_url')
          .or('username.ilike.%$query%,display_name.ilike.%$query%')
          .limit(20);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Failed to search users: $e');
      return [];
    }
  }
  
  // Follow user
  static Future<void> followUser(String followerId, String followingId) async {
    try {
      await _client.from('follows').insert({
        'follower_id': followerId,
        'following_id': followingId,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      // Update follower counts
      await _updateFollowerCounts(followerId, followingId);
    } catch (e) {
      throw Exception('Failed to follow user: $e');
    }
  }
  
  // Unfollow user
  static Future<void> unfollowUser(String followerId, String followingId) async {
    try {
      await _client
          .from('follows')
          .delete()
          .eq('follower_id', followerId)
          .eq('following_id', followingId);
      
      // Update follower counts
      await _updateFollowerCounts(followerId, followingId);
    } catch (e) {
      throw Exception('Failed to unfollow user: $e');
    }
  }
  
  // Check if user is following another user
  static Future<bool> isFollowing(String followerId, String followingId) async {
    try {
      final response = await _client
          .from('follows')
          .select('id')
          .eq('follower_id', followerId)
          .eq('following_id', followingId)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      return false;
    }
  }
  
  // Update follower counts
  static Future<void> _updateFollowerCounts(String followerId, String followingId) async {
    try {
      // Update follower count for the followed user
      final followerCount = await _client
          .from('follows')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('following_id', followingId);
      
      await _client
          .from('profiles')
          .update({'follower_count': followerCount.count})
          .eq('id', followingId);
      
      // Update following count for the follower
      final followingCount = await _client
          .from('follows')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('follower_id', followerId);
      
      await _client
          .from('profiles')
          .update({'following_count': followingCount.count})
          .eq('id', followerId);
    } catch (e) {
      print('Failed to update follower counts: $e');
    }
  }
}
```

## Database Operations

### 1. Posts Service

```dart
// lib/services/posts_service.dart
class PostsService {
  static final SupabaseClient _client = SupabaseConfig.client;
  
  // Create a new post
  static Future<Map<String, dynamic>> createPost({
    required String userId,
    required String imageUrl,
    String? caption,
    List<String>? tags,
    Map<String, dynamic>? location,
  }) async {
    try {
      final response = await _client.from('posts').insert({
        'user_id': userId,
        'image_url': imageUrl,
        'caption': caption ?? '',
        'tags': tags ?? [],
        'location': location,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).select().single();
      
      return response;
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }
  
  // Get posts feed
  static Future<List<Map<String, dynamic>>> getPostsFeed({
    String? userId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var query = _client
          .from('posts')
          .select('''
            *,
            profiles:user_id (
              id,
              username,
              display_name,
              avatar_url
            ),
            likes:post_likes (count),
            comments:post_comments (count)
          ''')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      
      if (userId != null) {
        query = query.eq('user_id', userId);
      }
      
      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Failed to get posts feed: $e');
      return [];
    }
  }
  
  // Get single post
  static Future<Map<String, dynamic>?> getPost(String postId) async {
    try {
      final response = await _client
          .from('posts')
          .select('''
            *,
            profiles:user_id (
              id,
              username,
              display_name,
              avatar_url
            ),
            likes:post_likes (count),
            comments:post_comments (count)
          ''')
          .eq('id', postId)
          .single();
      
      return response;
    } catch (e) {
      print('Failed to get post: $e');
      return null;
    }
  }
  
  // Update post
  static Future<void> updatePost({
    required String postId,
    String? caption,
    List<String>? tags,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (caption != null) updates['caption'] = caption;
      if (tags != null) updates['tags'] = tags;
      
      await _client
          .from('posts')
          .update(updates)
          .eq('id', postId);
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }
  
  // Delete post
  static Future<void> deletePost(String postId) async {
    try {
      await _client
          .from('posts')
          .delete()
          .eq('id', postId);
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }
  
  // Like post
  static Future<void> likePost(String postId, String userId) async {
    try {
      await _client.from('post_likes').insert({
        'post_id': postId,
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      // Update like count
      await _updateLikeCount(postId);
    } catch (e) {
      throw Exception('Failed to like post: $e');
    }
  }
  
  // Unlike post
  static Future<void> unlikePost(String postId, String userId) async {
    try {
      await _client
          .from('post_likes')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', userId);
      
      // Update like count
      await _updateLikeCount(postId);
    } catch (e) {
      throw Exception('Failed to unlike post: $e');
    }
  }
  
  // Check if user liked post
  static Future<bool> isPostLiked(String postId, String userId) async {
    try {
      final response = await _client
          .from('post_likes')
          .select('id')
          .eq('post_id', postId)
          .eq('user_id', userId)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      return false;
    }
  }
  
  // Update like count
  static Future<void> _updateLikeCount(String postId) async {
    try {
      final likeCount = await _client
          .from('post_likes')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('post_id', postId);
      
      await _client
          .from('posts')
          .update({'like_count': likeCount.count})
          .eq('id', postId);
    } catch (e) {
      print('Failed to update like count: $e');
    }
  }
}
```

### 2. Comments Service

```dart
// lib/services/comments_service.dart
class CommentsService {
  static final SupabaseClient _client = SupabaseConfig.client;
  
  // Add comment to post
  static Future<Map<String, dynamic>> addComment({
    required String postId,
    required String userId,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      final response = await _client.from('post_comments').insert({
        'post_id': postId,
        'user_id': userId,
        'content': content,
        'parent_comment_id': parentCommentId,
        'created_at': DateTime.now().toIso8601String(),
      }).select('''
        *,
        profiles:user_id (
          id,
          username,
          display_name,
          avatar_url
        )
      ''').single();
      
      // Update comment count
      await _updateCommentCount(postId);
      
      return response;
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }
  
  // Get comments for post
  static Future<List<Map<String, dynamic>>> getComments({
    required String postId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _client
          .from('post_comments')
          .select('''
            *,
            profiles:user_id (
              id,
              username,
              display_name,
              avatar_url
            ),
            replies:post_comments!parent_comment_id (
              *,
              profiles:user_id (
                id,
                username,
                display_name,
                avatar_url
              )
            )
          ''')
          .eq('post_id', postId)
          .is_('parent_comment_id', null)
          .order('created_at', ascending: true)
          .range(offset, offset + limit - 1);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Failed to get comments: $e');
      return [];
    }
  }
  
  // Delete comment
  static Future<void> deleteComment(String commentId, String postId) async {
    try {
      await _client
          .from('post_comments')
          .delete()
          .eq('id', commentId);
      
      // Update comment count
      await _updateCommentCount(postId);
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }
  
  // Update comment count
  static Future<void> _updateCommentCount(String postId) async {
    try {
      final commentCount = await _client
          .from('post_comments')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('post_id', postId);
      
      await _client
          .from('posts')
          .update({'comment_count': commentCount.count})
          .eq('id', postId);
    } catch (e) {
      print('Failed to update comment count: $e');
    }
  }
}
```

## Real-time Features

### 1. Real-time Service

```dart
// lib/services/realtime_service.dart
class RealtimeService {
  static final SupabaseClient _client = SupabaseConfig.client;
  static final Map<String, RealtimeChannel> _channels = {};
  
  // Subscribe to posts changes
  static RealtimeChannel subscribeToPostsChanges({
    required Function(Map<String, dynamic>) onInsert,
    required Function(Map<String, dynamic>) onUpdate,
    required Function(Map<String, dynamic>) onDelete,
  }) {
    const channelName = 'posts_changes';
    
    final channel = _client.channel(channelName);
    
    channel
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
    
    _channels[channelName] = channel;
    return channel;
  }
  
  // Subscribe to likes changes for a specific post
  static RealtimeChannel subscribeToPostLikes({
    required String postId,
    required Function(Map<String, dynamic>) onLike,
    required Function(Map<String, dynamic>) onUnlike,
  }) {
    final channelName = 'post_likes_$postId';
    
    final channel = _client.channel(channelName);
    
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'post_likes',
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
          table: 'post_likes',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'post_id',
            value: postId,
          ),
          callback: (payload) => onUnlike(payload.oldRecord),
        )
        .subscribe();
    
    _channels[channelName] = channel;
    return channel;
  }
  
  // Subscribe to comments changes for a specific post
  static RealtimeChannel subscribeToPostComments({
    required String postId,
    required Function(Map<String, dynamic>) onNewComment,
    required Function(Map<String, dynamic>) onDeleteComment,
  }) {
    final channelName = 'post_comments_$postId';
    
    final channel = _client.channel(channelName);
    
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'post_comments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'post_id',
            value: postId,
          ),
          callback: (payload) => onNewComment(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'post_comments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'post_id',
            value: postId,
          ),
          callback: (payload) => onDeleteComment(payload.oldRecord),
        )
        .subscribe();
    
    _channels[channelName] = channel;
    return channel;
  }
  
  // Subscribe to user presence
  static RealtimeChannel subscribeToPresence({
    required String channelName,
    required Function(String, Map<String, dynamic>) onJoin,
    required Function(String, Map<String, dynamic>) onLeave,
  }) {
    final channel = _client.channel(channelName);
    
    channel
        .onPresenceSync((syncs) {
          for (final sync in syncs) {
            onJoin(sync.key, sync.currentPresences.first.payload);
          }
        })
        .onPresenceJoin((key, currentPresences, newPresences) {
          onJoin(key, newPresences.first.payload);
        })
        .onPresenceLeave((key, currentPresences, leftPresences) {
          onLeave(key, leftPresences.first.payload);
        })
        .subscribe();
    
    _channels[channelName] = channel;
    return channel;
  }
  
  // Track user presence
  static Future<void> trackPresence({
    required String channelName,
    required Map<String, dynamic> presenceData,
  }) async {
    final channel = _channels[channelName];
    if (channel != null) {
      await channel.track(presenceData);
    }
  }
  
  // Unsubscribe from channel
  static Future<void> unsubscribe(String channelName) async {
    final channel = _channels.remove(channelName);
    if (channel != null) {
      await _client.removeChannel(channel);
    }
  }
  
  // Unsubscribe from all channels
  static Future<void> unsubscribeAll() async {
    for (final channel in _channels.values) {
      await _client.removeChannel(channel);
    }
    _channels.clear();
  }
}
```

## Storage Service

### 1. File Upload Service

```dart
// lib/services/storage_service.dart
class StorageService {
  static final SupabaseClient _client = SupabaseConfig.client;
  static const String _avatarsBucket = 'avatars';
  static const String _postsBucket = 'posts';
  
  // Upload avatar image
  static Future<String> uploadAvatar({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final fileExt = path.extension(imageFile.path);
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}$fileExt';
      
      await _client.storage
          .from(_avatarsBucket)
          .upload(fileName, imageFile);
      
      final publicUrl = _client.storage
          .from(_avatarsBucket)
          .getPublicUrl(fileName);
      
      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }
  
  // Upload post image
  static Future<String> uploadPostImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final fileExt = path.extension(imageFile.path);
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}$fileExt';
      
      await _client.storage
          .from(_postsBucket)
          .upload(fileName, imageFile);
      
      final publicUrl = _client.storage
          .from(_postsBucket)
          .getPublicUrl(fileName);
      
      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload post image: $e');
    }
  }
  
  // Delete file
  static Future<void> deleteFile({
    required String bucket,
    required String fileName,
  }) async {
    try {
      await _client.storage
          .from(bucket)
          .remove([fileName]);
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }
  
  // Get file URL
  static String getFileUrl({
    required String bucket,
    required String fileName,
  }) {
    return _client.storage
        .from(bucket)
        .getPublicUrl(fileName);
  }
  
  // Create signed URL for private files
  static Future<String> createSignedUrl({
    required String bucket,
    required String fileName,
    int expiresInSeconds = 3600,
  }) async {
    try {
      return await _client.storage
          .from(bucket)
          .createSignedUrl(fileName, expiresInSeconds);
    } catch (e) {
      throw Exception('Failed to create signed URL: $e');
    }
  }
}
```

Supabase provides a comprehensive backend solution for Flutter applications. Implement proper authentication, database operations, real-time features, and storage to build scalable and feature-rich applications.
