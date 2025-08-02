// Privacy Compliance Service
// Implements GDPR and privacy regulations compliance
// Provides data export, deletion, and consent management

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Privacy Service Provider
final privacyServiceProvider = Provider<PrivacyService>((ref) {
  return PrivacyService();
});

// Privacy Consent Model
class PrivacyConsent {
  final bool analytics;
  final bool marketing;
  final bool functional;
  final bool necessary;
  final DateTime consentDate;
  final String version;

  const PrivacyConsent({
    required this.analytics,
    required this.marketing,
    required this.functional,
    required this.necessary,
    required this.consentDate,
    required this.version,
  });

  factory PrivacyConsent.fromJson(Map<String, dynamic> json) {
    return PrivacyConsent(
      analytics: json['analytics'] as bool,
      marketing: json['marketing'] as bool,
      functional: json['functional'] as bool,
      necessary: json['necessary'] as bool,
      consentDate: DateTime.parse(json['consentDate'] as String),
      version: json['version'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'analytics': analytics,
      'marketing': marketing,
      'functional': functional,
      'necessary': necessary,
      'consentDate': consentDate.toIso8601String(),
      'version': version,
    };
  }

  PrivacyConsent copyWith({
    bool? analytics,
    bool? marketing,
    bool? functional,
    bool? necessary,
    DateTime? consentDate,
    String? version,
  }) {
    return PrivacyConsent(
      analytics: analytics ?? this.analytics,
      marketing: marketing ?? this.marketing,
      functional: functional ?? this.functional,
      necessary: necessary ?? this.necessary,
      consentDate: consentDate ?? this.consentDate,
      version: version ?? this.version,
    );
  }
}

// Data Export Options
enum ExportFormat { json, csv, pdf }

class DataExportRequest {
  final String userId;
  final ExportFormat format;
  final List<String> dataTypes;
  final DateTime requestDate;

  const DataExportRequest({
    required this.userId,
    required this.format,
    required this.dataTypes,
    required this.requestDate,
  });
}

// Privacy Service Implementation
class PrivacyService {
  static const String _consentKey = 'privacy_consent';
  static const String _currentVersion = '1.0.0';

  // Consent Management
  Future<PrivacyConsent?> getConsent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final consentJson = prefs.getString(_consentKey);
      
      if (consentJson != null) {
        final consentMap = jsonDecode(consentJson) as Map<String, dynamic>;
        return PrivacyConsent.fromJson(consentMap);
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting consent: $e');
      return null;
    }
  }

