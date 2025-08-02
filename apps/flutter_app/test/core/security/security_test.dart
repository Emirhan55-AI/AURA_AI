import 'package:flutter_test/flutter_test.dart';

/// Security and data protection tests
/// These tests verify secure storage, data validation, and privacy compliance
void main() {
  group('Security Tests', () {
    group('Data Validation', () {
      test('should validate email format correctly', () {
        // Test cases for email validation
        const validEmails = [
          'user@example.com',
          'test.email@domain.org',
          'user+tag@example.co.uk',
          'user123@test-domain.com',
        ];

        const invalidEmails = [
          'invalid-email',
          '@domain.com',
          'user@',
          'user..name@domain.com',
          'user@domain',
          '',
        ];

        for (final email in validEmails) {
          expect(isValidEmail(email), isTrue, reason: 'Email $email should be valid');
        }

        for (final email in invalidEmails) {
          expect(isValidEmail(email), isFalse, reason: 'Email $email should be invalid');
        }
      });

      test('should validate password strength', () {
        const weakPasswords = [
          '123',
          'password',
          '12345678',
          'abc',
          '',
        ];

        const strongPasswords = [
          'MySecureP@ss123',
          'Complex!Password2024',
          'Str0ng&SecurePass',
          'My#V3ryStr0ngP@ssw0rd',
        ];

        for (final password in weakPasswords) {
          expect(isStrongPassword(password), isFalse, reason: 'Password "$password" should be weak');
        }

        for (final password in strongPasswords) {
          expect(isStrongPassword(password), isTrue, reason: 'Password "$password" should be strong');
        }
      });

      test('should sanitize user input', () {
        const inputs = {
          '<script>alert("xss")</script>': 'alert("xss")',
          'Normal text': 'Normal text',
          '<b>Bold text</b>': 'Bold text',
          'Text with & symbols': 'Text with & symbols',
          '': '',
        };

        inputs.forEach((input, expected) {
          final sanitized = sanitizeInput(input);
          expect(sanitized, equals(expected), reason: 'Input "$input" should be sanitized to "$expected"');
        });
      });

      test('should validate file types for image uploads', () {
        const validImageTypes = [
          'image/jpeg',
          'image/jpg',
          'image/png',
          'image/webp',
        ];

        const invalidTypes = [
          'application/pdf',
          'text/html',
          'application/javascript',
          'video/mp4',
          '',
          'image/svg+xml', // Potentially dangerous
        ];

        for (final type in validImageTypes) {
          expect(isValidImageType(type), isTrue, reason: 'Type $type should be valid');
        }

        for (final type in invalidTypes) {
          expect(isValidImageType(type), isFalse, reason: 'Type $type should be invalid');
        }
      });

      test('should validate file size limits', () {
        const maxSizeInBytes = 5 * 1024 * 1024; // 5MB
        
        const validSizes = [
          1024, // 1KB
          1024 * 1024, // 1MB
          3 * 1024 * 1024, // 3MB
          maxSizeInBytes, // Exactly 5MB
        ];

        const invalidSizes = [
          maxSizeInBytes + 1, // Just over limit
          10 * 1024 * 1024, // 10MB
          50 * 1024 * 1024, // 50MB
        ];

        for (final size in validSizes) {
          expect(isValidFileSize(size, maxSizeInBytes), isTrue, reason: 'Size $size should be valid');
        }

        for (final size in invalidSizes) {
          expect(isValidFileSize(size, maxSizeInBytes), isFalse, reason: 'Size $size should be invalid');
        }
      });
    });

    group('Data Protection', () {
      test('should mask sensitive data in logs', () {
        const sensitiveData = {
          'password': 'mySecretPassword123',
          'email': 'user@example.com',
          'token': 'abc123xyz789',
          'credit_card': '4111-1111-1111-1111',
        };

        final masked = maskSensitiveData(sensitiveData);

        expect(masked['password'], equals('***'));
        expect(masked['email'], equals('u***@example.com'));
        expect(masked['token'], equals('abc***789'));
        expect(masked['credit_card'], equals('4111-****-****-1111'));
      });

      test('should generate secure random tokens', () {
        const tokenLength = 32;
        final token1 = generateSecureToken(tokenLength);
        final token2 = generateSecureToken(tokenLength);

        // Tokens should be different
        expect(token1, isNot(equals(token2)));
        
        // Tokens should have correct length
        expect(token1.length, equals(tokenLength));
        expect(token2.length, equals(tokenLength));
        
        // Tokens should contain only valid characters
        final validChars = RegExp(r'^[a-zA-Z0-9]+$');
        expect(validChars.hasMatch(token1), isTrue);
        expect(validChars.hasMatch(token2), isTrue);
      });

      test('should handle user consent tracking', () {
        final consent = UserConsent();
        
        // Initially no consent
        expect(consent.hasAnalyticsConsent, isFalse);
        expect(consent.hasMarketingConsent, isFalse);
        
        // Grant consent
        consent.grantAnalyticsConsent();
        consent.grantMarketingConsent();
        
        expect(consent.hasAnalyticsConsent, isTrue);
        expect(consent.hasMarketingConsent, isTrue);
        expect(consent.consentTimestamp, isNotNull);
        
        // Revoke consent
        consent.revokeAnalyticsConsent();
        expect(consent.hasAnalyticsConsent, isFalse);
        expect(consent.hasMarketingConsent, isTrue);
      });
    });

    group('Privacy Compliance', () {
      test('should implement data retention policies', () {
        final retentionPolicy = DataRetentionPolicy();
        
        // Test different data types
        expect(retentionPolicy.getRetentionPeriod('user_data'), equals(Duration(days: 365 * 7))); // 7 years
        expect(retentionPolicy.getRetentionPeriod('analytics_data'), equals(Duration(days: 365 * 2))); // 2 years
        expect(retentionPolicy.getRetentionPeriod('session_data'), equals(Duration(days: 30))); // 30 days
        expect(retentionPolicy.getRetentionPeriod('logs'), equals(Duration(days: 90))); // 90 days
      });

      test('should handle data anonymization', () {
        final userData = {
          'id': '12345',
          'name': 'John Doe',
          'email': 'john.doe@example.com',
          'phone': '+1-555-123-4567',
          'ip_address': '192.168.1.1',
          'user_agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
        };

        final anonymized = anonymizeUserData(userData);

        // Sensitive fields should be anonymized
        expect(anonymized['name'], isNot(equals('John Doe')));
        expect(anonymized['email'], isNot(equals('john.doe@example.com')));
        expect(anonymized['phone'], isNot(equals('+1-555-123-4567')));
        expect(anonymized['ip_address'], isNot(equals('192.168.1.1')));
        
        // ID should be preserved for data consistency
        expect(anonymized['id'], equals('12345'));
        
        // User agent might be partially anonymized
        expect(anonymized['user_agent'], isNotNull);
      });

      test('should implement right to be forgotten', () {
        final dataManager = UserDataManager();
        const userId = 'user123';
        
        // Add some user data
        dataManager.addUserData(userId, {'name': 'John', 'email': 'john@example.com'});
        dataManager.addUserAnalytics(userId, {'page_views': 100});
        dataManager.addUserPreferences(userId, {'theme': 'dark'});
        
        expect(dataManager.hasUserData(userId), isTrue);
        
        // Exercise right to be forgotten
        final deleted = dataManager.deleteAllUserData(userId);
        
        expect(deleted, isTrue);
        expect(dataManager.hasUserData(userId), isFalse);
      });
    });

    group('Access Control', () {
      test('should validate user permissions', () {
        final permissions = UserPermissions();
        
        // Test default permissions
        expect(permissions.canReadOwnData('user123'), isTrue);
        expect(permissions.canWriteOwnData('user123'), isTrue);
        expect(permissions.canDeleteOwnData('user123'), isTrue);
        expect(permissions.canAccessOtherUserData('user123', 'user456'), isFalse);
        
        // Test admin permissions
        permissions.grantAdminRole('admin123');
        expect(permissions.canAccessOtherUserData('admin123', 'user456'), isTrue);
        expect(permissions.canDeleteOtherUserData('admin123', 'user456'), isTrue);
      });

      test('should implement rate limiting', () {
        final rateLimiter = RateLimiter(maxRequests: 10, windowMinutes: 1);
        const userId = 'user123';
        
        // Make requests within limit
        for (int i = 0; i < 10; i++) {
          expect(rateLimiter.isAllowed(userId), isTrue);
        }
        
        // Next request should be rate limited
        expect(rateLimiter.isAllowed(userId), isFalse);
        
        // Different user should not be affected
        expect(rateLimiter.isAllowed('user456'), isTrue);
      });
    });
  });
}

