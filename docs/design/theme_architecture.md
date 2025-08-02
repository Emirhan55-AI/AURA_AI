
# Aura Project Theme Architecture (THEME_ARCHITECTURE.md)

**Version:** 2.1

This document describes the architecture and implementation strategy for theming within the Aura Flutter application. It leverages Flutter's Material 3 capabilities and `ThemeData` to create a consistent and maintainable design system. It is designed to be fully compliant with the dual-font strategy defined in `STYLE_GUIDE.md`.

## 1. Architectural Approach

Aura is built upon Flutter's built-in theme system. The core approach is to define `ThemeData` objects centrally and use them within `MaterialApp` via the `theme`, `darkTheme`, and `themeMode` parameters.

### 1.1. Core Theme Definitions

All theme definitions reside in the `lib/src/presentation/theme/` directory.

*   **`aura_light_theme.dart`**: Defines the `ThemeData` for the light theme, incorporating the dual-font strategy from `STYLE_GUIDE.md`.
*   **`aura_dark_theme.dart`**: Defines the `ThemeData` for the dark theme, incorporating the dual-font strategy from `STYLE_GUIDE.md`.
*   **`app_theme.dart`** (Optional): Exports the light and dark themes and potentially defines a `ThemeExtension` for project-specific customizations beyond standard Material properties.

### 1.2. Theme Application in `MaterialApp`

Themes are applied in the root `MaterialApp` widget.

*   **`theme`**: Points to the `auraLightTheme` defined in `aura_light_theme.dart`.
*   **`darkTheme`**: Points to the `auraDarkTheme` defined in `aura_dark_theme.dart`.
*   **`themeMode`**: Controls which theme is used. Commonly set to `ThemeMode.system` to follow the OS setting, but can be driven by user preference (e.g., via Riverpod state like `ref.watch(themeProvider)`).

### 1.3. Using Themes in Widgets

Widgets should consume theme data via `Theme.of(context)` to ensure consistency and adaptability.

*   **Colors:** `Theme.of(context).colorScheme.primary`
*   **Text Styles:** `Theme.of(context).textTheme.headlineMedium`
*   **Component Themes:** `Theme.of(context).inputDecorationTheme`
*   **Extensions (if used):** `Theme.of(context).extension<AuraCustomTheme>()`

## 2. Material 3 & `ColorScheme`

The theme fully embraces Material 3 design principles.

*   **`ColorScheme.fromSeed`**: This is the recommended method for generating harmonious color palettes for both light and dark themes. A single seed color (defined in `STYLE_GUIDE.md` as `#FF6F61` - Coral) is used to derive all primary, secondary, and neutral tones. This ensures brand consistency and supports dynamic color if needed in the future.
    *   **Light Theme Seed:** `ColorScheme.fromSeed(seedColor: Color(0xFFFF6F61))`
    *   **Dark Theme Seed:** `ColorScheme.fromSeed(seedColor: Color(0xFFFF6F61), brightness: Brightness.dark)`
*   **Customization:** While `fromSeed` provides a great base, specific colors from `STYLE_GUIDE.md` (like `surface`, `error`) can be overridden if exact values are mandated.

## 3. Defining a Light Theme (`aura_light_theme.dart` Example)

This example illustrates how a light theme is structured based on `STYLE_GUIDE.md`, particularly implementing the dual-font strategy.

