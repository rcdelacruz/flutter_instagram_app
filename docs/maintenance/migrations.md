# Data Migrations & Schema Updates

Comprehensive guide to managing data migrations, database schema updates, and data transformations in Flutter applications.

## Overview

Data migrations are essential when updating app versions that require changes to local databases, user preferences, or data structures. This guide covers migration strategies, implementation patterns, and best practices.

## Database Migrations

### 1. SQLite Migration Framework

```dart
// lib/database/migration_manager.dart
import 'package:sqflite/sqflite.dart';

class MigrationManager {
  static const int currentVersion = 5;
  static const String _migrationTableName = 'migrations';
  
  // Initialize database with migrations
  static Future<Database> initializeDatabase(String path) async {
    return await openDatabase(
      path,
      version: currentVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onDowngrade: _onDowngrade,
    );
  }
  
  // Create initial database schema
  static Future<void> _onCreate(Database db, int version) async {
    print('Creating database version $version');
    
    // Create migrations tracking table
    await _createMigrationsTable(db);
    
    // Run all migrations up to current version
    for (int i = 1; i <= version; i++) {
      await _runMigration(db, i);
    }
  }
  
  // Handle database upgrades
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion');
    
    // Ensure migrations table exists
    await _createMigrationsTable(db);
    
    // Run migrations for each version increment
    for (int i = oldVersion + 1; i <= newVersion; i++) {
      await _runMigration(db, i);
    }
  }
  
  // Handle database downgrades (rarely used)
  static Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {
    print('Downgrading database from version $oldVersion to $newVersion');
    
    // Implement downgrade logic if needed
    // Usually involves dropping tables and recreating
    await _dropAllTables(db);
    await _onCreate(db, newVersion);
  }
  
  // Create migrations tracking table
  static Future<void> _createMigrationsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_migrationTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        version INTEGER UNIQUE NOT NULL,
        name TEXT NOT NULL,
        executed_at TEXT NOT NULL
      )
    ''');
  }
  
  // Run specific migration
  static Future<void> _runMigration(Database db, int version) async {
    // Check if migration already executed
    final result = await db.query(
      _migrationTableName,
      where: 'version = ?',
      whereArgs: [version],
    );
    
    if (result.isNotEmpty) {
      print('Migration $version already executed, skipping');
      return;
    }
    
    final migration = _getMigration(version);
    if (migration != null) {
      try {
        print('Executing migration $version: ${migration.name}');
        await migration.up(db);
        
        // Record migration execution
        await db.insert(_migrationTableName, {
          'version': version,
          'name': migration.name,
          'executed_at': DateTime.now().toIso8601String(),
        });
        
        print('Migration $version completed successfully');
      } catch (e) {
        print('Migration $version failed: $e');
        rethrow;
      }
    }
  }
  
  // Get migration for specific version
  static Migration? _getMigration(int version) {
    switch (version) {
      case 1:
        return CreateInitialTables();
      case 2:
        return AddUserProfileFields();
      case 3:
        return CreatePostsTable();
      case 4:
        return AddIndexes();
      case 5:
        return AddNotificationsTable();
      default:
        return null;
    }
  }
  
  // Drop all tables (for downgrade)
  static Future<void> _dropAllTables(Database db) async {
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'"
    );
    
    for (final table in tables) {
      final tableName = table['name'] as String;
      await db.execute('DROP TABLE IF EXISTS $tableName');
    }
  }
  
  // Get migration history
  static Future<List<Map<String, dynamic>>> getMigrationHistory(Database db) async {
    try {
      return await db.query(
        _migrationTableName,
        orderBy: 'version ASC',
      );
    } catch (e) {
      return [];
    }
  }
}

// Base migration class
abstract class Migration {
  String get name;
  Future<void> up(Database db);
  Future<void> down(Database db) async {
    // Default implementation - override if needed
    throw UnimplementedError('Downgrade not implemented for $name');
  }
}
```

### 2. Specific Migration Implementations

