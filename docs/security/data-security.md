# Data Security

Comprehensive guide to implementing data security measures in Flutter applications, covering encryption, secure storage, and data protection.

## Overview

Data security is critical for protecting user information, credentials, and sensitive application data. This guide covers encryption, secure storage, data classification, and privacy protection.

## Secure Storage

### 1. Flutter Secure Storage

```dart
// lib/services/secure_storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      sharedPreferencesName: 'secure_prefs',
      preferencesKeyPrefix: 'app_',
    ),
    iOptions: IOSOptions(
      groupId: 'group.com.yourapp.flutter',
      accountName: 'YourApp',
      accessibility: IOSAccessibility.first_unlock_this_device,
    ),
  );
  
  // Store sensitive data
  static Future<void> storeSecureData(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      throw SecureStorageException('Failed to store secure data: $e');
    }
  }
  
  // Retrieve sensitive data
  static Future<String?> getSecureData(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      throw SecureStorageException('Failed to retrieve secure data: $e');
    }
  }
  
  // Store encrypted JSON
  static Future<void> storeSecureJson(String key, Map<String, dynamic> data) async {
    final jsonString = jsonEncode(data);
    await storeSecureData(key, jsonString);
  }
  
  // Retrieve encrypted JSON
  static Future<Map<String, dynamic>?> getSecureJson(String key) async {
    final jsonString = await getSecureData(key);
    if (jsonString == null) return null;
    
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw SecureStorageException('Failed to parse JSON data: $e');
    }
  }
  
  // Delete secure data
  static Future<void> deleteSecureData(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw SecureStorageException('Failed to delete secure data: $e');
    }
  }
  
  // Clear all secure data
  static Future<void> clearAllSecureData() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw SecureStorageException('Failed to clear secure data: $e');
    }
  }
  
  // Check if key exists
  static Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      return false;
    }
  }
  
  // Get all keys
  static Future<Map<String, String>> getAllSecureData() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      throw SecureStorageException('Failed to read all secure data: $e');
    }
  }
}

class SecureStorageException implements Exception {
  final String message;
  SecureStorageException(this.message);
  
  @override
  String toString() => 'SecureStorageException: $message';
}
```

### 2. Encrypted Database

