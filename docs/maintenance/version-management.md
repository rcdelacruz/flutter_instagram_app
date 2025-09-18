# Version Management

Comprehensive guide to managing versions, releases, and updates in Flutter applications.

## Overview

Version management involves tracking app versions, managing releases, handling updates, and maintaining backward compatibility. This guide covers semantic versioning, release strategies, and update mechanisms.

## Semantic Versioning

### 1. Version Number Structure

```yaml
# pubspec.yaml
name: yourapp
description: A Flutter Instagram clone application
version: 1.2.3+45

# Format: MAJOR.MINOR.PATCH+BUILD_NUMBER
# 1 = Major version (breaking changes)
# 2 = Minor version (new features, backward compatible)
# 3 = Patch version (bug fixes, backward compatible)
# 45 = Build number (incremental for each build)
```

### 2. Version Configuration

```dart
// lib/config/version_config.dart
class VersionConfig {
  static const String appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0',
  );
  
  static const int buildNumber = int.fromEnvironment(
    'BUILD_NUMBER',
    defaultValue: 1,
  );
  
  static const String buildDate = String.fromEnvironment(
    'BUILD_DATE',
    defaultValue: '',
  );
  
  static const String gitCommit = String.fromEnvironment(
    'GIT_COMMIT',
    defaultValue: '',
  );
  
  static const String buildEnvironment = String.fromEnvironment(
    'BUILD_ENVIRONMENT',
    defaultValue: 'development',
  );
  
  // Computed properties
  static String get fullVersion => '$appVersion+$buildNumber';
  static bool get isProduction => buildEnvironment == 'production';
  static bool get isDevelopment => buildEnvironment == 'development';
  
  // Version comparison
  static int compareVersions(String version1, String version2) {
    final v1Parts = version1.split('.').map(int.parse).toList();
    final v2Parts = version2.split('.').map(int.parse).toList();
    
    for (int i = 0; i < 3; i++) {
      final v1Part = i < v1Parts.length ? v1Parts[i] : 0;
      final v2Part = i < v2Parts.length ? v2Parts[i] : 0;
      
      if (v1Part < v2Part) return -1;
      if (v1Part > v2Part) return 1;
    }
    
    return 0;
  }
  
  static bool isVersionGreater(String version1, String version2) {
    return compareVersions(version1, version2) > 0;
  }
  
  static bool isVersionCompatible(String currentVersion, String minVersion) {
    return compareVersions(currentVersion, minVersion) >= 0;
  }
}
```

## Release Management

### 1. Release Strategy

```dart
// lib/services/release_service.dart
class ReleaseService {
  static const String _releaseNotesKey = 'release_notes';
  static const String _lastVersionKey = 'last_version';
  
  // Check if this is a new version
  static Future<bool> isNewVersion() async {
    final prefs = await SharedPreferences.getInstance();
    final lastVersion = prefs.getString(_lastVersionKey);
    final currentVersion = VersionConfig.appVersion;
    
    if (lastVersion == null || lastVersion != currentVersion) {
      await prefs.setString(_lastVersionKey, currentVersion);
      return true;
    }
    
    return false;
  }
  
  // Get release notes for version
  static Future<ReleaseNotes?> getReleaseNotes(String version) async {
    try {
      // This could fetch from API or local storage
      final response = await http.get(
        Uri.parse('https://api.yourapp.com/releases/$version'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ReleaseNotes.fromJson(data);
      }
    } catch (e) {
      print('Failed to fetch release notes: $e');
    }
    
    return null;
  }
  
  // Show release notes if new version
  static Future<void> showReleaseNotesIfNeeded(BuildContext context) async {
    if (await isNewVersion()) {
      final releaseNotes = await getReleaseNotes(VersionConfig.appVersion);
      
      if (releaseNotes != null && context.mounted) {
        await showDialog(
          context: context,
          builder: (context) => ReleaseNotesDialog(releaseNotes: releaseNotes),
        );
      }
    }
  }
  
  // Track version usage
  static void trackVersionUsage() {
    FirebaseAnalytics.instance.logEvent(
      name: 'app_version_usage',
      parameters: {
        'app_version': VersionConfig.appVersion,
        'build_number': VersionConfig.buildNumber,
        'build_environment': VersionConfig.buildEnvironment,
        'platform': Platform.operatingSystem,
      },
    );
  }
}

class ReleaseNotes {
  final String version;
  final String title;
  final String description;
  final List<String> features;
  final List<String> bugFixes;
  final List<String> improvements;
  final DateTime releaseDate;
  final bool isRequired;
  
  ReleaseNotes({
    required this.version,
    required this.title,
    required this.description,
    required this.features,
    required this.bugFixes,
    required this.improvements,
    required this.releaseDate,
    required this.isRequired,
  });
  
  factory ReleaseNotes.fromJson(Map<String, dynamic> json) {
    return ReleaseNotes(
      version: json['version'],
      title: json['title'],
      description: json['description'],
      features: List<String>.from(json['features'] ?? []),
      bugFixes: List<String>.from(json['bug_fixes'] ?? []),
      improvements: List<String>.from(json['improvements'] ?? []),
      releaseDate: DateTime.parse(json['release_date']),
      isRequired: json['is_required'] ?? false,
    );
  }
}
```

