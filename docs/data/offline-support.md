# Offline Support

Comprehensive guide to implementing robust offline functionality in Flutter applications.

## Overview

Offline support ensures your Flutter app remains functional when network connectivity is limited or unavailable. This guide covers caching strategies, data synchronization, and offline-first architecture.

## Offline Architecture

### 1. Offline-First Design

```dart
// lib/architecture/offline_repository.dart
abstract class OfflineRepository<T> {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<void> save(T item);
  Future<void> delete(String id);
  Future<void> syncWithServer();
}

class PostRepository implements OfflineRepository<Post> {
  final LocalDatabase _localDb;
  final ApiClient _apiClient;
  final ConnectivityService _connectivity;
  
  PostRepository(this._localDb, this._apiClient, this._connectivity);
  
  @override
  Future<List<Post>> getAll() async {
    // Always return local data first
    final localPosts = await _localDb.getAllPosts();
    
    // Try to sync with server if online
    if (await _connectivity.isConnected()) {
      try {
        await syncWithServer();
        return await _localDb.getAllPosts();
      } catch (e) {
        // Return local data if sync fails
        return localPosts;
      }
    }
    
    return localPosts;
  }
  
  @override
  Future<Post?> getById(String id) async {
    final localPost = await _localDb.getPostById(id);
    
    if (await _connectivity.isConnected()) {
      try {
        final serverPost = await _apiClient.getPost(id);
        await _localDb.savePost(serverPost);
        return serverPost;
      } catch (e) {
        return localPost;
      }
    }
    
    return localPost;
  }
  
  @override
  Future<void> save(Post post) async {
    // Save locally first
    await _localDb.savePost(post);
    
    // Queue for server sync
    await _queueForSync(post);
    
    // Try immediate sync if online
    if (await _connectivity.isConnected()) {
      try {
        await _syncPostToServer(post);
      } catch (e) {
        // Will be synced later
      }
    }
  }
  
  @override
  Future<void> syncWithServer() async {
    if (!await _connectivity.isConnected()) return;
    
    try {
      // Sync pending changes to server
      await _syncPendingChanges();
      
      // Fetch latest from server
      final serverPosts = await _apiClient.getAllPosts();
      await _localDb.savePosts(serverPosts);
    } catch (e) {
      throw SyncException('Failed to sync with server: $e');
    }
  }
}
```

### 2. Local Database Setup

```dart
// lib/database/local_database.dart
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  static Database? _database;
  
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    return await openDatabase(
      '$path/app_database.db',
      version: 1,
      onCreate: _onCreate,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE posts (
        id TEXT PRIMARY KEY,
        content TEXT NOT NULL,
        user_id TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        is_synced INTEGER DEFAULT 0,
        is_deleted INTEGER DEFAULT 0
      )
    ''');
    
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        data TEXT,
        created_at INTEGER NOT NULL
      )
    ''');
  }
  
  // Posts operations
  Future<List<Post>> getAllPosts() async {
    final db = await database;
    final maps = await db.query(
      'posts',
      where: 'is_deleted = ?',
      whereArgs: [0],
      orderBy: 'created_at DESC',
    );
    
    return maps.map((map) => Post.fromMap(map)).toList();
  }
  
  Future<Post?> getPostById(String id) async {
    final db = await database;
    final maps = await db.query(
      'posts',
      where: 'id = ? AND is_deleted = ?',
      whereArgs: [id, 0],
      limit: 1,
    );
    
    return maps.isNotEmpty ? Post.fromMap(maps.first) : null;
  }
  
  Future<void> savePost(Post post) async {
    final db = await database;
    await db.insert(
      'posts',
      post.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<void> deletePost(String id) async {
    final db = await database;
    await db.update(
      'posts',
      {'is_deleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Sync queue operations
  Future<void> addToSyncQueue(String tableName, String recordId, String operation, [Map<String, dynamic>? data]) async {
    final db = await database;
    await db.insert('sync_queue', {
      'table_name': tableName,
      'record_id': recordId,
      'operation': operation,
      'data': data != null ? jsonEncode(data) : null,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }
  
  Future<List<SyncQueueItem>> getPendingSyncItems() async {
    final db = await database;
    final maps = await db.query('sync_queue', orderBy: 'created_at ASC');
    return maps.map((map) => SyncQueueItem.fromMap(map)).toList();
  }
  
  Future<void> removeSyncQueueItem(int id) async {
    final db = await database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }
}
```

