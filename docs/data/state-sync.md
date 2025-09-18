# State Synchronization

Comprehensive guide to synchronizing application state across different parts of your Flutter app and with external data sources.

## Overview

State synchronization ensures data consistency across your Flutter application, from local state management to server synchronization. This guide covers patterns, tools, and best practices.

## Local State Synchronization

### 1. Riverpod State Sync

```dart
// lib/providers/sync_provider.dart
import 'package:riverpod/riverpod.dart';

// Global state that needs to be synced
final userProvider = StateNotifierProvider<UserNotifier, AsyncValue<User>>((ref) {
  return UserNotifier(ref);
});

final postsProvider = StateNotifierProvider<PostsNotifier, AsyncValue<List<Post>>>((ref) {
  return PostsNotifier(ref);
});

class UserNotifier extends StateNotifier<AsyncValue<User>> {
  final Ref ref;
  
  UserNotifier(this.ref) : super(const AsyncValue.loading());
  
  Future<void> updateUser(User user) async {
    state = AsyncValue.data(user);
    
    // Sync with other providers that depend on user
    ref.read(postsProvider.notifier).onUserChanged(user);
    ref.read(settingsProvider.notifier).onUserChanged(user);
  }
  
  Future<void> syncWithServer() async {
    try {
      final user = await userRepository.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class PostsNotifier extends StateNotifier<AsyncValue<List<Post>>> {
  final Ref ref;
  
  PostsNotifier(this.ref) : super(const AsyncValue.loading());
  
  void onUserChanged(User user) {
    // Reload posts when user changes
    loadUserPosts(user.id);
  }
  
  Future<void> loadUserPosts(String userId) async {
    try {
      final posts = await postRepository.getUserPosts(userId);
      state = AsyncValue.data(posts);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
```

### 2. Cross-Provider Dependencies

```dart
// lib/providers/dependent_providers.dart

// Provider that depends on user state
final userPostsProvider = FutureProvider.family<List<Post>, String>((ref, userId) async {
  // Watch user changes
  final user = ref.watch(userProvider);
  
  return user.when(
    data: (userData) => postRepository.getUserPosts(userData.id),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Provider that combines multiple states
final dashboardProvider = Provider<DashboardData>((ref) {
  final user = ref.watch(userProvider);
  final posts = ref.watch(postsProvider);
  final notifications = ref.watch(notificationsProvider);
  
  return DashboardData(
    user: user.valueOrNull,
    posts: posts.valueOrNull ?? [],
    notifications: notifications.valueOrNull ?? [],
  );
});

class DashboardData {
  final User? user;
  final List<Post> posts;
  final List<Notification> notifications;
  
  const DashboardData({
    this.user,
    required this.posts,
    required this.notifications,
  });
}
```

### 3. State Synchronization Service

```dart
// lib/services/state_sync_service.dart
class StateSyncService {
  final Ref ref;
  final List<StreamSubscription> _subscriptions = [];
  
  StateSyncService(this.ref);
  
  void initialize() {
    // Listen to user changes and sync dependent states
    _subscriptions.add(
      ref.listen(userProvider, (previous, next) {
        next.whenData((user) {
          _syncUserDependentStates(user);
        });
      }),
    );
    
    // Listen to connectivity changes
    _subscriptions.add(
      ref.listen(connectivityProvider, (previous, next) {
        if (next == ConnectivityResult.wifi || next == ConnectivityResult.mobile) {
          _syncAllStatesWithServer();
        }
      }),
    );
  }
  
  void _syncUserDependentStates(User user) {
    // Trigger sync for all user-dependent providers
    ref.read(postsProvider.notifier).loadUserPosts(user.id);
    ref.read(settingsProvider.notifier).loadUserSettings(user.id);
    ref.read(friendsProvider.notifier).loadUserFriends(user.id);
  }
  
  Future<void> _syncAllStatesWithServer() async {
    await Future.wait([
      ref.read(userProvider.notifier).syncWithServer(),
      ref.read(postsProvider.notifier).syncWithServer(),
      ref.read(settingsProvider.notifier).syncWithServer(),
    ]);
  }
  
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }
}
```