```dart
// lib/database/migrations/001_create_initial_tables.dart
class CreateInitialTables extends Migration {
  @override
  String get name => 'Create initial tables';
  
  @override
  Future<void> up(Database db) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    
    // Create settings table
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT UNIQUE NOT NULL,
        value TEXT,
        type TEXT NOT NULL DEFAULT 'string'
      )
    ''');
  }
  
  @override
  Future<void> down(Database db) async {
    await db.execute('DROP TABLE IF EXISTS users');
    await db.execute('DROP TABLE IF EXISTS settings');
  }
}

// lib/database/migrations/002_add_user_profile_fields.dart
class AddUserProfileFields extends Migration {
  @override
  String get name => 'Add user profile fields';
  
  @override
  Future<void> up(Database db) async {
    await db.execute('ALTER TABLE users ADD COLUMN bio TEXT');
    await db.execute('ALTER TABLE users ADD COLUMN avatar_url TEXT');
    await db.execute('ALTER TABLE users ADD COLUMN is_verified INTEGER DEFAULT 0');
    await db.execute('ALTER TABLE users ADD COLUMN follower_count INTEGER DEFAULT 0');
    await db.execute('ALTER TABLE users ADD COLUMN following_count INTEGER DEFAULT 0');
  }
  
  @override
  Future<void> down(Database db) async {
    // SQLite doesn't support DROP COLUMN, so we need to recreate the table
    await db.execute('''
      CREATE TABLE users_backup AS 
      SELECT id, username, email, created_at, updated_at 
      FROM users
    ''');
    
    await db.execute('DROP TABLE users');
    
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    
    await db.execute('INSERT INTO users SELECT * FROM users_backup');
    await db.execute('DROP TABLE users_backup');
  }
}

// lib/database/migrations/003_create_posts_table.dart
class CreatePostsTable extends Migration {
  @override
  String get name => 'Create posts table';
  
  @override
  Future<void> up(Database db) async {
    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        caption TEXT,
        image_url TEXT NOT NULL,
        like_count INTEGER DEFAULT 0,
        comment_count INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
    
    // Create comments table
    await db.execute('''
      CREATE TABLE comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        post_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (post_id) REFERENCES posts (id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
    
    // Create likes table
    await db.execute('''
      CREATE TABLE likes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        post_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        UNIQUE(post_id, user_id),
        FOREIGN KEY (post_id) REFERENCES posts (id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }
  
  @override
  Future<void> down(Database db) async {
    await db.execute('DROP TABLE IF EXISTS likes');
    await db.execute('DROP TABLE IF EXISTS comments');
    await db.execute('DROP TABLE IF EXISTS posts');
  }
}

// lib/database/migrations/004_add_indexes.dart
class AddIndexes extends Migration {
  @override
  String get name => 'Add database indexes for performance';
  
  @override
  Future<void> up(Database db) async {
    // User indexes
    await db.execute('CREATE INDEX idx_users_username ON users(username)');
    await db.execute('CREATE INDEX idx_users_email ON users(email)');
    
    // Post indexes
    await db.execute('CREATE INDEX idx_posts_user_id ON posts(user_id)');
    await db.execute('CREATE INDEX idx_posts_created_at ON posts(created_at)');
    
    // Comment indexes
    await db.execute('CREATE INDEX idx_comments_post_id ON comments(post_id)');
    await db.execute('CREATE INDEX idx_comments_user_id ON comments(user_id)');
    
    // Like indexes
    await db.execute('CREATE INDEX idx_likes_post_id ON likes(post_id)');
    await db.execute('CREATE INDEX idx_likes_user_id ON likes(user_id)');
  }
  
  @override
  Future<void> down(Database db) async {
    await db.execute('DROP INDEX IF EXISTS idx_users_username');
    await db.execute('DROP INDEX IF EXISTS idx_users_email');
    await db.execute('DROP INDEX IF EXISTS idx_posts_user_id');
    await db.execute('DROP INDEX IF EXISTS idx_posts_created_at');
    await db.execute('DROP INDEX IF EXISTS idx_comments_post_id');
    await db.execute('DROP INDEX IF EXISTS idx_comments_user_id');
    await db.execute('DROP INDEX IF EXISTS idx_likes_post_id');
    await db.execute('DROP INDEX IF EXISTS idx_likes_user_id');
  }
}

// lib/database/migrations/005_add_notifications_table.dart
class AddNotificationsTable extends Migration {
  @override
  String get name => 'Add notifications table';
  
  @override
  Future<void> up(Database db) async {
    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        data TEXT,
        is_read INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
    
    await db.execute('CREATE INDEX idx_notifications_user_id ON notifications(user_id)');
    await db.execute('CREATE INDEX idx_notifications_is_read ON notifications(is_read)');
    await db.execute('CREATE INDEX idx_notifications_created_at ON notifications(created_at)');
  }
  
  @override
  Future<void> down(Database db) async {
    await db.execute('DROP TABLE IF EXISTS notifications');
  }
}
```