### 3. Connectivity Service

```dart
// lib/services/connectivity_service.dart
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();
  
  Stream<bool> get connectionStream => _connectionController.stream;
  bool _isConnected = false;
  
  bool get isConnected => _isConnected;
  
  void initialize() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      final wasConnected = _isConnected;
      _isConnected = result != ConnectivityResult.none;
      
      if (!wasConnected && _isConnected) {
        // Connection restored
        _connectionController.add(true);
        _onConnectionRestored();
      } else if (wasConnected && !_isConnected) {
        // Connection lost
        _connectionController.add(false);
        _onConnectionLost();
      }
    });
    
    // Check initial connectivity
    _checkInitialConnectivity();
  }
  
  Future<void> _checkInitialConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _isConnected = result != ConnectivityResult.none;
    _connectionController.add(_isConnected);
  }
  
  void _onConnectionRestored() {
    // Trigger sync when connection is restored
    GetIt.instance<SyncService>().syncAll();
  }
  
  void _onConnectionLost() {
    // Handle offline mode
    print('Connection lost - entering offline mode');
  }
  
  void dispose() {
    _connectionController.close();
  }
}
```

## Caching Strategies

### 1. Multi-Level Caching

```dart
// lib/services/cache_service.dart
class CacheService {
  final Map<String, dynamic> _memoryCache = {};
  final LocalDatabase _localStorage;
  final Duration _memoryTtl;
  final Duration _diskTtl;
  
  CacheService(this._localStorage, {
    this._memoryTtl = const Duration(minutes: 5),
    this._diskTtl = const Duration(hours: 24),
  });
  
  Future<T?> get<T>(String key, T Function(Map<String, dynamic>) fromJson) async {
    // Check memory cache first
    final memoryItem = _memoryCache[key];
    if (memoryItem != null && !_isExpired(memoryItem['timestamp'], _memoryTtl)) {
      return fromJson(memoryItem['data']);
    }
    
    // Check disk cache
    final diskItem = await _localStorage.getCacheItem(key);
    if (diskItem != null && !_isExpired(diskItem.timestamp, _diskTtl)) {
      // Update memory cache
      _memoryCache[key] = {
        'data': diskItem.data,
        'timestamp': DateTime.now(),
      };
      return fromJson(diskItem.data);
    }
    
    return null;
  }
  
  Future<void> set<T>(String key, T data, Map<String, dynamic> Function(T) toJson) async {
    final jsonData = toJson(data);
    final timestamp = DateTime.now();
    
    // Update memory cache
    _memoryCache[key] = {
      'data': jsonData,
      'timestamp': timestamp,
    };
    
    // Update disk cache
    await _localStorage.setCacheItem(CacheItem(
      key: key,
      data: jsonData,
      timestamp: timestamp,
    ));
  }
  
  Future<void> invalidate(String key) async {
    _memoryCache.remove(key);
    await _localStorage.removeCacheItem(key);
  }
  
  Future<void> clear() async {
    _memoryCache.clear();
    await _localStorage.clearCache();
  }
  
  bool _isExpired(DateTime timestamp, Duration ttl) {
    return DateTime.now().difference(timestamp) > ttl;
  }
}
```

### 2. Image Caching

