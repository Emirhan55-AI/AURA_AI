import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/style_challenge_new.dart';
import '../../domain/repositories/style_challenge_repository.dart';

part 'style_challenges_providers.g.dart';

/// Provider for the StyleChallengeRepository
@riverpod
StyleChallengeRepository styleChallengeRepository(StyleChallengeRepositoryRef ref) {
  return MockStyleChallengeRepository();
}

/// Provider for active challenges
@riverpod
Future<List<StyleChallenge>> activeChallenges(ActiveChallengesRef ref) async {
  final repository = ref.watch(styleChallengeRepositoryProvider);
  return repository.getActiveChallenges();
}

/// Provider for upcoming challenges
@riverpod
Future<List<StyleChallenge>> upcomingChallenges(UpcomingChallengesRef ref) async {
  final repository = ref.watch(styleChallengeRepositoryProvider);
  return repository.getUpcomingChallenges();
}

/// Provider for past challenges
@riverpod
Future<List<StyleChallenge>> pastChallenges(PastChallengesRef ref) async {
  final repository = ref.watch(styleChallengeRepositoryProvider);
  return repository.getPastChallenges();
}

/// Provider for trending challenges
@riverpod
Future<List<StyleChallenge>> trendingChallenges(TrendingChallengesRef ref) async {
  final repository = ref.watch(styleChallengeRepositoryProvider);
  return repository.getTrendingChallenges();
}

/// Provider for a specific challenge by ID
@riverpod
Future<StyleChallenge?> challengeById(ChallengeByIdRef ref, String challengeId) async {
  final repository = ref.watch(styleChallengeRepositoryProvider);
  return repository.getChallengeById(challengeId);
}

/// Provider for challenge search results
@riverpod
Future<List<StyleChallenge>> challengeSearch(ChallengeSearchRef ref, String query) async {
  if (query.isEmpty) return [];
  
  final repository = ref.watch(styleChallengeRepositoryProvider);
  return repository.searchChallenges(query);
}

/// Provider for user participation status in a challenge
@riverpod
Future<bool> isUserParticipating(IsUserParticipatingRef ref, String challengeId) async {
  final repository = ref.watch(styleChallengeRepositoryProvider);
  return repository.isUserParticipating(challengeId);
}

/// State notifier for managing challenge interactions
@riverpod
class StyleChallengeActions extends _$StyleChallengeActions {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  /// Join a challenge
  Future<void> joinChallenge(String challengeId) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(styleChallengeRepositoryProvider);
      await repository.joinChallenge(challengeId);
      
      // Invalidate related providers to refresh data
      ref.invalidate(activeChallengesProvider);
      ref.invalidate(upcomingChallengesProvider);
      ref.invalidate(challengeByIdProvider(challengeId));
      ref.invalidate(isUserParticipatingProvider(challengeId));
      
      state = const AsyncValue.data(null);
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
      
      // Invalidate related providers to refresh data
      ref.invalidate(activeChallengesProvider);
      ref.invalidate(upcomingChallengesProvider);
      ref.invalidate(challengeByIdProvider(challengeId));
      ref.invalidate(isUserParticipatingProvider(challengeId));
      
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Submit an outfit to a challenge
  Future<void> submitOutfit(String challengeId, String outfitId) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(styleChallengeRepositoryProvider);
      await repository.submitOutfit(challengeId, outfitId);
      
      // Invalidate related providers to refresh data
      ref.invalidate(activeChallengesProvider);
      ref.invalidate(challengeByIdProvider(challengeId));
      
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Vote on a challenge submission
  Future<void> voteOnSubmission(String challengeId, String submissionId) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(styleChallengeRepositoryProvider);
      await repository.voteOnSubmission(challengeId, submissionId);
      
      // Invalidate related providers to refresh data
      ref.invalidate(challengeByIdProvider(challengeId));
      
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh all challenge data
  Future<void> refreshAll() async {
    ref.invalidate(activeChallengesProvider);
    ref.invalidate(upcomingChallengesProvider);
    ref.invalidate(pastChallengesProvider);
    ref.invalidate(trendingChallengesProvider);
  }

  /// Clear any error states
  void clearError() {
    if (state.hasError) {
      state = const AsyncValue.data(null);
    }
  }
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

/// State class for challenge filters
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
