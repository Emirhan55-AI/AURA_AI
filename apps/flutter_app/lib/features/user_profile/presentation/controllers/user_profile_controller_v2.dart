import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/user_analytics.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../data/repositories/supabase_profile_repository.dart';
import '../../../authentication/domain/repositories/auth_repository.dart';
import '../../../authentication/data/repositories/auth_repository_impl.dart';
import '../../../../core/services/image_upload_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'user_profile_controller_v2.g.dart';

/// Data class for user profile information used in the UI
class UserProfileData {
  final String id;
  final String displayName;
  final String username;
  final String bio;
  final String? avatarUrl;
  final int auraScore;
  final String auraLevel;
  final double auraProgress; // 0.0 to 1.0

  const UserProfileData({
    required this.id,
    required this.displayName,
    required this.username,
    required this.bio,
    this.avatarUrl,
    required this.auraScore,
    required this.auraLevel,
    required this.auraProgress,
  });

  UserProfileData copyWith({
    String? id,
    String? displayName,
    String? username,
    String? bio,
    String? avatarUrl,
    int? auraScore,
    String? auraLevel,
    double? auraProgress,
  }) {
    return UserProfileData(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      auraScore: auraScore ?? this.auraScore,
      auraLevel: auraLevel ?? this.auraLevel,
      auraProgress: auraProgress ?? this.auraProgress,
    );
  }
}

/// Data class for user statistics
class UserStatsData {
  final int combinations;
  final int favorites;
  final int followers;
  final int following;

  const UserStatsData({
    required this.combinations,
    required this.favorites,
    required this.followers,
    required this.following,
  });

  UserStatsData copyWith({
    int? combinations,
    int? favorites,
    int? followers,
    int? following,
  }) {
    return UserStatsData(
      combinations: combinations ?? this.combinations,
      favorites: favorites ?? this.favorites,
      followers: followers ?? this.followers,
      following: following ?? this.following,
    );
  }
}

/// Controller state for user profile
class UserProfileState {
  final AsyncValue<UserProfileData> userProfile;
  final AsyncValue<UserStatsData> userStats;
  final AsyncValue<UserAnalytics> userAnalytics;
  final String selectedTab;
  final List<String> availableTabs;
  final bool isUpdatingAvatar;

  const UserProfileState({
    required this.userProfile,
    required this.userStats,
    required this.userAnalytics,
    required this.selectedTab,
    required this.availableTabs,
    this.isUpdatingAvatar = false,
  });

  UserProfileState copyWith({
    AsyncValue<UserProfileData>? userProfile,
    AsyncValue<UserStatsData>? userStats,
    AsyncValue<UserAnalytics>? userAnalytics,
    String? selectedTab,
    List<String>? availableTabs,
    bool? isUpdatingAvatar,
  }) {
    return UserProfileState(
      userProfile: userProfile ?? this.userProfile,
      userStats: userStats ?? this.userStats,
      userAnalytics: userAnalytics ?? this.userAnalytics,
      selectedTab: selectedTab ?? this.selectedTab,
      availableTabs: availableTabs ?? this.availableTabs,
      isUpdatingAvatar: isUpdatingAvatar ?? this.isUpdatingAvatar,
    );
  }
}

// Providers
@riverpod
ProfileRepository profileRepository(ProfileRepositoryRef ref) {
  return SupabaseProfileRepository();
}

@riverpod
ImageUploadService imageUploadService(ImageUploadServiceRef ref) {
  return ImageUploadService(Supabase.instance.client);
}

@riverpod
WardrobeRepository userWardrobeRepository(UserWardrobeRepositoryRef ref) {
  return const SupabaseWardrobeRepository(supabase: null);
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl();
}

/// Real backend-integrated controller for user profile state management
@riverpod
class UserProfileControllerV2 extends _$UserProfileControllerV2 {
  @override
  UserProfileState build() {
    // Load initial data when controller is first created
    _loadInitialData();

    return UserProfileState(
      userProfile: const AsyncValue.loading(),
      userStats: const AsyncValue.loading(),
      userAnalytics: const AsyncValue.loading(),
      selectedTab: 'My Combinations',
      availableTabs: const [
        'My Combinations',
        'My Favorites',
        'My Likes',
        'Social Shares',
        'Communities',
        'Analytics',
      ],
    );
  }

  /// Load all initial profile data from backend
  Future<void> _loadInitialData() async {
    await Future.wait([
      loadProfile(),
      loadStats(),
      loadAnalytics(),
    ]);
  }

