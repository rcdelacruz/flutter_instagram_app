# Real-time Data

Comprehensive guide to implementing real-time data synchronization in Flutter applications using WebSockets, Server-Sent Events, and Supabase Realtime.

## Overview

Real-time data enables instant updates across your Flutter app, providing users with live information and collaborative features. This guide covers various real-time technologies and implementation patterns.

## Supabase Realtime

### 1. Realtime Setup

```dart
// lib/services/realtime_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Map<String, RealtimeChannel> _channels = {};
  final Map<String, StreamController> _controllers = {};
  
  // Posts realtime stream
  Stream<List<Post>> get postsStream {
    if (!_controllers.containsKey('posts')) {
      _controllers['posts'] = StreamController<List<Post>>.broadcast();
      _setupPostsChannel();
    }
    return _controllers['posts']!.stream as Stream<List<Post>>;
  }
  
  // Comments realtime stream
  Stream<List<Comment>> commentsStream(String postId) {
    final key = 'comments_$postId';
    if (!_controllers.containsKey(key)) {
      _controllers[key] = StreamController<List<Comment>>.broadcast();
      _setupCommentsChannel(postId);
    }
    return _controllers[key]!.stream as Stream<List<Comment>>;
  }
  
  void _setupPostsChannel() {
    final channel = _supabase.channel('public:posts');
    
    // Listen to INSERT events
    channel.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
        event: 'INSERT',
        schema: 'public',
        table: 'posts',
      ),
      (payload) {
        final newPost = Post.fromJson(payload['new']);
        _handlePostInsert(newPost);
      },
    );
    
    // Listen to UPDATE events
    channel.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
        event: 'UPDATE',
        schema: 'public',
        table: 'posts',
      ),
      (payload) {
        final updatedPost = Post.fromJson(payload['new']);
        _handlePostUpdate(updatedPost);
      },
    );
    
    // Listen to DELETE events
    channel.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
        event: 'DELETE',
        schema: 'public',
        table: 'posts',
      ),
      (payload) {
        final deletedPostId = payload['old']['id'];
        _handlePostDelete(deletedPostId);
      },
    );
    
    channel.subscribe();
    _channels['posts'] = channel;
  }
  
  void _setupCommentsChannel(String postId) {
    final channel = _supabase.channel('comments_$postId');
    
    channel.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
        event: '*',
        schema: 'public',
        table: 'comments',
        filter: 'post_id=eq.$postId',
      ),
      (payload) {
        _handleCommentChange(postId, payload);
      },
    );
    
    channel.subscribe();
    _channels['comments_$postId'] = channel;
  }
  
  void _handlePostInsert(Post post) {
    // Update local state and notify listeners
    final controller = _controllers['posts'] as StreamController<List<Post>>;
    // Implementation depends on your state management
  }
  
  void _handlePostUpdate(Post post) {
    // Update existing post in local state
  }
  
  void _handlePostDelete(String postId) {
    // Remove post from local state
  }
  
  void _handleCommentChange(String postId, Map<String, dynamic> payload) {
    final event = payload['eventType'];
    final controller = _controllers['comments_$postId'] as StreamController<List<Comment>>;
    
    switch (event) {
      case 'INSERT':
        final newComment = Comment.fromJson(payload['new']);
        // Add to local state
        break;
      case 'UPDATE':
        final updatedComment = Comment.fromJson(payload['new']);
        // Update in local state
        break;
      case 'DELETE':
        final deletedCommentId = payload['old']['id'];
        // Remove from local state
        break;
    }
  }
  
  void dispose() {
    for (final channel in _channels.values) {
      channel.unsubscribe();
    }
    _channels.clear();
    
    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }
}
```

### 2. Realtime Provider Integration

