import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/style_challenge.dart';
import '../../domain/models/challenge_submission.dart';
import '../../domain/repositories/style_challenge_repository.dart';
import '../providers/style_challenges_providers_simple.dart';

part 'challenge_detail_controller.g.dart';

/// State class for Challenge Detail Screen
class ChallengeDetailState {
  final StyleChallenge? challenge;
  final List<ChallengeSubmission> submissions;
  final bool isLoading;
  final bool isJoining;
  final bool isSubmitting;
  final bool isVoting;
  final String? error;
  final bool hasJoined;
  final bool hasSubmitted;
  final String? userSubmissionId;
  final int currentVotes;

  const ChallengeDetailState({
    this.challenge,
    this.submissions = const [],
    this.isLoading = false,
    this.isJoining = false,
    this.isSubmitting = false,
    this.isVoting = false,
    this.error,
    this.hasJoined = false,
    this.hasSubmitted = false,
    this.userSubmissionId,
    this.currentVotes = 0,
  });

  ChallengeDetailState copyWith({
    StyleChallenge? challenge,
    List<ChallengeSubmission>? submissions,
    bool? isLoading,
    bool? isJoining,
    bool? isSubmitting,
    bool? isVoting,
    String? error,
    bool? hasJoined,
    bool? hasSubmitted,
    String? userSubmissionId,
    int? currentVotes,
  }) {
    return ChallengeDetailState(
      challenge: challenge ?? this.challenge,
      submissions: submissions ?? this.submissions,
      isLoading: isLoading ?? this.isLoading,
      isJoining: isJoining ?? this.isJoining,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isVoting: isVoting ?? this.isVoting,
      error: error ?? this.error,
      hasJoined: hasJoined ?? this.hasJoined,
      hasSubmitted: hasSubmitted ?? this.hasSubmitted,
      userSubmissionId: userSubmissionId ?? this.userSubmissionId,
      currentVotes: currentVotes ?? this.currentVotes,
    );
  }
}

/// Controller for Challenge Detail Screen
@riverpod
class ChallengeDetailController extends _$ChallengeDetailController {
  @override
  Future<ChallengeDetailState> build(String challengeId) async {
    return await _loadChallengeDetails(challengeId);
  }