## Data Transformation Migrations

### 1. Data Migration Service

```dart
// lib/services/data_migration_service.dart
class DataMigrationService {
  static const String _dataMigrationKey = 'data_migration_version';
  static const int currentDataVersion = 3;
  
  // Run data migrations if needed
  static Future<void> runDataMigrationsIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDataVersion = prefs.getInt(_dataMigrationKey) ?? 0;
    
    if (lastDataVersion < currentDataVersion) {
      await _runDataMigrations(lastDataVersion, currentDataVersion);
      await prefs.setInt(_dataMigrationKey, currentDataVersion);
    }
  }
  
  // Run specific data migrations
  static Future<void> _runDataMigrations(int fromVersion, int toVersion) async {
    print('Running data migrations from version $fromVersion to $toVersion');
    
    for (int version = fromVersion + 1; version <= toVersion; version++) {
      await _runDataMigration(version);
    }
  }
  
  // Run specific data migration
  static Future<void> _runDataMigration(int version) async {
    switch (version) {
      case 1:
        await _migrateUserPreferences();
        break;
      case 2:
        await _migrateCachedImages();
        break;
      case 3:
        await _migrateNotificationSettings();
        break;
    }
  }
  
  // Migrate user preferences format
  static Future<void> _migrateUserPreferences() async {
    print('Migrating user preferences to new format');
    
    final prefs = await SharedPreferences.getInstance();
    
    // Migrate theme setting
    final oldTheme = prefs.getString('theme');
    if (oldTheme != null) {
      final newThemeMode = oldTheme == 'dark' ? 'dark' : 'light';
      await prefs.setString('theme_mode', newThemeMode);
      await prefs.remove('theme');
    }
    
    // Migrate notification settings
    final oldNotifications = prefs.getBool('notifications');
    if (oldNotifications != null) {
      await prefs.setBool('notifications_enabled', oldNotifications);
      await prefs.setBool('push_notifications_enabled', oldNotifications);
      await prefs.remove('notifications');
    }
    
    // Set default values for new settings
    if (!prefs.containsKey('auto_play_videos')) {
      await prefs.setBool('auto_play_videos', true);
    }
  }
  
  // Migrate cached images to new storage format
  static Future<void> _migrateCachedImages() async {
    print('Migrating cached images to new storage format');
    
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final oldCacheDir = Directory('${appDir.path}/cache');
      final newCacheDir = Directory('${appDir.path}/image_cache');
      
      if (await oldCacheDir.exists()) {
        // Create new cache directory
        await newCacheDir.create(recursive: true);
        
        // Move files to new location with new naming convention
        await for (final file in oldCacheDir.list()) {
          if (file is File) {
            final fileName = path.basename(file.path);
            final newPath = '${newCacheDir.path}/${_generateNewFileName(fileName)}';
            await file.copy(newPath);
          }
        }
        
        // Delete old cache directory
        await oldCacheDir.delete(recursive: true);
      }
    } catch (e) {
      print('Error migrating cached images: $e');
    }
  }
  
  // Migrate notification settings to new structure
  static Future<void> _migrateNotificationSettings() async {
    print('Migrating notification settings to new structure');
    
    final prefs = await SharedPreferences.getInstance();
    
    // Create new notification settings structure
    final notificationSettings = {
      'likes': prefs.getBool('notify_likes') ?? true,
      'comments': prefs.getBool('notify_comments') ?? true,
      'follows': prefs.getBool('notify_follows') ?? true,
      'mentions': prefs.getBool('notify_mentions') ?? true,
      'direct_messages': prefs.getBool('notify_messages') ?? true,
    };
    
    // Save new structure
    for (final entry in notificationSettings.entries) {
      await prefs.setBool('notification_${entry.key}', entry.value);
    }
    
    // Remove old keys
    await prefs.remove('notify_likes');
    await prefs.remove('notify_comments');
    await prefs.remove('notify_follows');
    await prefs.remove('notify_mentions');
    await prefs.remove('notify_messages');
  }
  
  static String _generateNewFileName(String oldFileName) {
    // Generate new file name with timestamp and hash
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final hash = oldFileName.hashCode.abs();
    final extension = path.extension(oldFileName);
    return '${timestamp}_$hash$extension';
  }
}
```