```dart
// lib/services/image_cache_service.dart
class OfflineImageCache {
  static final Map<String, Uint8List> _memoryCache = {};
  static const String _cacheDir = 'image_cache';
  
  static Future<Uint8List?> getImage(String url) async {
    // Check memory cache
    if (_memoryCache.containsKey(url)) {
      return _memoryCache[url];
    }
    
    // Check disk cache
    final file = await _getCacheFile(url);
    if (await file.exists()) {
      final bytes = await file.readAsBytes();
      _memoryCache[url] = bytes;
      return bytes;
    }
    
    return null;
  }
  
  static Future<void> cacheImage(String url, Uint8List bytes) async {
    // Cache in memory
    _memoryCache[url] = bytes;
    
    // Cache on disk
    final file = await _getCacheFile(url);
    await file.writeAsBytes(bytes);
  }
  
  static Future<File> _getCacheFile(String url) async {
    final directory = await getApplicationDocumentsDirectory();
    final cacheDirectory = Directory('${directory.path}/$_cacheDir');
    
    if (!await cacheDirectory.exists()) {
      await cacheDirectory.create(recursive: true);
    }
    
    final fileName = url.hashCode.toString();
    return File('${cacheDirectory.path}/$fileName');
  }
  
  static Future<void> clearCache() async {
    _memoryCache.clear();
    
    final directory = await getApplicationDocumentsDirectory();
    final cacheDirectory = Directory('${directory.path}/$_cacheDir');
    
    if (await cacheDirectory.exists()) {
      await cacheDirectory.delete(recursive: true);
    }
  }
}

// Offline-aware image widget
class OfflineImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  
  const OfflineImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: OfflineImageCache.getImage(imageUrl),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            width: width,
            height: height,
            fit: fit,
          );
        }
        
        // Try to load from network if not cached
        return Image.network(
          imageUrl,
          width: width,
          height: height,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              // Cache the image when loaded
              _cacheNetworkImage();
              return child;
            }
            return const CircularProgressIndicator();
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width,
              height: height,
              color: Colors.grey[300],
              child: const Icon(Icons.image_not_supported),
            );
          },
        );
      },
    );
  }
  
  void _cacheNetworkImage() async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        await OfflineImageCache.cacheImage(imageUrl, response.bodyBytes);
      }
    } catch (e) {
      // Ignore caching errors
    }
  }
}
```

## Sync Management

### 1. Sync Service

```dart
// lib/services/sync_service.dart
class SyncService {
  final LocalDatabase _localDb;
  final ApiClient _apiClient;
  final ConnectivityService _connectivity;
  bool _isSyncing = false;
  
  SyncService(this._localDb, this._apiClient, this._connectivity);
  
  Future<void> syncAll() async {
    if (_isSyncing || !_connectivity.isConnected) return;
    
    _isSyncing = true;
    
    try {
      await _syncPendingChanges();
      await _syncFromServer();
    } catch (e) {
      print('Sync failed: $e');
    } finally {
      _isSyncing = false;
    }
  }
  
  Future<void> _syncPendingChanges() async {
    final pendingItems = await _localDb.getPendingSyncItems();
    
    for (final item in pendingItems) {
      try {
        await _processSyncItem(item);
        await _localDb.removeSyncQueueItem(item.id);
      } catch (e) {
        print('Failed to sync item ${item.id}: $e');
        // Keep item in queue for retry
      }
    }
  }
  
  Future<void> _processSyncItem(SyncQueueItem item) async {
    switch (item.operation) {
      case 'CREATE':
        await _syncCreate(item);
        break;
      case 'UPDATE':
        await _syncUpdate(item);
        break;
      case 'DELETE':
        await _syncDelete(item);
        break;
    }
  }
  
  Future<void> _syncCreate(SyncQueueItem item) async {
    if (item.tableName == 'posts') {
      final postData = jsonDecode(item.data!);
      final post = Post.fromMap(postData);
      await _apiClient.createPost(post);
    }
  }
  
  Future<void> _syncFromServer() async {
    // Fetch latest data from server
    final serverPosts = await _apiClient.getAllPosts();
    
    for (final serverPost in serverPosts) {
      final localPost = await _localDb.getPostById(serverPost.id);
      
      if (localPost == null) {
        // New post from server
        await _localDb.savePost(serverPost.copyWith(isSynced: true));
      } else if (serverPost.updatedAt.isAfter(localPost.updatedAt)) {
        // Server version is newer
        await _localDb.savePost(serverPost.copyWith(isSynced: true));
      }
    }
  }
}
```

### 2. Conflict Resolution

