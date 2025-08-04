import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import the model classes directly from the widget files where they are currently defined
import '../widgets/challenges/challenge_card.dart';
import '../widgets/challenges/submissions_grid_view.dart';

/// State class for StyleChallengesController
class StyleChallengesState {
  final AsyncValue<List<StyleChallenge>> activeChallenges;
  final AsyncValue<List<StyleChallenge>> upcomingChallenges;
  final AsyncValue<List<StyleChallenge>> pastChallenges;
  final ChallengeStatus currentTab;
  final AsyncValue<StyleChallenge?> selectedChallenge;
  final AsyncValue<List<ChallengeSubmission>> challengeSubmissions;
  final AsyncValue<void> submissionState;
  final bool hasUserSubmittedToSelectedChallenge;

  const StyleChallengesState({
    required this.activeChallenges,
    required this.upcomingChallenges,
    required this.pastChallenges,
    required this.currentTab,
    required this.selectedChallenge,
    required this.challengeSubmissions,
    required this.submissionState,
    required this.hasUserSubmittedToSelectedChallenge,
  });

  /// Initial state with loading states for challenge lists
  factory StyleChallengesState.initial() => StyleChallengesState(
        activeChallenges: const AsyncValue.loading(),
        upcomingChallenges: const AsyncValue.loading(),
        pastChallenges: const AsyncValue.loading(),
        currentTab: ChallengeStatus.active,
        selectedChallenge: const AsyncValue.data(null),
        challengeSubmissions: const AsyncValue.data([]),
        submissionState: const AsyncValue.data(null),
        hasUserSubmittedToSelectedChallenge: false,
      );

  /// Creates a copy of this state with the given fields replaced
  StyleChallengesState copyWith({
    AsyncValue<List<StyleChallenge>>? activeChallenges,
    AsyncValue<List<StyleChallenge>>? upcomingChallenges,
    AsyncValue<List<StyleChallenge>>? pastChallenges,
    ChallengeStatus? currentTab,
    AsyncValue<StyleChallenge?>? selectedChallenge,
    AsyncValue<List<ChallengeSubmission>>? challengeSubmissions,
    AsyncValue<void>? submissionState,
    bool? hasUserSubmittedToSelectedChallenge,
  }) {
    return StyleChallengesState(
      activeChallenges: activeChallenges ?? this.activeChallenges,
      upcomingChallenges: upcomingChallenges ?? this.upcomingChallenges,
      pastChallenges: pastChallenges ?? this.pastChallenges,
      currentTab: currentTab ?? this.currentTab,
      selectedChallenge: selectedChallenge ?? this.selectedChallenge,
      challengeSubmissions: challengeSubmissions ?? this.challengeSubmissions,
      submissionState: submissionState ?? this.submissionState,
      hasUserSubmittedToSelectedChallenge:
          hasUserSubmittedToSelectedChallenge ?? this.hasUserSubmittedToSelectedChallenge,
    );
  }

  /// Helper method to get the challenges for the current tab
  AsyncValue<List<StyleChallenge>> getChallengesForCurrentTab() {
    switch (currentTab) {
      case ChallengeStatus.active:
        return activeChallenges;
      case ChallengeStatus.upcoming:
        return upcomingChallenges;
      case ChallengeStatus.past:
        return pastChallenges;
      case ChallengeStatus.voting:
        // Currently voting status challenges are not separately tracked
        // They could be filtered from active challenges
        return const AsyncValue.data([]);
    }
  }
}

/// Controller for managing style challenges
class StyleChallengesController extends StateNotifier<StyleChallengesState> {
  StyleChallengesController() : super(StyleChallengesState.initial()) {
    // Load active challenges initially
    loadChallenges(ChallengeStatus.active);
  }

  /// Loads challenges for the specified status
  Future<void> loadChallenges(ChallengeStatus status) async {
    try {
      // Set loading state for the specific tab
      switch (status) {
        case ChallengeStatus.active:
          state = state.copyWith(activeChallenges: const AsyncValue.loading());
          break;
        case ChallengeStatus.upcoming:
          state = state.copyWith(upcomingChallenges: const AsyncValue.loading());
          break;
        case ChallengeStatus.past:
          state = state.copyWith(pastChallenges: const AsyncValue.loading());
          break;
        case ChallengeStatus.voting:
          // Currently we don't have a separate tab for voting challenges
          break;
      }

      // TODO: In a future task, connect to a repository to fetch real data
      // For now, simulate a network request with mock data
      await Future<void>.delayed(const Duration(seconds: 1));

      // Create some mock data based on the status
      final challenges = _createMockChallenges(status);

      // Update state with the loaded challenges
      switch (status) {
        case ChallengeStatus.active:
          state = state.copyWith(activeChallenges: AsyncValue.data(challenges));
          break;
        case ChallengeStatus.upcoming:
          state = state.copyWith(upcomingChallenges: AsyncValue.data(challenges));
          break;
        case ChallengeStatus.past:
          state = state.copyWith(pastChallenges: AsyncValue.data(challenges));
          break;
        case ChallengeStatus.voting:
          // Currently we don't have a separate tab for voting challenges
          break;
      }
    } catch (e, stack) {
      // Update state with error for the specific tab
      switch (status) {
        case ChallengeStatus.active:
          state = state.copyWith(activeChallenges: AsyncValue.error(e, stack));
          break;
        case ChallengeStatus.upcoming:
          state = state.copyWith(upcomingChallenges: AsyncValue.error(e, stack));
          break;
        case ChallengeStatus.past:
          state = state.copyWith(pastChallenges: AsyncValue.error(e, stack));
          break;
        case ChallengeStatus.voting:
          // Currently we don't have a separate tab for voting challenges
          break;
      }
    }
  }

