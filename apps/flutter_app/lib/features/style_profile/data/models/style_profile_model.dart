import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/style_profile.dart';

part 'style_profile_model.g.dart';

@JsonSerializable(explicitToJson: true)
class StyleProfileModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final String name;
  final String? description;
  final Map<String, dynamic> preferences;
  @JsonKey(name: 'preferred_colors')
  final List<String> preferredColors;
  @JsonKey(name: 'preferred_styles')
  final List<String> preferredStyles;
  @JsonKey(name: 'preferred_brands')
  final List<String> preferredBrands;
  @JsonKey(name: 'avoided_colors')
  final List<String> avoidedColors;
  @JsonKey(name: 'avoided_styles')
  final List<String> avoidedStyles;
  @JsonKey(name: 'body_measurements')
  final Map<String, dynamic> bodyMeasurements;
  @JsonKey(name: 'body_type')
  final String? bodyType;
  @JsonKey(name: 'lifestyle_factors')
  final Map<String, dynamic> lifestyleFactors;
  @JsonKey(name: 'budget_preferences')
  final Map<String, dynamic> budgetPreferences;
  final List<String> occasions;
  @JsonKey(name: 'seasonal_preferences')
  final Map<String, dynamic> seasonalPreferences;
  @JsonKey(name: 'formality_preference')
  final double formalityPreference;
  @JsonKey(name: 'comfort_preference')
  final double comfortPreference;
  final double trendiness;
  final double sustainability;
  @JsonKey(name: 'personality_traits')
  final Map<String, dynamic> personalityTraits;
  @JsonKey(name: 'style_goals')
  final List<String> styleGoals;
  @JsonKey(name: 'social_preferences')
  final Map<String, dynamic> socialPreferences;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'is_default')
  final bool isDefault;
  @JsonKey(name: 'created_at', fromJson: _dateTimeFromString, toJson: _dateTimeToString)
  final DateTime createdAt;
  @JsonKey(name: 'updated_at', fromJson: _dateTimeFromString, toJson: _dateTimeToString)
  final DateTime updatedAt;

  const StyleProfileModel({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.preferences,
    this.preferredColors = const [],
    this.preferredStyles = const [],
    this.preferredBrands = const [],
    this.avoidedColors = const [],
    this.avoidedStyles = const [],
    this.bodyMeasurements = const {},
    this.bodyType,
    this.lifestyleFactors = const {},
    this.budgetPreferences = const {},
    this.occasions = const [],
    this.seasonalPreferences = const {},
    this.formalityPreference = 0.5,
    this.comfortPreference = 0.5,
    this.trendiness = 0.5,
    this.sustainability = 0.5,
    this.personalityTraits = const {},
    this.styleGoals = const [],
    this.socialPreferences = const {},
    this.isActive = true,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StyleProfileModel.fromJson(Map<String, dynamic> json) =>
      _$StyleProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$StyleProfileModelToJson(this);

  StyleProfile toEntity() {
    return StyleProfile(
      id: id,
      userId: userId,
      name: name,
      description: description,
      preferences: preferences,
      preferredColors: preferredColors,
      preferredStyles: preferredStyles,
      preferredBrands: preferredBrands,
      avoidedColors: avoidedColors,
      avoidedStyles: avoidedStyles,
      bodyMeasurements: bodyMeasurements,
      bodyType: bodyType,
      lifestyleFactors: lifestyleFactors,
      budgetPreferences: budgetPreferences,
      occasions: occasions,
      seasonalPreferences: seasonalPreferences,
      formalityPreference: formalityPreference,
      comfortPreference: comfortPreference,
      trendiness: trendiness,
      sustainability: sustainability,
      personalityTraits: personalityTraits,
      styleGoals: styleGoals,
      socialPreferences: socialPreferences,
      isActive: isActive,
      isDefault: isDefault,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory StyleProfileModel.fromEntity(StyleProfile entity) {
    return StyleProfileModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      description: entity.description,
      preferences: entity.preferences,
      preferredColors: entity.preferredColors,
      preferredStyles: entity.preferredStyles,
      preferredBrands: entity.preferredBrands,
      avoidedColors: entity.avoidedColors,
      avoidedStyles: entity.avoidedStyles,
      bodyMeasurements: entity.bodyMeasurements,
      bodyType: entity.bodyType,
      lifestyleFactors: entity.lifestyleFactors,
      budgetPreferences: entity.budgetPreferences,
      occasions: entity.occasions,
      seasonalPreferences: entity.seasonalPreferences,
      formalityPreference: entity.formalityPreference,
      comfortPreference: entity.comfortPreference,
      trendiness: entity.trendiness,
      sustainability: entity.sustainability,
      personalityTraits: entity.personalityTraits,
      styleGoals: entity.styleGoals,
      socialPreferences: entity.socialPreferences,
      isActive: entity.isActive,
      isDefault: entity.isDefault,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  // Helper methods for datetime conversion
  static DateTime _dateTimeFromString(String dateTimeString) {
    return DateTime.parse(dateTimeString);
  }

  static String _dateTimeToString(DateTime dateTime) {
    return dateTime.toIso8601String();
  }
}