```dart
// lib/providers/realtime_posts_provider.dart
class RealtimePostsNotifier extends StateNotifier<AsyncValue<List<Post>>> {
  final PostRepository _repository;
  final RealtimeService _realtimeService;
  StreamSubscription? _subscription;
  
  RealtimePostsNotifier(this._repository, this._realtimeService) 
      : super(const AsyncValue.loading()) {
    _initialize();
  }
  
  void _initialize() async {
    // Load initial data
    try {
      final posts = await _repository.getAllPosts();
      state = AsyncValue.data(posts);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
    
    // Subscribe to realtime updates
    _subscription = _realtimeService.postsStream.listen(
      (posts) {
        state = AsyncValue.data(posts);
      },
      onError: (error) {
        // Handle realtime errors gracefully
        print('Realtime error: $error');
      },
    );
  }
  
  Future<void> createPost(CreatePostRequest request) async {
    try {
      // Optimistic update
      final currentPosts = state.valueOrNull ?? [];
      final optimisticPost = Post(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        content: request.content,
        userId: request.userId,
        createdAt: DateTime.now(),
        isOptimistic: true,
      );
      
      state = AsyncValue.data([optimisticPost, ...currentPosts]);
      
      // Create on server (realtime will handle the update)
      await _repository.createPost(request);
      
    } catch (error) {
      // Revert optimistic update
      final currentPosts = state.valueOrNull ?? [];
      final revertedPosts = currentPosts.where((post) => !post.isOptimistic).toList();
      state = AsyncValue.data(revertedPosts);
      rethrow;
    }
  }
  
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final realtimePostsProvider = StateNotifierProvider<RealtimePostsNotifier, AsyncValue<List<Post>>>((ref) {
  final repository = ref.read(postRepositoryProvider);
  final realtimeService = ref.read(realtimeServiceProvider);
  return RealtimePostsNotifier(repository, realtimeService);
});
```

## WebSocket Implementation

### 1. WebSocket Service

```dart
// lib/services/websocket_service.dart
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final String _url;
  final Map<String, StreamController> _controllers = {};
  bool _isConnected = false;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  
  WebSocketService(this._url);
  
  bool get isConnected => _isConnected;
  
  Future<void> connect() async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_url));
      _isConnected = true;
      _reconnectAttempts = 0;
      
      // Listen to messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
      );
      
      // Start heartbeat
      _startHeartbeat();
      
      print('WebSocket connected');
    } catch (error) {
      print('WebSocket connection failed: $error');
      _scheduleReconnect();
    }
  }
  
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      final type = data['type'];
      final payload = data['payload'];
      
      switch (type) {
        case 'post_created':
          _notifyListeners('posts', payload);
          break;
        case 'post_updated':
          _notifyListeners('posts', payload);
          break;
        case 'comment_created':
          _notifyListeners('comments_${payload['post_id']}', payload);
          break;
        case 'user_online':
          _notifyListeners('user_status', payload);
          break;
        case 'heartbeat':
          // Heartbeat response
          break;
      }
    } catch (error) {
      print('Error handling WebSocket message: $error');
    }
  }
  
  void _handleError(error) {
    print('WebSocket error: $error');
    _isConnected = false;
    _scheduleReconnect();
  }
  
  void _handleDisconnection() {
    print('WebSocket disconnected');
    _isConnected = false;
    _heartbeatTimer?.cancel();
    _scheduleReconnect();
  }
  
  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      print('Max reconnection attempts reached');
      return;
    }
    
    _reconnectAttempts++;
    final delay = Duration(seconds: math.pow(2, _reconnectAttempts).toInt());
    
    _reconnectTimer = Timer(delay, () {
      print('Attempting to reconnect... (${_reconnectAttempts}/$_maxReconnectAttempts)');
      connect();
    });
  }
  
  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_isConnected) {
        send('heartbeat', {});
      }
    });
  }
  
  void send(String type, Map<String, dynamic> payload) {
    if (_isConnected && _channel != null) {
      final message = jsonEncode({
        'type': type,
        'payload': payload,
      });
      _channel!.sink.add(message);
    }
  }
  
  Stream<T> subscribe<T>(String channel, T Function(Map<String, dynamic>) fromJson) {
    if (!_controllers.containsKey(channel)) {
      _controllers[channel] = StreamController<T>.broadcast();
    }
    return _controllers[channel]!.stream as Stream<T>;
  }
  
  void _notifyListeners(String channel, Map<String, dynamic> data) {
    if (_controllers.containsKey(channel)) {
      _controllers[channel]!.add(data);
    }
  }
  
  void disconnect() {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _isConnected = false;
    
    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }
}
```