```dart
// lib/services/conflict_resolver.dart
class ConflictResolver {
  static Future<T> resolveConflict<T>({
    required T localVersion,
    required T serverVersion,
    required ConflictResolutionStrategy strategy,
  }) async {
    switch (strategy) {
      case ConflictResolutionStrategy.serverWins:
        return serverVersion;
      
      case ConflictResolutionStrategy.clientWins:
        return localVersion;
      
      case ConflictResolutionStrategy.manual:
        return await _showConflictDialog(localVersion, serverVersion);
      
      case ConflictResolutionStrategy.merge:
        return _mergeVersions(localVersion, serverVersion);
    }
  }
  
  static Future<T> _showConflictDialog<T>(T local, T server) async {
    // Show dialog to user for manual resolution
    // This is a simplified example
    return server; // Default to server version
  }
  
  static T _mergeVersions<T>(T local, T server) {
    // Implement merge logic based on type
    // This is a simplified example
    return server;
  }
}

enum ConflictResolutionStrategy {
  serverWins,
  clientWins,
  manual,
  merge,
}
```

## Offline UI Components

### 1. Offline Indicator

```dart
// lib/widgets/offline_indicator.dart
class OfflineIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: GetIt.instance<ConnectivityService>().connectionStream,
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? true;
        
        if (isConnected) {
          return const SizedBox.shrink();
        }
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          color: Colors.orange,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.cloud_off, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text(
                'You are offline',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

### 2. Sync Status Widget

```dart
// lib/widgets/sync_status_widget.dart
class SyncStatusWidget extends StatefulWidget {
  @override
  _SyncStatusWidgetState createState() => _SyncStatusWidgetState();
}

class _SyncStatusWidgetState extends State<SyncStatusWidget> {
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (_isSyncing)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(
              Icons.sync,
              size: 16,
              color: _lastSyncTime != null ? Colors.green : Colors.grey,
            ),
          const SizedBox(width: 8),
          Text(
            _getSyncStatusText(),
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
  
  String _getSyncStatusText() {
    if (_isSyncing) return 'Syncing...';
    if (_lastSyncTime == null) return 'Not synced';
    
    final difference = DateTime.now().difference(_lastSyncTime!);
    if (difference.inMinutes < 1) return 'Just synced';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    return '${difference.inHours}h ago';
  }
}
```

## Testing Offline Functionality

### 1. Offline Testing

```dart
// test/offline/offline_repository_test.dart
void main() {
  group('Offline Repository Tests', () {
    late PostRepository repository;
    late MockLocalDatabase mockLocalDb;
    late MockApiClient mockApiClient;
    late MockConnectivityService mockConnectivity;
    
    setUp(() {
      mockLocalDb = MockLocalDatabase();
      mockApiClient = MockApiClient();
      mockConnectivity = MockConnectivityService();
      repository = PostRepository(mockLocalDb, mockApiClient, mockConnectivity);
    });
    
    test('should return local data when offline', () async {
      // Arrange
      when(mockConnectivity.isConnected()).thenAnswer((_) async => false);
      when(mockLocalDb.getAllPosts()).thenAnswer((_) async => [testPost]);
      
      // Act
      final posts = await repository.getAll();
      
      // Assert
      expect(posts, [testPost]);
      verify(mockLocalDb.getAllPosts()).called(1);
      verifyNever(mockApiClient.getAllPosts());
    });
    
    test('should sync with server when online', () async {
      // Arrange
      when(mockConnectivity.isConnected()).thenAnswer((_) async => true);
      when(mockApiClient.getAllPosts()).thenAnswer((_) async => [serverPost]);
      when(mockLocalDb.getAllPosts()).thenAnswer((_) async => [serverPost]);
      
      // Act
      final posts = await repository.getAll();
      
      // Assert
      expect(posts, [serverPost]);
      verify(mockApiClient.getAllPosts()).called(1);
      verify(mockLocalDb.savePosts([serverPost])).called(1);
    });
  });
}
```

Offline support is essential for modern mobile apps. Design your data layer with offline-first principles and provide clear feedback to users about connectivity status.
