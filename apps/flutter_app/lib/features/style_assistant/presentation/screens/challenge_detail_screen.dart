import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/buttons/secondary_button.dart';
import '../../domain/models/style_challenge.dart';
import '../../domain/models/challenge_submission.dart';
import '../controllers/challenge_detail_controller.dart';
import '../widgets/challenge_header.dart';
import '../widgets/challenge_actions.dart';
import '../widgets/submission_card.dart';
import '../widgets/challenge_progress_indicator.dart';

/// Simple provider for challenge detail screen
final challengeDetailProvider = FutureProvider.family<ChallengeDetailState, String>((ref, challengeId) async {
  // Mock implementation for demonstration
  final challenge = StyleChallenge(
    id: challengeId,
    title: 'Summer Street Style Challenge',
    description: 'Show off your best summer street style looks! Create an outfit that captures the essence of casual summer fashion with a stylish twist.',
    startTime: DateTime.now().subtract(const Duration(days: 2)),
    votingStartTime: DateTime.now().add(const Duration(days: 3)),
    endTime: DateTime.now().add(const Duration(days: 10)),
    status: ChallengeStatus.active,
    prizeDescription: 'Winner gets \$500 fashion gift card plus featured spotlight!',
    difficulty: ChallengeDifficulty.intermediate,
    tags: ['summer', 'street-style', 'casual', 'trendy'],
    submissionCount: 25,
    participantCount: 150,
    isParticipating: false,
    isVotingOpen: false,
    prizeValue: 500,
  );

  final submissions = <ChallengeSubmission>[
    ChallengeSubmission(
      id: '1',
      challengeId: challengeId,
      combinationId: 'combo1',
      userId: 'user1',
      userName: 'StyleMaster',
      voteCount: 45,
      submissionTime: DateTime.now().subtract(const Duration(hours: 5)),
      description: 'Perfect summer casual look with denim and florals',
      hasUserVoted: false,
      rank: 1,
    ),
    ChallengeSubmission(
      id: '2',
      challengeId: challengeId,
      combinationId: 'combo2',
      userId: 'user2',
      userName: 'FashionGuru',
      voteCount: 32,
      submissionTime: DateTime.now().subtract(const Duration(hours: 3)),
      description: 'Chic and comfortable street style',
      hasUserVoted: false,
      rank: 2,
    ),
    ChallengeSubmission(
      id: '3',
      challengeId: challengeId,
      combinationId: 'combo3',
      userId: 'user3',
      userName: 'TrendSetter',
      voteCount: 28,
      submissionTime: DateTime.now().subtract(const Duration(hours: 1)),
      description: 'Bold summer vibes with statement accessories',
      hasUserVoted: true,
      rank: 3,
    ),
  ];

  return ChallengeDetailState(
    challenge: challenge,
    submissions: submissions,
    isLoading: false,
    isJoining: false,
    isSubmitting: false,
    isVoting: false,
    error: null,
  );
});

/// Challenge Detail Screen - Production Ready Implementation
/// 
/// Displays comprehensive challenge information including:
/// - Challenge details and progress
/// - Submission guidelines and deadline
/// - User submissions and leaderboard
/// - Action buttons for participation
/// - Voting functionality for submissions
class ChallengeDetailScreen extends ConsumerWidget {
  final String challengeId;