## Server State Synchronization

### 1. Real-time Sync with Supabase

```dart
// lib/services/realtime_sync_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeSyncService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Ref ref;
  RealtimeChannel? _channel;
  
  RealtimeSyncService(this.ref);
  
  void initialize() {
    _setupRealtimeSubscriptions();
  }
  
  void _setupRealtimeSubscriptions() {
    _channel = _supabase.channel('public:posts');
    
    // Listen to post insertions
    _channel!.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
        event: 'INSERT',
        schema: 'public',
        table: 'posts',
      ),
      (payload) {
        final newPost = Post.fromJson(payload['new']);
        ref.read(postsProvider.notifier).addPost(newPost);
      },
    );
    
    // Listen to post updates
    _channel!.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
        event: 'UPDATE',
        schema: 'public',
        table: 'posts',
      ),
      (payload) {
        final updatedPost = Post.fromJson(payload['new']);
        ref.read(postsProvider.notifier).updatePost(updatedPost);
      },
    );
    
    // Listen to post deletions
    _channel!.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
        event: 'DELETE',
        schema: 'public',
        table: 'posts',
      ),
      (payload) {
        final deletedPostId = payload['old']['id'];
        ref.read(postsProvider.notifier).removePost(deletedPostId);
      },
    );
    
    _channel!.subscribe();
  }
  
  void dispose() {
    _channel?.unsubscribe();
  }
}
```

### 2. Optimistic Updates

```dart
// lib/providers/optimistic_posts_provider.dart
class OptimisticPostsNotifier extends StateNotifier<AsyncValue<List<Post>>> {
  final PostRepository repository;
  final Ref ref;
  
  OptimisticPostsNotifier(this.repository, this.ref) : super(const AsyncValue.loading());
  
  Future<void> createPost(CreatePostRequest request) async {
    final currentPosts = state.valueOrNull ?? [];
    
    // Create optimistic post
    final optimisticPost = Post(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      content: request.content,
      userId: request.userId,
      createdAt: DateTime.now(),
      isOptimistic: true,
    );
    
    // Update state optimistically
    state = AsyncValue.data([optimisticPost, ...currentPosts]);
    
    try {
      // Send to server
      final serverPost = await repository.createPost(request);
      
      // Replace optimistic post with server response
      final updatedPosts = currentPosts.map((post) {
        return post.id == optimisticPost.id ? serverPost : post;
      }).toList();
      
      state = AsyncValue.data(updatedPosts);
    } catch (error) {
      // Revert optimistic update on error
      state = AsyncValue.data(currentPosts);
      
      // Show error to user
      ref.read(errorProvider.notifier).showError('Failed to create post');
      rethrow;
    }
  }
  
  Future<void> deletePost(String postId) async {
    final currentPosts = state.valueOrNull ?? [];
    final postToDelete = currentPosts.firstWhere((post) => post.id == postId);
    
    // Remove optimistically
    final optimisticPosts = currentPosts.where((post) => post.id != postId).toList();
    state = AsyncValue.data(optimisticPosts);
    
    try {
      await repository.deletePost(postId);
    } catch (error) {
      // Revert on error
      state = AsyncValue.data([...optimisticPosts, postToDelete]);
      ref.read(errorProvider.notifier).showError('Failed to delete post');
      rethrow;
    }
  }
}
```

### 3. Conflict Resolution

