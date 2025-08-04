import 'package:flutter/material.dart';

/// Data class representing a Challenge Submission (for UI structure)
class ChallengeSubmission {
  final String id;
  final String challengeId;
  final String combinationId;
  final String userId;
  final int voteCount;
  final String? imageUrl;
  final String? username;
  final DateTime submittedAt;

  const ChallengeSubmission({
    required this.id,
    required this.challengeId,
    required this.combinationId,
    required this.userId,
    required this.voteCount,
    this.imageUrl,
    this.username,
    required this.submittedAt,
  });
}

/// A grid view for displaying challenge submissions
class SubmissionsGridView extends StatelessWidget {
  final List<ChallengeSubmission> submissions;
  final Function(ChallengeSubmission submission) onSubmissionTap;
  final bool isVotingActive;

  const SubmissionsGridView({
    super.key,
    required this.submissions,
    required this.onSubmissionTap,
    this.isVotingActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (submissions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No submissions yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to submit your creation!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: submissions.length,
      itemBuilder: (context, index) {
        final submission = submissions[index];
        return _SubmissionCard(
          submission: submission,
          onTap: () => onSubmissionTap(submission),
          isVotingActive: isVotingActive,
        );
      },
    );
  }
}

/// Card widget for a single submission
class _SubmissionCard extends StatelessWidget {
  final ChallengeSubmission submission;
  final VoidCallback onTap;
  final bool isVotingActive;

  const _SubmissionCard({
    required this.submission,
    required this.onTap,
    required this.isVotingActive,
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
            // Submission image
            Expanded(
              child: submission.imageUrl != null
                  ? Image.network(
                      submission.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(colorScheme),
                    )
                  : _buildPlaceholderImage(colorScheme),
            ),
            
            // User info and vote count
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Username
                  Expanded(
                    child: Text(
                      submission.username ?? 'Anonymous',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // Vote count
                  if (isVotingActive || submission.voteCount > 0) ...[
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isVotingActive ? Icons.favorite_border : Icons.favorite,
                          size: 16,
                          color: isVotingActive
                              ? colorScheme.primary
                              : colorScheme.primary.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          submission.voteCount.toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isVotingActive
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
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
          Icons.image_outlined,
          size: 48,
          color: colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
      ),
    );
  }
}