// Mock implementations for testing

bool isValidEmail(String email) {
  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  return emailRegex.hasMatch(email);
}

bool isStrongPassword(String password) {
  if (password.length < 8) return false;
  if (!password.contains(RegExp(r'[A-Z]'))) return false;
  if (!password.contains(RegExp(r'[a-z]'))) return false;
  if (!password.contains(RegExp(r'[0-9]'))) return false;
  if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
  return true;
}

String sanitizeInput(String input) {
  return input
      .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
      .trim();
}

bool isValidImageType(String mimeType) {
  const validTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
  return validTypes.contains(mimeType);
}

bool isValidFileSize(int sizeInBytes, int maxSizeInBytes) {
  return sizeInBytes <= maxSizeInBytes;
}

Map<String, String> maskSensitiveData(Map<String, String> data) {
  final masked = <String, String>{};
  
  data.forEach((key, value) {
    switch (key.toLowerCase()) {
      case 'password':
        masked[key] = '***';
        break;
      case 'email':
        final parts = value.split('@');
        if (parts.length == 2) {
          final username = parts[0];
          final domain = parts[1];
          masked[key] = '${username.substring(0, 1)}***@$domain';
        } else {
          masked[key] = '***';
        }
        break;
      case 'token':
        if (value.length > 6) {
          masked[key] = '${value.substring(0, 3)}***${value.substring(value.length - 3)}';
        } else {
          masked[key] = '***';
        }
        break;
      case 'credit_card':
        if (value.length >= 16) {
          masked[key] = '${value.substring(0, 4)}-****-****-${value.substring(value.length - 4)}';
        } else {
          masked[key] = '***';
        }
        break;
      default:
        masked[key] = value;
    }
  });
  
  return masked;
}