```dart
// lib/services/encrypted_database_service.dart
import 'package:sqflite_sqlcipher/sqflite.dart';

class EncryptedDatabaseService {
  static Database? _database;
  static const String _databaseName = 'secure_app.db';
  static const int _databaseVersion = 1;
  
  // Initialize encrypted database
  static Future<Database> get database async {
    if (_database != null) return _database!;
    
    _database = await _initDatabase();
    return _database!;
  }
  
  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);
    
    // Get encryption password from secure storage
    final password = await _getDatabasePassword();
    
    return await openDatabase(
      path,
      version: _databaseVersion,
      password: password,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  static Future<String> _getDatabasePassword() async {
    const passwordKey = 'database_password';
    
    // Try to get existing password
    String? password = await SecureStorageService.getSecureData(passwordKey);
    
    if (password == null) {
      // Generate new password
      password = _generateSecurePassword();
      await SecureStorageService.storeSecureData(passwordKey, password);
    }
    
    return password;
  }
  
  static String _generateSecurePassword() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64.encode(bytes);
  }
  
  static Future<void> _onCreate(Database db, int version) async {
    // Create tables with encryption
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL,
        encrypted_data TEXT,
        created_at INTEGER NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE secure_notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        encrypted_content TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }
  
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades
    if (oldVersion < 2) {
      // Add new columns or tables
    }
  }
  
  // Insert encrypted data
  static Future<int> insertEncryptedData(String table, Map<String, dynamic> data) async {
    final db = await database;
    
    // Encrypt sensitive fields
    final encryptedData = await _encryptSensitiveFields(data);
    
    return await db.insert(table, encryptedData);
  }
  
  // Query encrypted data
  static Future<List<Map<String, dynamic>>> queryEncryptedData(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    
    final results = await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
    );
    
    // Decrypt sensitive fields
    final decryptedResults = <Map<String, dynamic>>[];
    for (final result in results) {
      final decryptedResult = await _decryptSensitiveFields(result);
      decryptedResults.add(decryptedResult);
    }
    
    return decryptedResults;
  }
  
  static Future<Map<String, dynamic>> _encryptSensitiveFields(Map<String, dynamic> data) async {
    final encryptedData = Map<String, dynamic>.from(data);
    
    // Encrypt specific fields
    if (data.containsKey('encrypted_data')) {
      final plaintext = data['encrypted_data'] as String;
      encryptedData['encrypted_data'] = await EncryptionService.encrypt(plaintext);
    }
    
    if (data.containsKey('encrypted_content')) {
      final plaintext = data['encrypted_content'] as String;
      encryptedData['encrypted_content'] = await EncryptionService.encrypt(plaintext);
    }
    
    return encryptedData;
  }
  
  static Future<Map<String, dynamic>> _decryptSensitiveFields(Map<String, dynamic> data) async {
    final decryptedData = Map<String, dynamic>.from(data);
    
    // Decrypt specific fields
    if (data.containsKey('encrypted_data') && data['encrypted_data'] != null) {
      final ciphertext = data['encrypted_data'] as String;
      decryptedData['encrypted_data'] = await EncryptionService.decrypt(ciphertext);
    }
    
    if (data.containsKey('encrypted_content') && data['encrypted_content'] != null) {
      final ciphertext = data['encrypted_content'] as String;
      decryptedData['encrypted_content'] = await EncryptionService.decrypt(ciphertext);
    }
    
    return decryptedData;
  }
  
  // Close database
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
```

## Encryption Services

### 1. AES Encryption Service

```dart
// lib/services/encryption_service.dart
import 'package:encrypt/encrypt.dart';

class EncryptionService {
  static late final Encrypter _encrypter;
  static late final IV _iv;
  static bool _initialized = false;
  
  // Initialize encryption service
  static Future<void> initialize() async {
    if (_initialized) return;
    
    final key = await _getOrCreateEncryptionKey();
    _encrypter = Encrypter(AES(key));
    _iv = IV.fromSecureRandom(16);
    _initialized = true;
  }
  
  static Future<Key> _getOrCreateEncryptionKey() async {
    const keyName = 'encryption_key';
    
    // Try to get existing key
    String? keyString = await SecureStorageService.getSecureData(keyName);
    
    if (keyString == null) {
      // Generate new key
      final key = Key.fromSecureRandom(32);
      keyString = key.base64;
      await SecureStorageService.storeSecureData(keyName, keyString);
      return key;
    }
    
    return Key.fromBase64(keyString);
  }
  
  // Encrypt string data
  static Future<String> encrypt(String plaintext) async {
    await initialize();
    
    final encrypted = _encrypter.encrypt(plaintext, iv: _iv);
    return encrypted.base64;
  }
  
  // Decrypt string data
  static Future<String> decrypt(String ciphertext) async {
    await initialize();
    
    final encrypted = Encrypted.fromBase64(ciphertext);
    return _encrypter.decrypt(encrypted, iv: _iv);
  }
  
  // Encrypt JSON data
  static Future<String> encryptJson(Map<String, dynamic> data) async {
    final jsonString = jsonEncode(data);
    return await encrypt(jsonString);
  }
  
  // Decrypt JSON data
  static Future<Map<String, dynamic>> decryptJson(String ciphertext) async {
    final jsonString = await decrypt(ciphertext);
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }
  
  // Encrypt file
  static Future<void> encryptFile(String inputPath, String outputPath) async {
    await initialize();
    
    final inputFile = File(inputPath);
    final outputFile = File(outputPath);
    
    final bytes = await inputFile.readAsBytes();
    final encrypted = _encrypter.encryptBytes(bytes, iv: _iv);
    
    await outputFile.writeAsBytes(encrypted.bytes);
  }
  
  // Decrypt file
  static Future<void> decryptFile(String inputPath, String outputPath) async {
    await initialize();
    
    final inputFile = File(inputPath);
    final outputFile = File(outputPath);
    
    final encryptedBytes = await inputFile.readAsBytes();
    final encrypted = Encrypted(encryptedBytes);
    final decryptedBytes = _encrypter.decryptBytes(encrypted, iv: _iv);
    
    await outputFile.writeAsBytes(decryptedBytes);
  }
  
  // Generate hash
  static String generateHash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  // Generate HMAC
  static String generateHMAC(String input, String secret) {
    final key = utf8.encode(secret);
    final bytes = utf8.encode(input);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return digest.toString();
  }
}
```