  Future<void> saveConsent(PrivacyConsent consent) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final consentJson = jsonEncode(consent.toJson());
      await prefs.setString(_consentKey, consentJson);
    } catch (e) {
      debugPrint('Error saving consent: $e');
      throw Exception('Failed to save privacy consent');
    }
  }

  Future<void> updateConsent({
    bool? analytics,
    bool? marketing,
    bool? functional,
  }) async {
    final currentConsent = await getConsent();
    
    if (currentConsent != null) {
      final updatedConsent = currentConsent.copyWith(
        analytics: analytics,
        marketing: marketing,
        functional: functional,
        consentDate: DateTime.now(),
        version: _currentVersion,
      );
      
      await saveConsent(updatedConsent);
    }
  }

  bool isConsentRequired() {
    // Check if consent is required based on user location or app settings
    return true; // For compliance, always require consent
  }

  Future<bool> hasValidConsent() async {
    final consent = await getConsent();
    if (consent == null) return false;
    
    // Check if consent is for current version
    if (consent.version != _currentVersion) return false;
    
    // Check if consent is not too old (e.g., older than 1 year)
    final oneYearAgo = DateTime.now().subtract(const Duration(days: 365));
    if (consent.consentDate.isBefore(oneYearAgo)) return false;
    
    return true;
  }

  // Data Export Functionality
  Future<Map<String, dynamic>> exportUserData(String userId) async {
    try {
      // Simulate data gathering from various sources
      final userData = await _getUserPersonalData(userId);
      final wardrobeData = await _getWardrobeData(userId);
      final preferencesData = await _getPreferencesData(userId);
      final analyticsData = await _getAnalyticsData(userId);
      
      return {
        'user_id': userId,
        'export_date': DateTime.now().toIso8601String(),
        'export_version': _currentVersion,
        'personal_data': userData,
        'wardrobe_data': wardrobeData,
        'preferences': preferencesData,
        'analytics_data': analyticsData,
        'privacy_consent': (await getConsent())?.toJson(),
      };
    } catch (e) {
      debugPrint('Error exporting user data: $e');
      rethrow;
    }
  }

  Future<File> exportToFile(DataExportRequest request) async {
    final data = await exportUserData(request.userId);
    final directory = await getApplicationDocumentsDirectory();
    
    switch (request.format) {
      case ExportFormat.json:
        return _exportToJson(data, directory, request.userId);
      case ExportFormat.csv:
        return _exportToCsv(data, directory, request.userId);
      case ExportFormat.pdf:
        return _exportToPdf(data, directory, request.userId);
    }
  }

  // Data Deletion
  Future<void> deleteUserData(String userId) async {
    try {
      // Delete from all data sources
      await _deleteFromUserRepository(userId);
      await _deleteFromWardrobeRepository(userId);
      await _deleteFromAnalytics(userId);
      await _deleteLocalData(userId);
      
      // Clear consent
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_consentKey);
      
      debugPrint('User data deleted successfully for user: $userId');
    } catch (e) {
      debugPrint('Error deleting user data: $e');
      throw Exception('Failed to delete user data');
    }
  }

  Future<void> anonymizeUserData(String userId) async {
    // Convert personal data to anonymized form
    // Keep statistical data but remove personal identifiers
    try {
      await _anonymizePersonalData(userId);
      await _anonymizeWardrobeData(userId);
      
      debugPrint('User data anonymized successfully for user: $userId');
    } catch (e) {
      debugPrint('Error anonymizing user data: $e');
      throw Exception('Failed to anonymize user data');
    }
  }

  // Right to Rectification
  Future<void> correctUserData(String userId, Map<String, dynamic> corrections) async {
    try {
      // Apply corrections to user data
      for (final entry in corrections.entries) {
        await _correctDataField(userId, entry.key, entry.value);
      }
      
      debugPrint('User data corrected successfully for user: $userId');
    } catch (e) {
      debugPrint('Error correcting user data: $e');
      throw Exception('Failed to correct user data');
    }
  }

  // Data Portability
  Future<String> generatePortableData(String userId) async {
    final data = await exportUserData(userId);
    
    // Create portable format (JSON)
    return jsonEncode({
      'format': 'aura_portable_data_v1',
      'exported_at': DateTime.now().toIso8601String(),
      'data': data,
    });
  }

  // Privacy Policy and Terms
  String getCurrentPrivacyPolicyVersion() => _currentVersion;
  
  Future<String> getPrivacyPolicyText() async {
    // In a real app, this would fetch from a service or local assets
    return '''
AURA Privacy Policy
Version $_currentVersion

This privacy policy describes how Aura collects, uses, and protects your personal information.

1. DATA COLLECTION
We collect information you provide directly to us and information about your use of our services.

2. DATA USE
We use your information to provide, maintain, and improve our services.

3. DATA SHARING
We do not sell or rent your personal information to third parties.

4. YOUR RIGHTS
You have the right to access, correct, delete, or export your personal data.

5. CONTACT
For privacy concerns, contact us at privacy@aura-app.com
    ''';
  }

  // Private helper methods
  Future<Map<String, dynamic>> _getUserPersonalData(String userId) async {
    // Simulate fetching user personal data
    return {
      'id': userId,
      'email': 'user@example.com', // Placeholder
      'name': 'John Doe', // Placeholder
      'created_at': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      'last_login': DateTime.now().toIso8601String(),
    };
  }

  Future<List<Map<String, dynamic>>> _getWardrobeData(String userId) async {
    // Simulate fetching wardrobe data
    return [
      {
        'id': '1',
        'name': 'Blue Shirt',
        'category': 'Tops',
        'color': 'Blue',
        'created_at': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
      },
      {
        'id': '2',
        'name': 'Black Jeans',
        'category': 'Bottoms',
        'color': 'Black',
        'created_at': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      },
    ];
  }

  Future<Map<String, dynamic>> _getPreferencesData(String userId) async {
    return {
      'theme': 'system',
      'language': 'en',
      'notifications_enabled': true,
    };
  }

  Future<Map<String, dynamic>> _getAnalyticsData(String userId) async {
    return {
      'total_logins': 25,
      'items_added': 15,
      'outfits_created': 8,
      'last_activity': DateTime.now().toIso8601String(),
    };
  }

  Future<File> _exportToJson(Map<String, dynamic> data, Directory directory, String userId) async {
    final file = File('${directory.path}/aura_data_export_$userId.json');
    await file.writeAsString(jsonEncode(data));
    return file;
  }

  Future<File> _exportToCsv(Map<String, dynamic> data, Directory directory, String userId) async {
    // Simple CSV export (in a real app, use a proper CSV library)
    final file = File('${directory.path}/aura_data_export_$userId.csv');
    final csvContent = _convertToCSV(data);
    await file.writeAsString(csvContent);
    return file;
  }

  Future<File> _exportToPdf(Map<String, dynamic> data, Directory directory, String userId) async {
    // PDF export would require pdf package
    // For now, just create a text file
    final file = File('${directory.path}/aura_data_export_$userId.txt');
    await file.writeAsString('PDF export not implemented yet. Data: ${jsonEncode(data)}');
    return file;
  }

  String _convertToCSV(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    buffer.writeln('Field,Value');
    
    void writeMapToCSV(Map<String, dynamic> map, String prefix) {
      for (final entry in map.entries) {
        final key = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';
        if (entry.value is Map) {
          writeMapToCSV(entry.value as Map<String, dynamic>, key);
        } else if (entry.value is List) {
          buffer.writeln('$key,"${entry.value.join(', ')}"');
        } else {
          buffer.writeln('$key,"${entry.value}"');
        }
      }
    }
    
    writeMapToCSV(data, '');
    return buffer.toString();
  }

  Future<void> _deleteFromUserRepository(String userId) async {
    // Simulate deletion from user repository
    debugPrint('Deleting user data from user repository: $userId');
  }

  Future<void> _deleteFromWardrobeRepository(String userId) async {
    // Simulate deletion from wardrobe repository
    debugPrint('Deleting wardrobe data for user: $userId');
  }

  Future<void> _deleteFromAnalytics(String userId) async {
    // Simulate deletion from analytics
    debugPrint('Deleting analytics data for user: $userId');
  }

  Future<void> _deleteLocalData(String userId) async {
    // Delete local data
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.contains(userId)) {
        await prefs.remove(key);
      }
    }
  }

  Future<void> _anonymizePersonalData(String userId) async {
    // Simulate anonymization
    debugPrint('Anonymizing personal data for user: $userId');
  }

  Future<void> _anonymizeWardrobeData(String userId) async {
    // Simulate anonymization
    debugPrint('Anonymizing wardrobe data for user: $userId');
  }

  Future<void> _correctDataField(String userId, String field, dynamic value) async {
    // Simulate data correction
    debugPrint('Correcting field $field for user $userId: $value');
  }
}