```dart
// lib/services/conflict_resolution_service.dart
class ConflictResolutionService {
  static T resolveConflict<T>({
    required T localVersion,
    required T serverVersion,
    required DateTime localTimestamp,
    required DateTime serverTimestamp,
    ConflictResolutionStrategy strategy = ConflictResolutionStrategy.serverWins,
  }) {
    switch (strategy) {
      case ConflictResolutionStrategy.serverWins:
        return serverVersion;
      
      case ConflictResolutionStrategy.clientWins:
        return localVersion;
      
      case ConflictResolutionStrategy.lastWriteWins:
        return localTimestamp.isAfter(serverTimestamp) ? localVersion : serverVersion;
      
      case ConflictResolutionStrategy.merge:
        return _mergeVersions(localVersion, serverVersion);
    }
  }
  
  static T _mergeVersions<T>(T local, T server) {
    // Implement merge logic based on type
    if (T == Post) {
      return _mergePosts(local as Post, server as Post) as T;
    }
    
    // Default to server version
    return server;
  }
  
  static Post _mergePosts(Post local, Post server) {
    return Post(
      id: server.id,
      content: local.content.isNotEmpty ? local.content : server.content,
      userId: server.userId,
      createdAt: server.createdAt,
      updatedAt: DateTime.now(),
      likes: server.likes, // Server has authoritative like count
    );
  }
}

enum ConflictResolutionStrategy {
  serverWins,
  clientWins,
  lastWriteWins,
  merge,
}
```

## Background Synchronization

### 1. Background Sync Service

```dart
// lib/services/background_sync_service.dart
class BackgroundSyncService {
  final Ref ref;
  Timer? _syncTimer;
  
  BackgroundSyncService(this.ref);
  
  void startPeriodicSync({Duration interval = const Duration(minutes: 5)}) {
    _syncTimer = Timer.periodic(interval, (_) {
      _performBackgroundSync();
    });
  }
  
  Future<void> _performBackgroundSync() async {
    try {
      // Only sync if app is in background and connected
      final appState = ref.read(appLifecycleProvider);
      final connectivity = ref.read(connectivityProvider);
      
      if (appState != AppLifecycleState.paused) return;
      if (connectivity == ConnectivityResult.none) return;
      
      // Sync critical data
      await Future.wait([
        _syncUserData(),
        _syncNotifications(),
        _syncCriticalPosts(),
      ]);
      
    } catch (error) {
      // Log error but don't throw
      debugPrint('Background sync failed: $error');
    }
  }
  
  Future<void> _syncUserData() async {
    await ref.read(userProvider.notifier).syncWithServer();
  }
  
  Future<void> _syncNotifications() async {
    await ref.read(notificationsProvider.notifier).syncWithServer();
  }
  
  Future<void> _syncCriticalPosts() async {
    // Only sync recent posts to save bandwidth
    await ref.read(postsProvider.notifier).syncRecentPosts();
  }
  
  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }
}
```

### 2. Sync Queue Management

```dart
// lib/services/sync_queue_service.dart
class SyncQueueService {
  final Queue<SyncOperation> _queue = Queue();
  bool _isProcessing = false;
  
  void addOperation(SyncOperation operation) {
    _queue.add(operation);
    _processQueue();
  }
  
  Future<void> _processQueue() async {
    if (_isProcessing || _queue.isEmpty) return;
    
    _isProcessing = true;
    
    while (_queue.isNotEmpty) {
      final operation = _queue.removeFirst();
      
      try {
        await operation.execute();
      } catch (error) {
        // Handle retry logic
        if (operation.retryCount < operation.maxRetries) {
          operation.retryCount++;
          _queue.add(operation);
        } else {
          // Log failed operation
          debugPrint('Sync operation failed permanently: ${operation.id}');
        }
      }
    }
    
    _isProcessing = false;
  }
}

abstract class SyncOperation {
  final String id;
  final int maxRetries;
  int retryCount;
  
  SyncOperation({
    required this.id,
    this.maxRetries = 3,
    this.retryCount = 0,
  });
  
  Future<void> execute();
}

class PostSyncOperation extends SyncOperation {
  final Post post;
  final PostRepository repository;
  
  PostSyncOperation({
    required this.post,
    required this.repository,
  }) : super(id: 'post_${post.id}');
  
  @override
  Future<void> execute() async {
    await repository.syncPost(post);
  }
}
```

