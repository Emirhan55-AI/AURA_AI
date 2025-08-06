import 'package:flutter/material.dart';
import '../../../domain/models/style_challenge_new.dart';

/// Modern challenge card with production-ready design
class ModernChallengeCard extends StatelessWidget {
  final StyleChallenge challenge;
  final VoidCallback onTap;
  final VoidCallback? onJoin;
  final VoidCallback? onLeave;

  const ModernChallengeCard({
    super.key,
    required this.challenge,
    required this.onTap,
    this.onJoin,
    this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 2,
      shadowColor: colorScheme.shadow.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Expanded(
              flex: 3,
              child: _buildImageSection(context),
            ),
            
            // Content section
            Expanded(
              flex: 2,
              child: _buildContentSection(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        image: challenge.imageUrl != null
            ? DecorationImage(
                image: NetworkImage(challenge.imageUrl!),
                fit: BoxFit.cover,
                onError: (_, __) => {},
              )
            : null,
      ),
      child: Stack(
        children: [
          // Fallback for no image
          if (challenge.imageUrl == null)
            Center(
              child: Icon(
                Icons.style,
                size: 48,
                color: colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
            ),
          
          // Status badge
          Positioned(
            top: 8,
            left: 8,
            child: _buildStatusBadge(context),
          ),
          
          // Difficulty badge
          Positioned(
            top: 8,
            right: 8,
            child: _buildDifficultyBadge(context),
          ),
          
          // Participation indicator
          if (challenge.isParticipating)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: 16,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContentSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            challenge.title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 4),
          
          // Time info
          Text(
            challenge.timeRangeText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: challenge.statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const Spacer(),
          
          // Stats row
          Row(
            children: [
              Icon(
                Icons.people,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                '${challenge.participantCount}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.upload,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                '${challenge.submissionCount}',
                style: theme.textTheme.bodySmall,
              ),
              const Spacer(),
              _buildActionButton(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: challenge.statusColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _statusToString(challenge.status),
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: challenge.difficultyColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _difficultyToString(challenge.difficulty),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final theme = Theme.of(context);
    
    if (challenge.isParticipating && onLeave != null) {
      return InkWell(
        onTap: onLeave,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Leave',
            style: TextStyle(
              color: theme.colorScheme.onErrorContainer,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    
    if (challenge.canParticipate && onJoin != null) {
      return InkWell(
        onTap: onJoin,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Join',
            style: TextStyle(
              color: theme.colorScheme.onPrimaryContainer,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  String _statusToString(ChallengeStatus status) {
    switch (status) {
      case ChallengeStatus.active:
        return 'ACTIVE';
      case ChallengeStatus.upcoming:
        return 'SOON';
      case ChallengeStatus.voting:
        return 'VOTING';
      case ChallengeStatus.past:
        return 'ENDED';
    }
  }

  String _difficultyToString(ChallengeDifficulty difficulty) {
    switch (difficulty) {
      case ChallengeDifficulty.beginner:
        return 'Easy';
      case ChallengeDifficulty.intermediate:
        return 'Medium';
      case ChallengeDifficulty.advanced:
        return 'Hard';
    }
  }
}
