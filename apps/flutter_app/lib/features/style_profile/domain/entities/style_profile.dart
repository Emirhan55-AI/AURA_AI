class StyleProfile {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final Map<String, dynamic> preferences;
  final List<String> preferredColors;
  final List<String> preferredStyles;
  final List<String> preferredBrands;
  final List<String> avoidedColors;
  final List<String> avoidedStyles;
  final Map<String, dynamic> bodyMeasurements;
  final String? bodyType;
  final Map<String, dynamic> lifestyleFactors;
  final Map<String, dynamic> budgetPreferences;
  final List<String> occasions;
  final Map<String, dynamic> seasonalPreferences;
  final double formalityPreference;
  final double comfortPreference;
  final double trendiness;
  final double sustainability;
  final Map<String, dynamic> personalityTraits;
  final List<String> styleGoals;
  final Map<String, dynamic> socialPreferences;
  final bool isActive;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StyleProfile({
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

  /// Default style profile for users who skip onboarding
  static StyleProfile createDefault({
    required String id,
    required String userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    return StyleProfile(
      id: id,
      userId: userId,
      name: 'Default Style',
      description: 'Auto-generated default style profile',
      preferences: const {
        'mood': 'neutral',
        'style': 'casual',
        'formality': 0.3,
        'comfort': 0.7,
        'trendiness': 0.4,
      },
      preferredColors: const ['beige', 'gray', 'navy', 'white', 'black'],
      preferredStyles: const ['casual', 'business-casual'],
      formalityPreference: 0.3,
      comfortPreference: 0.7,
      trendiness: 0.4,
      sustainability: 0.5,
      isDefault: true,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  @override
  String toString() {
    return 'StyleProfile(id: $id, userId: $userId, name: $name, isDefault: $isDefault, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StyleProfile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  StyleProfile copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    Map<String, dynamic>? preferences,
    List<String>? preferredColors,
    List<String>? preferredStyles,
    List<String>? preferredBrands,
    List<String>? avoidedColors,
    List<String>? avoidedStyles,
    Map<String, dynamic>? bodyMeasurements,
    String? bodyType,
    Map<String, dynamic>? lifestyleFactors,
    Map<String, dynamic>? budgetPreferences,
    List<String>? occasions,
    Map<String, dynamic>? seasonalPreferences,
    double? formalityPreference,
    double? comfortPreference,
    double? trendiness,
    double? sustainability,
    Map<String, dynamic>? personalityTraits,
    List<String>? styleGoals,
    Map<String, dynamic>? socialPreferences,
    bool? isActive,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StyleProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      preferences: preferences ?? this.preferences,
      preferredColors: preferredColors ?? this.preferredColors,
      preferredStyles: preferredStyles ?? this.preferredStyles,
      preferredBrands: preferredBrands ?? this.preferredBrands,
      avoidedColors: avoidedColors ?? this.avoidedColors,
      avoidedStyles: avoidedStyles ?? this.avoidedStyles,
      bodyMeasurements: bodyMeasurements ?? this.bodyMeasurements,
      bodyType: bodyType ?? this.bodyType,
      lifestyleFactors: lifestyleFactors ?? this.lifestyleFactors,
      budgetPreferences: budgetPreferences ?? this.budgetPreferences,
      occasions: occasions ?? this.occasions,
      seasonalPreferences: seasonalPreferences ?? this.seasonalPreferences,
      formalityPreference: formalityPreference ?? this.formalityPreference,
      comfortPreference: comfortPreference ?? this.comfortPreference,
      trendiness: trendiness ?? this.trendiness,
      sustainability: sustainability ?? this.sustainability,
      personalityTraits: personalityTraits ?? this.personalityTraits,
      styleGoals: styleGoals ?? this.styleGoals,
      socialPreferences: socialPreferences ?? this.socialPreferences,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Calculate style compatibility score with another profile (0.0 to 1.0)
  double calculateCompatibilityWith(StyleProfile other) {
    double colorScore = _calculateListCompatibility(preferredColors, other.preferredColors);
    double styleScore = _calculateListCompatibility(preferredStyles, other.preferredStyles);
    double formalityScore = 1.0 - (formalityPreference - other.formalityPreference).abs();
    double comfortScore = 1.0 - (comfortPreference - other.comfortPreference).abs();
    double trendinessScore = 1.0 - (trendiness - other.trendiness).abs();
    
    return (colorScore + styleScore + formalityScore + comfortScore + trendinessScore) / 5.0;
  }

  /// Calculate preference strength for a specific category (0.0 to 1.0)
  double getPreferenceStrength(String category) {
    switch (category.toLowerCase()) {
      case 'formality':
        return formalityPreference;
      case 'comfort':
        return comfortPreference;
      case 'trendiness':
        return trendiness;
      case 'sustainability':
        return sustainability;
      default:
        return preferences[category]?.toDouble() ?? 0.5;
    }
  }

  /// Check if a color is preferred
  bool isColorPreferred(String color) {
    return preferredColors.contains(color.toLowerCase());
  }

  /// Check if a color should be avoided
  bool isColorAvoided(String color) {
    return avoidedColors.contains(color.toLowerCase());
  }

  /// Check if a style is preferred
  bool isStylePreferred(String style) {
    return preferredStyles.contains(style.toLowerCase());
  }

  /// Get the dominant style preference
  String? get dominantStyle {
    if (preferredStyles.isEmpty) return null;
    return preferredStyles.first;
  }

  /// Get the dominant color preference
  String? get dominantColor {
    if (preferredColors.isEmpty) return null;
    return preferredColors.first;
  }

  // Helper method to calculate compatibility between two lists
  double _calculateListCompatibility(List<String> list1, List<String> list2) {
    if (list1.isEmpty || list2.isEmpty) return 0.5;
    
    final set1 = list1.map((e) => e.toLowerCase()).toSet();
    final set2 = list2.map((e) => e.toLowerCase()).toSet();
    final intersection = set1.intersection(set2);
    final union = set1.union(set2);
    
    return union.isEmpty ? 0.0 : intersection.length / union.length;
  }
}
