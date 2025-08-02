import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/profile.dart';

abstract class ProfileRepository {
  /// Get profile by user ID
  Future<Either<Failure, Profile>> getProfile(String userId);
  
  /// Get current user's profile
  Future<Either<Failure, Profile>> getCurrentProfile();
  
  /// Create a new profile
  Future<Either<Failure, Profile>> createProfile(Profile profile);
  
  /// Update existing profile
  Future<Either<Failure, Profile>> updateProfile(Profile profile);
  
  /// Delete profile (soft delete)
  Future<Either<Failure, void>> deleteProfile(String userId);
  
  /// Check if onboarding is completed
  Future<Either<Failure, bool>> isOnboardingCompleted(String userId);
  
  /// Mark onboarding as completed
  Future<Either<Failure, void>> markOnboardingCompleted(String userId);
  
  /// Mark onboarding as skipped
  Future<Either<Failure, void>> markOnboardingSkipped(String userId);
  
  /// Update style preferences
  Future<Either<Failure, Profile>> updateStylePreferences(
    String userId, 
    Map<String, dynamic> stylePreferences,
  );
  
  /// Update measurements
  Future<Either<Failure, Profile>> updateMeasurements(
    String userId, 
    Map<String, dynamic> measurements,
  );
  
  /// Update privacy settings
  Future<Either<Failure, Profile>> updatePrivacySettings(
    String userId, 
    Map<String, dynamic> privacySettings,
  );
  
  /// Update notification preferences
  Future<Either<Failure, Profile>> updateNotificationPreferences(
    String userId, 
    Map<String, dynamic> notificationPreferences,
  );
}
