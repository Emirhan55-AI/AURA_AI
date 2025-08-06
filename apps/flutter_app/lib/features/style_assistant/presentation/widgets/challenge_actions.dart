import 'package:flutter/material.dart';

import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/buttons/secondary_button.dart';
import '../../domain/models/style_challenge.dart';
import '../controllers/challenge_detail_controller.dart';

/// Challenge Actions Widget
/// 
/// Displays action buttons for challenge participation
class ChallengeActions extends StatelessWidget {
  final StyleChallenge challenge;
  final ChallengeDetailState state;
  final VoidCallback onJoin;
  final VoidCallback onLeave;
  final VoidCallback onSubmit;

  const ChallengeActions({
    super.key,
    required this.challenge,
    required this.state,
    required this.onJoin,
    required this.onLeave,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.isJoining || state.isLeaving || state.isSubmitting)
          _buildLoadingActions(context)
        else
          _buildNormalActions(context),
        
        const SizedBox(height: 16),
        
        // Additional info
        _buildActionInfo(context),
      ],
    );
  }

  /// Build loading state actions
  Widget _buildLoadingActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _getLoadingText(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build normal state actions
  Widget _buildNormalActions(BuildContext context) {
    // Challenge ended
    if (challenge.status == ChallengeStatus.past) {
      return _buildEndedActions(context);
    }
    
    // Challenge not started yet
    if (challenge.status == ChallengeStatus.upcoming) {
      return _buildUpcomingActions(context);
    }
    
    // User not participating
    if (!challenge.isParticipating) {
      return _buildJoinActions(context);
    }
    
    // User participating - different actions based on phase
    if (challenge.status == ChallengeStatus.active) {
      return _buildParticipatingActions(context);
    } else if (challenge.status == ChallengeStatus.voting) {
      return _buildVotingActions(context);
    }
    
    return const SizedBox.shrink();
  }

  /// Build actions for ended challenge
  Widget _buildEndedActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.emoji_events,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Challenge Completed',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Check out the results and winner!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              // Navigate to results
            },
            child: const Text('View Results'),
          ),
        ],
      ),
    );
  }

  /// Build actions for upcoming challenge
  Widget _buildUpcomingActions(BuildContext context) {
    return Column(
      children: [
        PrimaryButton(
          onPressed: onJoin,
          child: const Text('Join Challenge'),
        ),
        const SizedBox(height: 8),
        Text(
          'Challenge starts ${_formatStartTime(challenge.startTime)}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Build actions for joining challenge
  Widget _buildJoinActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            onPressed: onJoin,
            child: const Text('Join Challenge'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SecondaryButton(
            onPressed: () {
              // Share challenge
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.share, size: 18),
                const SizedBox(width: 8),
                const Text('Share'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build actions for participating user during active phase
  Widget _buildParticipatingActions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                onPressed: onSubmit,
                child: const Text('Submit Outfit'),
              ),
            ),
            const SizedBox(width: 12),
            SecondaryButton(
              onPressed: onLeave,
              style: SecondaryButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                side: BorderSide(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.5),
                ),
              ),
              child: const Text('Leave'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Submission deadline: ${_formatSubmissionDeadline(challenge.votingStartTime)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build actions for voting phase
  Widget _buildVotingActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.how_to_vote,
                color: Colors.orange,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voting Phase Active',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Vote for your favorite submissions below!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  onPressed: onLeave,
                  style: SecondaryButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.error.withOpacity(0.5),
                    ),
                  ),
                  child: const Text('Leave Challenge'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build action information
  Widget _buildActionInfo(BuildContext context) {
    if (!challenge.isParticipating) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Join to submit your style and compete for prizes!',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  /// Get loading text based on current operation
  String _getLoadingText() {
    if (state.isJoining) return 'Joining...';
    if (state.isLeaving) return 'Leaving...';
    if (state.isSubmitting) return 'Submitting...';
    return 'Loading...';
  }

  /// Format start time
  String _formatStartTime(DateTime startTime) {
    final now = DateTime.now();
    final difference = startTime.difference(now);
    
    if (difference.inDays > 0) {
      return 'in ${difference.inDays} days';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours} hours';
    } else if (difference.inMinutes > 0) {
      return 'in ${difference.inMinutes} minutes';
    } else {
      return 'soon';
    }
  }

  /// Format submission deadline
  String _formatSubmissionDeadline(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    
    if (difference.inDays > 1) {
      return '${difference.inDays} days';
    } else if (difference.inDays == 1) {
      return 'tomorrow';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes';
    } else {
      return 'ending soon';
    }
  }
}
