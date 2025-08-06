import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../domain/entities/settings.dart';
import '../../data/repositories/supabase_profile_repository.dart';

part 'settings_controller.g.dart';

/// Settings Controller that manages user preferences with real backend integration
@riverpod
class SettingsController extends _$SettingsController {
  SupabaseProfileRepository get _profileRepository => SupabaseProfileRepository();

  @override
  Future<Settings> build() async {
    // Load settings from both local storage and backend
    return await _loadSettings();
  }

  /// Load settings from persistent storage and sync with backend
  Future<Settings> _loadSettings() async {
    try {
      final prefsService = ref.read(preferencesServiceProvider);
      
      // First, load from local storage for immediate response
      final localSettings = await _loadLocalSettings(prefsService);
      
      // Then try to sync with backend if user is authenticated
      try {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          final profileResult = await _profileRepository.getCurrentProfile();
          
          profileResult.fold(
            (failure) {
              // Fallback to local settings if backend fails
              // Could log this error for monitoring
            },
            (profile) async {
              // Sync backend settings with local settings
              final backendSettings = _extractSettingsFromProfile(profile, localSettings);
              
              // Save any new backend settings to local storage
              await _saveLocalSettings(prefsService, backendSettings);
              
              // Update in-memory state  
              state = AsyncValue.data(backendSettings);
            },
          );
        }
      } catch (e) {
        // Backend sync failed, use local settings
        // This ensures app works offline
      }
      
      return localSettings;
    } catch (e) {
      // Return default settings if loading fails
      return const Settings();
    }
  }

  /// Load settings from local SharedPreferences
  Future<Settings> _loadLocalSettings(PreferencesService prefsService) async {
    // Load all settings from SharedPreferences
    final pushNotifications = await prefsService.getBool('push_notifications', defaultValue: true);
    final emailNotifications = await prefsService.getBool('email_notifications', defaultValue: false);
    final inAppSounds = await prefsService.getBool('in_app_sounds', defaultValue: true);
    final vibration = await prefsService.getBool('vibration', defaultValue: true);
    final notificationVolume = await prefsService.getDouble('notification_volume', defaultValue: 0.7);
    
    final dataAnalytics = await prefsService.getBool('data_analytics', defaultValue: false);
    final adPersonalization = await prefsService.getBool('ad_personalization', defaultValue: false);
    final locationAccess = await prefsService.getBool('location_access', defaultValue: true);
    final twoFactorAuth = await prefsService.getBool('two_factor_auth', defaultValue: false);
    
    final language = await prefsService.getString('language') ?? 'English';
    final theme = await prefsService.getString('theme') ?? 'System';
    final units = await prefsService.getString('units') ?? 'Metric';
    final defaultLocation = await prefsService.getString('default_location');
    
    final appVersion = await prefsService.getString('app_version');
    final lastUpdatedStr = await prefsService.getString('settings_last_updated');
    DateTime? lastUpdated;
    if (lastUpdatedStr != null) {
      lastUpdated = DateTime.tryParse(lastUpdatedStr);
    }

    return Settings(
      pushNotifications: pushNotifications,
      emailNotifications: emailNotifications,
      inAppSounds: inAppSounds,
      vibration: vibration,
      notificationVolume: notificationVolume,
      dataAnalytics: dataAnalytics,
      adPersonalization: adPersonalization,
      locationAccess: locationAccess,
      twoFactorAuth: twoFactorAuth,
      language: language,
      theme: theme,
      units: units,
      defaultLocation: defaultLocation,
      appVersion: appVersion,
      lastUpdated: lastUpdated,
    );
  }

  /// Extract settings from profile entity
  Settings _extractSettingsFromProfile(dynamic profile, Settings fallback) {
    try {
      // Extract notification preferences from profile
      final notificationPrefs = profile.notificationPreferences as Map<String, dynamic>?;
      final privacySettings = profile.privacySettings as Map<String, dynamic>?;
      
      return Settings(
        // Notification settings from backend
        pushNotifications: (notificationPrefs?['push_notifications'] as bool?) ?? fallback.pushNotifications,
        emailNotifications: (notificationPrefs?['email_notifications'] as bool?) ?? fallback.emailNotifications,
        inAppSounds: (notificationPrefs?['in_app_sounds'] as bool?) ?? fallback.inAppSounds,
        vibration: (notificationPrefs?['vibration'] as bool?) ?? fallback.vibration,
        notificationVolume: (notificationPrefs?['notification_volume'] as double?) ?? fallback.notificationVolume,
        
        // Privacy settings from backend
        dataAnalytics: (privacySettings?['data_analytics'] as bool?) ?? fallback.dataAnalytics,
        adPersonalization: (privacySettings?['ad_personalization'] as bool?) ?? fallback.adPersonalization,
        locationAccess: (privacySettings?['location_access'] as bool?) ?? fallback.locationAccess,
        twoFactorAuth: (privacySettings?['two_factor_auth'] as bool?) ?? fallback.twoFactorAuth,
        
        // App preferences (keep local for now)
        language: fallback.language,
        theme: fallback.theme,
        units: fallback.units,
        defaultLocation: (profile.location as String?) ?? fallback.defaultLocation,
        
        // App info
        appVersion: fallback.appVersion,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      return fallback;
    }
  }

  /// Save settings to local storage
  Future<void> _saveLocalSettings(PreferencesService prefsService, Settings settings) async {
    try {
      // Save all settings to SharedPreferences
      await Future.wait<void>([
        prefsService.setBool('push_notifications', settings.pushNotifications),
        prefsService.setBool('email_notifications', settings.emailNotifications),
        prefsService.setBool('in_app_sounds', settings.inAppSounds),
        prefsService.setBool('vibration', settings.vibration),
        prefsService.setDouble('notification_volume', settings.notificationVolume),
        
        prefsService.setBool('data_analytics', settings.dataAnalytics),
        prefsService.setBool('ad_personalization', settings.adPersonalization),
        prefsService.setBool('location_access', settings.locationAccess),
        prefsService.setBool('two_factor_auth', settings.twoFactorAuth),
        
        prefsService.setString('language', settings.language),
        prefsService.setString('theme', settings.theme),
        prefsService.setString('units', settings.units),
        if (settings.defaultLocation != null)
          prefsService.setString('default_location', settings.defaultLocation!),
        
        if (settings.appVersion != null)
          prefsService.setString('app_version', settings.appVersion!),
        prefsService.setString('settings_last_updated', DateTime.now().toIso8601String()),
      ]);
    } catch (e) {
      // Handle save error - could show error to user
      rethrow;
    }
  }

  /// Save settings to both local storage and backend
  Future<void> _saveSettings(Settings settings) async {
    try {
      final prefsService = ref.read(preferencesServiceProvider);
      
      // Save to local storage first
      await _saveLocalSettings(prefsService, settings);
      
      // Then sync with backend if user is authenticated
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await _syncSettingsToBackend(settings);
      }
    } catch (e) {
      // Handle save error - could show error to user
      rethrow;
    }
  }

  /// Sync settings to backend profile
  Future<void> _syncSettingsToBackend(Settings settings) async {
    try {
      // Get current profile
      final profileResult = await _profileRepository.getCurrentProfile();
      
      profileResult.fold(
        (failure) {
          // Backend sync failed, but local save succeeded
          // Could log this for monitoring
        },
        (profile) async {
          // Create notification preferences map
          final notificationPrefs = {
            'push_notifications': settings.pushNotifications,
            'email_notifications': settings.emailNotifications,
            'in_app_sounds': settings.inAppSounds,
            'vibration': settings.vibration,
            'notification_volume': settings.notificationVolume,
          };
          
          // Create privacy settings map
          final privacySettings = {
            'data_analytics': settings.dataAnalytics,
            'ad_personalization': settings.adPersonalization,
            'location_access': settings.locationAccess,
            'two_factor_auth': settings.twoFactorAuth,
          };
          
          // Update profile with new settings
          await _profileRepository.updateNotificationPreferences(
            profile.userId,
            notificationPrefs,
          );
          
          await _profileRepository.updatePrivacySettings(
            profile.userId,
            privacySettings,
          );
        },
      );
    } catch (e) {
      // Backend sync failed, but local save succeeded
      // App continues to work with local settings
    }
  }

  // Notification Settings
  Future<void> updatePushNotifications(bool enabled) async {
    final currentSettings = state.value!;
    final newSettings = currentSettings.copyWith(pushNotifications: enabled);
    await _saveSettings(newSettings);
    state = AsyncValue.data(newSettings);
  }

  Future<void> updateEmailNotifications(bool enabled) async {
    final currentSettings = state.value!;
    final newSettings = currentSettings.copyWith(emailNotifications: enabled);
    await _saveSettings(newSettings);
    state = AsyncValue.data(newSettings);
  }

  Future<void> updateInAppSounds(bool enabled) async {
    final currentSettings = state.value!;
    final newSettings = currentSettings.copyWith(inAppSounds: enabled);
    await _saveSettings(newSettings);
    state = AsyncValue.data(newSettings);
  }

  Future<void> updateVibration(bool enabled) async {
    final currentSettings = state.value!;
    final newSettings = currentSettings.copyWith(vibration: enabled);
    await _saveSettings(newSettings);
    state = AsyncValue.data(newSettings);
  }

  Future<void> updateNotificationVolume(double volume) async {
    final currentSettings = state.value!;
    final newSettings = currentSettings.copyWith(notificationVolume: volume);
    await _saveSettings(newSettings);
    state = AsyncValue.data(newSettings);
  }

  // Privacy & Security Settings
  Future<void> updateDataAnalytics(bool enabled) async {
    final currentSettings = state.value!;
    final newSettings = currentSettings.copyWith(dataAnalytics: enabled);
    await _saveSettings(newSettings);
    state = AsyncValue.data(newSettings);
  }

  Future<void> updateAdPersonalization(bool enabled) async {
    final currentSettings = state.value!;
    final newSettings = currentSettings.copyWith(adPersonalization: enabled);
    await _saveSettings(newSettings);
    state = AsyncValue.data(newSettings);
  }

  Future<void> updateLocationAccess(bool enabled) async {
    final currentSettings = state.value!;
    final newSettings = currentSettings.copyWith(locationAccess: enabled);
    await _saveSettings(newSettings);
    state = AsyncValue.data(newSettings);
  }

  Future<void> updateTwoFactorAuth(bool enabled) async {
    final currentSettings = state.value!;
    final newSettings = currentSettings.copyWith(twoFactorAuth: enabled);
    await _saveSettings(newSettings);
    state = AsyncValue.data(newSettings);
  }

  // App Preferences
  Future<void> updateLanguage(String language) async {
    final currentSettings = state.value!;
    final newSettings = currentSettings.copyWith(language: language);
    await _saveSettings(newSettings);
    state = AsyncValue.data(newSettings);
  }

  Future<void> updateTheme(String theme) async {
    final currentSettings = state.value!;
    final newSettings = currentSettings.copyWith(theme: theme);
    await _saveSettings(newSettings);
    state = AsyncValue.data(newSettings);
  }

  Future<void> updateUnits(String units) async {
    final currentSettings = state.value!;
    final newSettings = currentSettings.copyWith(units: units);
    await _saveSettings(newSettings);
    state = AsyncValue.data(newSettings);
  }

  Future<void> updateDefaultLocation(String? location) async {
    final currentSettings = state.value!;
    final newSettings = currentSettings.copyWith(defaultLocation: location);
    await _saveSettings(newSettings);
    state = AsyncValue.data(newSettings);
  }

  // Account Actions
  Future<bool> logout() async {
    try {
      // Clear secure storage (auth tokens)
      final secureStorage = ref.read(secureStorageServiceProvider);
      await secureStorage.clearAll();
      
      // Clear all preferences
      final prefsService = ref.read(preferencesServiceProvider);
      await prefsService.clear();
      
      // Reset settings to default
      state = const AsyncValue.data(Settings());
      
      return true;
    } catch (e) {
      // Handle logout error
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    try {
      // TODO: Call backend API to delete account
      // This would involve calling the user repository
      
      // For now, just clear all local data
      final success = await logout();
      return success;
    } catch (e) {
      // Handle delete account error
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  // Reset all settings to default
  Future<void> resetToDefaults() async {
    const defaultSettings = Settings();
    await _saveSettings(defaultSettings);
    state = const AsyncValue.data(defaultSettings);
  }
}