### 2. Backup and Recovery

```dart
// lib/services/backup_service.dart
class BackupService {
  // Create backup before migration
  static Future<String> createBackup() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${appDir.path}/backups');
    await backupDir.create(recursive: true);
    
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupPath = '${backupDir.path}/backup_$timestamp.json';
    
    final backupData = await _collectBackupData();
    final backupFile = File(backupPath);
    await backupFile.writeAsString(jsonEncode(backupData));
    
    print('Backup created at: $backupPath');
    return backupPath;
  }
  
  // Collect all data for backup
  static Future<Map<String, dynamic>> _collectBackupData() async {
    final prefs = await SharedPreferences.getInstance();
    final db = await DatabaseService.database;
    
    return {
      'version': VersionConfig.appVersion,
      'timestamp': DateTime.now().toIso8601String(),
      'preferences': prefs.getKeys().fold<Map<String, dynamic>>({}, (map, key) {
        final value = prefs.get(key);
        if (value != null) {
          map[key] = value;
        }
        return map;
      }),
      'database': await _exportDatabaseData(db),
    };
  }
  
  // Export database data
  static Future<Map<String, List<Map<String, dynamic>>>> _exportDatabaseData(Database db) async {
    final tables = ['users', 'posts', 'comments', 'likes', 'notifications'];
    final data = <String, List<Map<String, dynamic>>>{};
    
    for (final table in tables) {
      try {
        data[table] = await db.query(table);
      } catch (e) {
        print('Error exporting table $table: $e');
        data[table] = [];
      }
    }
    
    return data;
  }
  
  // Restore from backup
  static Future<void> restoreFromBackup(String backupPath) async {
    try {
      final backupFile = File(backupPath);
      if (!await backupFile.exists()) {
        throw Exception('Backup file not found: $backupPath');
      }
      
      final backupContent = await backupFile.readAsString();
      final backupData = jsonDecode(backupContent) as Map<String, dynamic>;
      
      await _restorePreferences(backupData['preferences']);
      await _restoreDatabaseData(backupData['database']);
      
      print('Backup restored successfully from: $backupPath');
    } catch (e) {
      print('Error restoring backup: $e');
      rethrow;
    }
  }
  
  // Restore preferences
  static Future<void> _restorePreferences(Map<String, dynamic> preferences) async {
    final prefs = await SharedPreferences.getInstance();
    
    for (final entry in preferences.entries) {
      final value = entry.value;
      if (value is String) {
        await prefs.setString(entry.key, value);
      } else if (value is bool) {
        await prefs.setBool(entry.key, value);
      } else if (value is int) {
        await prefs.setInt(entry.key, value);
      } else if (value is double) {
        await prefs.setDouble(entry.key, value);
      } else if (value is List<String>) {
        await prefs.setStringList(entry.key, value);
      }
    }
  }
  
  // Restore database data
  static Future<void> _restoreDatabaseData(Map<String, dynamic> databaseData) async {
    final db = await DatabaseService.database;
    
    // Clear existing data
    await db.transaction((txn) async {
      for (final table in databaseData.keys) {
        await txn.delete(table);
      }
    });
    
    // Restore data
    await db.transaction((txn) async {
      for (final entry in databaseData.entries) {
        final table = entry.key;
        final rows = entry.value as List<dynamic>;
        
        for (final row in rows) {
          await txn.insert(table, row as Map<String, dynamic>);
        }
      }
    });
  }
  
  // Clean old backups
  static Future<void> cleanOldBackups({int keepCount = 5}) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${appDir.path}/backups');
      
      if (!await backupDir.exists()) return;
      
      final backupFiles = await backupDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.json'))
          .cast<File>()
          .toList();
      
      // Sort by modification time (newest first)
      backupFiles.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      
      // Delete old backups
      if (backupFiles.length > keepCount) {
        for (int i = keepCount; i < backupFiles.length; i++) {
          await backupFiles[i].delete();
          print('Deleted old backup: ${backupFiles[i].path}');
        }
      }
    } catch (e) {
      print('Error cleaning old backups: $e');
    }
  }
}
```

## Migration Testing

### 1. Migration Test Framework