// Privacy Controller for UI
final privacyControllerProvider = StateNotifierProvider<PrivacyController, PrivacyState>((ref) {
  final privacyService = ref.read(privacyServiceProvider);
  return PrivacyController(privacyService);
});

class PrivacyState {
  final PrivacyConsent? consent;
  final bool isLoading;
  final String? error;
  final bool isExporting;
  final File? exportedFile;

  const PrivacyState({
    this.consent,
    this.isLoading = false,
    this.error,
    this.isExporting = false,
    this.exportedFile,
  });

  PrivacyState copyWith({
    PrivacyConsent? consent,
    bool? isLoading,
    String? error,
    bool? isExporting,
    File? exportedFile,
  }) {
    return PrivacyState(
      consent: consent ?? this.consent,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isExporting: isExporting ?? this.isExporting,
      exportedFile: exportedFile ?? this.exportedFile,
    );
  }
}

class PrivacyController extends StateNotifier<PrivacyState> {
  final PrivacyService _privacyService;

  PrivacyController(this._privacyService) : super(const PrivacyState());

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final consent = await _privacyService.getConsent();
      state = state.copyWith(consent: consent, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updateConsent({
    bool? analytics,
    bool? marketing,
    bool? functional,
  }) async {
    state = state.copyWith(isLoading: true);
    
    try {
      await _privacyService.updateConsent(
        analytics: analytics,
        marketing: marketing,
        functional: functional,
      );
      
      final updatedConsent = await _privacyService.getConsent();
      state = state.copyWith(consent: updatedConsent, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> giveInitialConsent(PrivacyConsent consent) async {
    state = state.copyWith(isLoading: true);
    
    try {
      await _privacyService.saveConsent(consent);
      state = state.copyWith(consent: consent, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> exportData(String userId, ExportFormat format) async {
    state = state.copyWith(isExporting: true);
    
    try {
      final request = DataExportRequest(
        userId: userId,
        format: format,
        dataTypes: ['personal', 'wardrobe', 'preferences', 'analytics'],
        requestDate: DateTime.now(),
      );
      
      final file = await _privacyService.exportToFile(request);
      state = state.copyWith(exportedFile: file, isExporting: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isExporting: false);
    }
  }

  Future<void> deleteAllData(String userId) async {
    state = state.copyWith(isLoading: true);
    
    try {
      await _privacyService.deleteUserData(userId);
      state = state.copyWith(consent: null, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
