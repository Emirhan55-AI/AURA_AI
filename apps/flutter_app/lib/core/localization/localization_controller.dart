import 'dart:ui';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/preferences_service.dart';

part 'localization_controller.g.dart';

/// Localization controller for managing app language and locale settings
/// Handles language switching, persistence, and system locale detection
@riverpod
class LocalizationController extends _$LocalizationController {
  @override
  Locale build() {
    // Initialize with system locale, then load saved preference
    _loadSavedLocale();
    return _getSystemLocale();
  }

  /// Load saved locale preference from storage
  Future<void> _loadSavedLocale() async {
    try {
      final preferencesService = ref.read(preferencesServiceProvider);
      final savedLanguageCode = await preferencesService.getSelectedLanguage();
      
      if (savedLanguageCode != null) {
        final locale = Locale(savedLanguageCode);
        if (_isSupportedLocale(locale)) {
          state = locale;
        }
      }
    } catch (error) {
      // If loading fails, keep system locale
      print('Failed to load saved locale: $error');
    }
  }

  /// Set locale and persist to storage
  Future<void> setLocale(Locale locale) async {
    try {
      if (!_isSupportedLocale(locale)) {
        throw ArgumentError('Unsupported locale: ${locale.languageCode}');
      }
      
      state = locale;
      
      final preferencesService = ref.read(preferencesServiceProvider);
      await preferencesService.setSelectedLanguage(locale.languageCode);
      
      print('Locale changed to: ${locale.languageCode}');
    } catch (error) {
      print('Failed to save locale preference: $error');
    }
  }

  /// Set locale by language code
  Future<void> setLanguage(String languageCode) async {
    await setLocale(Locale(languageCode));
  }

  /// Set Turkish locale
  Future<void> setTurkish() => setLocale(const Locale('tr'));

  /// Set English locale
  Future<void> setEnglish() => setLocale(const Locale('en'));

  /// Toggle between supported languages
  Future<void> toggleLanguage() async {
    final currentLocale = state;
    Locale newLocale;
    
    switch (currentLocale.languageCode) {
      case 'tr':
        newLocale = const Locale('en');
        break;
      case 'en':
        newLocale = const Locale('tr');
        break;
      default:
        // Default to English if unknown locale
        newLocale = const Locale('en');
        break;
    }
    
    await setLocale(newLocale);
  }

  /// Check if current locale is Turkish
  bool get isTurkish => state.languageCode == 'tr';

  /// Check if current locale is English
  bool get isEnglish => state.languageCode == 'en';

  /// Get current language name
  String get currentLanguageName {
    switch (state.languageCode) {
      case 'tr':
        return 'Türkçe';
      case 'en':
        return 'English';
      default:
        return 'Unknown';
    }
  }

  /// Get current language display name in current locale
  String get currentLanguageDisplayName {
    switch (state.languageCode) {
      case 'tr':
        return 'Türkçe';
      case 'en':
        return 'English';
      default:
        return 'Unknown';
    }
  }

  /// Get system locale
  Locale _getSystemLocale() {
    final systemLocale = PlatformDispatcher.instance.locale;
    
    // Check if system locale is supported
    if (_isSupportedLocale(systemLocale)) {
      return systemLocale;
    }
    
    // Check if system language (without country) is supported
    final systemLanguageLocale = Locale(systemLocale.languageCode);
    if (_isSupportedLocale(systemLanguageLocale)) {
      return systemLanguageLocale;
    }
    
    // Default to English if system locale is not supported
    return const Locale('en');
  }

  /// Check if locale is supported
  bool _isSupportedLocale(Locale locale) {
    return AppLocales.supported.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }
}

/// Provider for checking if app is using Turkish
@riverpod
bool isTurkishLocale(IsTurkishLocaleRef ref) {
  final locale = ref.watch(localizationControllerProvider);
  return locale.languageCode == 'tr';
}

/// Provider for checking if app is using English
@riverpod
bool isEnglishLocale(IsEnglishLocaleRef ref) {
  final locale = ref.watch(localizationControllerProvider);
  return locale.languageCode == 'en';
}

/// Provider for current language name
@riverpod
String currentLanguageName(CurrentLanguageNameRef ref) {
  final controller = ref.read(localizationControllerProvider.notifier);
  return controller.currentLanguageName;
}

/// App locale configuration
class AppLocales {
  /// Supported locales
  static const List<Locale> supported = [
    Locale('en'), // English
    Locale('tr'), // Turkish
  ];

  /// Default locale
  static const Locale defaultLocale = Locale('en');

  /// Get all supported language options
  static List<LanguageOption> getAllLanguageOptions() {
    return [
      const LanguageOption(
        locale: Locale('en'),
        name: 'English',
        nativeName: 'English',
        flagEmoji: '🇺🇸',
      ),
      const LanguageOption(
        locale: Locale('tr'),
        name: 'Turkish',
        nativeName: 'Türkçe',
        flagEmoji: '🇹🇷',
      ),
    ];
  }

  /// Get language option by locale
  static LanguageOption? getLanguageOption(Locale locale) {
    try {
      return getAllLanguageOptions().firstWhere(
        (option) => option.locale.languageCode == locale.languageCode,
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if locale is supported
  static bool isSupported(Locale locale) {
    return supported.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }
}

/// Language option data
class LanguageOption {
  final Locale locale;
  final String name;
  final String nativeName;
  final String flagEmoji;

  const LanguageOption({
    required this.locale,
    required this.name,
    required this.nativeName,
    required this.flagEmoji,
  });

  @override
  String toString() {
    return 'LanguageOption(locale: $locale, name: $name, nativeName: $nativeName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is LanguageOption &&
      other.locale == locale &&
      other.name == name &&
      other.nativeName == nativeName &&
      other.flagEmoji == flagEmoji;
  }

  @override
  int get hashCode {
    return locale.hashCode ^
      name.hashCode ^
      nativeName.hashCode ^
      flagEmoji.hashCode;
  }
}

/// Localization utilities
class LocalizationUtils {
  /// Get direction for locale (LTR/RTL)
  static TextDirection getTextDirection(Locale locale) {
    // Add RTL languages if needed in the future
    return TextDirection.ltr;
  }

  /// Get locale from language code
  static Locale getLocaleFromLanguageCode(String languageCode) {
    return Locale(languageCode);
  }

  /// Format locale for display
  static String formatLocaleForDisplay(Locale locale) {
    final option = AppLocales.getLanguageOption(locale);
    return option?.nativeName ?? locale.languageCode.toUpperCase();
  }

  /// Get best matching locale from preferences
  static Locale getBestMatchingLocale(
    List<Locale> supportedLocales,
    List<Locale> systemLocales,
  ) {
    // Check if any system locale is directly supported
    for (final systemLocale in systemLocales) {
      for (final supportedLocale in supportedLocales) {
        if (systemLocale.languageCode == supportedLocale.languageCode) {
          return supportedLocale;
        }
      }
    }
    
    // Return default locale if no match found
    return AppLocales.defaultLocale;
  }
}