### 2. Release Notes Dialog

```dart
// lib/widgets/release_notes_dialog.dart
class ReleaseNotesDialog extends StatelessWidget {
  final ReleaseNotes releaseNotes;
  
  const ReleaseNotesDialog({
    Key? key,
    required this.releaseNotes,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.new_releases, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'What\'s New in ${releaseNotes.version}',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                releaseNotes.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(releaseNotes.description),
              const SizedBox(height: 16),
              
              if (releaseNotes.features.isNotEmpty) ...[
                _buildSection('✨ New Features', releaseNotes.features),
                const SizedBox(height: 12),
              ],
              
              if (releaseNotes.improvements.isNotEmpty) ...[
                _buildSection('🚀 Improvements', releaseNotes.improvements),
                const SizedBox(height: 12),
              ],
              
              if (releaseNotes.bugFixes.isNotEmpty) ...[
                _buildSection('🐛 Bug Fixes', releaseNotes.bugFixes),
                const SizedBox(height: 12),
              ],
              
              Text(
                'Released on ${DateFormat('MMM dd, yyyy').format(releaseNotes.releaseDate)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Got it!'),
        ),
      ],
    );
  }
  
  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontSize: 12)),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }
}
```

## App Update Management

### 1. Update Checker Service

```dart
// lib/services/update_checker_service.dart
class UpdateCheckerService {
  static const String _lastUpdateCheckKey = 'last_update_check';
  static const Duration _checkInterval = Duration(hours: 24);
  
  // Check for app updates
  static Future<UpdateInfo?> checkForUpdates() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.yourapp.com/app/version-info'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updateInfo = UpdateInfo.fromJson(data);
        
        // Check if update is available
        if (VersionConfig.isVersionGreater(
          updateInfo.latestVersion,
          VersionConfig.appVersion,
        )) {
          return updateInfo;
        }
      }
    } catch (e) {
      print('Failed to check for updates: $e');
    }
    
    return null;
  }
  
  // Check if should check for updates
  static Future<bool> shouldCheckForUpdates() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getInt(_lastUpdateCheckKey);
    
    if (lastCheck == null) return true;
    
    final lastCheckTime = DateTime.fromMillisecondsSinceEpoch(lastCheck);
    final now = DateTime.now();
    
    return now.difference(lastCheckTime) > _checkInterval;
  }
  
  // Mark update check as done
  static Future<void> markUpdateCheckDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastUpdateCheckKey, DateTime.now().millisecondsSinceEpoch);
  }
  
  // Check and show update dialog if needed
  static Future<void> checkAndShowUpdateDialog(BuildContext context) async {
    if (!await shouldCheckForUpdates()) return;
    
    final updateInfo = await checkForUpdates();
    await markUpdateCheckDone();
    
    if (updateInfo != null && context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: !updateInfo.isRequired,
        builder: (context) => UpdateDialog(updateInfo: updateInfo),
      );
    }
  }
  
  // Force update check
  static Future<UpdateInfo?> forceUpdateCheck() async {
    return await checkForUpdates();
  }
}

class UpdateInfo {
  final String latestVersion;
  final String title;
  final String description;
  final List<String> features;
  final bool isRequired;
  final String downloadUrl;
  final DateTime releaseDate;
  final String minSupportedVersion;
  
  UpdateInfo({
    required this.latestVersion,
    required this.title,
    required this.description,
    required this.features,
    required this.isRequired,
    required this.downloadUrl,
    required this.releaseDate,
    required this.minSupportedVersion,
  });
  
  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      latestVersion: json['latest_version'],
      title: json['title'],
      description: json['description'],
      features: List<String>.from(json['features'] ?? []),
      isRequired: json['is_required'] ?? false,
      downloadUrl: json['download_url'],
      releaseDate: DateTime.parse(json['release_date']),
      minSupportedVersion: json['min_supported_version'],
    );
  }
  
  bool get isCurrentVersionSupported {
    return VersionConfig.isVersionCompatible(
      VersionConfig.appVersion,
      minSupportedVersion,
    );
  }
}
```