### 2. Key Management Service

```dart
// lib/services/key_management_service.dart
class KeyManagementService {
  static const String _masterKeyName = 'master_key';
  static const String _keyVersionName = 'key_version';
  
  // Generate master key
  static Future<void> generateMasterKey() async {
    final masterKey = Key.fromSecureRandom(32);
    await SecureStorageService.storeSecureData(_masterKeyName, masterKey.base64);
    await SecureStorageService.storeSecureData(_keyVersionName, '1');
  }
  
  // Get master key
  static Future<Key?> getMasterKey() async {
    final keyString = await SecureStorageService.getSecureData(_masterKeyName);
    if (keyString == null) return null;
    
    return Key.fromBase64(keyString);
  }
  
  // Rotate master key
  static Future<void> rotateMasterKey() async {
    final oldKey = await getMasterKey();
    if (oldKey == null) {
      await generateMasterKey();
      return;
    }
    
    // Generate new key
    final newKey = Key.fromSecureRandom(32);
    
    // Get current version
    final versionString = await SecureStorageService.getSecureData(_keyVersionName);
    final currentVersion = int.tryParse(versionString ?? '1') ?? 1;
    final newVersion = currentVersion + 1;
    
    // Store new key and version
    await SecureStorageService.storeSecureData(_masterKeyName, newKey.base64);
    await SecureStorageService.storeSecureData(_keyVersionName, newVersion.toString());
    
    // Re-encrypt existing data with new key
    await _reEncryptExistingData(oldKey, newKey);
  }
  
  static Future<void> _reEncryptExistingData(Key oldKey, Key newKey) async {
    // This would re-encrypt all existing encrypted data
    // Implementation depends on your data structure
    
    // Example: Re-encrypt secure storage data
    final allData = await SecureStorageService.getAllSecureData();
    
    for (final entry in allData.entries) {
      if (entry.key.startsWith('encrypted_')) {
        try {
          // Decrypt with old key
          final oldEncrypter = Encrypter(AES(oldKey));
          final iv = IV.fromSecureRandom(16);
          final encrypted = Encrypted.fromBase64(entry.value);
          final plaintext = oldEncrypter.decrypt(encrypted, iv: iv);
          
          // Encrypt with new key
          final newEncrypter = Encrypter(AES(newKey));
          final newEncrypted = newEncrypter.encrypt(plaintext, iv: iv);
          
          // Store re-encrypted data
          await SecureStorageService.storeSecureData(entry.key, newEncrypted.base64);
        } catch (e) {
          print('Failed to re-encrypt ${entry.key}: $e');
        }
      }
    }
  }
  
  // Derive key from password
  static Key deriveKeyFromPassword(String password, String salt) {
    final saltBytes = utf8.encode(salt);
    final passwordBytes = utf8.encode(password);
    
    // Use PBKDF2 for key derivation
    final pbkdf2 = PBKDF2();
    final derivedBytes = pbkdf2.generateKey(passwordBytes, saltBytes, 10000, 32);
    
    return Key(Uint8List.fromList(derivedBytes));
  }
  
  // Generate salt
  static String generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64.encode(bytes);
  }
}
```

