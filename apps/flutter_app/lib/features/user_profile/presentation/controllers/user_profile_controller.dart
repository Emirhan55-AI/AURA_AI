import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_analytics.dart';
import '../../domain/entities/profile.dart';
import '../../data/repositories/supabase_profile_repository.dart';

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

  const UserProfileState({
    required this.userProfile,
    required this.userStats,
    required this.userAnalytics,
    required this.selectedTab,
    required this.availableTabs,
  });

  UserProfileState copyWith({
    AsyncValue<UserProfileData>? userProfile,
    AsyncValue<UserStatsData>? userStats,
    AsyncValue<UserAnalytics>? userAnalytics,
    String? selectedTab,
    List<String>? availableTabs,
  }) {
    return UserProfileState(
      userProfile: userProfile ?? this.userProfile,
      userStats: userStats ?? this.userStats,
      userAnalytics: userAnalytics ?? this.userAnalytics,
      selectedTab: selectedTab ?? this.selectedTab,
      availableTabs: availableTabs ?? this.availableTabs,
    );
  }
}

/// Controller for user profile state management with real backend integration
class UserProfileController extends StateNotifier<UserProfileState> {
  final SupabaseProfileRepository _repository;

  UserProfileController({
    SupabaseProfileRepository? repository,
  }) : _repository = repository ?? SupabaseProfileRepository(),
       super(
    UserProfileState(
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
    ),
  ) {
    // Load initial data
    loadProfile();
  }

