import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final String selectedTab;
  final List<String> availableTabs;

  const UserProfileState({
    required this.userProfile,
    required this.userStats,
    required this.selectedTab,
    required this.availableTabs,
  });

  UserProfileState copyWith({
    AsyncValue<UserProfileData>? userProfile,
    AsyncValue<UserStatsData>? userStats,
    String? selectedTab,
    List<String>? availableTabs,
  }) {
    return UserProfileState(
      userProfile: userProfile ?? this.userProfile,
      userStats: userStats ?? this.userStats,
      selectedTab: selectedTab ?? this.selectedTab,
      availableTabs: availableTabs ?? this.availableTabs,
    );
  }
}

/// Controller for user profile state management
class UserProfileController extends StateNotifier<UserProfileState> {
  UserProfileController() : super(
    UserProfileState(
      userProfile: const AsyncValue.loading(),
      userStats: const AsyncValue.loading(),
      selectedTab: 'My Combinations',
      availableTabs: const [
        'My Combinations',
        'My Favorites',
        'My Likes',
        'Social Shares',
        'Communities',
        'Swap History',
      ],
    ),
  ) {
    // Load initial data
    loadProfile();
  }

  /// Load user profile data
  Future<void> loadProfile() async {
    state = state.copyWith(
      userProfile: const AsyncValue.loading(),
      userStats: const AsyncValue.loading(),
    );
    
    try {
      // Simulate loading profile data
      await Future<void>.delayed(const Duration(milliseconds: 800));
      
      const profile = UserProfileData(
        id: '1',
        displayName: 'Emma Wilson',
        username: '@emma_style',
        bio: 'Fashion enthusiast | Style curator | Sustainable fashion advocate ✨',
        avatarUrl: null,
        auraScore: 2847,
        auraLevel: 'Style Maven',
        auraProgress: 0.73,
      );
      
      state = state.copyWith(userProfile: AsyncValue.data(profile));

      // Load stats separately
      await _loadStats();
    } catch (error, stackTrace) {
      state = state.copyWith(
        userProfile: AsyncValue.error(error, stackTrace),
      );
    }
  }

  /// Load user statistics
  Future<void> _loadStats() async {
    try {
      // Simulate loading stats
      await Future<void>.delayed(const Duration(milliseconds: 600));
      
      const stats = UserStatsData(
        combinations: 127,
        favorites: 89,
        followers: 1204,
        following: 456,
      );
      
      state = state.copyWith(userStats: AsyncValue.data(stats));
    } catch (error, stackTrace) {
      state = state.copyWith(
        userStats: AsyncValue.error(error, stackTrace),
      );
    }
  }

  /// Refresh user profile data
  Future<void> refreshProfile() async {
    try {
      // Keep current data while refreshing
      await Future<void>.delayed(const Duration(milliseconds: 500));
      
      const refreshedProfile = UserProfileData(
        id: '1',
        displayName: 'Emma Wilson',
        username: '@emma_style',
        bio: 'Fashion enthusiast | Style curator | Sustainable fashion advocate ✨',
        avatarUrl: null,
        auraScore: 2847,
        auraLevel: 'Style Maven',
        auraProgress: 0.73,
      );
      
      const refreshedStats = UserStatsData(
        combinations: 127,
        favorites: 89,
        followers: 1204,
        following: 456,
      );
      
      state = state.copyWith(
        userProfile: AsyncValue.data(refreshedProfile),
        userStats: AsyncValue.data(refreshedStats),
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        userProfile: AsyncValue.error(error, stackTrace),
        userStats: AsyncValue.error(error, stackTrace),
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

/// Provider for user profile controller
final userProfileControllerProvider = StateNotifierProvider<UserProfileController, UserProfileState>((ref) {
  return UserProfileController();
});