  /// Changes the current tab and ensures challenges for that tab are loaded
  void changeTab(ChallengeStatus newStatus) {
    state = state.copyWith(currentTab: newStatus);
    
    // Check if we need to load data for the new tab
    switch (newStatus) {
      case ChallengeStatus.active:
        if (state.activeChallenges is! AsyncData) {
          loadChallenges(newStatus);
        }
        break;
      case ChallengeStatus.upcoming:
        if (state.upcomingChallenges is! AsyncData) {
          loadChallenges(newStatus);
        }
        break;
      case ChallengeStatus.past:
        if (state.pastChallenges is! AsyncData) {
          loadChallenges(newStatus);
        }
        break;
      case ChallengeStatus.voting:
        // Currently we don't have a separate tab for voting challenges
        break;
    }
  }

  /// Loads the details of a specific challenge and its submissions
  Future<void> loadChallengeDetail(String challengeId) async {
    try {
      // Set loading states
      state = state.copyWith(
        selectedChallenge: const AsyncValue.loading(),
        challengeSubmissions: const AsyncValue.loading(),
      );

      // TODO: In a future task, connect to a repository to fetch real data
      // For now, simulate a network request with mock data
      await Future<void>.delayed(const Duration(seconds: 1));

      // Find the challenge in our lists (in a real app, we'd fetch it from the server)
      StyleChallenge? challenge;
      
      // Look through all challenge lists
      final activeChallenges = state.activeChallenges.valueOrNull ?? [];
      final upcomingChallenges = state.upcomingChallenges.valueOrNull ?? [];
      final pastChallenges = state.pastChallenges.valueOrNull ?? [];
      
      challenge = activeChallenges.where((c) => c.id == challengeId).firstOrNull ??
                 upcomingChallenges.where((c) => c.id == challengeId).firstOrNull ??
                 pastChallenges.where((c) => c.id == challengeId).firstOrNull;

      if (challenge == null) {
        throw Exception("Challenge not found");
      }

      // Create mock submissions
      final submissions = _createMockSubmissions(challengeId);

      // Check if the user has submitted to this challenge
      final hasSubmitted = challenge.isParticipating;

      // Update state
      state = state.copyWith(
        selectedChallenge: AsyncValue.data(challenge),
        challengeSubmissions: AsyncValue.data(submissions),
        hasUserSubmittedToSelectedChallenge: hasSubmitted,
      );
    } catch (e, stack) {
      // Update state with errors
      state = state.copyWith(
        selectedChallenge: AsyncValue.error(e, stack),
        challengeSubmissions: AsyncValue.error(e, stack),
      );
    }
  }

  /// Submits a user's combination to a challenge
  Future<void> submitCombination(String challengeId, String combinationId) async {
    try {
      // Set submitting state
      state = state.copyWith(submissionState: const AsyncValue.loading());

      // TODO: In a future task, connect to a repository to submit real data
      // For now, simulate a network request
      await Future<void>.delayed(const Duration(seconds: 2));

      // Update participation status
      state = state.copyWith(
        hasUserSubmittedToSelectedChallenge: true,
        submissionState: const AsyncValue.data(null),
      );

      // Refresh the challenge detail to get updated submissions
      await loadChallengeDetail(challengeId);
    } catch (e, stack) {
      // Update state with error
      state = state.copyWith(submissionState: AsyncValue.error(e, stack));
    }
  }

  /// Retries loading challenges for a specific status
  Future<void> retryLoadChallenges(ChallengeStatus status) async {
    await loadChallenges(status);
  }

  /// Retries loading a challenge's detail
  Future<void> retryLoadChallengeDetail(String challengeId) async {
    await loadChallengeDetail(challengeId);
  }

  /// Retries the last submission
  Future<void> retryLastSubmission() async {
    if (state.selectedChallenge.valueOrNull?.id != null) {
      // We need a combination ID in a real app, but for now we'll use a dummy one
      await submitCombination(
        state.selectedChallenge.value!.id, 
        'retry_combination_1'
      );
    }
  }