### 2. WebSocket Provider

```dart
// lib/providers/websocket_provider.dart
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService('wss://your-websocket-url.com');
  
  // Auto-connect when provider is created
  service.connect();
  
  // Dispose when provider is disposed
  ref.onDispose(() {
    service.disconnect();
  });
  
  return service;
});

final webSocketConnectionProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(webSocketServiceProvider);
  return Stream.periodic(const Duration(seconds: 1), (_) => service.isConnected);
});
```

## Server-Sent Events (SSE)

### 1. SSE Service

```dart
// lib/services/sse_service.dart
import 'package:http/http.dart' as http;

class SSEService {
  final String _url;
  final Map<String, StreamController> _controllers = {};
  http.Client? _client;
  bool _isConnected = false;
  
  SSEService(this._url);
  
  bool get isConnected => _isConnected;
  
  Stream<T> subscribe<T>(String endpoint, T Function(Map<String, dynamic>) fromJson) {
    final key = endpoint;
    if (!_controllers.containsKey(key)) {
      _controllers[key] = StreamController<T>.broadcast();
      _startListening(endpoint, fromJson);
    }
    return _controllers[key]!.stream as Stream<T>;
  }
  
  void _startListening<T>(String endpoint, T Function(Map<String, dynamic>) fromJson) async {
    try {
      _client = http.Client();
      final request = http.Request('GET', Uri.parse('$_url/$endpoint'));
      request.headers['Accept'] = 'text/event-stream';
      request.headers['Cache-Control'] = 'no-cache';
      
      final response = await _client!.send(request);
      _isConnected = true;
      
      response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) => _handleSSELine(endpoint, line, fromJson),
            onError: (error) => _handleError(endpoint, error),
            onDone: () => _handleDisconnection(endpoint),
          );
    } catch (error) {
      _handleError(endpoint, error);
    }
  }
  
  void _handleSSELine<T>(String endpoint, String line, T Function(Map<String, dynamic>) fromJson) {
    if (line.startsWith('data: ')) {
      try {
        final jsonData = line.substring(6);
        final data = jsonDecode(jsonData);
        final parsedData = fromJson(data);
        
        if (_controllers.containsKey(endpoint)) {
          _controllers[endpoint]!.add(parsedData);
        }
      } catch (error) {
        print('Error parsing SSE data: $error');
      }
    }
  }
  
  void _handleError(String endpoint, dynamic error) {
    print('SSE error for $endpoint: $error');
    _isConnected = false;
    // Implement reconnection logic if needed
  }
  
  void _handleDisconnection(String endpoint) {
    print('SSE disconnected for $endpoint');
    _isConnected = false;
  }
  
  void dispose() {
    _client?.close();
    _isConnected = false;
    
    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }
}
```

## Real-time UI Components

### 1. Live Feed Widget

```dart
// lib/widgets/live_feed_widget.dart
class LiveFeedWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(realtimePostsProvider);
    
    return postsAsync.when(
      data: (posts) => _buildFeed(posts),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorWidget(error),
    );
  }
  
  Widget _buildFeed(List<Post> posts) {
    return RefreshIndicator(
      onRefresh: () async {
        // Manual refresh if needed
      },
      child: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: PostWidget(
              post: post,
              isNew: post.isNew, // Highlight new posts
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('Failed to load feed: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Retry logic
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
```

### 2. Real-time Comments