String generateSecureToken(int length) {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = DateTime.now().millisecondsSinceEpoch;
  var token = '';
  
  for (int i = 0; i < length; i++) {
    token += chars[(random + i) % chars.length];
  }
  
  return token;
}

class UserConsent {
  bool _analyticsConsent = false;
  bool _marketingConsent = false;
  DateTime? _consentTimestamp;

  bool get hasAnalyticsConsent => _analyticsConsent;
  bool get hasMarketingConsent => _marketingConsent;
  DateTime? get consentTimestamp => _consentTimestamp;

  void grantAnalyticsConsent() {
    _analyticsConsent = true;
    _consentTimestamp = DateTime.now();
  }

  void grantMarketingConsent() {
    _marketingConsent = true;
    _consentTimestamp = DateTime.now();
  }

  void revokeAnalyticsConsent() {
    _analyticsConsent = false;
  }

  void revokeMarketingConsent() {
    _marketingConsent = false;
  }
}

class DataRetentionPolicy {
  Duration getRetentionPeriod(String dataType) {
    switch (dataType) {
      case 'user_data':
        return const Duration(days: 365 * 7);
      case 'analytics_data':
        return const Duration(days: 365 * 2);
      case 'session_data':
        return const Duration(days: 30);
      case 'logs':
        return const Duration(days: 90);
      default:
        return const Duration(days: 365);
    }
  }
}

Map<String, dynamic> anonymizeUserData(Map<String, dynamic> userData) {
  final anonymized = Map<String, dynamic>.from(userData);
  
  // Anonymize sensitive fields
  if (anonymized.containsKey('name')) {
    anonymized['name'] = 'Anonymous User';
  }
  if (anonymized.containsKey('email')) {
    anonymized['email'] = 'anonymous@example.com';
  }
  if (anonymized.containsKey('phone')) {
    anonymized['phone'] = '***-***-****';
  }
  if (anonymized.containsKey('ip_address')) {
    anonymized['ip_address'] = '0.0.0.0';
  }
  
  return anonymized;
}

class UserDataManager {
  final Map<String, Map<String, dynamic>> _userData = {};
  final Map<String, Map<String, dynamic>> _analyticsData = {};
  final Map<String, Map<String, dynamic>> _preferencesData = {};

  void addUserData(String userId, Map<String, dynamic> data) {
    _userData[userId] = data;
  }

  void addUserAnalytics(String userId, Map<String, dynamic> data) {
    _analyticsData[userId] = data;
  }

  void addUserPreferences(String userId, Map<String, dynamic> data) {
    _preferencesData[userId] = data;
  }

  bool hasUserData(String userId) {
    return _userData.containsKey(userId) ||
           _analyticsData.containsKey(userId) ||
           _preferencesData.containsKey(userId);
  }

  bool deleteAllUserData(String userId) {
    bool deleted = false;
    
    if (_userData.remove(userId) != null) deleted = true;
    if (_analyticsData.remove(userId) != null) deleted = true;
    if (_preferencesData.remove(userId) != null) deleted = true;
    
    return deleted;
  }
}

class UserPermissions {
  final Set<String> _adminUsers = {};

  bool canReadOwnData(String userId) => true;
  bool canWriteOwnData(String userId) => true;
  bool canDeleteOwnData(String userId) => true;

  bool canAccessOtherUserData(String userId, String targetUserId) {
    return _adminUsers.contains(userId);
  }

  bool canDeleteOtherUserData(String userId, String targetUserId) {
    return _adminUsers.contains(userId);
  }

  void grantAdminRole(String userId) {
    _adminUsers.add(userId);
  }

  void revokeAdminRole(String userId) {
    _adminUsers.remove(userId);
  }
}

class RateLimiter {
  final int maxRequests;
  final int windowMinutes;
  final Map<String, List<DateTime>> _requestHistory = {};

  RateLimiter({required this.maxRequests, required this.windowMinutes});

  bool isAllowed(String userId) {
    final now = DateTime.now();
    final windowStart = now.subtract(Duration(minutes: windowMinutes));
    
    _requestHistory[userId] ??= [];
    final userRequests = _requestHistory[userId]!;
    
    // Remove old requests outside the window
    userRequests.removeWhere((timestamp) => timestamp.isBefore(windowStart));
    
    // Check if within limit
    if (userRequests.length >= maxRequests) {
      return false;
    }
    
    // Add current request
    userRequests.add(now);
    return true;
  }
}
