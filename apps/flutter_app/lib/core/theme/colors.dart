import 'package:flutter/material.dart';

/// Custom color palette for Aura application
/// Primary color source: Aura's signature "Warm Coral" (#FF6F61)
/// Designed to create a warm, personal, and accessible user experience
class AuraColors {
  // Private constructor to prevent instantiation
  AuraColors._();

  /// Aura's signature warm coral color (#FF6F61)
  /// This color embodies Aura's warm and personal brand identity
  static const Color warmCoral = Color(0xFFFF6F61);

  /// Secondary warm accent colors
  static const Color softPeach = Color(0xFFFFB3A7);
  static const Color deepCoral = Color(0xFFE55A4F);

  /// Neutral colors for backgrounds and surfaces (warm-toned)
  static const Color warmWhite = Color(0xFFFFFBF8);
  static const Color warmGrey50 = Color(0xFFFAF8F6);
  static const Color warmGrey100 = Color(0xFFF5F2F0);
  static const Color warmGrey200 = Color(0xFFEAE6E3);
  static const Color warmGrey300 = Color(0xFFD6D0CC);
  static const Color warmGrey400 = Color(0xFFB8ADA7);
  static const Color warmGrey500 = Color(0xFF9A8A82);
  static const Color warmGrey600 = Color(0xFF7C685D);
  static const Color warmGrey700 = Color(0xFF5E4538);
  static const Color warmGrey800 = Color(0xFF402213);
  static const Color warmGrey900 = Color(0xFF2A1A0F);

  /// Dark theme specific colors (maintaining warmth)
  static const Color darkSurface = Color(0xFF1A1612);
  static const Color darkBackground = Color(0xFF141210);
  static const Color darkSurfaceVariant = Color(0xFF1F1C18);

  /// Success, warning, and error colors (warm-toned variants)
  static const Color warmSuccess = Color(0xFF4CAF50);
  static const Color warmWarning = Color(0xFFFF9800);
  static const Color warmError = Color(0xFFE57373);

  /// Additional accent colors for variety
  static const Color warmTeal = Color(0xFF26A69A);
  static const Color warmAmber = Color(0xFFFFC107);
  static const Color warmPurple = Color(0xFFAB47BC);
}