  /// Load user profile data from Supabase backend
  Future<void> loadProfile() async {
    state = state.copyWith(
      userProfile: const AsyncValue.loading(),
      userStats: const AsyncValue.loading(),
      userAnalytics: const AsyncValue.loading(),
    );
    
    try {
      // Load profile from Supabase
      final profileResult = await _repository.getCurrentProfile();
      
      profileResult.fold(
        (failure) {
          state = state.copyWith(
            userProfile: AsyncValue.error(failure, StackTrace.current),
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

      // Load stats and analytics separately
      await _loadStats();
      await _loadAnalytics();
    } catch (error, stackTrace) {
      state = state.copyWith(
        userProfile: AsyncValue.error(error, stackTrace),
        userAnalytics: AsyncValue.error(error, stackTrace),
      );
    }
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

  /// Load user statistics from Supabase backend
  Future<void> _loadStats() async {
    try {
      // Get current user ID from Supabase auth
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        state = state.copyWith(
          userStats: AsyncValue.error('No authenticated user', StackTrace.current),
        );
        return;
      }

      final statsResult = await _repository.getUserStats(user.id);
      
      statsResult.fold(
        (failure) {
          state = state.copyWith(
            userStats: AsyncValue.error(failure, StackTrace.current),
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
    } catch (error, stackTrace) {
      state = state.copyWith(
        userStats: AsyncValue.error(error, stackTrace),
      );
    }
  }

  /// Load user analytics separately
  Future<void> _loadAnalytics() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      
      final analytics = UserAnalytics(
        totalItems: 78,
        wornItems: 56,
        unwornItems: 22,
        wearRatio: 0.72,
        categoryDistribution: const {
          'Tops': 22,
          'Bottoms': 18,
          'Dresses': 12,
          'Outerwear': 8,
          'Shoes': 14,
          'Accessories': 4,
        },
        colorDistribution: const {
          'Black': 20,
          'White': 15,
          'Navy': 12,
          'Beige': 10,
          'Gray': 8,
        },
        brandDistribution: const {
          'Zara': 15,
          'H&M': 12,
          'Uniqlo': 8,
          'COS': 6,
        },
        stylePreferences: const {
          'Casual Chic': 45,
          'Professional': 30,
          'Evening': 15,
          'Sporty': 10,
        },
        topStyles: const ['Casual Chic', 'Professional', 'Evening'],
        seasonalPreferences: const {
          'Spring': 0.25,
          'Summer': 0.30,
          'Fall': 0.25,
          'Winter': 0.20,
        },
        recentInsights: [
          OutfitInsight(
            id: 'insight_1',
            type: 'recommendation',
            title: 'Most Worn Item',
            description: 'Your black blazer appears in 40% of your professional outfits',
            iconCode: '👔',
            colorHex: '#2196F3',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            actionText: 'Diversify your looks',
          ),
          OutfitInsight(
            id: 'insight_2',
            type: 'trend',
            title: 'Underutilized Items',
            description: 'You have 12 items worn less than 3 times this year',
            iconCode: '👗',
            colorHex: '#FF9800',
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
            actionText: 'Create new outfits',
          ),
        ],
        daysActive: 90,
        outfitsCreated: 247,
        outfitsWorn: 189,
        averageOutfitsPerWeek: 12.5,
        weeklyActivity: const {
          'Monday': 15,
          'Tuesday': 18,
          'Wednesday': 20,
          'Thursday': 17,
          'Friday': 22,
          'Saturday': 25,
          'Sunday': 12,
        },
        totalLikes: 2847,
        totalShares: 156,
        totalComments: 432,
        socialEngagementRate: 0.18,
        topHashtags: const ['#styleinspo', '#outfitoftheday', '#fashion'],
        sustainabilityScore: 78.5,
        itemsSwapped: 5,
        itemsRecycled: 3,
        costPerWear: 12.50,
        totalWardrobeValue: 2450.0,
        streakDays: 14,
        badgesEarned: 8,
        recentAchievements: [
          Achievement(
            id: 'eco_warrior',
            title: 'Eco Warrior',
            description: 'High sustainability score for 3 months',
            iconCode: '🌱',
            category: 'sustainability',
            points: 100,
            unlockedAt: DateTime.parse('2024-01-15'),
            isNew: false,
          ),
          Achievement(
            id: 'style_master',
            title: 'Style Master',
            description: 'Created 200+ outfits',
            iconCode: '✨',
            category: 'style',
            points: 200,
            unlockedAt: DateTime.parse('2024-02-20'),
            isNew: true,
          ),
        ],
        lastUpdated: DateTime.now(),
        monthlyTrends: const {
          'January': 0.85,
          'February': 0.92,
          'March': 0.78,
          'April': 0.88,
        },
      );
      
      state = state.copyWith(userAnalytics: AsyncValue.data(analytics));
    } catch (error, stackTrace) {
      state = state.copyWith(userAnalytics: AsyncValue.error(error, stackTrace));
    }
  }

  /// Refresh user profile data from backend
  Future<void> refreshProfile() async {
    try {
      await loadProfile();
    } catch (e) {
      // Error handling is done in loadProfile
    }
  }

  /// Update user avatar using image picker
  Future<void> updateAvatar() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      // Get current user
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Read image as bytes
      final imageBytes = await pickedFile.readAsBytes();
      
      // Upload avatar using repository
      final uploadResult = await _repository.updateAvatar(user.id, imageBytes);

      uploadResult.fold(
        (failure) {
          // Handle error (could show snackbar in UI)
          state = state.copyWith(
            userProfile: AsyncValue.error(failure, StackTrace.current),
          );
        },
        (newAvatarUrl) {
          // Update current profile data with new avatar
          final currentProfile = state.userProfile.value;
          if (currentProfile != null) {
            final updatedProfile = currentProfile.copyWith(avatarUrl: newAvatarUrl);
            state = state.copyWith(
              userProfile: AsyncValue.data(updatedProfile),
            );
          }
        },
      );
    } catch (e) {
      state = state.copyWith(
        userProfile: AsyncValue.error(e, StackTrace.current),
      );
    }
  }

  /// Update user profile information
  Future<void> updateProfile({
    String? displayName,
    String? bio,
    String? location,
  }) async {
    try {
      // Get the current full profile from backend first
      final profileResult = await _repository.getCurrentProfile();
      if (profileResult.isLeft()) return;

      final currentProfile = profileResult.getOrElse(() => throw Exception('No profile'));
      
      // Create updated profile with new data
      final updatedProfile = Profile(
        id: currentProfile.id,
        userId: currentProfile.userId,
        displayName: displayName ?? currentProfile.displayName,
        avatar: currentProfile.avatar,
        bio: bio ?? currentProfile.bio,
        dateOfBirth: currentProfile.dateOfBirth,
        gender: currentProfile.gender,
        location: location ?? currentProfile.location,
        preferredStyle: currentProfile.preferredStyle,
        measurements: currentProfile.measurements,
        stylePreferences: currentProfile.stylePreferences,
        bodyType: currentProfile.bodyType,
        colorPalette: currentProfile.colorPalette,
        styleGoals: currentProfile.styleGoals,
        budgetRange: currentProfile.budgetRange,
        onboardingCompleted: currentProfile.onboardingCompleted,
        onboardingSkipped: currentProfile.onboardingSkipped,
        privacySettings: currentProfile.privacySettings,
        notificationPreferences: currentProfile.notificationPreferences,
        createdAt: currentProfile.createdAt,
        updatedAt: DateTime.now(),
      );

      final result = await _repository.updateProfile(updatedProfile);
      
      result.fold(
        (failure) {
          state = state.copyWith(
            userProfile: AsyncValue.error(failure, StackTrace.current),
          );
        },
        (updated) {
          // Update UI data with new profile information
          final updatedUserData = _convertProfileToUserData(updated);
          state = state.copyWith(
            userProfile: AsyncValue.data(updatedUserData),
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        userProfile: AsyncValue.error(e, StackTrace.current),
      );
    }
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
    await _loadStats();
  }

  /// Navigate to settings (emits navigation event)
  void navigateToSettings() {
    // TODO: Implement navigation logic or emit navigation event
    // This could be handled through a navigation service or router
  }

  /// Navigate to stat detail screen
  void navigateToStatDetail(String statType) {
    // TODO: Implement navigation logic for stat detail
    // statType could be 'combinations', 'favorites', 'followers', 'following'
  }
}

/// Provider for user profile controller with backend integration
final userProfileControllerProvider = StateNotifierProvider<UserProfileController, UserProfileState>((ref) {
  return UserProfileController();
});