## State Persistence

### 1. Persistent State Provider

```dart
// lib/providers/persistent_state_provider.dart
class PersistentStateNotifier<T> extends StateNotifier<T> {
  final String key;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;
  
  PersistentStateNotifier({
    required T initialState,
    required this.key,
    required this.fromJson,
    required this.toJson,
  }) : super(initialState) {
    _loadState();
  }
  
  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(key);
      
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        state = fromJson(json);
      }
    } catch (error) {
      debugPrint('Failed to load state for $key: $error');
    }
  }
  
  @override
  set state(T value) {
    super.state = value;
    _saveState(value);
  }
  
  Future<void> _saveState(T value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(toJson(value));
      await prefs.setString(key, jsonString);
    } catch (error) {
      debugPrint('Failed to save state for $key: $error');
    }
  }
}

// Usage
final userSettingsProvider = StateNotifierProvider<PersistentStateNotifier<UserSettings>, UserSettings>((ref) {
  return PersistentStateNotifier<UserSettings>(
    initialState: UserSettings.defaultSettings(),
    key: 'user_settings',
    fromJson: UserSettings.fromJson,
    toJson: (settings) => settings.toJson(),
  );
});
```

### 2. Sync Status Tracking

```dart
// lib/providers/sync_status_provider.dart
class SyncStatusNotifier extends StateNotifier<SyncStatus> {
  SyncStatusNotifier() : super(SyncStatus.idle);
  
  Future<void> performSync(Future<void> Function() syncOperation) async {
    state = SyncStatus.syncing;
    
    try {
      await syncOperation();
      state = SyncStatus.success;
      
      // Reset to idle after showing success
      Timer(const Duration(seconds: 2), () {
        if (mounted) state = SyncStatus.idle;
      });
    } catch (error) {
      state = SyncStatus.error;
      
      // Reset to idle after showing error
      Timer(const Duration(seconds: 5), () {
        if (mounted) state = SyncStatus.idle;
      });
    }
  }
}

enum SyncStatus {
  idle,
  syncing,
  success,
  error,
}

final syncStatusProvider = StateNotifierProvider<SyncStatusNotifier, SyncStatus>((ref) {
  return SyncStatusNotifier();
});

// UI Widget to show sync status
class SyncStatusIndicator extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(syncStatusProvider);
    
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _buildStatusWidget(syncStatus),
    );
  }
  
  Widget _buildStatusWidget(SyncStatus status) {
    switch (status) {
      case SyncStatus.syncing:
        return const CircularProgressIndicator();
      case SyncStatus.success:
        return const Icon(Icons.check_circle, color: Colors.green);
      case SyncStatus.error:
        return const Icon(Icons.error, color: Colors.red);
      case SyncStatus.idle:
        return const SizedBox.shrink();
    }
  }
}
```

## Testing State Synchronization

### 1. Sync Testing

```dart
// test/sync/state_sync_test.dart
void main() {
  group('State Synchronization Tests', () {
    testWidgets('should sync user state across providers', (tester) async {
      final container = ProviderContainer();
      
      // Update user
      final user = User(id: '1', name: 'John', email: 'john@example.com');
      container.read(userProvider.notifier).updateUser(user);
      
      // Verify dependent providers are updated
      await tester.pump();
      
      final posts = container.read(userPostsProvider('1'));
      expect(posts, isA<AsyncValue<List<Post>>>());
    });
    
    test('should handle optimistic updates correctly', () async {
      final notifier = OptimisticPostsNotifier(MockPostRepository(), MockRef());
      
      // Perform optimistic update
      await notifier.createPost(CreatePostRequest(content: 'Test post'));
      
      // Verify optimistic state
      final posts = notifier.state.valueOrNull;
      expect(posts?.first.content, 'Test post');
      expect(posts?.first.isOptimistic, true);
    });
  });
}
```

State synchronization is critical for maintaining data consistency. Design your sync strategy early and test thoroughly to ensure reliable user experiences.