## Data Classification & Protection

### 1. Data Classification Service

```dart
// lib/services/data_classification_service.dart
enum DataClassification {
  public,
  internal,
  confidential,
  restricted,
}

class DataClassificationService {
  static const Map<DataClassification, DataProtectionLevel> _protectionLevels = {
    DataClassification.public: DataProtectionLevel.none,
    DataClassification.internal: DataProtectionLevel.basic,
    DataClassification.confidential: DataProtectionLevel.standard,
    DataClassification.restricted: DataProtectionLevel.maximum,
  };
  
  // Classify data based on content
  static DataClassification classifyData(String data) {
    // Check for PII patterns
    if (_containsPII(data)) {
      return DataClassification.restricted;
    }
    
    // Check for financial information
    if (_containsFinancialInfo(data)) {
      return DataClassification.confidential;
    }
    
    // Check for internal identifiers
    if (_containsInternalInfo(data)) {
      return DataClassification.internal;
    }
    
    return DataClassification.public;
  }
  
  static bool _containsPII(String data) {
    // Check for email addresses
    final emailRegex = RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b');
    if (emailRegex.hasMatch(data)) return true;
    
    // Check for phone numbers
    final phoneRegex = RegExp(r'\b\d{3}-\d{3}-\d{4}\b|\b\(\d{3}\)\s*\d{3}-\d{4}\b');
    if (phoneRegex.hasMatch(data)) return true;
    
    // Check for SSN patterns
    final ssnRegex = RegExp(r'\b\d{3}-\d{2}-\d{4}\b');
    if (ssnRegex.hasMatch(data)) return true;
    
    return false;
  }
  
  static bool _containsFinancialInfo(String data) {
    // Check for credit card numbers
    final ccRegex = RegExp(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b');
    if (ccRegex.hasMatch(data)) return true;
    
    // Check for bank account patterns
    final bankRegex = RegExp(r'\b\d{8,17}\b');
    if (bankRegex.hasMatch(data)) return true;
    
    return false;
  }
  
  static bool _containsInternalInfo(String data) {
    // Check for internal IDs or codes
    final internalRegex = RegExp(r'\b(EMP|USR|SYS)\d+\b');
    return internalRegex.hasMatch(data);
  }
  
  // Get protection level for classification
  static DataProtectionLevel getProtectionLevel(DataClassification classification) {
    return _protectionLevels[classification] ?? DataProtectionLevel.basic;
  }
  
  // Apply protection based on classification
  static Future<String> protectData(String data, DataClassification classification) async {
    final protectionLevel = getProtectionLevel(classification);
    
    switch (protectionLevel) {
      case DataProtectionLevel.none:
        return data;
      
      case DataProtectionLevel.basic:
        return await EncryptionService.encrypt(data);
      
      case DataProtectionLevel.standard:
        final encrypted = await EncryptionService.encrypt(data);
        return await _addIntegrityCheck(encrypted);
      
      case DataProtectionLevel.maximum:
        final encrypted = await EncryptionService.encrypt(data);
        final withIntegrity = await _addIntegrityCheck(encrypted);
        return await _addAccessControl(withIntegrity);
    }
  }
  
  static Future<String> _addIntegrityCheck(String data) async {
    final hash = EncryptionService.generateHash(data);
    return '$data|$hash';
  }
  
  static Future<String> _addAccessControl(String data) async {
    // Add access control metadata
    final accessControl = {
      'data': data,
      'access_level': 'restricted',
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    return await EncryptionService.encryptJson(accessControl);
  }
}

enum DataProtectionLevel {
  none,
  basic,
  standard,
  maximum,
}
```

### 2. Data Masking Service

