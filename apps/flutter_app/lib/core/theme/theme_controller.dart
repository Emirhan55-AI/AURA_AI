import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/preferences_service.dart';
import '../theme/app_theme.dart';

part 'theme_controller.g.dart';

/// Theme controller for managing app theme state
/// Handles theme switching, persistence, and system theme detection
@riverpod
class ThemeController extends _$ThemeController {
  @override
  ThemeMode build() {
    // Initialize with system theme, then load saved preference
    _loadSavedTheme();
    return ThemeMode.system;
  }

  /// Load saved theme preference from storage
  Future<void> _loadSavedTheme() async {
    try {
      final preferencesService = ref.read(preferencesServiceProvider);
      final savedThemeIndex = await preferencesService.getThemeMode();
      
      if (savedThemeIndex != null) {
        final themeMode = ThemeMode.values[savedThemeIndex];
        state = themeMode;
      }
    } catch (error) {
      // If loading fails, keep system theme
      debugPrint('Failed to load saved theme: $error');
    }
  }

  /// Set theme mode and persist to storage
  Future<void> setThemeMode(ThemeMode themeMode) async {
    try {
      state = themeMode;
      
      final preferencesService = ref.read(preferencesServiceProvider);
      await preferencesService.setThemeMode(themeMode.index);
      
      debugPrint('Theme changed to: $themeMode');
    } catch (error) {
      debugPrint('Failed to save theme preference: $error');
    }
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    final currentTheme = state;
    ThemeMode newTheme;
    
    switch (currentTheme) {
      case ThemeMode.light:
        newTheme = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        newTheme = ThemeMode.light;
        break;
      case ThemeMode.system:
        // If system theme, switch to opposite of current brightness
        final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        newTheme = brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
        break;
    }
    
    await setThemeMode(newTheme);
  }

  /// Set light theme
  Future<void> setLightTheme() => setThemeMode(ThemeMode.light);

  /// Set dark theme
  Future<void> setDarkTheme() => setThemeMode(ThemeMode.dark);

  /// Set system theme
  Future<void> setSystemTheme() => setThemeMode(ThemeMode.system);

  /// Check if current theme is light
  bool get isLightTheme => state == ThemeMode.light;

  /// Check if current theme is dark
  bool get isDarkTheme => state == ThemeMode.dark;

  /// Check if using system theme
  bool get isSystemTheme => state == ThemeMode.system;

  /// Get current theme mode as string
  String get themeModeString {
    switch (state) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
}

/// Provider for checking if app is using dark theme
@riverpod
bool isDarkTheme(IsDarkThemeRef ref) {
  final themeMode = ref.watch(themeControllerProvider);
  
  switch (themeMode) {
    case ThemeMode.dark:
      return true;
    case ThemeMode.light:
      return false;
    case ThemeMode.system:
      // Check system brightness
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
  }
}

/// Provider for current theme data (light or dark)
@riverpod
ThemeData currentThemeData(CurrentThemeDataRef ref) {
  final isDark = ref.watch(isDarkThemeProvider);
  return isDark ? AppTheme.darkTheme : AppTheme.lightTheme;
}

/// Provider for current color scheme
@riverpod
ColorScheme currentColorScheme(CurrentColorSchemeRef ref) {
  final themeData = ref.watch(currentThemeDataProvider);
  return themeData.colorScheme;
}

/// Theme preference utilities
class ThemeUtils {
  /// Get theme mode icon
  static IconData getThemeIcon(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  /// Get theme mode description
  static String getThemeDescription(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light theme with bright colors';
      case ThemeMode.dark:
        return 'Dark theme for low-light environments';
      case ThemeMode.system:
        return 'Automatically match system theme';
    }
  }

  /// Get all available theme modes with metadata
  static List<ThemeModeOption> getAllThemeModes() {
    return ThemeMode.values.map((mode) {
      return ThemeModeOption(
        mode: mode,
        icon: getThemeIcon(mode),
        title: mode.name.capitalize(),
        description: getThemeDescription(mode),
      );
    }).toList();
  }
}

/// Theme mode option data
class ThemeModeOption {
  final ThemeMode mode;
  final IconData icon;
  final String title;
  final String description;

  const ThemeModeOption({
    required this.mode,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  String toString() {
    return 'ThemeModeOption(mode: $mode, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ThemeModeOption &&
      other.mode == mode &&
      other.icon == icon &&
      other.title == title &&
      other.description == description;
  }

  @override
  int get hashCode {
    return mode.hashCode ^
      icon.hashCode ^
      title.hashCode ^
      description.hashCode;
  }
}

/// String extension for capitalizing first letter
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
