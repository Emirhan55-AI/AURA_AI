class Profile {
  final String id;
  final String userId;
  final String? displayName;
  final String? avatar;
  final String? bio;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? location;
  final Map<String, dynamic>? preferredStyle;
  final Map<String, dynamic>? measurements;
  final Map<String, dynamic>? stylePreferences;
  final String? bodyType;
  final List<String>? colorPalette;
  final List<String>? styleGoals;
  final Map<String, dynamic>? budgetRange;
  final bool onboardingCompleted;
  final bool onboardingSkipped;
  final Map<String, dynamic>? privacySettings;
  final Map<String, dynamic>? notificationPreferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Profile({
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

  @override
  String toString() {
    return 'Profile(id: $id, userId: $userId, displayName: $displayName, onboardingCompleted: $onboardingCompleted)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Profile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  Profile copyWith({
    String? id,
    String? userId,
    String? displayName,
    String? avatar,
    String? bio,
    DateTime? dateOfBirth,
    String? gender,
    String? location,
    Map<String, dynamic>? preferredStyle,
    Map<String, dynamic>? measurements,
    Map<String, dynamic>? stylePreferences,
    String? bodyType,
    List<String>? colorPalette,
    List<String>? styleGoals,
    Map<String, dynamic>? budgetRange,
    bool? onboardingCompleted,
    bool? onboardingSkipped,
    Map<String, dynamic>? privacySettings,
    Map<String, dynamic>? notificationPreferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      preferredStyle: preferredStyle ?? this.preferredStyle,
      measurements: measurements ?? this.measurements,
      stylePreferences: stylePreferences ?? this.stylePreferences,
      bodyType: bodyType ?? this.bodyType,
      colorPalette: colorPalette ?? this.colorPalette,
      styleGoals: styleGoals ?? this.styleGoals,
      budgetRange: budgetRange ?? this.budgetRange,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      onboardingSkipped: onboardingSkipped ?? this.onboardingSkipped,
      privacySettings: privacySettings ?? this.privacySettings,
      notificationPreferences: notificationPreferences ?? this.notificationPreferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
