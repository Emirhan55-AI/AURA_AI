import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/profile_model.dart';

/// Supabase implementation of ProfileRepository
/// Handles all profile-related database operations with real Supabase backend
class SupabaseProfileRepository implements ProfileRepository {
  final SupabaseClient _supabase;

  SupabaseProfileRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<Either<Failure, Profile>> getProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      final profileModel = ProfileModel.fromJson(response);
      return Right(profileModel.toEntity());
    } on PostgrestException catch (e) {
      return Left(NetworkFailure.serverError(
        code: e.code, 
        details: 'Failed to get profile: ${e.message}',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Unexpected error occurred',
        details: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, Profile>> getCurrentProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return Left(AuthFailure.notAuthenticated());
      }

      return await getProfile(user.id);
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Failed to get current profile',
        details: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, Profile>> createProfile(Profile profile) async {
    try {
      final profileModel = ProfileModel.fromEntity(profile);
      final response = await _supabase
          .from('profiles')
          .insert(profileModel.toJson())
          .select()
          .single();

      final createdProfile = ProfileModel.fromJson(response);
      return Right(createdProfile.toEntity());
    } on PostgrestException catch (e) {
      return Left(NetworkFailure.serverError(
        code: e.code,
        details: 'Failed to create profile: ${e.message}',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Unexpected error occurred',
        details: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, Profile>> updateProfile(Profile profile) async {
    try {
      final profileModel = ProfileModel.fromEntity(profile);
      final updateData = profileModel.toJson();
      
      // Remove id from update data and ensure updated_at is set
      updateData.remove('id');
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('profiles')
          .update(updateData)
          .eq('id', profile.id)
          .select()
          .single();

      final updatedProfile = ProfileModel.fromJson(response);
      return Right(updatedProfile.toEntity());
    } on PostgrestException catch (e) {
      return Left(NetworkFailure.serverError(
        code: e.code,
        details: 'Failed to update profile: ${e.message}',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Unexpected error occurred',
        details: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProfile(String userId) async {
    try {
      await _supabase
          .from('profiles')
          .delete()
          .eq('id', userId);

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(NetworkFailure.serverError(
        code: e.code,
        details: 'Failed to delete profile: ${e.message}',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Unexpected error occurred',
        details: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> isOnboardingCompleted(String userId) async {
    try {
      final response = await _supabase
          .from('user_onboarding')
          .select('completed, skipped')
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        return const Right(false);
      }

      final completed = response['completed'] as bool? ?? false;
      final skipped = response['skipped'] as bool? ?? false;
      
      return Right(completed || skipped);
    } on PostgrestException catch (e) {
      return Left(NetworkFailure.serverError(
        code: e.code,
        details: 'Failed to check onboarding status: ${e.message}',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Unexpected error occurred',
        details: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, void>> markOnboardingCompleted(String userId) async {
    try {
      await _supabase
          .from('user_onboarding')
          .upsert({
            'user_id': userId,
            'completed': true,
            'skipped': false,
            'completed_at': DateTime.now().toIso8601String(),
          });

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(NetworkFailure.serverError(
        code: e.code,
        details: 'Failed to mark onboarding completed: ${e.message}',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Unexpected error occurred',
        details: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, void>> markOnboardingSkipped(String userId) async {
    try {
      await _supabase
          .from('user_onboarding')
          .upsert({
            'user_id': userId,
            'completed': false,
            'skipped': true,
            'skipped_at': DateTime.now().toIso8601String(),
          });

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(NetworkFailure.serverError(
        code: e.code,
        details: 'Failed to mark onboarding skipped: ${e.message}',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Unexpected error occurred',
        details: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, Profile>> updateStylePreferences(
    String userId,
    Map<String, dynamic> stylePreferences,
  ) async {
    try {
      final response = await _supabase
          .from('profiles')
          .update({
            'style_preferences': stylePreferences,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId)
          .select()
          .single();

      final updatedProfile = ProfileModel.fromJson(response);
      return Right(updatedProfile.toEntity());
    } on PostgrestException catch (e) {
      return Left(NetworkFailure.serverError(
        code: e.code,
        details: 'Failed to update style preferences: ${e.message}',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Unexpected error occurred',
        details: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, Profile>> updateMeasurements(
    String userId,
    Map<String, dynamic> measurements,
  ) async {
    try {
      final response = await _supabase
          .from('profiles')
          .update({
            'measurements': measurements,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId)
          .select()
          .single();

      final updatedProfile = ProfileModel.fromJson(response);
      return Right(updatedProfile.toEntity());
    } on PostgrestException catch (e) {
      return Left(NetworkFailure.serverError(
        code: e.code,
        details: 'Failed to update measurements: ${e.message}',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Unexpected error occurred',
        details: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, Profile>> updatePrivacySettings(
    String userId,
    Map<String, dynamic> privacySettings,
  ) async {
    try {
      final response = await _supabase
          .from('profiles')
          .update({
            'privacy_settings': privacySettings,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId)
          .select()
          .single();

      final updatedProfile = ProfileModel.fromJson(response);
      return Right(updatedProfile.toEntity());
    } on PostgrestException catch (e) {
      return Left(NetworkFailure.serverError(
        code: e.code,
        details: 'Failed to update privacy settings: ${e.message}',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Unexpected error occurred',
        details: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, Profile>> updateNotificationPreferences(
    String userId,
    Map<String, dynamic> notificationPreferences,
  ) async {
    try {
      final response = await _supabase
          .from('profiles')
          .update({
            'notification_preferences': notificationPreferences,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId)
          .select()
          .single();

      final updatedProfile = ProfileModel.fromJson(response);
      return Right(updatedProfile.toEntity());
    } on PostgrestException catch (e) {
      return Left(NetworkFailure.serverError(
        code: e.code,
        details: 'Failed to update notification preferences: ${e.message}',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Unexpected error occurred',
        details: e.toString(),
      ));
    }
  }

  /// Get user statistics from database
  Future<Either<Failure, Map<String, int>>> getUserStats(String userId) async {
    try {
      // Get combinations count
      final combinationsResponse = await _supabase
          .from('outfit_combinations')
          .select('id')
          .eq('user_id', userId);

      // Get favorites count  
      final favoritesResponse = await _supabase
          .from('user_favorites')
          .select('id')
          .eq('user_id', userId);

      // Get followers count
      final followersResponse = await _supabase
          .from('user_follows')
          .select('id')
          .eq('following_id', userId);

      // Get following count
      final followingResponse = await _supabase
          .from('user_follows')
          .select('id')
          .eq('follower_id', userId);

      return Right({
        'combinations': combinationsResponse.length,
        'favorites': favoritesResponse.length,
        'followers': followersResponse.length,
        'following': followingResponse.length,
      });
    } on PostgrestException catch (e) {
      return Left(NetworkFailure.serverError(
        code: e.code,
        details: 'Failed to get user stats: ${e.message}',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Unexpected error occurred',
        details: e.toString(),
      ));
    }
  }

  /// Update user avatar with image upload
  Future<Either<Failure, String>> updateAvatar(String userId, Uint8List imageData) async {
    try {
      // Upload image to Supabase storage
      final fileName = 'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final response = await _supabase.storage
          .from('profile-images')
          .uploadBinary('avatars/$fileName', imageData);

      if (response.isEmpty) {
        return Left(ServiceFailure(
          message: 'Failed to upload avatar image',
        ));
      }

      // Get public URL
      final imageUrl = _supabase.storage
          .from('profile-images')
          .getPublicUrl('avatars/$fileName');

      // Update profile with new avatar URL
      await _supabase
          .from('profiles')
          .update({
            'avatar_url': imageUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      return Right(imageUrl);
    } on StorageException catch (e) {
      return Left(ServiceFailure(
        message: 'Failed to upload avatar',
        details: e.message,
      ));
    } on PostgrestException catch (e) {
      return Left(NetworkFailure.serverError(
        code: e.code,
        details: 'Failed to update avatar URL: ${e.message}',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Unexpected error occurred',
        details: e.toString(),
      ));
    }
  }
}
