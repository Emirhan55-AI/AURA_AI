import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/profile.dart';

part 'profile_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ProfileModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'display_name')
  final String? displayName;
  final String? avatar;
  final String? bio;
  @JsonKey(name: 'date_of_birth', fromJson: _dateFromString, toJson: _dateToString)
  final DateTime? dateOfBirth;
  final String? gender;
  final String? location;
  @JsonKey(name: 'preferred_style')
  final Map<String, dynamic>? preferredStyle;
  final Map<String, dynamic>? measurements;
  @JsonKey(name: 'style_preferences')
  final Map<String, dynamic>? stylePreferences;
  @JsonKey(name: 'body_type')
  final String? bodyType;
  @JsonKey(name: 'color_palette')
  final List<String>? colorPalette;
  @JsonKey(name: 'style_goals')
  final List<String>? styleGoals;
  @JsonKey(name: 'budget_range')
  final Map<String, dynamic>? budgetRange;
  @JsonKey(name: 'onboarding_completed')
  final bool onboardingCompleted;
  @JsonKey(name: 'onboarding_skipped')
  final bool onboardingSkipped;
  @JsonKey(name: 'privacy_settings')
  final Map<String, dynamic>? privacySettings;
  @JsonKey(name: 'notification_preferences')
  final Map<String, dynamic>? notificationPreferences;
  @JsonKey(name: 'created_at', fromJson: _dateTimeFromString, toJson: _dateTimeToString)
  final DateTime createdAt;
  @JsonKey(name: 'updated_at', fromJson: _dateTimeFromString, toJson: _dateTimeToString)
  final DateTime updatedAt;

  const ProfileModel({
    required this.id,
    required this.userId,
    this.displayName,
    this.avatar,
    this.bio,
    this.dateOfBirth,
    this.gender,
    this.location,
    this.preferredStyle,
    this.measurements,
    this.stylePreferences,
    this.bodyType,
    this.colorPalette,
    this.styleGoals,
    this.budgetRange,
    this.onboardingCompleted = false,
    this.onboardingSkipped = false,
    this.privacySettings,
    this.notificationPreferences,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);

  Profile toEntity() {
    return Profile(
      id: id,
      userId: userId,
      displayName: displayName,
      avatar: avatar,
      bio: bio,
      dateOfBirth: dateOfBirth,
      gender: gender,
      location: location,
      preferredStyle: preferredStyle,
      measurements: measurements,
      stylePreferences: stylePreferences,
      bodyType: bodyType,
      colorPalette: colorPalette,
      styleGoals: styleGoals,
      budgetRange: budgetRange,
      onboardingCompleted: onboardingCompleted,
      onboardingSkipped: onboardingSkipped,
      privacySettings: privacySettings,
      notificationPreferences: notificationPreferences,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory ProfileModel.fromEntity(Profile entity) {
    return ProfileModel(
      id: entity.id,
      userId: entity.userId,
      displayName: entity.displayName,
      avatar: entity.avatar,
      bio: entity.bio,
      dateOfBirth: entity.dateOfBirth,
      gender: entity.gender,
      location: entity.location,
      preferredStyle: entity.preferredStyle,
      measurements: entity.measurements,
      stylePreferences: entity.stylePreferences,
      bodyType: entity.bodyType,
      colorPalette: entity.colorPalette,
      styleGoals: entity.styleGoals,
      budgetRange: entity.budgetRange,
      onboardingCompleted: entity.onboardingCompleted,
      onboardingSkipped: entity.onboardingSkipped,
      privacySettings: entity.privacySettings,
      notificationPreferences: entity.notificationPreferences,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  // Helper methods for date/datetime conversion
  static DateTime? _dateFromString(String? dateString) {
    if (dateString == null) return null;
    return DateTime.tryParse(dateString);
  }

  static String? _dateToString(DateTime? date) {
    if (date == null) return null;
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  static DateTime _dateTimeFromString(String dateTimeString) {
    return DateTime.parse(dateTimeString);
  }

  static String _dateTimeToString(DateTime dateTime) {
    return dateTime.toIso8601String();
  }
}