### 2. Update Dialog

```dart
// lib/widgets/update_dialog.dart
class UpdateDialog extends StatelessWidget {
  final UpdateInfo updateInfo;
  
  const UpdateDialog({
    Key? key,
    required this.updateInfo,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !updateInfo.isRequired,
      child: AlertDialog(
        title: Row(
          children: [
            Icon(
              updateInfo.isRequired ? Icons.warning : Icons.system_update,
              color: updateInfo.isRequired ? Colors.orange : Colors.blue,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                updateInfo.isRequired ? 'Update Required' : 'Update Available',
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              updateInfo.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(updateInfo.description),
            const SizedBox(height: 12),
            
            if (updateInfo.features.isNotEmpty) ...[
              const Text(
                'What\'s New:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              ...updateInfo.features.map((feature) => Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(feature)),
                  ],
                ),
              )).toList(),
              const SizedBox(height: 12),
            ],
            
            Text(
              'Version ${updateInfo.latestVersion}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          if (!updateInfo.isRequired)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Later'),
            ),
          ElevatedButton(
            onPressed: () => _handleUpdate(context),
            child: Text(updateInfo.isRequired ? 'Update Now' : 'Update'),
          ),
        ],
      ),
    );
  }
  
  void _handleUpdate(BuildContext context) {
    // Open app store or download page
    if (Platform.isIOS) {
      _openAppStore();
    } else if (Platform.isAndroid) {
      _openPlayStore();
    } else {
      _openDownloadPage();
    }
    
    Navigator.of(context).pop();
  }
  
  void _openAppStore() {
    // Open iOS App Store
    launch('https://apps.apple.com/app/id123456789');
  }
  
  void _openPlayStore() {
    // Open Google Play Store
    launch('https://play.google.com/store/apps/details?id=com.yourapp.flutter');
  }
  
  void _openDownloadPage() {
    // Open download page for other platforms
    launch(updateInfo.downloadUrl);
  }
}
```

## Version Tracking

### 1. Version Analytics

```dart
// lib/services/version_analytics.dart
class VersionAnalytics {
  // Track version adoption
  static void trackVersionAdoption() {
    FirebaseAnalytics.instance.logEvent(
      name: 'version_adoption',
      parameters: {
        'app_version': VersionConfig.appVersion,
        'build_number': VersionConfig.buildNumber,
        'platform': Platform.operatingSystem,
        'platform_version': Platform.operatingSystemVersion,
        'first_launch': _isFirstLaunch(),
      },
    );
  }
  
  // Track version migration
  static void trackVersionMigration(String fromVersion, String toVersion) {
    FirebaseAnalytics.instance.logEvent(
      name: 'version_migration',
      parameters: {
        'from_version': fromVersion,
        'to_version': toVersion,
        'migration_time': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
  
  // Track update prompts
  static void trackUpdatePrompt({
    required String availableVersion,
    required String currentVersion,
    required bool isRequired,
    required String action, // 'shown', 'accepted', 'dismissed'
  }) {
    FirebaseAnalytics.instance.logEvent(
      name: 'update_prompt',
      parameters: {
        'available_version': availableVersion,
        'current_version': currentVersion,
        'is_required': isRequired,
        'action': action,
      },
    );
  }
  
  // Track version compatibility issues
  static void trackCompatibilityIssue({
    required String feature,
    required String minRequiredVersion,
    required String currentVersion,
  }) {
    FirebaseAnalytics.instance.logEvent(
      name: 'version_compatibility_issue',
      parameters: {
        'feature': feature,
        'min_required_version': minRequiredVersion,
        'current_version': currentVersion,
      },
    );
  }
  
  static bool _isFirstLaunch() {
    // Check if this is the first launch of this version
    // Implementation depends on your app's state management
    return false; // Placeholder
  }
}
```

### 2. Version Migration