```dart
// test/migration_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MigrationTestHelper {
  static Future<Database> createTestDatabase() async {
    sqfliteFfiInit();
    return await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          // Create initial schema for testing
        },
      ),
    );
  }
  
  static Future<void> testMigration({
    required Migration migration,
    required Future<void> Function(Database) setupData,
    required Future<void> Function(Database) verifyResult,
  }) async {
    final db = await createTestDatabase();
    
    try {
      // Setup test data
      await setupData(db);
      
      // Run migration
      await migration.up(db);
      
      // Verify result
      await verifyResult(db);
    } finally {
      await db.close();
    }
  }
}

void main() {
  group('Database Migrations', () {
    test('Migration 002: Add user profile fields', () async {
      await MigrationTestHelper.testMigration(
        migration: AddUserProfileFields(),
        setupData: (db) async {
          // Create users table with initial schema
          await db.execute('''
            CREATE TABLE users (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT UNIQUE NOT NULL,
              email TEXT UNIQUE NOT NULL,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL
            )
          ''');
          
          // Insert test data
          await db.insert('users', {
            'username': 'testuser',
            'email': 'test@example.com',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
        },
        verifyResult: (db) async {
          // Verify new columns exist
          final result = await db.rawQuery('PRAGMA table_info(users)');
          final columnNames = result.map((row) => row['name']).toList();
          
          expect(columnNames, contains('bio'));
          expect(columnNames, contains('avatar_url'));
          expect(columnNames, contains('is_verified'));
          expect(columnNames, contains('follower_count'));
          expect(columnNames, contains('following_count'));
          
          // Verify existing data is preserved
          final users = await db.query('users');
          expect(users.length, equals(1));
          expect(users.first['username'], equals('testuser'));
        },
      );
    });
    
    test('Migration rollback', () async {
      final db = await MigrationTestHelper.createTestDatabase();
      
      try {
        // Setup initial state
        await CreateInitialTables().up(db);
        await AddUserProfileFields().up(db);
        
        // Verify migration applied
        var result = await db.rawQuery('PRAGMA table_info(users)');
        var columnNames = result.map((row) => row['name']).toList();
        expect(columnNames, contains('bio'));
        
        // Rollback migration
        await AddUserProfileFields().down(db);
        
        // Verify rollback
        result = await db.rawQuery('PRAGMA table_info(users)');
        columnNames = result.map((row) => row['name']).toList();
        expect(columnNames, isNot(contains('bio')));
      } finally {
        await db.close();
      }
    });
  });
}
```

### 2. Migration Validation

```dart
// lib/utils/migration_validator.dart
class MigrationValidator {
  // Validate database schema
  static Future<bool> validateSchema(Database db) async {
    try {
      // Check required tables exist
      final requiredTables = ['users', 'posts', 'comments', 'likes', 'notifications'];
      
      for (final table in requiredTables) {
        final result = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
          [table],
        );
        
        if (result.isEmpty) {
          print('Missing required table: $table');
          return false;
        }
      }
      
      // Check required indexes exist
      final requiredIndexes = [
        'idx_users_username',
        'idx_posts_user_id',
        'idx_comments_post_id',
      ];
      
      for (final index in requiredIndexes) {
        final result = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='index' AND name=?",
          [index],
        );
        
        if (result.isEmpty) {
          print('Missing required index: $index');
          return false;
        }
      }
      
      return true;
    } catch (e) {
      print('Schema validation error: $e');
      return false;
    }
  }
  
  // Validate data integrity
  static Future<bool> validateDataIntegrity(Database db) async {
    try {
      // Check foreign key constraints
      final orphanedPosts = await db.rawQuery('''
        SELECT COUNT(*) as count FROM posts 
        WHERE user_id NOT IN (SELECT id FROM users)
      ''');
      
      if ((orphanedPosts.first['count'] as int) > 0) {
        print('Found orphaned posts');
        return false;
      }
      
      // Check data consistency
      final postCounts = await db.rawQuery('''
        SELECT p.id, p.like_count, COUNT(l.id) as actual_likes
        FROM posts p
        LEFT JOIN likes l ON p.id = l.post_id
        GROUP BY p.id
        HAVING p.like_count != actual_likes
      ''');
      
      if (postCounts.isNotEmpty) {
        print('Found inconsistent like counts');
        return false;
      }
      
      return true;
    } catch (e) {
      print('Data integrity validation error: $e');
      return false;
    }
  }
}
```

Data migrations are critical for maintaining app functionality across versions. Implement comprehensive migration strategies, backup mechanisms, and validation processes to ensure data integrity during updates.
