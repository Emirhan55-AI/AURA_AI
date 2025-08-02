import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/style_profile.dart';

abstract class StyleProfileRepository {
  /// Get all style profiles for the current user
  Future<Either<Failure, List<StyleProfile>>> getStyleProfiles();
  
  /// Get style profile by ID
  Future<Either<Failure, StyleProfile>> getStyleProfile(String profileId);
  
  /// Get the active/default style profile for the user
  Future<Either<Failure, StyleProfile>> getActiveStyleProfile();
  
  /// Create a new style profile
  Future<Either<Failure, StyleProfile>> createStyleProfile(StyleProfile profile);
  
  /// Update existing style profile
  Future<Either<Failure, StyleProfile>> updateStyleProfile(StyleProfile profile);
  
  /// Delete style profile
  Future<Either<Failure, void>> deleteStyleProfile(String profileId);
  
  /// Set a profile as active/default
  Future<Either<Failure, StyleProfile>> setActiveProfile(String profileId);
  
  /// Create default style profile (for onboarding skip)
  Future<Either<Failure, StyleProfile>> createDefaultProfile(String userId);
  
  /// Update style preferences from onboarding
  Future<Either<Failure, StyleProfile>> updateFromOnboarding(
    String profileId,
    Map<String, dynamic> onboardingData,
  );
  
  /// Get profiles by style compatibility
  Future<Either<Failure, List<StyleProfile>>> getCompatibleProfiles(
    StyleProfile referenceProfile,
    {double minCompatibility = 0.7}
  );
  
  /// Calculate style recommendations based on profile
  Future<Either<Failure, Map<String, dynamic>>> getStyleRecommendations(
    String profileId,
  );
  
  /// Update color preferences
  Future<Either<Failure, StyleProfile>> updateColorPreferences(
    String profileId,
    List<String> preferredColors,
    List<String> avoidedColors,
  );
  
  /// Update style preferences
  Future<Either<Failure, StyleProfile>> updateStylePreferences(
    String profileId,
    List<String> preferredStyles,
    List<String> avoidedStyles,
  );
  
  /// Update body measurements
  Future<Either<Failure, StyleProfile>> updateBodyMeasurements(
    String profileId,
    Map<String, dynamic> measurements,
  );
  
  /// Update lifestyle factors
  Future<Either<Failure, StyleProfile>> updateLifestyleFactors(
    String profileId,
    Map<String, dynamic> lifestyleFactors,
  );
  
  /// Update budget preferences
  Future<Either<Failure, StyleProfile>> updateBudgetPreferences(
    String profileId,
    Map<String, dynamic> budgetPreferences,
  );
}
