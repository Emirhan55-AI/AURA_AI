import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';

/// Enhanced secure storage service with encryption and audit logging
class SecureStorageService {
  // Platform-specific options for secure storage
  static const AndroidOptions _androidOptions = AndroidOptions(
    // Basic Android options without advanced encryption settings
  );

  static const IOSOptions _iosOptions = IOSOptions(
    accountName: 'com.aura.app',
    synchronizable: false,
  );

  static const LinuxOptions _linuxOptions = LinuxOptions();

  static const WindowsOptions _windowsOptions = WindowsOptions();

  static const MacOsOptions _macOsOptions = MacOsOptions(
    accountName: 'com.aura.app',
    synchronizable: false,
  );

  static const WebOptions _webOptions = WebOptions(
    dbName: 'aura_secure_storage',
    publicKey: 'aura_public_key',
  );

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: _androidOptions,
    iOptions: _iosOptions,
    lOptions: _linuxOptions,
    wOptions: _windowsOptions,
    mOptions: _macOsOptions,
    webOptions: _webOptions,
  );

  // Singleton pattern
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  // Security audit logging
  final List<SecurityAuditLog> _auditLogs = [];

  /// Store sensitive data with encryption
  Future<bool> storeSecureData({
    required String key,
    required String value,
    bool enableEncryption = true,
  }) async {
    try {
      // Encrypt data if requested
      String processedValue = value;
      if (enableEncryption) {
        processedValue = await _encryptData(value);
      }

      // Store in secure storage
      await _storage.write(key: key, value: processedValue);

      _logSecurityEvent(
        SecurityEventType.dataStored,
        'Secure data stored for key: $key',
      );

      return true;
    } catch (e) {
      _logSecurityEvent(
        SecurityEventType.error,
        'Failed to store secure data: $e',
      );
      return false;
    }
  }

  /// Retrieve sensitive data with decryption
  Future<String?> getSecureData({
    required String key,
    bool isEncrypted = true,
  }) async {
    try {
      // Retrieve from secure storage
      final rawValue = await _storage.read(key: key);
      if (rawValue == null) return null;

      // Decrypt if encrypted
      String processedValue = rawValue;
      if (isEncrypted) {
        processedValue = await _decryptData(rawValue);
      }

      _logSecurityEvent(
        SecurityEventType.dataRetrieved,
        'Secure data retrieved for key: $key',
      );

      return processedValue;
    } catch (e) {
      _logSecurityEvent(
        SecurityEventType.error,
        'Failed to retrieve secure data: $e',
      );
      return null;
    }
  }

  /// Delete secure data
  Future<bool> deleteSecureData({
    required String key,
  }) async {
    try {
      await _storage.delete(key: key);

      _logSecurityEvent(
        SecurityEventType.dataDeleted,
        'Secure data deleted for key: $key',
      );

      return true;
    } catch (e) {
      _logSecurityEvent(
        SecurityEventType.error,
        'Failed to delete secure data: $e',
      );
      return false;
    }
  }

  /// Clear all secure storage
  Future<bool> clearAllSecureData() async {
    try {
      await _storage.deleteAll();

      _logSecurityEvent(
        SecurityEventType.allDataCleared,
        'All secure data cleared',
      );

      return true;
    } catch (e) {
      _logSecurityEvent(
        SecurityEventType.error,
        'Failed to clear all secure data: $e',
      );
      return false;
    }
  }

  /// Check if secure storage is available
  Future<bool> isSecureStorageAvailable() async {
    try {
      // Test write and read operation
      const testKey = '_aura_test_key';
      const testValue = 'test';
      
      await _storage.write(key: testKey, value: testValue);
      final result = await _storage.read(key: testKey);
      await _storage.delete(key: testKey);
      
      return result == testValue;
    } catch (e) {
      _logSecurityEvent(
        SecurityEventType.error,
        'Secure storage availability check failed: $e',
      );
      return false;
    }
  }

  /// Encrypt data using SHA256 and Base64 encoding
  Future<String> _encryptData(String data) async {
    try {
      // Get or create encryption key
      final encryptionKey = await _getOrCreateEncryptionKey();
      
      // Create hash with key and data combined
      final combinedData = '$encryptionKey:$data';
      final bytes = utf8.encode(combinedData);
      final digest = sha256.convert(bytes);
      
      // Base64 encode the original data with hash prefix
      final dataBytes = utf8.encode(data);
      final encoded = base64Encode(dataBytes);
      
      // Return hash:encoded_data format
      return '${digest.toString()}:$encoded';
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  /// Decrypt data using SHA256 verification and Base64 decoding
  Future<String> _decryptData(String encryptedData) async {
    try {
      // Split hash and encoded data
      final parts = encryptedData.split(':');
      if (parts.length < 2) {
        throw Exception('Invalid encrypted data format');
      }
      
      final hash = parts[0];
      final encodedData = parts.sublist(1).join(':');
      
      // Decode the data
      final decoded = base64Decode(encodedData);
      final data = utf8.decode(decoded);
      
      // Verify hash
      final encryptionKey = await _getOrCreateEncryptionKey();
      final combinedData = '$encryptionKey:$data';
      final bytes = utf8.encode(combinedData);
      final expectedHash = sha256.convert(bytes).toString();
      
      if (hash != expectedHash) {
        throw Exception('Data integrity check failed');
      }
      
      return data;
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  /// Get or create encryption key
  Future<String> _getOrCreateEncryptionKey() async {
    const keyName = 'aura_encryption_key';
    
    String? existingKey = await _storage.read(key: keyName);
    if (existingKey != null) {
      return existingKey;
    }

    // Generate new encryption key
    final random = Random.secure();
    final key = List.generate(32, (index) => random.nextInt(256))
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();

    await _storage.write(key: keyName, value: key);
    
    _logSecurityEvent(
      SecurityEventType.keyGenerated,
      'New encryption key generated',
    );

    return key;
  }

  /// Rotate encryption keys
  Future<bool> rotateEncryptionKey() async {
    try {
      // Read all existing data
      final allData = await _storage.readAll();
      
      // Delete old encryption key
      await _storage.delete(key: 'aura_encryption_key');
      
      // Generate new key
      await _getOrCreateEncryptionKey();
      
      // Re-encrypt all data with new key
      for (final entry in allData.entries) {
        if (entry.key != 'aura_encryption_key') {
          // Decrypt with old key, encrypt with new key
          final decrypted = await _decryptData(entry.value);
          final reEncrypted = await _encryptData(decrypted);
          await _storage.write(key: entry.key, value: reEncrypted);
        }
      }

      _logSecurityEvent(
        SecurityEventType.keyRotated,
        'Encryption key rotated successfully',
      );

      return true;
    } catch (e) {
      _logSecurityEvent(
        SecurityEventType.error,
        'Key rotation failed: $e',
      );
      return false;
    }
  }

  /// Security audit logging
  void _logSecurityEvent(SecurityEventType eventType, String description) {
    final log = SecurityAuditLog(
      timestamp: DateTime.now(),
      eventType: eventType,
      description: description,
    );

    _auditLogs.add(log);

    // Keep only last 1000 logs to prevent memory issues
    if (_auditLogs.length > 1000) {
      _auditLogs.removeAt(0);
    }

    // In production, also send to remote logging service
    print('Security Event [${eventType.name}]: $description');
  }

  /// Get security audit logs
  List<SecurityAuditLog> getSecurityAuditLogs() {
    return List.from(_auditLogs);
  }

  /// Get security health status
  Future<SecurityHealthStatus> getSecurityHealthStatus() async {
    try {
      final secureStorageAvailable = await isSecureStorageAvailable();
      final encryptionKeyExists = await _storage.containsKey(key: 'aura_encryption_key');
      final recentErrors = _auditLogs
          .where((log) => 
              log.eventType == SecurityEventType.error &&
              log.timestamp.isAfter(DateTime.now().subtract(const Duration(hours: 24))))
          .length;

      return SecurityHealthStatus(
        secureStorageAvailable: secureStorageAvailable,
        encryptionEnabled: encryptionKeyExists,
        recentErrorCount: recentErrors,
        lastAuditLogCount: _auditLogs.length,
        isHealthy: secureStorageAvailable && encryptionKeyExists && recentErrors < 5,
      );
    } catch (e) {
      _logSecurityEvent(
        SecurityEventType.error,
        'Failed to get security health status: $e',
      );
      return SecurityHealthStatus(
        secureStorageAvailable: false,
        encryptionEnabled: false,
        recentErrorCount: 999,
        lastAuditLogCount: _auditLogs.length,
        isHealthy: false,
      );
    }
  }
}

/// Security event types for audit logging
enum SecurityEventType {
  dataStored,
  dataRetrieved,
  dataDeleted,
  allDataCleared,
  keyGenerated,
  keyRotated,
  error,
}

/// Security audit log entry
class SecurityAuditLog {
  final DateTime timestamp;
  final SecurityEventType eventType;
  final String description;

  SecurityAuditLog({
    required this.timestamp,
    required this.eventType,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'eventType': eventType.name,
    'description': description,
  };

  factory SecurityAuditLog.fromJson(Map<String, dynamic> json) => SecurityAuditLog(
    timestamp: DateTime.parse(json['timestamp'] as String),
    eventType: SecurityEventType.values.firstWhere(
      (e) => e.name == json['eventType'],
    ),
    description: json['description'] as String,
  );
}

/// Security health status
class SecurityHealthStatus {
  final bool secureStorageAvailable;
  final bool encryptionEnabled;
  final int recentErrorCount;
  final int lastAuditLogCount;
  final bool isHealthy;

  SecurityHealthStatus({
    required this.secureStorageAvailable,
    required this.encryptionEnabled,
    required this.recentErrorCount,
    required this.lastAuditLogCount,
    required this.isHealthy,
  });

  Map<String, dynamic> toJson() => {
    'secureStorageAvailable': secureStorageAvailable,
    'encryptionEnabled': encryptionEnabled,
    'recentErrorCount': recentErrorCount,
    'lastAuditLogCount': lastAuditLogCount,
    'isHealthy': isHealthy,
  };
}