```dart
// lib/services/version_migration_service.dart
class VersionMigrationService {
  static const String _migrationVersionKey = 'migration_version';
  
  // Run migrations if needed
  static Future<void> runMigrationsIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final lastMigrationVersion = prefs.getString(_migrationVersionKey);
    final currentVersion = VersionConfig.appVersion;
    
    if (lastMigrationVersion == null || 
        VersionConfig.isVersionGreater(currentVersion, lastMigrationVersion)) {
      
      await _runMigrations(lastMigrationVersion, currentVersion);
      await prefs.setString(_migrationVersionKey, currentVersion);
      
      // Track migration
      if (lastMigrationVersion != null) {
        VersionAnalytics.trackVersionMigration(lastMigrationVersion, currentVersion);
      }
    }
  }
  
  // Run specific migrations
  static Future<void> _runMigrations(String? fromVersion, String toVersion) async {
    print('Running migrations from $fromVersion to $toVersion');
    
    // Example migrations
    if (fromVersion == null) {
      await _migrateFromFreshInstall();
    }
    
    if (fromVersion != null && VersionConfig.isVersionGreater('1.1.0', fromVersion)) {
      await _migrateTo110();
    }
    
    if (fromVersion != null && VersionConfig.isVersionGreater('1.2.0', fromVersion)) {
      await _migrateTo120();
    }
    
    if (fromVersion != null && VersionConfig.isVersionGreater('2.0.0', fromVersion)) {
      await _migrateTo200();
    }
  }
  
  // Migration for fresh installs
  static Future<void> _migrateFromFreshInstall() async {
    print('Setting up fresh installation');
    
    // Set default preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch', true);
    await prefs.setString('install_date', DateTime.now().toIso8601String());
  }
  
  // Migration to version 1.1.0
  static Future<void> _migrateTo110() async {
    print('Migrating to version 1.1.0');
    
    // Example: Update database schema
    // await DatabaseService.updateSchema();
    
    // Example: Migrate user preferences
    final prefs = await SharedPreferences.getInstance();
    final oldTheme = prefs.getString('theme');
    if (oldTheme == 'dark') {
      await prefs.setString('theme_mode', 'dark');
      await prefs.remove('theme');
    }
  }
  
  // Migration to version 1.2.0
  static Future<void> _migrateTo120() async {
    print('Migrating to version 1.2.0');
    
    // Example: Clear old cache
    // await CacheService.clearOldCache();
    
    // Example: Update notification settings
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('notifications_enabled')) {
      await prefs.setBool('notifications_enabled', true);
    }
  }
  
  // Migration to version 2.0.0 (major version)
  static Future<void> _migrateTo200() async {
    print('Migrating to version 2.0.0 (major version)');
    
    // Example: Major data structure changes
    // await DatabaseService.migrateToV2();
    
    // Example: Reset certain preferences due to breaking changes
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('deprecated_setting');
    
    // Show migration notice to user
    await prefs.setBool('show_v2_welcome', true);
  }
}
```

## Version Information Widget

### 1. About Screen

```dart
// lib/screens/about_screen.dart
class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  // App icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Theme.of(context).primaryColor,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // App name and version
                  const Text(
                    'YourApp',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version ${VersionConfig.fullVersion}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Version details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Version Information',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('App Version', VersionConfig.appVersion),
                    _buildInfoRow('Build Number', VersionConfig.buildNumber.toString()),
                    _buildInfoRow('Environment', VersionConfig.buildEnvironment),
                    if (VersionConfig.buildDate.isNotEmpty)
                      _buildInfoRow('Build Date', VersionConfig.buildDate),
                    if (VersionConfig.gitCommit.isNotEmpty)
                      _buildInfoRow('Git Commit', VersionConfig.gitCommit.substring(0, 8)),
                    _buildInfoRow('Platform', Platform.operatingSystem),
                    _buildInfoRow('Platform Version', Platform.operatingSystemVersion),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Actions
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _checkForUpdates(context),
                child: const Text('Check for Updates'),
              ),
            ),
            
            const SizedBox(height: 8),
            
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showReleaseNotes(context),
                child: const Text('View Release Notes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
  
  void _checkForUpdates(BuildContext context) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    final updateInfo = await UpdateCheckerService.forceUpdateCheck();
    
    Navigator.of(context).pop(); // Close loading
    
    if (updateInfo != null) {
      await showDialog(
        context: context,
        builder: (context) => UpdateDialog(updateInfo: updateInfo),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have the latest version!')),
      );
    }
  }
  
  void _showReleaseNotes(BuildContext context) async {
    final releaseNotes = await ReleaseService.getReleaseNotes(VersionConfig.appVersion);
    
    if (releaseNotes != null) {
      await showDialog(
        context: context,
        builder: (context) => ReleaseNotesDialog(releaseNotes: releaseNotes),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Release notes not available')),
      );
    }
  }
}
```

Version management is crucial for maintaining app quality and user experience. Implement proper versioning strategies, update mechanisms, and migration processes to ensure smooth app evolution.
