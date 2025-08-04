import 'package:flutter/material.dart';

/// Data class representing a Style Challenge (for UI structure)
class StyleChallenge {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime votingStartTime;
  final DateTime endTime;
  final ChallengeStatus status;
  final String prizeDescription;
  final String? imageUrl;
  final int submissionCount;
  final bool isParticipating;

  const StyleChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.votingStartTime,
    required this.endTime,
    required this.status,
    required this.prizeDescription,
    this.imageUrl,
    this.submissionCount = 0,
    this.isParticipating = false,
  });

  // Helper method to get a formatted time range string
  String get timeRangeText {
    final now = DateTime.now();
    
    switch (status) {
      case ChallengeStatus.active:
        final daysRemaining = endTime.difference(now).inDays;
        final hoursRemaining = endTime.difference(now).inHours % 24;
        if (daysRemaining > 0) {
          return '$daysRemaining days left';
        } else if (hoursRemaining > 0) {
          return '$hoursRemaining hours left';
        } else {
          return 'Ending soon';
        }
      
      case ChallengeStatus.upcoming:
        final daysToStart = startTime.difference(now).inDays;
        return 'Starts in $daysToStart days';
      
      case ChallengeStatus.voting:
        return 'Voting in progress';
        
      case ChallengeStatus.past:
        return 'Challenge ended';
    }
  }
}

/// Enum representing the status of a challenge
enum ChallengeStatus {
  active,
  upcoming,
  voting,
  past,
}

/// A card widget representing a style challenge in a list or grid
class ChallengeCard extends StatelessWidget {
  final StyleChallenge challenge;
  final VoidCallback onTap;

  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Challenge image or placeholder
            AspectRatio(
              aspectRatio: 16 / 9,
              child: challenge.imageUrl != null
                  ? Image.network(
                      challenge.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(colorScheme),
                    )
                  : _buildPlaceholderImage(colorScheme),
            ),
            
            // Status badge
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: _buildStatusChip(context),
            ),
            
            // Challenge title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                challenge.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Time remaining and submissions count
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    challenge.timeRangeText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getTimeRemainingColor(colorScheme),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${challenge.submissionCount}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceVariant,
      child: Center(
        child: Icon(
          Icons.style,
          size: 48,
          color: colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Color backgroundColor;
    Color textColor;
    String label;
    IconData iconData;
    
    switch (challenge.status) {
      case ChallengeStatus.active:
        backgroundColor = colorScheme.primaryContainer;
        textColor = colorScheme.onPrimaryContainer;
        label = 'Active';
        iconData = Icons.timer;
      case ChallengeStatus.upcoming:
        backgroundColor = colorScheme.tertiaryContainer;
        textColor = colorScheme.onTertiaryContainer;
        label = 'Upcoming';
        iconData = Icons.calendar_today;
      case ChallengeStatus.voting:
        backgroundColor = colorScheme.secondaryContainer;
        textColor = colorScheme.onSecondaryContainer;
        label = 'Voting';
        iconData = Icons.how_to_vote;
      case ChallengeStatus.past:
        backgroundColor = colorScheme.surfaceVariant;
        textColor = colorScheme.onSurfaceVariant;
        label = 'Past';
        iconData = Icons.history;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: 16,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (challenge.isParticipating) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.check_circle,
              size: 12,
              color: textColor,
            ),
          ],
        ],
      ),
    );
  }

  Color _getTimeRemainingColor(ColorScheme colorScheme) {
    switch (challenge.status) {
      case ChallengeStatus.active:
        return colorScheme.primary;
      case ChallengeStatus.upcoming:
        return colorScheme.tertiary;
      case ChallengeStatus.voting:
        return colorScheme.secondary;
      case ChallengeStatus.past:
        return colorScheme.onSurfaceVariant;
    }
  }
}