  /// Refreshes all challenge data
  Future<void> refreshAll() async {
    await loadChallenges(ChallengeStatus.active);
    await loadChallenges(ChallengeStatus.upcoming);
    await loadChallenges(ChallengeStatus.past);
    
    // If there's a selected challenge, refresh that too
    if (state.selectedChallenge.valueOrNull?.id != null) {
      await loadChallengeDetail(state.selectedChallenge.value!.id);
    }
  }

  // Helper methods to create mock data for development
  
  List<StyleChallenge> _createMockChallenges(ChallengeStatus targetStatus) {
    final now = DateTime.now();
    
    // For demo purposes - simulate empty state for upcoming challenges occasionally
    if (targetStatus == ChallengeStatus.upcoming && now.second % 3 == 0) {
      return [];
    }
    
    return [
      StyleChallenge(
        id: 'challenge1',
        title: 'Summer Beach Party Outfit',
        description: 'Create the perfect outfit for a beach party. Should be stylish yet comfortable for a day in the sun.',
        startTime: now.subtract(const Duration(days: 2)),
        votingStartTime: now.add(const Duration(days: 5)),
        endTime: now.add(const Duration(days: 7)),
        status: targetStatus == ChallengeStatus.active ? ChallengeStatus.active : ChallengeStatus.past,
        prizeDescription: 'Featured spotlight on app homepage and social media feature',
        submissionCount: targetStatus == ChallengeStatus.active ? 18 : 42,
        isParticipating: targetStatus == ChallengeStatus.active,
      ),
      StyleChallenge(
        id: 'challenge2',
        title: 'Office Chic on a Budget',
        description: 'Create a professional office look using affordable pieces. Style that does not break the bank!',
        startTime: now.subtract(const Duration(days: 5)),
        votingStartTime: now.add(const Duration(days: 2)),
        endTime: now.add(const Duration(days: 4)),
        status: targetStatus,
        prizeDescription: '200 Style Points + feature in "Budget Finds" collection',
        imageUrl: 'https://images.unsplash.com/photo-1580566232691-a497d124276c',
        submissionCount: 26,
      ),
      StyleChallenge(
        id: 'challenge3',
        title: 'Date Night Glam',
        description: 'Create the perfect romantic date night outfit that makes you feel confident and beautiful.',
        startTime: now.subtract(const Duration(days: 10)),
        votingStartTime: now.subtract(const Duration(days: 3)),
        endTime: now.subtract(const Duration(days: 1)),
        status: targetStatus,
        prizeDescription: 'Gift card to your favorite clothing store worth \$50',
        submissionCount: 34,
        isParticipating: targetStatus == ChallengeStatus.past,
      ),
    ];
  }

  List<ChallengeSubmission> _createMockSubmissions(String challengeId) {
    final now = DateTime.now();
    
    // Find the challenge to check its status
    StyleChallenge? challenge;
    
    final activeChallenges = state.activeChallenges.valueOrNull ?? [];
    final upcomingChallenges = state.upcomingChallenges.valueOrNull ?? [];
    final pastChallenges = state.pastChallenges.valueOrNull ?? [];
    
    challenge = activeChallenges.where((c) => c.id == challengeId).firstOrNull ??
               upcomingChallenges.where((c) => c.id == challengeId).firstOrNull ??
               pastChallenges.where((c) => c.id == challengeId).firstOrNull;
    
    if (challenge?.status == ChallengeStatus.upcoming) {
      return []; // No submissions for upcoming challenges
    }
    
    if (challenge?.submissionCount == 0) {
      return []; // Respect the challenge's submission count
    }
    
    // For active, voting and past challenges, create mock submissions
    // The number is limited for demo purposes
    final count = challenge?.submissionCount ?? 10;
    final limitedCount = count > 10 ? 10 : count;
    
    return List.generate(limitedCount, (index) {
      final isUserSubmission = index == 0 && (challenge?.isParticipating ?? false);
      return ChallengeSubmission(
        id: 'submission_${challengeId}_$index',
        challengeId: challengeId,
        combinationId: 'combination_$index',
        userId: isUserSubmission ? 'current_user' : 'user_$index',
        voteCount: challenge?.status == ChallengeStatus.past
            ? (limitedCount - index) * 5 + (index % 3) // More votes for past challenges
            : challenge?.status == ChallengeStatus.voting
                ? (limitedCount - index) * 2 + (index % 3) // Some votes for voting phase
                : 0, // No votes yet for active phase
        username: isUserSubmission ? 'You' : 'User ${index + 1}',
        submittedAt: now.subtract(Duration(days: index, hours: index * 2)),
      );
    });
  }
}

// Create providers
final styleChallengesControllerProvider = StateNotifierProvider<StyleChallengesController, StyleChallengesState>(
  (ref) => StyleChallengesController(),
);