```dart
// lib/widgets/realtime_comments_widget.dart
class RealtimeCommentsWidget extends ConsumerWidget {
  final String postId;
  
  const RealtimeCommentsWidget({Key? key, required this.postId}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsAsync = ref.watch(realtimeCommentsProvider(postId));
    
    return commentsAsync.when(
      data: (comments) => _buildComments(comments, ref),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
  
  Widget _buildComments(List<Comment> comments, WidgetRef ref) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              return AnimatedSlide(
                offset: comment.isNew ? const Offset(1, 0) : Offset.zero,
                duration: const Duration(milliseconds: 300),
                child: CommentWidget(comment: comment),
              );
            },
          ),
        ),
        CommentInputWidget(
          onSubmit: (content) {
            ref.read(realtimeCommentsProvider(postId).notifier)
                .addComment(content);
          },
        ),
      ],
    );
  }
}

final realtimeCommentsProvider = StateNotifierProvider.family<
    RealtimeCommentsNotifier, 
    AsyncValue<List<Comment>>, 
    String
>((ref, postId) {
  final realtimeService = ref.read(realtimeServiceProvider);
  return RealtimeCommentsNotifier(postId, realtimeService);
});
```

### 3. Connection Status Indicator

```dart
// lib/widgets/connection_status_widget.dart
class ConnectionStatusWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(webSocketConnectionProvider).valueOrNull ?? false;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isConnected ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isConnected ? Icons.wifi : Icons.wifi_off,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            isConnected ? 'Live' : 'Offline',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
```

## Performance Optimization

### 1. Message Throttling

```dart
// lib/utils/message_throttler.dart
class MessageThrottler {
  final Duration _throttleDuration;
  final Map<String, Timer> _timers = {};
  final Map<String, dynamic> _pendingMessages = {};
  
  MessageThrottler({Duration throttleDuration = const Duration(milliseconds: 100)})
      : _throttleDuration = throttleDuration;
  
  void throttle(String key, dynamic message, void Function(dynamic) callback) {
    _pendingMessages[key] = message;
    
    if (_timers.containsKey(key)) {
      _timers[key]!.cancel();
    }
    
    _timers[key] = Timer(_throttleDuration, () {
      final pendingMessage = _pendingMessages[key];
      if (pendingMessage != null) {
        callback(pendingMessage);
        _pendingMessages.remove(key);
      }
      _timers.remove(key);
    });
  }
  
  void dispose() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _pendingMessages.clear();
  }
}
```

### 2. Efficient State Updates

```dart
// lib/providers/optimized_realtime_provider.dart
class OptimizedRealtimeNotifier extends StateNotifier<AsyncValue<List<Post>>> {
  final MessageThrottler _throttler = MessageThrottler();
  
  OptimizedRealtimeNotifier() : super(const AsyncValue.loading());
  
  void handleRealtimeUpdate(Post updatedPost) {
    _throttler.throttle('posts_update', updatedPost, (post) {
      final currentPosts = state.valueOrNull ?? [];
      final updatedPosts = currentPosts.map((p) {
        return p.id == post.id ? post : p;
      }).toList();
      
      state = AsyncValue.data(updatedPosts);
    });
  }
  
  @override
  void dispose() {
    _throttler.dispose();
    super.dispose();
  }
}
```

## Testing Real-time Features

### 1. Real-time Testing

```dart
// test/realtime/realtime_service_test.dart
void main() {
  group('Realtime Service Tests', () {
    late RealtimeService service;
    late MockSupabaseClient mockSupabase;
    
    setUp(() {
      mockSupabase = MockSupabaseClient();
      service = RealtimeService();
    });
    
    test('should handle post insertion', () async {
      // Arrange
      final testPost = Post(id: '1', content: 'Test', userId: 'user1');
      
      // Act
      service._handlePostInsert(testPost);
      
      // Assert
      // Verify that the post was added to the stream
    });
    
    test('should reconnect on connection loss', () async {
      // Test reconnection logic
    });
  });
}
```

Real-time features enhance user engagement but require careful implementation to handle connection issues and optimize performance. Always provide fallbacks for offline scenarios.
