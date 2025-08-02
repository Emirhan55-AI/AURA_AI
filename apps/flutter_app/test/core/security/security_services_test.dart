import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../lib/src/core/security/secure_storage_service.dart';
import '../../../lib/src/core/security/network_security_service.dart';

void main() {
  group('Security Services Tests', () {
    late SecureStorageService secureStorageService;

    setUp(() {
      // Initialize mock secure storage
      FlutterSecureStorage.setMockInitialValues({});
      secureStorageService = SecureStorageService();
    });

    group('Secure Storage Service', () {
      test('should store and retrieve encrypted data correctly', () async {
        const key = 'test_key';
        const value = 'sensitive_data_123';

        // Store data
        final storeResult = await secureStorageService.storeSecureData(
          key: key,
          value: value,
          enableEncryption: true,
        );

        expect(storeResult, true);

        // Retrieve data
        final retrievedValue = await secureStorageService.getSecureData(
          key: key,
          isEncrypted: true,
        );

        expect(retrievedValue, value);
      });

      test('should store and retrieve unencrypted data correctly', () async {
        const key = 'test_key_plain';
        const value = 'plain_data_456';

        // Store data without encryption
        final storeResult = await secureStorageService.storeSecureData(
          key: key,
          value: value,
          enableEncryption: false,
        );

        expect(storeResult, true);

        // Retrieve data without decryption
        final retrievedValue = await secureStorageService.getSecureData(
          key: key,
          isEncrypted: false,
        );

        expect(retrievedValue, value);
      });

      test('should delete data successfully', () async {
        const key = 'test_key_delete';
        const value = 'data_to_delete';

        // Store data first
        await secureStorageService.storeSecureData(
          key: key,
          value: value,
        );

        // Verify data exists
        final beforeDelete = await secureStorageService.getSecureData(key: key);
        expect(beforeDelete, isNotNull);

        // Delete data
        final deleteResult = await secureStorageService.deleteSecureData(key: key);
        expect(deleteResult, true);

        // Verify data is deleted
        final afterDelete = await secureStorageService.getSecureData(key: key);
        expect(afterDelete, isNull);
      });

      test('should handle encryption key generation', () async {
        // This test implicitly checks key generation by using encryption
        const key = 'test_encryption_key';
        const value = 'test_encryption_value';

        final result = await secureStorageService.storeSecureData(
          key: key,
          value: value,
          enableEncryption: true,
        );

        expect(result, true);

        final retrieved = await secureStorageService.getSecureData(
          key: key,
          isEncrypted: true,
        );

        expect(retrieved, value);
      });

      test('should rotate encryption keys successfully', () async {
        const key = 'test_rotation_key';
        const value = 'test_rotation_value';

        // Store initial data
        await secureStorageService.storeSecureData(
          key: key,
          value: value,
          enableEncryption: true,
        );

        // Rotate keys
        final rotationResult = await secureStorageService.rotateEncryptionKey();
        expect(rotationResult, true);

        // Data should still be retrievable after rotation
        final retrieved = await secureStorageService.getSecureData(
          key: key,
          isEncrypted: true,
        );

        expect(retrieved, value);
      });

      test('should clear all data successfully', () async {
        // Store multiple items
        await secureStorageService.storeSecureData(key: 'key1', value: 'value1');
        await secureStorageService.storeSecureData(key: 'key2', value: 'value2');
        await secureStorageService.storeSecureData(key: 'key3', value: 'value3');

        // Clear all data
        final clearResult = await secureStorageService.clearAllSecureData();
        expect(clearResult, true);

        // Verify all data is cleared
        final value1 = await secureStorageService.getSecureData(key: 'key1');
        final value2 = await secureStorageService.getSecureData(key: 'key2');
        final value3 = await secureStorageService.getSecureData(key: 'key3');

        expect(value1, isNull);
        expect(value2, isNull);
        expect(value3, isNull);
      });

      test('should track security audit logs', () async {
        // Perform operations that generate audit logs
        await secureStorageService.storeSecureData(key: 'audit_test', value: 'audit_value');
        await secureStorageService.getSecureData(key: 'audit_test');
        await secureStorageService.deleteSecureData(key: 'audit_test');

        // Check audit logs
        final auditLogs = secureStorageService.getSecurityAuditLogs();
        expect(auditLogs.isNotEmpty, true);

        // Should have logs for store, retrieve, and delete operations
        final storeLog = auditLogs.any((log) => 
            log.eventType == SecurityEventType.dataStored);
        final retrieveLog = auditLogs.any((log) => 
            log.eventType == SecurityEventType.dataRetrieved);
        final deleteLog = auditLogs.any((log) => 
            log.eventType == SecurityEventType.dataDeleted);

        expect(storeLog, true);
        expect(retrieveLog, true);
        expect(deleteLog, true);
      });

      test('should provide security health status', () async {
        final healthStatus = await secureStorageService.getSecurityHealthStatus();

        expect(healthStatus, isNotNull);
        expect(healthStatus.lastAuditLogCount, greaterThanOrEqualTo(0));
        expect(healthStatus.recentErrorCount, greaterThanOrEqualTo(0));
      });
    });

    group('Network Security Service', () {
      test('should validate secure URLs correctly', () {
        // Valid HTTPS URLs
        expect(NetworkSecurityService.isUrlSecure('https://supabase.co/api'), true);
        expect(NetworkSecurityService.isUrlSecure('https://api.aura-app.com/data'), true);

        // Invalid HTTP URLs
        expect(NetworkSecurityService.isUrlSecure('http://example.com'), false);
        expect(NetworkSecurityService.isUrlSecure('ftp://example.com'), false);

        // Invalid domains
        expect(NetworkSecurityService.isUrlSecure('https://malicious.com'), false);
      });

      test('should sanitize input correctly', () {
        const dangerousInput = '<script>alert("xss")</script>SELECT * FROM users';
        final sanitized = NetworkSecurityService.sanitizeInput(dangerousInput);

        expect(sanitized.contains('<script>'), false);
        expect(sanitized.contains('SELECT'), false);
        expect(sanitized.contains('alert'), false);
      });

      test('should generate secure tokens', () {
        final token1 = NetworkSecurityService.generateSecureToken();
        final token2 = NetworkSecurityService.generateSecureToken();

        expect(token1.length, 32);
        expect(token2.length, 32);
        expect(token1, isNot(equals(token2))); // Should be different

        // Test custom length
        final shortToken = NetworkSecurityService.generateSecureToken(length: 16);
        expect(shortToken.length, 16);
      });

      test('should provide security headers', () {
        final headers = NetworkSecurityService.getSecurityHeaders();

        expect(headers.containsKey('X-Content-Type-Options'), true);
        expect(headers.containsKey('X-Frame-Options'), true);
        expect(headers.containsKey('X-XSS-Protection'), true);
        expect(headers.containsKey('Strict-Transport-Security'), true);
        expect(headers.containsKey('Content-Security-Policy'), true);

        expect(headers['X-Content-Type-Options'], 'nosniff');
        expect(headers['X-Frame-Options'], 'DENY');
      });

      test('should check security environment', () async {
        final securityCheck = await NetworkSecurityService.checkSecurityEnvironment();

        expect(securityCheck, isNotNull);
        expect(securityCheck.isDebugging, isA<bool>());
        expect(securityCheck.isPotentiallyCompromised, isA<bool>());
        expect(securityCheck.hasSecureNetwork, isA<bool>());
        expect(securityCheck.isSecure, isA<bool>());
      });

      test('should create secure HTTP client', () {
        final client = NetworkSecurityService.createSecureHttpClient();

        expect(client, isNotNull);
        expect(client.connectionTimeout, const Duration(seconds: 30));
      });
    });

    group('Security Integration Tests', () {
      test('should work together for secure data flow', () async {
        // Simulate secure data storage and network validation
        const sensitiveData = 'user_authentication_token_12345';
        const storageKey = 'auth_token';

        // Store sensitive data securely
        final storeResult = await secureStorageService.storeSecureData(
          key: storageKey,
          value: sensitiveData,
          enableEncryption: true,
        );
        expect(storeResult, true);

        // Validate network security
        const apiUrl = 'https://supabase.co/api/auth';
        final isUrlSecure = NetworkSecurityService.isUrlSecure(apiUrl);
        expect(isUrlSecure, true);

        // Get security headers for API call
        final headers = NetworkSecurityService.getSecurityHeaders();
        expect(headers.isNotEmpty, true);

        // Retrieve stored data
        final retrievedToken = await secureStorageService.getSecureData(
          key: storageKey,
          isEncrypted: true,
        );
        expect(retrievedToken, sensitiveData);

        // Check overall security health
        final healthStatus = await secureStorageService.getSecurityHealthStatus();
        expect(healthStatus.isHealthy, true);
      });
    });
  });
}
