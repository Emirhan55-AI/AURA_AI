import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../lib/src/core/privacy/privacy_service.dart';

void main() {
  group('Privacy Service Unit Tests', () {
    late PrivacyService privacyService;

    setUp(() async {
      // Initialize shared preferences
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      privacyService = PrivacyService(prefs);
    });

    group('Consent Management', () {
      test('should save and retrieve consent correctly', () async {
        final consent = PrivacyConsent(
          acceptedAnalytics: true,
          acceptedMarketing: false,
          acceptedPersonalization: true,
          timestamp: DateTime.now(),
        );

        await privacyService.saveConsent(consent);
        final retrieved = await privacyService.getConsent();

        expect(retrieved, isNotNull);
        expect(retrieved!.acceptedAnalytics, true);
        expect(retrieved.acceptedMarketing, false);
        expect(retrieved.acceptedPersonalization, true);
      });

      test('should update existing consent', () async {
        // Save initial consent
        final initialConsent = PrivacyConsent(
          acceptedAnalytics: false,
          acceptedMarketing: false,
          acceptedPersonalization: false,
          timestamp: DateTime.now(),
        );
        await privacyService.saveConsent(initialConsent);

        // Update consent
        final updatedConsent = PrivacyConsent(
          acceptedAnalytics: true,
          acceptedMarketing: true,
          acceptedPersonalization: true,
          timestamp: DateTime.now(),
        );
        await privacyService.saveConsent(updatedConsent);

        final retrieved = await privacyService.getConsent();
        expect(retrieved!.acceptedAnalytics, true);
        expect(retrieved.acceptedMarketing, true);
        expect(retrieved.acceptedPersonalization, true);
      });

      test('should validate consent correctly', () async {
        final validConsent = PrivacyConsent(
          acceptedAnalytics: true,
          acceptedMarketing: false,
          acceptedPersonalization: true,
          timestamp: DateTime.now(),
        );

        final isValid = await privacyService.isConsentValid(validConsent);
        expect(isValid, true);

        // Test expired consent
        final expiredConsent = PrivacyConsent(
          acceptedAnalytics: true,
          acceptedMarketing: false,
          acceptedPersonalization: true,
          timestamp: DateTime.now().subtract(const Duration(days: 400)), // Expired
        );

        final isExpired = await privacyService.isConsentValid(expiredConsent);
        expect(isExpired, false);
      });
    });

    group('Data Export', () {
      test('should prepare data for export', () async {
        const userId = 'test_user_123';
        
        final exportData = await privacyService.exportUserData(userId);
        
        expect(exportData, isNotNull);
        expect(exportData.containsKey('user'), true);
        expect(exportData.containsKey('wardrobe'), true);
        expect(exportData.containsKey('analytics'), true);
        expect(exportData.containsKey('export_info'), true);
        
        final exportInfo = exportData['export_info'] as Map<String, dynamic>;
        expect(exportInfo['user_id'], userId);
        expect(exportInfo['export_date'], isNotNull);
      });

      test('should export to JSON format', () async {
        const userId = 'test_user_123';
        
        final jsonResult = await privacyService.exportToFormat(userId, 'json');
        
        expect(jsonResult, isNotNull);
        expect(jsonResult.containsKey('success'), true);
        expect(jsonResult['success'], true);
        expect(jsonResult.containsKey('data'), true);
      });
    });

    group('Data Deletion', () {
      test('should delete user data successfully', () async {
        const userId = 'test_user_123';
        
        final result = await privacyService.deleteUserData(userId);
        
        expect(result, true);
      });

      test('should anonymize user data', () async {
        const userId = 'test_user_123';
        
        final result = await privacyService.anonymizeUserData(userId);
        
        expect(result, true);
      });
    });

    group('Data Correction', () {
      test('should handle data correction requests', () async {
        const userId = 'test_user_123';
        final corrections = {
          'name': 'Updated Name',
          'email': 'updated@example.com',
        };
        
        final result = await privacyService.correctUserData(userId, corrections);
        
        expect(result, true);
      });
    });

    group('Privacy Policy', () {
      test('should return current privacy policy version', () async {
        final version = await privacyService.getCurrentPrivacyPolicyVersion();
        
        expect(version, isNotNull);
        expect(version, isA<String>());
      });

      test('should return privacy policy content', () async {
        final content = await privacyService.getPrivacyPolicyContent();
        
        expect(content, isNotNull);
        expect(content, isA<String>());
        expect(content.isNotEmpty, true);
      });
    });

    group('Privacy Controller', () {
      test('should manage privacy state correctly', () async {
        final container = ProviderContainer();
        
        // Test initial state
        final controller = container.read(privacyControllerProvider.notifier);
        final initialState = container.read(privacyControllerProvider);
        
        expect(initialState, isNotNull);
        expect(initialState.isLoading, false);
        expect(initialState.error, isNull);
        
        container.dispose();
      });
    });
  });
}
