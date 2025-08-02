# Aura Localization Guide

This document outlines the strategy and implementation details for internationalization (i18n) and localization (l10n) in the Aura Flutter application. It covers supported languages, file formats, integration with Flutter, and best practices for managing translatable content.

## Table of Contents

1.  [Overview](#1-overview)
2.  [Supported Languages](#2-supported-languages)
3.  [Technology & Tools](#3-technology--tools)
    *   [3.1. Flutter's Official Solution: `gen-l10n`](#31-flutters-official-solution-gen-l10n)
    *   [3.2. File Format: ARB (Application Resource Bundle)](#32-file-format-arb-application-resource-bundle)
    *   [3.3. State Management Integration (Riverpod)](#33-state-management-integration-riverpod)
4.  [ARB File Structure & Best Practices](#4-arb-file-structure--best-practices)
    *   [4.1. File Naming](#41-file-naming)
    *   [4.2. Message Keys](#42-message-keys)
    *   [4.3. Placeholders & Plurals](#43-placeholders--plurals)
    *   [4.4. Example ARB Files](#44-example-arb-files)
5.  [Integration with Flutter App](#5-integration-with-flutter-app)
    *   [5.1. Configuration (`l10n.yaml`)](#51-configuration-l10nyaml)
    *   [5.2. Running Code Generation](#52-running-code-generation)
    *   [5.3. Using Generated Code](#53-using-generated-code)
    *   [5.4. MaterialApp Setup](#54-materialapp-setup)
6.  [Changing Language](#6-changing-language)
    *   [6.1. UI for Language Selection](#61-ui-for-language-selection)
7.  [Testing Localized UI](#7-testing-localized-ui)
8.  [Best Practices](#8-best-practices)
9.  [Managing Translations](#9-managing-translations)
    *   [9.1. Translation Management Systems (TMS)](#91-translation-management-systems-tms)

## 1. Overview

As a global application aiming to provide a personalized experience, Aura must support multiple languages and regions. This guide defines how to structure, manage, and integrate translations to ensure a seamless experience for users worldwide.

This strategy aligns with the Flutter framework's capabilities and the architectural principles outlined in `Hibrit Mimari Uygulama Rehberi Taslağı_.pdf`.

## 2. Supported Languages

*   **Initial Target:** English (en), Turkish (tr)
*   **Future Expansion:** The system should be designed to easily accommodate new languages (e.g., Spanish (es), French (fr)).

## 3. Technology & Tools

### 3.1. Flutter's Official Solution: `gen-l10n`

*   **Tool:** Flutter provides an official command-line tool, `gen-l10n`, for generating localized messages. This is the recommended approach.
*   **Documentation:** [https://docs.flutter.dev/ui/accessibility-and-localization/internationalization](https://docs.flutter.dev/ui/accessibility-and-localization/internationalization)

### 3.2. File Format: ARB (Application Resource Bundle)

*   **Format:** Use `.arb` (Application Resource Bundle) files to store translations. These are JSON-like files that are human-readable and supported by `gen-l10n`.
*   **Structure:** Each language will have its own `.arb` file (e.g., `app_en.arb`, `app_tr.arb`).
*   **Location:** Store ARB files in a dedicated directory, typically `lib/l10n/` or `assets/l10n/`.

### 3.3. State Management Integration (Riverpod)

*   **Locale Management:** Use a Riverpod `StateProvider` to manage the currently selected `Locale`. This allows the UI to reactively rebuild when the language changes.
    *   *Example Provider:*
        ```dart
        // lib/core/presentation/providers/locale_provider.dart
        import 'package:flutter/material.dart';
        import 'package:riverpod_annotation/riverpod_annotation.dart';

        part 'locale_provider.g.dart';

        @riverpod
        class LocaleNotifier extends _$LocaleNotifier {
          @override
          Locale build() {
            // Initial locale, could be from shared_preferences or system locale
            return const Locale('en'); // Default to English
          }

          void setLocale(Locale newLocale) {
            state = newLocale;
            // Optionally, save the selected locale to shared_preferences for persistence
          }
        }
        ```
*   **Usage:** Wrap your app with `MaterialApp.locale` and provide the Riverpod locale. Use `MaterialApp.localizationsDelegates` and `MaterialApp.supportedLocales` as required by Flutter's i18n setup.

## 4. ARB File Structure & Best Practices

### 4.1. File Naming

*   **Base File:** `app_en.arb` - This contains the default messages and serves as the source of truth.
*   **Translated Files:** `app_<language_code>.arb` (e.g., `app_tr.arb`).

### 4.2. Message Keys

*   **Naming Convention:** Use clear, descriptive, and consistent keys.
    *   **Flat Naming (Common):** `wardrobeHome_title`, `addItemScreen_saveButton_label`. Simple and widely used.
    *   **Hierarchical Naming (Advanced):** For larger applications, a hierarchical scheme like `wardrobe.home.title`, `addItemScreen.saveButton.label` can improve organization *within* the ARB file. Note that `gen-l10n` will still generate flat method names like `wardrobeHomeTitle()` in the Dart code. Choose based on your team's preference and project size.
*   **Avoid:** Unclear keys like `title1`, `button2` or inconsistent casing.

### 4.3. Placeholders & Plurals

*   **Placeholders:** Use ICU (International Components for Unicode) syntax within ARB messages for dynamic content.
    *   *ARB Entry:*
        ```json
        {
          "itemsCountMessage": "You have {count, plural, =0{no items} =1{1 item} other{# items}} in your wardrobe."
        }
        ```
    *   *Usage in Dart:*
        ```dart
        Text(AppLocalizations.of(context)!.itemsCountMessage(count: userItemCount));
        ```
*   **Plurals:** ICU syntax also handles pluralization rules specific to each language.
*   **Dates/Times/Numbers:** For formatting, rely on Flutter's `intl` package (`DateFormat`, `NumberFormat`) in conjunction with the selected locale, rather than putting fully formatted strings in ARB files.

### 4.4. Example ARB Files

#### `lib/l10n/app_en.arb`

```json
{
  "@@locale": "en",
  "appTitle": "Aura",
  "wardrobeHome_title": "My Wardrobe",
  "addItemScreen_title": "Add New Item",
  "addItemScreen_saveButton_label": "Save",
  "itemsCountMessage": "You have {count, plural, =0{no items} =1{1 item} other{# items}} in your wardrobe.",
  "common_cancel": "Cancel",
  "common_ok": "OK"
}
```

#### `lib/l10n/app_tr.arb`

```json
{
  "@@locale": "tr",
  "appTitle": "Aura",
  "wardrobeHome_title": "Gardırobum",
  "addItemScreen_title": "Yeni Eşya Ekle",
  "addItemScreen_saveButton_label": "Kaydet",
  "itemsCountMessage": "Gardırobunuzda {count, plural, =0{hiç eşya yok} =1{1 eşya} other{# eşya}} var.",
  "common_cancel": "İptal",
  "common_ok": "Tamam"
}
```

## 5. Integration with Flutter App

### 5.1. Configuration (`l10n.yaml`)

*   Create a configuration file `l10n.yaml` (or use `flutter gen-l10n --arb-dir ...` command arguments) to specify input/output directories and other settings.
    *   *Example `l10n.yaml`:*
        ```yaml
        arb-dir: lib/l10n
        template-arb-file: app_en.arb
        output-localization-file: app_localizations.dart
        output-class: AppLocalizations
        synthetic-package: false # Generates files within your project, not a separate package
        ```

### 5.2. Running Code Generation

*   Run the generation command: `flutter gen-l10n` (or `flutter pub run flutter_gen/gen_l10n:generate`). This command reads the ARB files and generates the necessary Dart code (`app_localizations.dart`).
*   **Automation:** This command should be run whenever ARB files are updated. It can be integrated into the development workflow or CI/CD pipeline. See `CI_CD_GUIDE.md`.

### 5.3. Using Generated Code

*   The `flutter gen-l10n` tool generates an `AppLocalizations` class.
*   Access translated messages using `AppLocalizations.of(context)!.messageKey()`.
    *   *Example Usage:*
        ```dart
        Text(AppLocalizations.of(context)!.wardrobeHome_title),
        ElevatedButton(
          onPressed: () { /* ... */ },
          child: Text(AppLocalizations.of(context)!.addItemScreen_saveButton_label),
        ),
        Text(AppLocalizations.of(context)!.itemsCountMessage(count: 5)),
        ```

### 5.4. MaterialApp Setup

*   Configure `MaterialApp` to use the generated localizations and the Riverpod locale provider.
    *   *Example `main.dart` snippet:*
        ```dart
        import 'package:flutter_localizations/flutter_localizations.dart';
        import 'generated/l10n/app_localizations.dart'; // Adjust path if needed
        import 'core/presentation/providers/locale_provider.dart';

        class MyApp extends ConsumerWidget {
          @override
          Widget build(BuildContext context, WidgetRef ref) {
            final locale = ref.watch(localeProvider);

            return MaterialApp(
              title: 'Aura',
              locale: locale, // Use the locale from Riverpod
              supportedLocales: const [
                Locale('en'), // English
                Locale('tr'), // Turkish
                // Add more locales here
              ],
              localizationsDelegates: const [
                AppLocalizations.delegate, // Add the generated delegate
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              // ... other MaterialApp properties (theme, home, routes)
            );
          }
        }
        ```

## 6. Changing Language

*   To change the language, simply update the state of the Riverpod `localeProvider`.
    *   *Example:*
        ```dart
        // In a settings screen or language picker
        ElevatedButton(
          onPressed: () {
            ref.read(localeProvider.notifier).setLocale(const Locale('tr'));
          },
          child: Text('Switch to Turkish'),
        );
        ```
*   The app's UI will automatically rebuild with the new locale, fetching the correct translations.

### 6.1. UI for Language Selection

Providing a user-friendly way to change the language is essential. Here's an example using a `PopupMenuButton`:

*   *Example UI Widget:*
    ```dart
    import 'package:flutter/material.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:aura/generated/l10n/app_localizations.dart';
    import 'core/presentation/providers/locale_provider.dart';

    class LanguageSelector extends ConsumerWidget {
      const LanguageSelector({super.key});

      @override
      Widget build(BuildContext context, WidgetRef ref) {
        final currentLocale = ref.watch(localeProvider);

        return PopupMenuButton<Locale>(
          icon: const Icon(Icons.language),
          onSelected: (Locale newLocale) {
            ref.read(localeProvider.notifier).setLocale(newLocale);
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
            PopupMenuItem<Locale>(
              value: const Locale('en'),
              child: Text(AppLocalizations.of(context)!.localeNameEn), // Ensure these keys exist in your ARB files
            ),
            PopupMenuItem<Locale>(
              value: const Locale('tr'),
              child: Text(AppLocalizations.of(context)!.localeNameTr),
            ),
            // Add more languages as needed
          ],
          // Show the currently selected language's name as the button's child
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _getLocaleDisplayName(currentLocale, context),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        );
      }

      String _getLocaleDisplayName(Locale locale, BuildContext context) {
        // Map locale codes to display names using localized strings
        switch (locale.languageCode) {
          case 'en':
            return AppLocalizations.of(context)!.localeNameEn;
          case 'tr':
            return AppLocalizations.of(context)!.localeNameTr;
          default:
            return locale.languageCode.toUpperCase();
        }
      }
    }
    ```
*   *ARB Entries Needed for Above Example:*
    ```json
    // In app_en.arb
    "localeNameEn": "English",
    "localeNameTr": "Turkish"

    // In app_tr.arb
    "localeNameEn": "İngilizce",
    "localeNameTr": "Türkçe"
    ```

## 7. Testing Localized UI

Testing ensures that your UI adapts correctly to different languages and locales.

*   **Widget Tests:** Test individual widgets or screens with different locales to verify text display and layout.
    *   *Example Widget Test Snippet:*
        ```dart
        import 'package:flutter_test/flutter_test.dart';
        import 'package:flutter/material.dart';
        import 'package:flutter_localizations/flutter_localizations.dart';
        import 'package:aura/generated/l10n/app_localizations.dart';
        import 'package:aura/main.dart'; // Assuming MyApp is your root widget

        void main() {
          testWidgets('WardrobeHomeScreen displays localized title in English', (WidgetTester tester) async {
            // Build the app with English locale
            await tester.pumpWidget(
              MaterialApp(
                locale: const Locale('en'),
                supportedLocales: const [Locale('en'), Locale('tr')],
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                home: const WardrobeHomeScreen(), // Your screen to test
              ),
            );

            // Verify the localized text is displayed
            expect(find.text('My Wardrobe'), findsOneWidget);
          });

           testWidgets('WardrobeHomeScreen displays localized title in Turkish', (WidgetTester tester) async {
            await tester.pumpWidget(
              MaterialApp(
                locale: const Locale('tr'),
                supportedLocales: const [Locale('en'), Locale('tr')],
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                home: const WardrobeHomeScreen(),
              ),
            );

            expect(find.text('Gardırobum'), findsOneWidget);
          });
        }
        ```
*   **Golden Tests:** For UIs where layout or text overflow is critical with different text lengths, golden tests can visually capture and compare the UI across locales. See `Flutter Tasarım Sistemi (Material 3 + Atomic Design + Monorepo).pdf` pg 29 for more on golden tests.
    *   *Example Golden Test Concept (requires setup):*
        ```dart
        // test/widget/wardrobe_home_golden_test.dart
        import 'package:flutter_test/flutter_test.dart';
        import 'package:golden_toolkit/golden_toolkit.dart'; // Example package

        void main() {
          testGoldens('WardrobeHomeScreen looks correct in English', (tester) async {
            final builder = DeviceBuilder()
              ..overrideLocale(const Locale('en')) // Set locale for the test
              ..addScenario(
                widget: const MyApp(), // Your app or the specific screen
                name: 'default english',
              );

            await tester.pumpDeviceBuilder(builder);
            await screenMatchesGolden(tester, 'wardrobe_home_screen_en');
          });
        }
        ```

## 8. Best Practices

*   **Centralized Translations:** Keep all translatable strings in ARB files. Avoid hardcoding UI text directly in Dart widgets.
*   **Descriptive Keys:** Use clear and descriptive keys in ARB files for maintainability.
*   **ICU Syntax:** Leverage ICU syntax for placeholders and plurals to handle language-specific rules correctly.
*   **Formatting Libraries:** Use `intl` package's `DateFormat`, `NumberFormat` etc., for date, time, and number formatting based on the current locale.
*   **Testing:** Test the app with different locales to ensure UI elements adapt correctly (text length, layout changes). Consider using golden tests for visual verification if critical. See section 7.
*   **Onboarding (`Dokümantasyon ve Onboarding.pdf`):** Ensure the localization setup is part of the onboarding documentation, including how to add a new language or update translations (`make l10n` or similar command if used).
*   **CI/CD (`CI_CD_GUIDE.md`):** Consider running `flutter gen-l10n` as part of the CI process to ensure ARB files are valid and code is generated.

## 9. Managing Translations

*   **Manual:** Developers or translators directly edit the `.arb` files. Suitable for small teams/languages.
*   **Translation Management System (TMS) (Future):** For larger scale or professional translation workflows, consider integrating with a TMS. This often involves exporting ARB files, uploading to the TMS, translators working within the TMS, and downloading updated ARB files.

### 9.1. Translation Management Systems (TMS)

For projects requiring frequent updates or collaboration with professional translators, a TMS can streamline the workflow. Here are some popular options:

*   **Lokalise:** A comprehensive localization platform offering features like translation memory, glossaries, and integrations with development workflows.
*   **Phrase:** Provides tools for managing translations, including context-based translation, collaboration features, and API/CLI integrations.
*   **POEditor:** A user-friendly tool for managing software translations, supporting various file formats including ARB, and offering collaboration features.
*   **Simple Solutions (e.g., Google Sheets):** For very small teams or simple projects, syncing translations via a shared Google Sheet (using custom scripts or tools) can be a lightweight, albeit less robust, solution.