  /// Load user profile data from Supabase
  Future<void> loadProfile() async {
    state = state.copyWith(
      userProfile: const AsyncValue.loading(),
    );

    final repository = ref.read(profileRepositoryProvider);
    final result = await repository.getCurrentProfile();

    result.fold(
      (failure) {
        state = state.copyWith(
          userProfile: AsyncValue.error(failure.message, StackTrace.current),
        );
      },
      (profile) {
        // Convert domain Profile to UI UserProfileData
        final userProfileData = _convertProfileToUserData(profile);
        state = state.copyWith(
          userProfile: AsyncValue.data(userProfileData),
        );
      },
    );
  }

  /// Convert domain Profile to UI UserProfileData with calculated Aura score
  UserProfileData _convertProfileToUserData(Profile profile) {
    // Calculate Aura score based on profile completeness and activity
    final auraScore = _calculateAuraScore(profile);
    final auraLevel = _getAuraLevel(auraScore);
    final auraProgress = _getAuraProgress(auraScore);

    return UserProfileData(
      id: profile.id,
      displayName: profile.displayName ?? 'Aura User',
      username: '@${profile.displayName?.toLowerCase().replaceAll(' ', '_') ?? 'aura_user'}',
      bio: profile.bio ?? 'Welcome to my style journey!',
      avatarUrl: profile.avatar,
      auraScore: auraScore,
      auraLevel: auraLevel,
      auraProgress: auraProgress,
    );
  }

  /// Calculate Aura score based on profile and activity data
  int _calculateAuraScore(Profile profile) {
    int score = 0;

    // Base score for having a profile
    score += 100;

    // Profile completeness bonus
    if (profile.displayName != null) score += 50;
    if (profile.bio != null && profile.bio!.isNotEmpty) score += 75;
    if (profile.avatar != null) score += 100;
    if (profile.dateOfBirth != null) score += 25;
    if (profile.location != null) score += 25;

    // Style preferences bonus
    if (profile.stylePreferences != null && profile.stylePreferences!.isNotEmpty) {
      score += 150;
    }

    // Measurements bonus (shows commitment)
    if (profile.measurements != null && profile.measurements!.isNotEmpty) {
      score += 100;
    }

    // Onboarding completion bonus
    if (profile.onboardingCompleted) score += 200;

    // Privacy settings (shows engagement)
    if (profile.privacySettings != null) score += 50;

    return score;
  }

  /// Get Aura level based on score
  String _getAuraLevel(int score) {
    if (score >= 800) return 'Style Icon';
    if (score >= 600) return 'Style Maven';
    if (score >= 400) return 'Style Explorer';
    if (score >= 200) return 'Style Starter';
    return 'New Stylish';
  }

  /// Get Aura progress (0.0 to 1.0) for current level
  double _getAuraProgress(int score) {
    if (score >= 800) return 1.0;
    if (score >= 600) return (score - 600) / 200.0;
    if (score >= 400) return (score - 400) / 200.0;
    if (score >= 200) return (score - 200) / 200.0;
    return score / 200.0;
  }