  /// Load challenge details and submissions
  Future<ChallengeDetailState> _loadChallengeDetails(String challengeId) async {
    try {
      final repository = ref.read(styleChallengeRepositoryProvider);
      final challenge = await repository.getChallengeById(challengeId);
      final submissions = await repository.getChallengeSubmissions(challengeId);
      final userSubmission = await repository.getUserSubmission(challengeId, 'current_user_id'); // Mock user ID

      return ChallengeDetailState(
        isLoading: false,
        challenge: challenge,
        submissions: submissions,
        hasJoined: challenge?.isParticipating ?? false,
        hasSubmitted: userSubmission != null,
        userSubmissionId: userSubmission?.id,
      );
    } catch (error) {
      return ChallengeDetailState(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  /// Join the challenge
  Future<void> joinChallenge() async {
    final currentState = await future;
    if (currentState.challenge == null || currentState.isJoining) return;

    state = AsyncValue.data(currentState.copyWith(isJoining: true, error: null));

    try {
      final repository = ref.read(styleChallengeRepositoryProvider);
      await repository.joinChallenge(currentState.challenge!.id);

      // Update challenge with participation status
      final updatedChallenge = currentState.challenge!.copyWith(
        isParticipating: true,
        participantCount: currentState.challenge!.participantCount + 1,
      );

      state = AsyncValue.data(currentState.copyWith(
        isJoining: false,
        challenge: updatedChallenge,
        hasJoined: true,
      ));
    } catch (error) {
      state = AsyncValue.data(currentState.copyWith(
        isJoining: false,
        error: error.toString(),
      ));
    }
  }

  /// Leave the challenge
  Future<void> leaveChallenge() async {
    final currentState = await future;
    if (currentState.challenge == null || currentState.isJoining) return;

    state = AsyncValue.data(currentState.copyWith(isJoining: true, error: null));

    try {
      final repository = ref.read(styleChallengeRepositoryProvider);
      await repository.leaveChallenge(currentState.challenge!.id);

      final updatedChallenge = currentState.challenge!.copyWith(
        isParticipating: false,
        participantCount: currentState.challenge!.participantCount - 1,
      );

      state = AsyncValue.data(currentState.copyWith(
        isJoining: false,
        challenge: updatedChallenge,
        hasJoined: false,
        hasSubmitted: false,
        userSubmissionId: null,
      ));
    } catch (error) {
      state = AsyncValue.data(currentState.copyWith(
        isJoining: false,
        error: error.toString(),
      ));
    }
  }

  /// Submit an outfit for the challenge
  Future<void> submitOutfit(String combinationId, String? description) async {
    final currentState = await future;
    if (currentState.challenge == null || currentState.isSubmitting) return;

    state = AsyncValue.data(currentState.copyWith(isSubmitting: true, error: null));

    try {
      final repository = ref.read(styleChallengeRepositoryProvider);
      final submission = await repository.submitChallengeEntry(
        currentState.challenge!.id,
        combinationId,
        description ?? '',
      );

      // Add submission to the list and update state
      final updatedSubmissions = [...currentState.submissions, submission];
      final updatedChallenge = currentState.challenge!.copyWith(
        submissionCount: currentState.challenge!.submissionCount + 1,
      );

      state = AsyncValue.data(currentState.copyWith(
        isSubmitting: false,
        challenge: updatedChallenge,
        submissions: updatedSubmissions,
        hasSubmitted: true,
        userSubmissionId: submission.id,
      ));
    } catch (error) {
      state = AsyncValue.data(currentState.copyWith(
        isSubmitting: false,
        error: error.toString(),
      ));
    }
  }

  /// Vote for a submission
  Future<void> voteForSubmission(String submissionId) async {
    final currentState = await future;
    if (currentState.isVoting) return;

    state = AsyncValue.data(currentState.copyWith(isVoting: true, error: null));

    try {
      final repository = ref.read(styleChallengeRepositoryProvider);
      await repository.voteForSubmission(submissionId);

      // Update the submission vote count in the list
      final updatedSubmissions = currentState.submissions.map((submission) {
        if (submission.id == submissionId) {
          return submission.copyWith(
            voteCount: submission.voteCount + 1,
            hasUserVoted: true,
          );
        }
        return submission;
      }).toList();

      state = AsyncValue.data(currentState.copyWith(
        isVoting: false,
        submissions: updatedSubmissions,
        currentVotes: currentState.currentVotes + 1,
      ));
    } catch (error) {
      state = AsyncValue.data(currentState.copyWith(
        isVoting: false,
        error: error.toString(),
      ));
    }
  }

  /// Remove vote from a submission
  Future<void> removeVote(String submissionId) async {
    final currentState = await future;
    if (currentState.isVoting) return;

    state = AsyncValue.data(currentState.copyWith(isVoting: true, error: null));

    try {
      final repository = ref.read(styleChallengeRepositoryProvider);
      await repository.removeVote(submissionId);

      // Update the submission vote count in the list
      final updatedSubmissions = currentState.submissions.map((submission) {
        if (submission.id == submissionId) {
          return submission.copyWith(
            voteCount: submission.voteCount - 1,
            hasUserVoted: false,
          );
        }
        return submission;
      }).toList();

      state = AsyncValue.data(currentState.copyWith(
        isVoting: false,
        submissions: updatedSubmissions,
        currentVotes: currentState.currentVotes - 1,
      ));
    } catch (error) {
      state = AsyncValue.data(currentState.copyWith(
        isVoting: false,
        error: error.toString(),
      ));
    }
  }

  /// Refresh challenge data
  Future<void> refresh() async {
    final currentState = await future;
    if (currentState.challenge != null) {
      state = AsyncValue.data(await _loadChallengeDetails(currentState.challenge!.id));
    }
  }
}
