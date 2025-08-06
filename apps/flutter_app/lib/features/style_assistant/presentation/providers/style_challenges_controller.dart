import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/style_challenge_new.dart';
import '../../domain/repositories/style_challenge_repository.dart';

part 'style_challenges_controller.g.dart';

/// Modern Riverpod controller for Style Challenges
@riverpod
class StyleChallengesController extends _$StyleChallengesController {
  @override
  Future<List<StyleChallenge>> build() async {
    // Load all challenges initially
    final repository = ref.read(styleChallengeRepositoryProvider);
    return repository.getActiveChallenges();
  }

  /// Get challenges by status
  Future<List<StyleChallenge>> getChallengesByStatus(ChallengeStatus status) async {
    final repository = ref.read(styleChallengeRepositoryProvider);
    
    switch (status) {
      case ChallengeStatus.active:
        return repository.getActiveChallenges();
      case ChallengeStatus.upcoming:
        return repository.getUpcomingChallenges();
      case ChallengeStatus.past:
        return repository.getPastChallenges();
    }
  }

  /// Get trending challenges
  Future<List<StyleChallenge>> getTrendingChallenges() async {
    final repository = ref.read(styleChallengeRepositoryProvider);
    return repository.getTrendingChallenges();
  }

  /// Search challenges
  Future<List<StyleChallenge>> searchChallenges(String query) async {
    if (query.isEmpty) return [];
    
    final repository = ref.read(styleChallengeRepositoryProvider);
    return repository.searchChallenges(query);
  }

  /// Join a challenge
  Future<void> joinChallenge(String challengeId) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(styleChallengeRepositoryProvider);
      await repository.joinChallenge(challengeId);
      
      // Refresh the challenges list
      ref.invalidateSelf();
      
      // Also invalidate specific challenge providers
      ref.invalidate(challengeByIdProvider(challengeId));
      ref.invalidate(isUserParticipatingProvider(challengeId));
      
      state = await AsyncValue.guard(() => build());
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Leave a challenge
  Future<void> leaveChallenge(String challengeId) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(styleChallengeRepositoryProvider);
      await repository.leaveChallenge(challengeId);
      
      // Refresh the challenges list
      ref.invalidateSelf();
      
      // Also invalidate specific challenge providers
      ref.invalidate(challengeByIdProvider(challengeId));
      ref.invalidate(isUserParticipatingProvider(challengeId));
      
      state = await AsyncValue.guard(() => build());
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Submit an outfit to a challenge
  Future<void> submitOutfit(String challengeId, String outfitId) async {
    try {
      final repository = ref.read(styleChallengeRepositoryProvider);
      await repository.submitOutfit(challengeId, outfitId);
      
      // Refresh relevant data
      ref.invalidate(challengeByIdProvider(challengeId));
      ref.invalidateSelf();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Vote on a challenge submission
  Future<void> voteOnSubmission(String challengeId, String submissionId) async {
    try {
      final repository = ref.read(styleChallengeRepositoryProvider);
      await repository.voteOnSubmission(challengeId, submissionId);
      
      // Refresh challenge data
      ref.invalidate(challengeByIdProvider(challengeId));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh all challenge data
  Future<void> refreshAll() async {
    ref.invalidateSelf();
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

/// Provider for challenges by status
@riverpod
Future<List<StyleChallenge>> challengesByStatus(
  ChallengesByStatusRef ref,
  ChallengeStatus status,
) async {
  final repository = ref.watch(styleChallengeRepositoryProvider);
  
  switch (status) {
    case ChallengeStatus.active:
      return repository.getActiveChallenges();
    case ChallengeStatus.upcoming:
      return repository.getUpcomingChallenges();
    case ChallengeStatus.past:
      return repository.getPastChallenges();
  }
}

/// Provider for trending challenges
@riverpod
Future<List<StyleChallenge>> trendingChallenges(TrendingChallengesRef ref) async {
  final repository = ref.watch(styleChallengeRepositoryProvider);
  return repository.getTrendingChallenges();
}

/// Provider for a specific challenge by ID
@riverpod
Future<StyleChallenge?> challengeById(
  ChallengeByIdRef ref,
  String challengeId,
) async {
  final repository = ref.watch(styleChallengeRepositoryProvider);
  return repository.getChallengeById(challengeId);
}

/// Provider for user participation status
@riverpod
Future<bool> isUserParticipating(
  IsUserParticipatingRef ref,
  String challengeId,
) async {
  final repository = ref.watch(styleChallengeRepositoryProvider);
  return repository.isUserParticipating(challengeId);
}

/// Provider for challenge search results
@riverpod
Future<List<StyleChallenge>> challengeSearch(
  ChallengeSearchRef ref,
  String query,
) async {
  if (query.isEmpty) return [];
  
  final repository = ref.watch(styleChallengeRepositoryProvider);
  return repository.searchChallenges(query);
}

/// Provider for the StyleChallengeRepository
@riverpod
StyleChallengeRepository styleChallengeRepository(StyleChallengeRepositoryRef ref) {
  return MockStyleChallengeRepository();
}

/// Provider for current tab state
@riverpod
class CurrentChallengeTab extends _$CurrentChallengeTab {
  @override
  ChallengeStatus build() {
    return ChallengeStatus.active;
  }

  void setTab(ChallengeStatus status) {
    state = status;
  }
}

/// Challenge Filter State
class ChallengeFilterState {
  final ChallengeDifficulty? difficulty;
  final String searchQuery;
  final List<String> selectedTags;

  const ChallengeFilterState({
    this.difficulty,
    this.searchQuery = '',
    this.selectedTags = const [],
  });

  ChallengeFilterState copyWith({
    ChallengeDifficulty? difficulty,
    String? searchQuery,
    List<String>? selectedTags,
  }) {
    return ChallengeFilterState(
      difficulty: difficulty ?? this.difficulty,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTags: selectedTags ?? this.selectedTags,
    );
  }

  bool get hasActiveFilters {
    return difficulty != null || 
           searchQuery.isNotEmpty || 
           selectedTags.isNotEmpty;
  }
}

/// Provider for challenge filters
@riverpod
class ChallengeFilters extends _$ChallengeFilters {
  @override
  ChallengeFilterState build() {
    return const ChallengeFilterState();
  }

  void setDifficulty(ChallengeDifficulty? difficulty) {
    state = state.copyWith(difficulty: difficulty);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void addTag(String tag) {
    final newTags = List<String>.from(state.selectedTags)..add(tag);
    state = state.copyWith(selectedTags: newTags);
  }

  void removeTag(String tag) {
    final newTags = List<String>.from(state.selectedTags)..remove(tag);
    state = state.copyWith(selectedTags: newTags);
  }

  void clearFilters() {
    state = const ChallengeFilterState();
  }
}