```dart
// lib/services/data_masking_service.dart
class DataMaskingService {
  // Mask email addresses
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    
    final username = parts[0];
    final domain = parts[1];
    
    if (username.length <= 2) {
      return '${username[0]}***@$domain';
    }
    
    final maskedUsername = '${username.substring(0, 2)}${'*' * (username.length - 2)}';
    return '$maskedUsername@$domain';
  }
  
  // Mask phone numbers
  static String maskPhoneNumber(String phone) {
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length == 10) {
      return '(${digitsOnly.substring(0, 3)}) ***-${digitsOnly.substring(6)}';
    } else if (digitsOnly.length == 11) {
      return '${digitsOnly.substring(0, 1)} (${digitsOnly.substring(1, 4)}) ***-${digitsOnly.substring(7)}';
    }
    
    return phone;
  }
  
  // Mask credit card numbers
  static String maskCreditCard(String cardNumber) {
    final digitsOnly = cardNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length >= 13) {
      final lastFour = digitsOnly.substring(digitsOnly.length - 4);
      return '**** **** **** $lastFour';
    }
    
    return cardNumber;
  }
  
  // Mask SSN
  static String maskSSN(String ssn) {
    final digitsOnly = ssn.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length == 9) {
      return '***-**-${digitsOnly.substring(5)}';
    }
    
    return ssn;
  }
  
  // Generic data masking
  static String maskString(String input, {int visibleChars = 2}) {
    if (input.length <= visibleChars) {
      return '*' * input.length;
    }
    
    final visible = input.substring(0, visibleChars);
    final masked = '*' * (input.length - visibleChars);
    return '$visible$masked';
  }
  
  // Mask based on data classification
  static String maskByClassification(String data, DataClassification classification) {
    switch (classification) {
      case DataClassification.public:
        return data;
      
      case DataClassification.internal:
        return maskString(data, visibleChars: 4);
      
      case DataClassification.confidential:
        return maskString(data, visibleChars: 2);
      
      case DataClassification.restricted:
        return '*' * data.length;
    }
  }
}
```

## Privacy Protection

### 1. Privacy Manager

