import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'preferences_service.g.dart';

/// Service for managing application preferences using SharedPreferences
/// Handles non-sensitive user preferences and app settings
@riverpod
PreferencesService preferencesService(PreferencesServiceRef ref) {
  return PreferencesService._();
}

class PreferencesService {
  PreferencesService._();

  /// Preference keys
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';
  static const String _selectedThemeKey = 'selected_theme';
  static const String _selectedLanguageKey = 'selected_language';

  /// Set onboarding completion status
  Future<void> setOnboardingComplete(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, value);
  }

  /// Get onboarding completion status
  Future<bool> getOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  /// Set whether user has seen onboarding
  Future<void> setHasSeenOnboarding(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenOnboardingKey, value);
  }

  /// Get whether user has seen onboarding
  Future<bool> getHasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenOnboardingKey) ?? false;
  }

  /// Set selected theme
  Future<void> setSelectedTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedThemeKey, theme);
  }

  /// Get selected theme
  Future<String?> getSelectedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedThemeKey);
  }

  /// Set theme mode (0: system, 1: light, 2: dark)
  Future<void> setThemeMode(int themeModeIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', themeModeIndex);
  }

  /// Get theme mode (0: system, 1: light, 2: dark)
  Future<int?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('theme_mode');
  }

  /// Set selected language
  Future<bool> setSelectedLanguage(String language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_selectedLanguageKey, language);
    } catch (error) {
      print('Error setting selected language: $error');
      return false;
    }
  }

  /// Get selected language
  Future<String?> getSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedLanguageKey);
  }

  /// Store custom boolean preference
  Future<void> setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  /// Get custom boolean preference
  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? defaultValue;
  }

  /// Store custom string preference
  Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  /// Get custom string preference
  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  /// Store custom integer preference
  Future<void> setInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  /// Get custom integer preference
  Future<int> getInt(String key, {int defaultValue = 0}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key) ?? defaultValue;
  }

  /// Remove specific preference
  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  /// Clear all preferences
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // App settings keys
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _darkModeKey = 'dark_mode';
  static const String _firstTimeUserKey = 'first_time_user';
  static const String _autoSyncKey = 'auto_sync';
  static const String _offlineModeKey = 'offline_mode';
  static const String _analyticsEnabledKey = 'analytics_enabled';
  static const String _crashReportingKey = 'crash_reporting';
  static const String _appVersionKey = 'app_version';
  static const String _lastSyncTimeKey = 'last_sync_time';
  static const String _privacyPolicyAcceptedKey = 'privacy_policy_accepted';
  static const String _termsAcceptedKey = 'terms_accepted';

  // App settings methods
  /// Set notifications enabled preference
  Future<bool> setNotificationsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_notificationsEnabledKey, enabled);
    } catch (error) {
      print('Error setting notifications enabled: $error');
      return false;
    }
  }

  /// Get notifications enabled preference
  Future<bool> getNotificationsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_notificationsEnabledKey) ?? true; // Default enabled
    } catch (error) {
      print('Error getting notifications enabled: $error');
      return true;
    }
  }

  /// Set dark mode preference
  Future<bool> setDarkMode(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_darkModeKey, enabled);
    } catch (error) {
      print('Error setting dark mode: $error');
      return false;
    }
  }

  /// Get dark mode preference
  Future<bool> getDarkMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_darkModeKey) ?? false; // Default light mode
    } catch (error) {
      print('Error getting dark mode: $error');
      return false;
    }
  }

  /// Set first time user flag
  Future<bool> setFirstTimeUser(bool isFirstTime) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_firstTimeUserKey, isFirstTime);
    } catch (error) {
      print('Error setting first time user: $error');
      return false;
    }
  }

  /// Get first time user flag
  Future<bool> isFirstTimeUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_firstTimeUserKey) ?? true; // Default first time
    } catch (error) {
      print('Error getting first time user: $error');
      return true;
    }
  }

  /// Set auto sync enabled preference
  Future<bool> setAutoSyncEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_autoSyncKey, enabled);
    } catch (error) {
      print('Error setting auto sync: $error');
      return false;
    }
  }

  /// Get auto sync enabled preference
  Future<bool> getAutoSyncEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_autoSyncKey) ?? true; // Default enabled
    } catch (error) {
      print('Error getting auto sync: $error');
      return true;
    }
  }

  /// Set offline mode enabled preference
  Future<bool> setOfflineModeEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_offlineModeKey, enabled);
    } catch (error) {
      print('Error setting offline mode: $error');
      return false;
    }
  }

  /// Get offline mode enabled preference
  Future<bool> getOfflineModeEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_offlineModeKey) ?? false; // Default disabled
    } catch (error) {
      print('Error getting offline mode: $error');
      return false;
    }
  }

  /// Set analytics enabled preference
  Future<bool> setAnalyticsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_analyticsEnabledKey, enabled);
    } catch (error) {
      print('Error setting analytics enabled: $error');
      return false;
    }
  }

  /// Get analytics enabled preference
  Future<bool> getAnalyticsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_analyticsEnabledKey) ?? true; // Default enabled
    } catch (error) {
      print('Error getting analytics enabled: $error');
      return true;
    }
  }

  /// Set crash reporting enabled preference
  Future<bool> setCrashReportingEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_crashReportingKey, enabled);
    } catch (error) {
      print('Error setting crash reporting: $error');
      return false;
    }
  }

  /// Get crash reporting enabled preference
  Future<bool> getCrashReportingEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_crashReportingKey) ?? true; // Default enabled
    } catch (error) {
      print('Error getting crash reporting: $error');
      return true;
    }
  }

  /// Set app version
  Future<bool> setAppVersion(String version) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_appVersionKey, version);
    } catch (error) {
      print('Error setting app version: $error');
      return false;
    }
  }

  /// Get app version
  Future<String?> getAppVersion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_appVersionKey);
    } catch (error) {
      print('Error getting app version: $error');
      return null;
    }
  }

  /// Set last sync time
  Future<bool> setLastSyncTime(DateTime dateTime) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_lastSyncTimeKey, dateTime.toIso8601String());
    } catch (error) {
      print('Error setting last sync time: $error');
      return false;
    }
  }

  /// Get last sync time
  Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeString = prefs.getString(_lastSyncTimeKey);
      return timeString != null ? DateTime.tryParse(timeString) : null;
    } catch (error) {
      print('Error getting last sync time: $error');
      return null;
    }
  }

  /// Set privacy policy accepted
  Future<bool> setPrivacyPolicyAccepted(bool accepted) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_privacyPolicyAcceptedKey, accepted);
    } catch (error) {
      print('Error setting privacy policy accepted: $error');
      return false;
    }
  }

  /// Get privacy policy accepted
  Future<bool> getPrivacyPolicyAccepted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_privacyPolicyAcceptedKey) ?? false; // Default not accepted
    } catch (error) {
      print('Error getting privacy policy accepted: $error');
      return false;
    }
  }

  /// Set terms accepted
  Future<bool> setTermsAccepted(bool accepted) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_termsAcceptedKey, accepted);
    } catch (error) {
      print('Error setting terms accepted: $error');
      return false;
    }
  }

  /// Get terms accepted
  Future<bool> getTermsAccepted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_termsAcceptedKey) ?? false; // Default not accepted
    } catch (error) {
      print('Error getting terms accepted: $error');
      return false;
    }
  }

  // Settings bundle methods
  /// Get all app settings
  Future<Map<String, dynamic>> getAllSettings() async {
    try {
      return {
        'notifications_enabled': await getNotificationsEnabled(),
        'dark_mode': await getDarkMode(),
        'first_time_user': await isFirstTimeUser(),
        'auto_sync': await getAutoSyncEnabled(),
        'offline_mode': await getOfflineModeEnabled(),
        'analytics_enabled': await getAnalyticsEnabled(),
        'crash_reporting': await getCrashReportingEnabled(),
        'app_version': await getAppVersion(),
        'last_sync_time': await getLastSyncTime(),
        'privacy_policy_accepted': await getPrivacyPolicyAccepted(),
        'terms_accepted': await getTermsAccepted(),
        'selected_language': await getSelectedLanguage(),
        'theme_mode': await getThemeMode(),
      };
    } catch (error) {
      print('Error getting all settings: $error');
      return {};
    }
  }

  /// Reset all settings to defaults
  Future<bool> resetToDefaults() async {
    try {
      final results = await Future.wait([
        setNotificationsEnabled(true),
        setDarkMode(false),
        setFirstTimeUser(true),
        setAutoSyncEnabled(true),
        setOfflineModeEnabled(false),
        setAnalyticsEnabled(true),
        setCrashReportingEnabled(true),
        setPrivacyPolicyAccepted(false),
        setTermsAccepted(false),
      ]);
      
      return results.every((result) => result);
    } catch (error) {
      print('Error resetting to defaults: $error');
      return false;
    }
  }

  /// Export settings for backup
  Future<Map<String, dynamic>> exportSettings() async {
    try {
      final allSettings = await getAllSettings();
      return {
        'version': '1.0',
        'exported_at': DateTime.now().toIso8601String(),
        'settings': allSettings,
      };
    } catch (error) {
      print('Error exporting settings: $error');
      return {};
    }
  }

  /// Import settings from backup
  Future<bool> importSettings(Map<String, dynamic> backup) async {
    try {
      final settings = backup['settings'] as Map<String, dynamic>?;
      if (settings == null) return false;
      
      final results = <Future<bool>>[];
      
      if (settings['notifications_enabled'] != null) {
        results.add(setNotificationsEnabled(settings['notifications_enabled'] as bool));
      }
      if (settings['dark_mode'] != null) {
        results.add(setDarkMode(settings['dark_mode'] as bool));
      }
      if (settings['auto_sync'] != null) {
        results.add(setAutoSyncEnabled(settings['auto_sync'] as bool));
      }
      if (settings['offline_mode'] != null) {
        results.add(setOfflineModeEnabled(settings['offline_mode'] as bool));
      }
      if (settings['analytics_enabled'] != null) {
        results.add(setAnalyticsEnabled(settings['analytics_enabled'] as bool));
      }
      if (settings['crash_reporting'] != null) {
        results.add(setCrashReportingEnabled(settings['crash_reporting'] as bool));
      }
      if (settings['privacy_policy_accepted'] != null) {
        results.add(setPrivacyPolicyAccepted(settings['privacy_policy_accepted'] as bool));
      }
      if (settings['terms_accepted'] != null) {
        results.add(setTermsAccepted(settings['terms_accepted'] as bool));
      }
      if (settings['selected_language'] != null) {
        results.add(setSelectedLanguage(settings['selected_language'] as String));
      }
      
      final allResults = await Future.wait(results);
      return allResults.every((result) => result);
    } catch (error) {
      print('Error importing settings: $error');
      return false;
    }
  }
}