  /// Load user statistics from backend
  Future<void> loadStats() async {
    state = state.copyWith(
      userStats: const AsyncValue.loading(),
    );

    try {
      final repository = ref.read(profileRepositoryProvider) as SupabaseProfileRepository;
      final authRepo = ref.read(authRepositoryProvider);
      
      // Get current user
      final userResult = await authRepo.getCurrentUser();
      if (userResult.isLeft()) {
        state = state.copyWith(
          userStats: AsyncValue.error('No authenticated user', StackTrace.current),
        );
        return;
      }

      final user = userResult.getOrElse(() => throw Exception('No user'));
      final statsResult = await repository.getUserStats(user.id);

      statsResult.fold(
        (failure) {
          state = state.copyWith(
            userStats: AsyncValue.error(failure.message, StackTrace.current),
          );
        },
        (stats) {
          final userStats = UserStatsData(
            combinations: stats['combinations'] ?? 0,
            favorites: stats['favorites'] ?? 0,
            followers: stats['followers'] ?? 0,
            following: stats['following'] ?? 0,
          );
          state = state.copyWith(
            userStats: AsyncValue.data(userStats),
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        userStats: AsyncValue.error(e.toString(), StackTrace.current),
      );
    }
  }

  /// Load user analytics from wardrobe data
  Future<void> loadAnalytics() async {
    state = state.copyWith(
      userAnalytics: const AsyncValue.loading(),
    );

    try {
      final wardrobeRepository = ref.read(userWardrobeRepositoryProvider);
      final authRepo = ref.read(authRepositoryProvider);
      
      // Get current user
      final userResult = await authRepo.getCurrentUser();
      if (userResult.isLeft()) {
        state = state.copyWith(
          userAnalytics: AsyncValue.error('No authenticated user', StackTrace.current),
        );
        return;
      }

      final user = userResult.getOrElse(() => throw Exception('No user'));
      final analyticsResult = await wardrobeRepository.getUserAnalytics(user.id);

      analyticsResult.fold(
        (failure) {
          state = state.copyWith(
            userAnalytics: AsyncValue.error(failure.message, StackTrace.current),
          );
        },
        (analytics) {
          state = state.copyWith(
            userAnalytics: AsyncValue.data(analytics),
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        userAnalytics: AsyncValue.error(e.toString(), StackTrace.current),
      );
    }
  }

  /// Update user profile information
  Future<void> updateProfile({
    String? displayName,
    String? bio,
    String? location,
    Map<String, dynamic>? stylePreferences,
  }) async {
    final currentProfile = state.userProfile.value;
    if (currentProfile == null) return;

    final repository = ref.read(profileRepositoryProvider);
    
    try {
      // Get the current full profile from backend
      final profileResult = await repository.getCurrentProfile();
      if (profileResult.isLeft()) return;

      final profile = profileResult.getOrElse(() => throw Exception('No profile'));
      
      // Create updated profile
      final updatedProfile = Profile(
        id: profile.id,
        userId: profile.userId,
        displayName: displayName ?? profile.displayName,
        avatar: profile.avatar,
        bio: bio ?? profile.bio,
        dateOfBirth: profile.dateOfBirth,
        gender: profile.gender,
        location: location ?? profile.location,
        preferredStyle: profile.preferredStyle,
        measurements: profile.measurements,
        stylePreferences: stylePreferences ?? profile.stylePreferences,
        bodyType: profile.bodyType,
        colorPalette: profile.colorPalette,
        styleGoals: profile.styleGoals,
        budgetRange: profile.budgetRange,
        onboardingCompleted: profile.onboardingCompleted,
        onboardingSkipped: profile.onboardingSkipped,
        privacySettings: profile.privacySettings,
        notificationPreferences: profile.notificationPreferences,
        createdAt: profile.createdAt,
        updatedAt: DateTime.now(),
      );

      final result = await repository.updateProfile(updatedProfile);
      
      result.fold(
        (failure) {
          // Handle error
          state = state.copyWith(
            userProfile: AsyncValue.error(failure.message, StackTrace.current),
          );
        },
        (updated) {
          // Update UI data
          final updatedUserData = _convertProfileToUserData(updated);
          state = state.copyWith(
            userProfile: AsyncValue.data(updatedUserData),
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        userProfile: AsyncValue.error(e.toString(), StackTrace.current),
      );
    }
  }

  /// Update user avatar with image picker
  Future<void> updateAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (pickedFile == null) return;

    state = state.copyWith(isUpdatingAvatar: true);

    try {
      // Read image as bytes
      final imageBytes = await pickedFile.readAsBytes();
      
      // Get current user
      final authRepo = ref.read(authRepositoryProvider);
      final userResult = await authRepo.getCurrentUser();
      if (userResult.isLeft()) return;

      final user = userResult.getOrElse(() => throw Exception('No user'));
      
      // Upload avatar using repository
      final repository = ref.read(profileRepositoryProvider) as SupabaseProfileRepository;
      final uploadResult = await repository.updateAvatar(user.id, imageBytes);

      uploadResult.fold(
        (failure) {
          state = state.copyWith(
            isUpdatingAvatar: false,
            userProfile: AsyncValue.error(failure.message, StackTrace.current),
          );
        },
        (newAvatarUrl) {
          // Update current profile data with new avatar
          final currentProfile = state.userProfile.value;
          if (currentProfile != null) {
            final updatedProfile = currentProfile.copyWith(avatarUrl: newAvatarUrl);
            state = state.copyWith(
              isUpdatingAvatar: false,
              userProfile: AsyncValue.data(updatedProfile),
            );
          }
        },
      );
    } catch (e) {
      state = state.copyWith(
        isUpdatingAvatar: false,
        userProfile: AsyncValue.error(e.toString(), StackTrace.current),
      );
    }
  }

  /// Refresh all profile data
  Future<void> refreshProfile() async {
    await _loadInitialData();
  }

  /// Select a specific tab
  void selectTab(String tabName) {
    if (state.availableTabs.contains(tabName)) {
      state = state.copyWith(selectedTab: tabName);
    }
  }

  /// Retry loading profile after error
  Future<void> retry() async {
    await loadProfile();
  }

  /// Retry loading stats after error
  Future<void> retryStats() async {
    await loadStats();
  }

  /// Navigate to settings (handled by app router)
  void navigateToSettings() {
    // Navigation will be handled by the app router
    // This could emit an event or call a navigation service
  }

  /// Navigate to stat detail screen
  void navigateToStatDetail(String statType) {
    // Navigation will be handled by the app router
    // statType could be 'combinations', 'favorites', 'followers', 'following'
  }
}
