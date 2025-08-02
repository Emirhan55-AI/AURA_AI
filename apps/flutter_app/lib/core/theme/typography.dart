import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography configuration for Aura application
/// Implements dual-font strategy as per STYLE_GUIDE.md:
/// - Urbanist for headings (Display, Headline, Title styles)
/// - Inter for body text (Body, Label styles)
class AuraTypography {
  // Private constructor to prevent instantiation
  AuraTypography._();

  /// Complete text theme implementing dual-font strategy
  /// Based on Material 3 text theme with Urbanist + Inter fonts
  static TextTheme get textTheme => TextTheme(
    // Display styles - Urbanist font family
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    
    // Headline styles - Urbanist font family
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    
    // Title styles - Urbanist font family
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    
    // Body styles - Inter font family
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    
    // Label styles - Inter font family
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );

  // DISPLAY STYLES - URBANIST FONT FAMILY
  
  /// Display Large - Urbanist font
  /// Usage: App title on splash screen, hero headlines
  static TextStyle get displayLarge => GoogleFonts.urbanist(
        fontSize: 57,
        fontWeight: FontWeight.w300, // Light
        letterSpacing: -0.25,
        height: 64.0 / 57.0, // Line height / font size
      );

  /// Display Medium - Urbanist font
  /// Usage: Section titles on landing pages
  static TextStyle get displayMedium => GoogleFonts.urbanist(
        fontSize: 45,
        fontWeight: FontWeight.w300, // Light
        letterSpacing: 0,
        height: 52.0 / 45.0,
      );

  /// Display Small - Urbanist font
  /// Usage: Card titles for major sections
  static TextStyle get displaySmall => GoogleFonts.urbanist(
        fontSize: 36,
        fontWeight: FontWeight.w400, // Regular
        letterSpacing: 0,
        height: 44.0 / 36.0,
      );

  // HEADLINE STYLES - URBANIST FONT FAMILY
  
  /// Headline Large - Urbanist font
  /// Usage: Screen titles
  static TextStyle get headlineLarge => GoogleFonts.urbanist(
        fontSize: 32,
        fontWeight: FontWeight.w400, // Regular
        letterSpacing: 0,
        height: 40.0 / 32.0,
      );

  /// Headline Medium - Urbanist font
  /// Usage: Subsection titles within a screen
  static TextStyle get headlineMedium => GoogleFonts.urbanist(
        fontSize: 28,
        fontWeight: FontWeight.w400, // Regular
        letterSpacing: 0,
        height: 36.0 / 28.0,
      );

  /// Headline Small - Urbanist font
  /// Usage: Card titles, dialog titles
  static TextStyle get headlineSmall => GoogleFonts.urbanist(
        fontSize: 24,
        fontWeight: FontWeight.w400, // Regular
        letterSpacing: 0,
        height: 32.0 / 24.0,
      );

  // TITLE STYLES - URBANIST FONT FAMILY
  
  /// Title Large - Urbanist font
  /// Usage: List item titles
  static TextStyle get titleLarge => GoogleFonts.urbanist(
        fontSize: 22,
        fontWeight: FontWeight.w400, // Regular
        letterSpacing: 0,
        height: 28.0 / 22.0,
      );

  /// Title Medium - Urbanist font
  /// Usage: Prominent body text, emphasized text within paragraphs
  static TextStyle get titleMedium => GoogleFonts.urbanist(
        fontSize: 16,
        fontWeight: FontWeight.w500, // Medium
        letterSpacing: 0.15,
        height: 24.0 / 16.0,
      );

  /// Title Small - Urbanist font
  /// Usage: Button text, less prominent card titles
  static TextStyle get titleSmall => GoogleFonts.urbanist(
        fontSize: 14,
        fontWeight: FontWeight.w500, // Medium
        letterSpacing: 0.1,
        height: 20.0 / 14.0,
      );

  // BODY STYLES - INTER FONT FAMILY
  
  /// Body Large - Inter font
  /// Usage: Main paragraph text
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400, // Regular
        letterSpacing: 0.5,
        height: 24.0 / 16.0,
      );

  /// Body Medium - Inter font
  /// Usage: Secondary text, captions
  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400, // Regular
        letterSpacing: 0.25,
        height: 20.0 / 14.0,
      );

  /// Body Small - Inter font
  /// Usage: Helper text, disabled text, fine print
  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400, // Regular
        letterSpacing: 0.4,
        height: 16.0 / 12.0,
      );

  // LABEL STYLES - INTER FONT FAMILY
  
  /// Label Large - Inter font
  /// Usage: Primary button text
  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500, // Medium
        letterSpacing: 0.1,
        height: 20.0 / 14.0,
      );

  /// Label Medium - Inter font
  /// Usage: Outlined button text, text field labels
  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500, // Medium
        letterSpacing: 0.5,
        height: 16.0 / 12.0,
      );

  /// Label Small - Inter font
  /// Usage: Chip text, small tags, input hints
  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500, // Medium
        letterSpacing: 0.5,
        height: 16.0 / 11.0,
      );

  /// Apply the text theme to a specific color scheme
  /// This ensures text colors are properly applied based on theme
  static TextTheme applyToColorScheme(ColorScheme colorScheme) {
    return textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );
  }
}