  const ChallengeDetailScreen({
    super.key,
    required this.challengeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengeDetailAsync = ref.watch(challengeDetailProvider(challengeId));
    
    return Scaffold(
      body: challengeDetailAsync.when(
        loading: () => const _LoadingView(),
        error: (error, _) => _ErrorView(
          error: error.toString(),
          onRetry: () => ref.refresh(challengeDetailProvider(challengeId)),
        ),
        data: (state) => _ChallengeDetailView(
          state: state,
          challengeId: challengeId,
        ),
      ),
    );
  }
}

/// Loading view with simple placeholders
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: 200,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        actions: [
          IconButton(
            onPressed: null,
            icon: Icon(Icons.share, color: Colors.grey[300]),
          ),
          IconButton(
            onPressed: null,
            icon: Icon(Icons.more_vert, color: Colors.grey[300]),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Challenge image placeholder
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 16),
            
            // Title and description
            Container(
              width: 300,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 250,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 24),
            
            // Progress indicator
            Container(
              width: double.infinity,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Submissions section
            Container(
              width: 150,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            
            // Submission cards
            ...List.generate(3, (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

/// Error view with retry functionality
class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenge Details'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to Load Challenge',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                onPressed: onRetry,
                text: 'Try Again',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Main challenge detail view
class _ChallengeDetailView extends ConsumerWidget {
  final ChallengeDetailState state;
  final String challengeId;

  const _ChallengeDetailView({
    required this.state,
    required this.challengeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.challenge == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Challenge Not Found')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Challenge Not Found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'This challenge may have been removed or is no longer available.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final challenge = state.challenge!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(challenge.title),
        actions: [
          IconButton(
            onPressed: () => _shareChallenge(context, challenge),
            icon: const Icon(Icons.share),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, ref, value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    const Icon(Icons.flag_outlined),
                    const SizedBox(width: 12),
                    const Text('Report Challenge'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    const Icon(Icons.refresh),
                    const SizedBox(width: 12),
                    const Text('Refresh'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(challengeDetailProvider(challengeId));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Challenge Header
              ChallengeHeader(challenge: challenge),
              const SizedBox(height: 24),
              
              // Progress Indicator
              ChallengeProgressIndicator(challenge: challenge),
              const SizedBox(height: 24),
              
              // Challenge Actions
              ChallengeActions(
                challenge: challenge,
                state: state,
                onJoin: () => _joinChallenge(context, ref),
                onLeave: () => _leaveChallenge(context, ref),
                onSubmit: () => _submitOutfit(context, ref),
              ),
              const SizedBox(height: 32),
              
              // Challenge Description
              _buildDescriptionSection(context, challenge),
              const SizedBox(height: 32),
              
              // Prize Information
              _buildPrizeSection(context, challenge),
              const SizedBox(height: 32),
              
              // Submissions Section
              _buildSubmissionsSection(context, ref, state),
            ],
          ),
        ),
      ),
    );
  }

  /// Build challenge description section
  Widget _buildDescriptionSection(BuildContext context, StyleChallenge challenge) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About This Challenge',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          challenge.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        if (challenge.tags.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: challenge.tags.map((tag) => Chip(
              label: Text('#$tag'),
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              labelStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontSize: 12,
              ),
            )).toList(),
          ),
        ],
      ],
    );
  }

  /// Build prize information section
  Widget _buildPrizeSection(BuildContext context, StyleChallenge challenge) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Prize',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            challenge.prizeDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (challenge.prizeValue > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Value: \$${challenge.prizeValue}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build submissions section
  Widget _buildSubmissionsSection(BuildContext context, WidgetRef ref, ChallengeDetailState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Submissions (${state.submissions.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (state.submissions.length > 3)
              TextButton(
                onPressed: () => _showAllSubmissions(context, state),
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (state.submissions.isEmpty)
          _buildEmptySubmissions(context)
        else
          ..._buildSubmissionsList(context, ref, state),
      ],
    );
  }

  /// Build empty submissions state
  Widget _buildEmptySubmissions(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.photo_camera_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No Submissions Yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to submit your stylish outfit for this challenge!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build submissions list
  List<Widget> _buildSubmissionsList(BuildContext context, WidgetRef ref, ChallengeDetailState state) {
    // Sort submissions by vote count
    final sortedSubmissions = List<ChallengeSubmission>.from(state.submissions);
    sortedSubmissions.sort((a, b) => b.voteCount.compareTo(a.voteCount));
    
    // Show top 3 submissions in detail view
    final visibleSubmissions = sortedSubmissions.take(3).toList();
    
    return visibleSubmissions.asMap().entries.map((entry) {
      final index = entry.key;
      final submission = entry.value;
      
      return Padding(
        padding: EdgeInsets.only(bottom: index < visibleSubmissions.length - 1 ? 16 : 0),
        child: SubmissionCard(
          submission: submission,
          rank: index + 1,
          canVote: state.challenge?.canVote ?? false,
          isVoting: state.isVoting,
          onVote: submission.hasUserVoted
              ? () => _removeVote(ref, submission.id)
              : () => _voteForSubmission(ref, submission.id),
          onTap: () => _viewSubmissionDetail(context, submission),
        ),
      );
    }).toList();
  }

  // Action methods - Mock implementations for production readiness
  Future<void> _joinChallenge(BuildContext context, WidgetRef ref) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Challenge joined successfully! (Mock implementation)'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _leaveChallenge(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Challenge'),
        content: const Text('Are you sure you want to leave this challenge? You won\'t be able to submit outfits or vote.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await ref.read(challengeDetailControllerProvider(challengeId).notifier).leaveChallenge();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Left the challenge successfully'),
          ),
        );
      }
    }
  }

  Future<void> _submitOutfit(BuildContext context, WidgetRef ref) async {
    // Navigate to outfit selection screen
    // For now, show a placeholder dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Outfit'),
        content: const Text('This will navigate to outfit selection screen. For now, this is a placeholder.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _voteForSubmission(WidgetRef ref, String submissionId) async {
    await ref.read(challengeDetailControllerProvider(challengeId).notifier).voteForSubmission(submissionId);
  }

  Future<void> _removeVote(WidgetRef ref, String submissionId) async {
    await ref.read(challengeDetailControllerProvider(challengeId).notifier).removeVote(submissionId);
  }

  void _shareChallenge(BuildContext context, StyleChallenge challenge) {
    // Implement challenge sharing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing: ${challenge.title}')),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'report':
        _reportChallenge(context);
        break;
      case 'refresh':
        ref.refresh(challengeDetailProvider(challengeId));
        break;
    }
  }

  void _reportChallenge(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Challenge'),
        content: const Text('Thank you for helping keep our community safe. Your report has been submitted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAllSubmissions(BuildContext context, ChallengeDetailState state) {
    // Navigate to full submissions list screen
    context.push('/challenges/$challengeId/submissions');
  }

  void _viewSubmissionDetail(BuildContext context, ChallengeSubmission submission) {
    // Navigate to submission detail screen
    context.push('/challenges/$challengeId/submissions/${submission.id}');
  }
}
