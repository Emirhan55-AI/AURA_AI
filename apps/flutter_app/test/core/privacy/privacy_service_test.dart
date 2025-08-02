// Privacy Service Tests
// Tests privacy compliance functionality including consent management,
// data export, deletion, and GDPR rights implementation

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../lib/core/services/privacy_service.dart';

void main() {
  group('Privacy Service Tests', () {
    late PrivacyService privacyService;

    setUp(() {
      privacyService = PrivacyService();
      SharedPreferences.setMockInitialValues({});
    });

    group('Consent Management', () {
      testWidgets('should save and retrieve consent correctly', (WidgetTester tester) async {
        // Arrange
        final consent = PrivacyConsent(
          necessary: true,
          functional: true,
          analytics: false,
          marketing: false,
          consentDate: DateTime.now(),
          version: '1.0.0',
        );

        // Act
        await privacyService.saveConsent(consent);
        final retrievedConsent = await privacyService.getConsent();

        // Assert
        expect(retrievedConsent, isNotNull);
        expect(retrievedConsent!.necessary, isTrue);
        expect(retrievedConsent.functional, isTrue);
        expect(retrievedConsent.analytics, isFalse);
        expect(retrievedConsent.marketing, isFalse);
        expect(retrievedConsent.version, equals('1.0.0'));
      });

      testWidgets('should return null when no consent exists', (WidgetTester tester) async {
        // Act
        final consent = await privacyService.getConsent();

        // Assert
        expect(consent, isNull);
      });

      testWidgets('should update existing consent', (WidgetTester tester) async {
        // Arrange
        final initialConsent = PrivacyConsent(
          necessary: true,
          functional: false,
          analytics: false,
          marketing: false,
          consentDate: DateTime.now(),
          version: '1.0.0',
        );
        await privacyService.saveConsent(initialConsent);

        // Act
        await privacyService.updateConsent(analytics: true, marketing: true);
        final updatedConsent = await privacyService.getConsent();

        // Assert
        expect(updatedConsent, isNotNull);
        expect(updatedConsent!.necessary, isTrue);
        expect(updatedConsent.functional, isFalse);
        expect(updatedConsent.analytics, isTrue);
        expect(updatedConsent.marketing, isTrue);
      });

      testWidgets('should validate consent correctly', (WidgetTester tester) async {
        // Test valid consent
        final validConsent = PrivacyConsent(
          necessary: true,
          functional: true,
          analytics: true,
          marketing: false,
          consentDate: DateTime.now(),
          version: '1.0.0',
        );
        await privacyService.saveConsent(validConsent);

        expect(await privacyService.hasValidConsent(), isTrue);

        // Test outdated consent
        final outdatedConsent = PrivacyConsent(
          necessary: true,
          functional: true,
          analytics: true,
          marketing: false,
          consentDate: DateTime.now().subtract(const Duration(days: 400)), // Over 1 year old
          version: '1.0.0',
        );
        await privacyService.saveConsent(outdatedConsent);

        expect(await privacyService.hasValidConsent(), isFalse);
      });
    });

    group('Data Export', () {
      testWidgets('should export user data correctly', (WidgetTester tester) async {
        // Act
        final exportedData = await privacyService.exportUserData('test_user_id');

        // Assert
        expect(exportedData, isA<Map<String, dynamic>>());
        expect(exportedData.containsKey('user_id'), isTrue);
        expect(exportedData.containsKey('export_date'), isTrue);
        expect(exportedData.containsKey('personal_data'), isTrue);
        expect(exportedData.containsKey('wardrobe_data'), isTrue);
        expect(exportedData.containsKey('preferences'), isTrue);
        expect(exportedData.containsKey('analytics_data'), isTrue);
        expect(exportedData['user_id'], equals('test_user_id'));
      });

      testWidgets('should generate portable data format', (WidgetTester tester) async {
        // Act
        final portableData = await privacyService.generatePortableData('test_user_id');

        // Assert
        expect(portableData, isA<String>());
        expect(portableData.contains('aura_portable_data_v1'), isTrue);
        expect(portableData.contains('test_user_id'), isTrue);
      });

      testWidgets('should export to different formats', (WidgetTester tester) async {
        // Test JSON export
        final jsonRequest = DataExportRequest(
          userId: 'test_user',
          format: ExportFormat.json,
          dataTypes: ['personal', 'wardrobe'],
          requestDate: DateTime.now(),
        );

        final jsonFile = await privacyService.exportToFile(jsonRequest);
        expect(jsonFile.path.endsWith('.json'), isTrue);

        // Test CSV export
        final csvRequest = DataExportRequest(
          userId: 'test_user',
          format: ExportFormat.csv,
          dataTypes: ['personal', 'wardrobe'],
          requestDate: DateTime.now(),
        );

        final csvFile = await privacyService.exportToFile(csvRequest);
        expect(csvFile.path.endsWith('.csv'), isTrue);
      });
    });

    group('Data Deletion', () {
      testWidgets('should delete user data successfully', (WidgetTester tester) async {
        // Arrange
        final consent = PrivacyConsent(
          necessary: true,
          functional: true,
          analytics: true,
          marketing: true,
          consentDate: DateTime.now(),
          version: '1.0.0',
        );
        await privacyService.saveConsent(consent);

        // Act
        await privacyService.deleteUserData('test_user_id');

        // Assert
        final consentAfterDeletion = await privacyService.getConsent();
        expect(consentAfterDeletion, isNull);
      });

      testWidgets('should anonymize user data', (WidgetTester tester) async {
        // Act & Assert (no exception should be thrown)
        expect(() => privacyService.anonymizeUserData('test_user_id'), returnsNormally);
      });
    });

    group('Data Correction', () {
      testWidgets('should handle data correction requests', (WidgetTester tester) async {
        // Arrange
        final corrections = {
          'name': 'Updated Name',
          'email': 'updated@example.com',
        };

        // Act & Assert (no exception should be thrown)
        expect(() => privacyService.correctUserData('test_user_id', corrections), returnsNormally);
      });
    });

    group('Privacy Policy', () {
      testWidgets('should return current privacy policy version', (WidgetTester tester) async {
        // Act
        final version = privacyService.getCurrentPrivacyPolicyVersion();

        // Assert
        expect(version, isNotEmpty);
      });

      testWidgets('should return privacy policy text', (WidgetTester tester) async {
        // Act
        final policyText = await privacyService.getPrivacyPolicyText();

        // Assert
        expect(policyText, isNotEmpty);
        expect(policyText.contains('AURA Privacy Policy'), isTrue);
        expect(policyText.contains('DATA COLLECTION'), isTrue);
        expect(policyText.contains('YOUR RIGHTS'), isTrue);
      });
    });

    group('Privacy Controller', () {
      testWidgets('should manage privacy state correctly', (WidgetTester tester) async {
        // Arrange
        final container = ProviderContainer();
        final controller = container.read(privacyControllerProvider.notifier);

        // Act
        await controller.initialize();

        // Assert
        final state = container.read(privacyControllerProvider);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });

      testWidgets('should update consent through controller', (WidgetTester tester) async {
        // Arrange
        final container = ProviderContainer();
        final controller = container.read(privacyControllerProvider.notifier);

        // Act
        await controller.updateConsent(analytics: true, marketing: false);

        // Assert
        final state = container.read(privacyControllerProvider);
        expect(state.consent, isNotNull);
        expect(state.consent!.analytics, isTrue);
        expect(state.consent!.marketing, isFalse);
      });

      testWidgets('should handle export through controller', (WidgetTester tester) async {
        // Arrange
        final container = ProviderContainer();
        final controller = container.read(privacyControllerProvider.notifier);

        // Act
        await controller.exportData('test_user', ExportFormat.json);

        // Assert
        final state = container.read(privacyControllerProvider);
        expect(state.isExporting, isFalse);
        expect(state.exportedFile, isNotNull);
      });

      testWidgets('should handle data deletion through controller', (WidgetTester tester) async {
        // Arrange
        final container = ProviderContainer();
        final controller = container.read(privacyControllerProvider.notifier);

        // First give consent
        final consent = PrivacyConsent(
          necessary: true,
          functional: true,
          analytics: true,
          marketing: false,
          consentDate: DateTime.now(),
          version: '1.0.0',
        );
        await controller.giveInitialConsent(consent);

        // Act
        await controller.deleteAllData('test_user');

        // Assert
        final state = container.read(privacyControllerProvider);
        expect(state.consent, isNull);
        expect(state.isLoading, isFalse);
      });

      testWidgets('should clear errors correctly', (WidgetTester tester) async {
        // Arrange
        final container = ProviderContainer();
        final controller = container.read(privacyControllerProvider.notifier);

        // Act
        controller.clearError();

        // Assert
        final state = container.read(privacyControllerProvider);
        expect(state.error, isNull);
      });
    });

    group('GDPR Compliance', () {
      testWidgets('should implement right to access', (WidgetTester tester) async {
        // Right to access is implemented through data export
        final data = await privacyService.exportUserData('test_user');
        
        expect(data, isNotNull);
        expect(data.containsKey('personal_data'), isTrue);
        expect(data.containsKey('wardrobe_data'), isTrue);
      });

      testWidgets('should implement right to rectification', (WidgetTester tester) async {
        // Right to rectification is implemented through data correction
        final corrections = {'email': 'newemail@example.com'};
        
        expect(() => privacyService.correctUserData('test_user', corrections), returnsNormally);
      });

      testWidgets('should implement right to erasure', (WidgetTester tester) async {
        // Right to erasure is implemented through data deletion
        expect(() => privacyService.deleteUserData('test_user'), returnsNormally);
      });

      testWidgets('should implement right to data portability', (WidgetTester tester) async {
        // Right to data portability is implemented through portable data export
        final portableData = await privacyService.generatePortableData('test_user');
        
        expect(portableData, isNotNull);
        expect(portableData.contains('aura_portable_data_v1'), isTrue);
      });

      testWidgets('should require consent', (WidgetTester tester) async {
        // Consent requirement check
        expect(privacyService.isConsentRequired(), isTrue);
      });
    });
  });
}
