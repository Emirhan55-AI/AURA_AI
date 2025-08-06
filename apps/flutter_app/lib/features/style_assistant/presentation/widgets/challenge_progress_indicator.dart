import 'package:flutter/material.dart';

import '../../domain/models/style_challenge.dart';

/// Challenge Progress Indicator Widget
/// 
/// Shows the progress of a challenge with visual indicators
class ChallengeProgressIndicator extends StatelessWidget {
  final StyleChallenge challenge;

  const ChallengeProgressIndicator({
    super.key,
    required this.challenge,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Challenge Progress',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${challenge.progressPercentage.toInt()}%',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Progress bar
        LinearProgressIndicator(
          value: challenge.progressPercentage / 100,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(
            challenge.statusColor,
          ),
          minHeight: 6,
        ),
        
        const SizedBox(height: 12),
        
        // Phase indicators
        Row(
          children: [
            _buildPhaseIndicator(
              context,
              'Submit',
              ChallengeStatus.active,
              Icons.camera_alt,
            ),
            Expanded(
              child: Container(
                height: 2,
                color: _getPhaseColor(context, ChallengeStatus.active),
              ),
            ),
            _buildPhaseIndicator(
              context,
              'Vote',
              ChallengeStatus.voting,
              Icons.how_to_vote,
            ),
            Expanded(
              child: Container(
                height: 2,
                color: _getPhaseColor(context, ChallengeStatus.voting),
              ),
            ),
            _buildPhaseIndicator(
              context,
              'Results',
              ChallengeStatus.past,
              Icons.emoji_events,
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Current phase info
        _buildCurrentPhaseInfo(context),
      ],
    );
  }

  /// Build phase indicator
  Widget _buildPhaseIndicator(
    BuildContext context,
    String label,
    ChallengeStatus phaseStatus,
    IconData icon,
  ) {
    final isActive = challenge.status == phaseStatus;
    final isPassed = _isPhaseCompleted(phaseStatus);
    final color = _getPhaseColor(context, phaseStatus);
    
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive || isPassed ? color : Colors.grey.shade300,
            shape: BoxShape.circle,
            border: isActive ? Border.all(
              color: color,
              width: 3,
            ) : null,
          ),
          child: Icon(
            isPassed ? Icons.check : icon,
            size: 16,
            color: isActive || isPassed ? Colors.white : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isActive ? color : Colors.grey.shade600,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  /// Build current phase information
  Widget _buildCurrentPhaseInfo(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: challenge.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: challenge.statusColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getCurrentPhaseIcon(),
                size: 16,
                color: challenge.statusColor,
              ),
              const SizedBox(width: 8),
              Text(
                _getCurrentPhaseTitle(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: challenge.statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _getCurrentPhaseDescription(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: challenge.statusColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            challenge.timeRangeText,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: challenge.statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Get color for a specific phase
  Color _getPhaseColor(BuildContext context, ChallengeStatus phaseStatus) {
    if (_isPhaseCompleted(phaseStatus)) {
      return Colors.green;
    } else if (challenge.status == phaseStatus) {
      return challenge.statusColor;
    } else {
      return Colors.grey.shade300;
    }
  }

  /// Check if phase is completed
  bool _isPhaseCompleted(ChallengeStatus phaseStatus) {
    final currentIndex = ChallengeStatus.values.indexOf(challenge.status);
    final phaseIndex = ChallengeStatus.values.indexOf(phaseStatus);
    
    // Special handling for the flow
    switch (phaseStatus) {
      case ChallengeStatus.upcoming:
        return challenge.status != ChallengeStatus.upcoming;
      case ChallengeStatus.active:
        return challenge.status == ChallengeStatus.voting || challenge.status == ChallengeStatus.past;
      case ChallengeStatus.voting:
        return challenge.status == ChallengeStatus.past;
      case ChallengeStatus.past:
        return false; // Never completed until it's actually past
    }
  }

  /// Get current phase icon
  IconData _getCurrentPhaseIcon() {
    switch (challenge.status) {
      case ChallengeStatus.upcoming:
        return Icons.schedule;
      case ChallengeStatus.active:
        return Icons.camera_alt;
      case ChallengeStatus.voting:
        return Icons.how_to_vote;
      case ChallengeStatus.past:
        return Icons.emoji_events;
    }
  }

  /// Get current phase title
  String _getCurrentPhaseTitle() {
    switch (challenge.status) {
      case ChallengeStatus.upcoming:
        return 'Starting Soon';
      case ChallengeStatus.active:
        return 'Submission Phase';
      case ChallengeStatus.voting:
        return 'Voting Phase';
      case ChallengeStatus.past:
        return 'Challenge Ended';
    }
  }

  /// Get current phase description
  String _getCurrentPhaseDescription() {
    switch (challenge.status) {
      case ChallengeStatus.upcoming:
        return 'Challenge will start soon. Join now to participate!';
      case ChallengeStatus.active:
        return 'Submit your stylish outfit to compete for prizes.';
      case ChallengeStatus.voting:
        return 'Vote for your favorite submissions to help choose the winner.';
      case ChallengeStatus.past:
        return 'This challenge has ended. Check out the winner and results!';
    }
  }
}
