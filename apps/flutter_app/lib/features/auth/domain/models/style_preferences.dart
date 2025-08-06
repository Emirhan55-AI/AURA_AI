import 'package:freezed_annotation/freezed_annotation.dart';

part 'style_preferences.freezed.dart';
part 'style_preferences.g.dart';

@freezed
class StylePreferences with _$StylePreferences {
  const factory StylePreferences({
    required List<String> favoriteColors,
    required List<String> favoriteStyles,
    required List<String> occasions,
    required Map<String, double> styleScores,
    required bool sustainabilityFocus,
    required Map<String, bool> preferences,
  }) = _StylePreferences;

  factory StylePreferences.fromJson(Map<String, dynamic> json) =>
      _$StylePreferencesFromJson(json);
  
  factory StylePreferences.empty() => const StylePreferences(
    favoriteColors: [],
    favoriteStyles: [],
    occasions: [],
    styleScores: {},
    sustainabilityFocus: false,
    preferences: {},
  );
}
