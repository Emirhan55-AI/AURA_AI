import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/challenge_submission.dart';
import '../../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../../shared/widgets/buttons/secondary_button.dart';
import '../providers/challenge_detail_providers.dart';

/// Modern submission card widget following Material 3 design
class SubmissionCard extends ConsumerWidget {
  final ChallengeSubmission submission;
  final bool showVoteButton;
  final VoidCallback? onTap;

  const SubmissionCard({
    super.key,
    required this.submission,
    this.showVoteButton = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.all(8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Outfit Image Section
            _buildImageSection(context),
            
            // Content Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info Row
                  _buildUserInfoRow(context),
                  
                  const SizedBox(height: 12),
                  
                  // Description
                  if (submission.description?.isNotEmpty == true)
                    _buildDescription(context),
                  
                  // Tags
                  if (submission.tags.isNotEmpty)
                    _buildTags(context),
                  
                  const SizedBox(height: 12),
                  
                  // Stats and Actions Row
                  _buildStatsAndActions(context, ref),
                ],
              ),
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
      height: 200,
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        image: submission.outfitImageUrl != null
            ? DecorationImage(
                image: NetworkImage(submission.outfitImageUrl!),
                fit: BoxFit.cover,
                onError: (_, __) => {},
              )
            : null,
      ),
      child: Stack(
        children: [
          // Fallback for no image
          if (submission.outfitImageUrl == null)
            Center(
              child: Icon(
                Icons.checkroom,
                size: 48,
                color: colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
            ),
          
          // Rank badge (top-left)
          if (submission.rank > 0)
            Positioned(
              top: 8,
              left: 8,
              child: _buildRankBadge(context),
            ),
          
          // Status badge (top-right)
          Positioned(
            top: 8,
            right: 8,
            child: _buildStatusBadge(context),
          ),
          
          // Vote count (bottom-right)
          Positioned(
            bottom: 8,
            right: 8,
            child: _buildVoteCountBadge(context),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoRow(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        // User avatar
        CircleAvatar(
          radius: 20,
          backgroundImage: submission.userAvatarUrl != null
              ? NetworkImage(submission.userAvatarUrl!)
              : null,
          child: submission.userAvatarUrl == null
              ? Icon(Icons.person, color: theme.colorScheme.onSurface)
              : null,
        ),
        
        const SizedBox(width: 12),
        
        // User info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                submission.userName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                submission.timeAgo,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        
        // Score (if available)
        if (submission.score > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star,
                  size: 16,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 4),
                Text(
                  submission.formattedScore,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        submission.description!,
        style: theme.textTheme.bodyMedium,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildTags(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: submission.tags.take(3).map((tag) => Chip(
          label: Text(
            '#$tag',
            style: theme.textTheme.labelSmall,
          ),
          backgroundColor: theme.colorScheme.surfaceVariant,
          side: BorderSide.none,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        )).toList(),
      ),
    );
  }

  Widget _buildStatsAndActions(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final actionsState = ref.watch(challengeDetailActionsProvider);
    
    return Row(
      children: [
        // Vote count with icon
        Icon(
          Icons.favorite,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 4),
        Text(
          '${submission.voteCount}',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const Spacer(),
        
        // Vote button
        if (showVoteButton && submission.canVote)
          SizedBox(
            height: 32,
            child: PrimaryButton(
              text: 'Vote',
              onPressed: actionsState.isLoading ? null : () {
                ref.read(challengeDetailActionsProvider.notifier)
                    .voteOnSubmission(submission.id, submission.challengeId);
              },
              isLoading: actionsState.isLoading,
            ),
          ),
        
        // Already voted indicator
        if (submission.hasUserVoted)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check,
                  size: 16,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 4),
                Text(
                  'Voted',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRankBadge(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        submission.rankDisplay,
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: submission.statusColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        submission.statusText,
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildVoteCountBadge(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.favorite,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            '${submission.voteCount}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
