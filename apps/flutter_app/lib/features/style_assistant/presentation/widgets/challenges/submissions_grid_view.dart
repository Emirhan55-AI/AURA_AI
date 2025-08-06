import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/challenge_submission.dart';
import 'submission_card.dart';
import '../../../../../shared/widgets/common/loading_widget.dart';
import '../../../../../shared/widgets/common/error_widget.dart';
import '../../../../../shared/widgets/common/empty_state_widget.dart';

/// Modern submissions grid view widget following docs standards
class SubmissionsGridView extends ConsumerWidget {
  final List<ChallengeSubmission> submissions;
  final bool isLoading;
  final String? error;
  final bool showVoteButtons;
  final VoidCallback? onRefresh;

  const SubmissionsGridView({
    super.key,
    required this.submissions,
    this.isLoading = false,
    this.error,
    this.showVoteButtons = true,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Error state
    if (error != null) {
      return CustomErrorWidget(
        message: error!,
        onRetry: onRefresh,
      );
    }

    // Loading state
    if (isLoading) {
      return const LoadingWidget();
    }

    // Empty state
    if (submissions.isEmpty) {
      return EmptyStateWidget(
        title: 'No Submissions Yet',
        message: 'Be the first to submit your outfit for this challenge!',
        icon: Icons.checkroom_outlined,
        actionText: 'Refresh',
        onAction: onRefresh,
      );
    }

    // Success state - Show submissions grid
    return _buildSubmissionsGrid(context);
  }

  Widget _buildSubmissionsGrid(BuildContext context) {
    final theme = Theme.of(context);
    
    return RefreshIndicator(
      onRefresh: onRefresh != null 
          ? () async => onRefresh!() 
          : () async {},
      child: CustomScrollView(
        slivers: [
          // Header with submission count
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Submissions (${submissions.length})',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    showVoteButtons 
                        ? 'Vote for your favorite outfits!'
                        : 'Check out these amazing submissions',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Top 3 Winners Section (if rankings are available)
          if (_hasRankedSubmissions())
            SliverToBoxAdapter(
              child: _buildTopThreeSection(context),
            ),

          // All Submissions Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75, // Adjust for card content
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final submission = submissions[index];
                  return SubmissionCard(
                    submission: submission,
                    showVoteButton: showVoteButtons,
                    onTap: () => _showSubmissionDetail(context, submission),
                  );
                },
                childCount: submissions.length,
              ),
            ),
          ),

          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildTopThreeSection(BuildContext context) {
    final theme = Theme.of(context);
    final topThree = submissions.where((s) => s.isTopThree).toList()
      ..sort((a, b) => a.rank.compareTo(b.rank));

    if (topThree.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: theme.colorScheme.onPrimaryContainer,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Top Winners',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: topThree.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final submission = topThree[index];
                return _buildWinnerCard(context, submission);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinnerCard(BuildContext context, ChallengeSubmission submission) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () => _showSubmissionDetail(context, submission),
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getRankColor(submission.rank),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            // Rank badge
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: _getRankColor(submission.rank),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
              ),
              child: Text(
                submission.rankDisplay,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // User info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: submission.userAvatarUrl != null
                          ? NetworkImage(submission.userAvatarUrl!)
                          : null,
                      child: submission.userAvatarUrl == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      submission.userName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '${submission.voteCount} votes',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }

  bool _hasRankedSubmissions() {
    return submissions.any((s) => s.rank > 0);
  }

  void _showSubmissionDetail(BuildContext context, ChallengeSubmission submission) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSubmissionDetailModal(context, submission),
    );
  }

  Widget _buildSubmissionDetailModal(BuildContext context, ChallengeSubmission submission) {
    final theme = Theme.of(context);
    
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Large outfit image
                    if (submission.outfitImageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: 3 / 4,
                          child: Image.network(
                            submission.outfitImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: theme.colorScheme.surfaceVariant,
                              child: Icon(
                                Icons.checkroom,
                                size: 64,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 24),
                    
                    // User and submission info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: submission.userAvatarUrl != null
                              ? NetworkImage(submission.userAvatarUrl!)
                              : null,
                          child: submission.userAvatarUrl == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                submission.userName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
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
                        if (submission.rank > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getRankColor(submission.rank),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              submission.rankDisplay,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    if (submission.description?.isNotEmpty == true) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Description',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        submission.description!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                    
                    if (submission.tags.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Tags',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: submission.tags.map((tag) => Chip(
                          label: Text('#$tag'),
                          backgroundColor: theme.colorScheme.surfaceVariant,
                        )).toList(),
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    // Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(context, 'Votes', '${submission.voteCount}', Icons.favorite),
                        if (submission.score > 0)
                          _buildStatItem(context, 'Score', submission.formattedScore, Icons.star),
                        _buildStatItem(context, 'Status', submission.statusText, Icons.info_outline),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
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