```dart
// lib/src/presentation/theme/aura_light_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Assuming colors are defined in a constants file or directly here
// import '../../core/constants/style_guide.dart';

// Define core colors based on STYLE_GUIDE.md
abstract class AppColors {
  static const primary = Color(0xFFFF6F61); // Coral
  static const onPrimary = Color(0xFFFFFFFF); // White
  static const secondary = Color(0xFFFFD700); // Gold
  static const onSecondary = Color(0xFF000000); // Black
  static const error = Color(0xFFBA1A1A); // Red
  static const onError = Color(0xFFFFFFFF); // White
  static const surface = Color(0xFFFFFBFF); // Light surface
  static const onSurface = Color(0xFF1C1B1F); // Near-black
  static const outline = Color(0xFF79747E); // Grey
  static const surfaceVariant = Color(0xFFE7E0EC);
  static const onSurfaceVariant = Color(0xFF49454F);
}

final auraLightTheme = ThemeData(
  useMaterial3: true, // Essential for Material 3
  brightness: Brightness.light, // Explicitly set brightness

  // Generate ColorScheme from the seed color defined in STYLE_GUIDE.md
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary, // #FF6F61 - Coral
    // brightness defaults to light
  ).copyWith(
    // Override any specific colors if needed beyond the seed-derived ones
    // surface: AppColors.surface,
    // error: AppColors.error,
  ),

  // Typography based on the DUAL-FONT strategy from STYLE_GUIDE.md
  textTheme: _buildTextTheme(), // Define separately for clarity

  // Component Themes
  inputDecorationTheme: _inputDecorationTheme(), // Defined based on STYLE_GUIDE.md
  elevatedButtonTheme: _elevatedButtonTheme(),
  cardTheme: _cardTheme(),

  // Other component themes...
  // appBarTheme, tabBarTheme, etc.
);

// --- Typography Implementation ---
/// Helper function to build a custom TextTheme using Urbanist for headings and Inter for body text,
/// as defined in STYLE_GUIDE.md.
TextTheme _buildTextTheme() {
  // We explicitly define all text styles to use Urbanist for headings and Inter for body text,
  // as per the updated STYLE_GUIDE.md.
  return TextTheme(
    displayLarge: GoogleFonts.urbanist(fontWeight: FontWeight.w300, fontSize: 57.0, letterSpacing: -0.25, height: 64.0/57.0, color: AppColors.onSurface),
    displayMedium: GoogleFonts.urbanist(fontWeight: FontWeight.w300, fontSize: 45.0, height: 52.0/45.0, color: AppColors.onSurface),
    displaySmall: GoogleFonts.urbanist(fontWeight: FontWeight.w400, fontSize: 36.0, height: 44.0/36.0, color: AppColors.onSurface),
    headlineLarge: GoogleFonts.urbanist(fontWeight: FontWeight.w400, fontSize: 32.0, height: 40.0/32.0, color: AppColors.onSurface),
    headlineMedium: GoogleFonts.urbanist(fontWeight: FontWeight.w400, fontSize: 28.0, height: 36.0/28.0, color: AppColors.onSurface),
    headlineSmall: GoogleFonts.urbanist(fontWeight: FontWeight.w400, fontSize: 24.0, height: 32.0/24.0, color: AppColors.onSurface),
    titleLarge: GoogleFonts.urbanist(fontWeight: FontWeight.w400, fontSize: 22.0, height: 28.0/22.0, color: AppColors.onSurface),
    titleMedium: GoogleFonts.urbanist(fontWeight: FontWeight.w500, fontSize: 16.0, letterSpacing: 0.15, height: 24.0/16.0, color: AppColors.onSurface),
    titleSmall: GoogleFonts.urbanist(fontWeight: FontWeight.w500, fontSize: 14.0, letterSpacing: 0.1, height: 20.0/14.0, color: AppColors.onSurface),
    bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 16.0, letterSpacing: 0.5, height: 24.0/16.0, color: AppColors.onSurface),
    bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 14.0, letterSpacing: 0.25, height: 20.0/14.0, color: AppColors.onSurface),
    bodySmall: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 12.0, letterSpacing: 0.4, height: 16.0/12.0, color: AppColors.onSurface),
    labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14.0, letterSpacing: 0.1, height: 20.0/14.0, color: AppColors.onPrimary), // Example for buttons
    labelMedium: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 12.0, letterSpacing: 0.5, height: 16.0/12.0, color: AppColors.onSurfaceVariant),
    labelSmall: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 11.0, letterSpacing: 0.5, height: 16.0/11.0, color: AppColors.onSurfaceVariant),
  );
}

// --- Component Theme Implementations ---
InputDecorationTheme _inputDecorationTheme() {
  return InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceVariant.withOpacity(0.5), // Example, adjust based on STYLE_GUIDE.md
    labelStyle: _buildTextTheme().bodyLarge?.copyWith(color: AppColors.onSurfaceVariant),
    hintStyle: _buildTextTheme().bodyLarge?.copyWith(color: AppColors.onSurfaceVariant.withOpacity(0.7)),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0), // From STYLE_GUIDE.md
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: AppColors.primary), // From STYLE_GUIDE.md
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: AppColors.error), // From STYLE_GUIDE.md
    ),
    // ... other states
  );
}

// Placeholder for ElevatedButton theme, following STYLE_GUIDE.md
ElevatedButtonThemeData _elevatedButtonTheme() {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // From STYLE_GUIDE.md
      ),
      textStyle: _buildTextTheme().labelLarge, // Uses Inter from theme
    ),
  );
}

// Placeholder for Card theme, following STYLE_GUIDE.md
CardTheme _cardTheme() {
  return CardTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0), // From STYLE_GUIDE.md
    ),
    // elevation: ... (use standard Material 3 elevations or define)
  );
}

// Similar helper functions for other components (OutlinedButton, TextButton, etc.) would go here.
// Remember to use the correct text styles from _buildTextTheme() for labels/text.
```

## 4. Theming Best Practices

*   **Centralize Definitions:** Keep all `ThemeData` objects in the designated theme directory (`lib/src/presentation/theme/`). Avoid defining theme data inline in widgets.
*   **Adhere to `STYLE_GUIDE.md`:** All color, typography, and component styles defined in the central theme files *must* originate from or be consistent with the values and principles laid out in `STYLE_GUIDE.md`. This now explicitly includes the dual-font strategy for `textTheme`.
*   **Leverage `Theme.of(context)`:** This is the primary method for accessing theme properties in widgets. It ensures consistency and allows the UI to react to theme changes.
    *   **Good:**
        ```dart
        Text('Title', style: Theme.of(context).textTheme.headlineMedium);
        ```
    *   **Avoid (unless absolutely necessary for a very specific override):**
        ```dart
        Text('Title', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue));
        ```
*   **Theme Extensions (Optional):** For custom properties not covered by standard `ThemeData` (e.g., specific spacings, custom component styles), consider using `ThemeExtension`. This keeps custom theming organized and accessible via `Theme.of(context).extension<MyCustomExtension>()`.
*   **Dynamic Theming:** While the base setup uses static light/dark themes, the architecture supports dynamic switching. This is typically achieved by changing the `themeMode` or even the `theme`/`darkTheme` properties of `MaterialApp` based on state (e.g., a Riverpod provider). The UI rebuilds automatically when this state changes.

## 5. Usage Notes

*   All theme definitions must be stored in the `lib/src/presentation/theme/` directory.
*   Theme files must strictly adhere to the color and typography rules defined in `STYLE_GUIDE.md`. **This now critically includes implementing the dual-font (`Urbanist` for headings, `Inter` for body) strategy within `textTheme`.**
*   Component themes (e.g., `inputDecorationTheme`, `buttonTheme`) should be defined within the main theme files to ensure global consistency.
*   Before adding a new theme property, `STYLE_GUIDE.md` should be updated first.
*   The dynamic theme feature is optional. The base application must have support for fixed light and dark themes.
*   Special components related to the theme (e.g., a custom AppBar style) can be defined in `app_theme.dart` or kept in a separate file.
*   Using `ColorScheme.fromSeed` is preferred to maintain theme integrity.
