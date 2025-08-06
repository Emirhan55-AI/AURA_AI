/// Settings entity that represents user preferences and app configuration
class Settings {
  // Account Settings
  final bool twoFactorAuth;
  
  // Notification Settings
  final bool pushNotifications;
  final bool emailNotifications;
  final bool inAppSounds;
  final bool vibration;
  final double notificationVolume;
  
  // Privacy & Security Settings
  final bool dataAnalytics;
  final bool adPersonalization;
  final bool locationAccess;
  
  // App Preferences
  final String language;
  final String theme;
  final String units;
  final String? defaultLocation;
  
  // App Info
  final String? appVersion;
  final DateTime? lastUpdated;

  const Settings({
    this.twoFactorAuth = false,
    this.pushNotifications = true,
    this.emailNotifications = false,
    this.inAppSounds = true,
    this.vibration = true,
    this.notificationVolume = 0.7,
    this.dataAnalytics = false,
    this.adPersonalization = false,
    this.locationAccess = true,
    this.language = 'English',
    this.theme = 'System',
    this.units = 'Metric',
    this.defaultLocation,
    this.appVersion,
    this.lastUpdated,
  });

  /// Returns true if dark theme is selected
  bool get isDarkTheme => theme == 'Dark';
  
  /// Returns true if light theme is selected
  bool get isLightTheme => theme == 'Light';
  
  /// Returns true if system theme should be used
  bool get isSystemTheme => theme == 'System';
  
  /// Returns true if notifications are fully enabled
  bool get areNotificationsEnabled => pushNotifications || emailNotifications;
  
  /// Returns the notification volume as a percentage string
  String get notificationVolumePercentage => '${(notificationVolume * 100).round()}%';
  
  /// Copy this settings instance with updated values
  Settings copyWith({
    bool? twoFactorAuth,
    bool? pushNotifications,
    bool? emailNotifications,
    bool? inAppSounds,
    bool? vibration,
    double? notificationVolume,
    bool? dataAnalytics,
    bool? adPersonalization,
    bool? locationAccess,
    String? language,
    String? theme,
    String? units,
    String? defaultLocation,
    String? appVersion,
    DateTime? lastUpdated,
  }) {
    return Settings(
      twoFactorAuth: twoFactorAuth ?? this.twoFactorAuth,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      inAppSounds: inAppSounds ?? this.inAppSounds,
      vibration: vibration ?? this.vibration,
      notificationVolume: notificationVolume ?? this.notificationVolume,
      dataAnalytics: dataAnalytics ?? this.dataAnalytics,
      adPersonalization: adPersonalization ?? this.adPersonalization,
      locationAccess: locationAccess ?? this.locationAccess,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      units: units ?? this.units,
      defaultLocation: defaultLocation ?? this.defaultLocation,
      appVersion: appVersion ?? this.appVersion,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Enum for supported languages
enum SupportedLanguage {
  english('English', 'en'),
  spanish('Spanish', 'es'),
  french('French', 'fr'),
  german('German', 'de'),
  turkish('Turkish', 'tr');

  const SupportedLanguage(this.displayName, this.code);

  final String displayName;
  final String code;
}

/// Enum for supported themes
enum SupportedTheme {
  light('Light'),
  dark('Dark'),
  system('System');

  const SupportedTheme(this.displayName);

  final String displayName;
}

/// Enum for supported unit systems
enum SupportedUnits {
  metric('Metric'),
  imperial('Imperial');

  const SupportedUnits(this.displayName);

  final String displayName;
}