```dart
// lib/services/privacy_manager.dart
class PrivacyManager {
  static const String _privacySettingsKey = 'privacy_settings';
  
  // Get privacy settings
  static Future<PrivacySettings> getPrivacySettings() async {
    final settingsJson = await SecureStorageService.getSecureJson(_privacySettingsKey);
    
    if (settingsJson == null) {
      return PrivacySettings.defaultSettings();
    }
    
    return PrivacySettings.fromJson(settingsJson);
  }
  
  // Update privacy settings
  static Future<void> updatePrivacySettings(PrivacySettings settings) async {
    await SecureStorageService.storeSecureJson(_privacySettingsKey, settings.toJson());
  }
  
  // Check if data collection is allowed
  static Future<bool> isDataCollectionAllowed(DataType dataType) async {
    final settings = await getPrivacySettings();
    
    switch (dataType) {
      case DataType.analytics:
        return settings.allowAnalytics;
      case DataType.crashReports:
        return settings.allowCrashReports;
      case DataType.location:
        return settings.allowLocationTracking;
      case DataType.personalInfo:
        return settings.allowPersonalInfoCollection;
    }
  }
  
  // Anonymize user data
  static Map<String, dynamic> anonymizeUserData(Map<String, dynamic> userData) {
    final anonymized = Map<String, dynamic>.from(userData);
    
    // Remove or hash PII
    if (anonymized.containsKey('email')) {
      anonymized['email'] = EncryptionService.generateHash(anonymized['email']);
    }
    
    if (anonymized.containsKey('phone')) {
      anonymized.remove('phone');
    }
    
    if (anonymized.containsKey('name')) {
      anonymized.remove('name');
    }
    
    // Add anonymization timestamp
    anonymized['anonymized_at'] = DateTime.now().toIso8601String();
    
    return anonymized;
  }
  
  // Data retention management
  static Future<void> cleanupExpiredData() async {
    final settings = await getPrivacySettings();
    final cutoffDate = DateTime.now().subtract(Duration(days: settings.dataRetentionDays));
    
    // Clean up local database
    await _cleanupDatabaseData(cutoffDate);
    
    // Clean up cached files
    await _cleanupCachedFiles(cutoffDate);
    
    // Clean up logs
    await _cleanupLogs(cutoffDate);
  }
  
  static Future<void> _cleanupDatabaseData(DateTime cutoffDate) async {
    final db = await EncryptedDatabaseService.database;
    
    await db.delete(
      'user_activities',
      where: 'created_at < ?',
      whereArgs: [cutoffDate.millisecondsSinceEpoch],
    );
  }
  
  static Future<void> _cleanupCachedFiles(DateTime cutoffDate) async {
    final cacheDir = await getTemporaryDirectory();
    final files = cacheDir.listSync();
    
    for (final file in files) {
      if (file is File) {
        final stat = await file.stat();
        if (stat.modified.isBefore(cutoffDate)) {
          await file.delete();
        }
      }
    }
  }
  
  static Future<void> _cleanupLogs(DateTime cutoffDate) async {
    // Clean up application logs older than cutoff date
    // Implementation depends on your logging system
  }
}

class PrivacySettings {
  final bool allowAnalytics;
  final bool allowCrashReports;
  final bool allowLocationTracking;
  final bool allowPersonalInfoCollection;
  final int dataRetentionDays;
  
  const PrivacySettings({
    required this.allowAnalytics,
    required this.allowCrashReports,
    required this.allowLocationTracking,
    required this.allowPersonalInfoCollection,
    required this.dataRetentionDays,
  });
  
  factory PrivacySettings.defaultSettings() {
    return const PrivacySettings(
      allowAnalytics: false,
      allowCrashReports: true,
      allowLocationTracking: false,
      allowPersonalInfoCollection: false,
      dataRetentionDays: 30,
    );
  }
  
  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      allowAnalytics: json['allowAnalytics'] ?? false,
      allowCrashReports: json['allowCrashReports'] ?? true,
      allowLocationTracking: json['allowLocationTracking'] ?? false,
      allowPersonalInfoCollection: json['allowPersonalInfoCollection'] ?? false,
      dataRetentionDays: json['dataRetentionDays'] ?? 30,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'allowAnalytics': allowAnalytics,
      'allowCrashReports': allowCrashReports,
      'allowLocationTracking': allowLocationTracking,
      'allowPersonalInfoCollection': allowPersonalInfoCollection,
      'dataRetentionDays': dataRetentionDays,
    };
  }
}

enum DataType {
  analytics,
  crashReports,
  location,
  personalInfo,
}
```

## Security Testing

### 1. Data Security Tests

```dart
// test/security/data_security_test.dart
void main() {
  group('Data Security Tests', () {
    test('should encrypt and decrypt data correctly', () async {
      const plaintext = 'sensitive data';
      
      final encrypted = await EncryptionService.encrypt(plaintext);
      expect(encrypted, isNot(equals(plaintext)));
      
      final decrypted = await EncryptionService.decrypt(encrypted);
      expect(decrypted, equals(plaintext));
    });
    
    test('should classify data correctly', () {
      const email = 'user@example.com';
      const publicData = 'public information';
      
      final emailClassification = DataClassificationService.classifyData(email);
      expect(emailClassification, equals(DataClassification.restricted));
      
      final publicClassification = DataClassificationService.classifyData(publicData);
      expect(publicClassification, equals(DataClassification.public));
    });
    
    test('should mask sensitive data', () {
      const email = 'john.doe@example.com';
      const phone = '(555) 123-4567';
      
      final maskedEmail = DataMaskingService.maskEmail(email);
      expect(maskedEmail, equals('jo*******@example.com'));
      
      final maskedPhone = DataMaskingService.maskPhoneNumber(phone);
      expect(maskedPhone, equals('(555) ***-4567'));
    });
  });
}
```

Data security requires a comprehensive approach including encryption, secure storage, data classification, and privacy protection. Regularly audit your data handling practices and stay updated with security best practices.
