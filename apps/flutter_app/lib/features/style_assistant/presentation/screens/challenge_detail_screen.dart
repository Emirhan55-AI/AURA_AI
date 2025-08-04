import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/style_challenges_controller.dart';
import '../widgets/challenges/challenge_card.dart';
import '../widgets/challenges/submissions_grid_view.dart';

/// Screen for displaying details of a specific style challenge
class ChallengeDetailScreen extends ConsumerStatefulWidget {
  final StyleChallenge challenge;

  const ChallengeDetailScreen({
    super.key,
    required this.challenge,
  });

  @override
  ConsumerState<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends ConsumerState<ChallengeDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load challenge details on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(styleChallengesControllerProvider.notifier)
          .loadChallengeDetail(widget.challenge.id);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final styleChallengesState = ref.watch(styleChallengesControllerProvider);
    final styleChallengesController = ref.read(styleChallengesControllerProvider.notifier);
    
    // Get the challenge from the controller if available, otherwise use the one passed in
    final challenge = styleChallengesState.selectedChallenge.valueOrNull ?? widget.challenge;
    final submissionsState = styleChallengesState.challengeSubmissions;
    
    // Determine if the challenge is in voting phase or active (for participate button)
    final bool isVotingActive = challenge.status == ChallengeStatus.voting;
    final bool canParticipate = challenge.status == ChallengeStatus.active && 
                                !styleChallengesState.hasUserSubmittedToSelectedChallenge;

    return Scaffold(
      appBar: AppBar(
        title: Text(challenge.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh challenge data',
            onPressed: () {
              styleChallengesController.retryLoadChallengeDetail(challenge.id);
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share challenge',
            onPressed: () {
              // This will later implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share functionality coming soon!')),
              );
            },
          ),
        ],
      ),
      body: _buildBody(context, submissionsState, isVotingActive, styleChallengesController),
      floatingActionButton: canParticipate
          ? FloatingActionButton.extended(
              onPressed: () {
                // For demo, create a dummy combination ID
                styleChallengesController.submitCombination(
                  challenge.id, 
                  'dummy_combination_${DateTime.now().millisecondsSinceEpoch}',
                );
              },
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Submit Outfit'),
              heroTag: 'submit_outfit',
            )
          : null,
    );
  }

  Widget _buildBody(
    BuildContext context, 
    AsyncValue<List<ChallengeSubmission>> submissionsState, 
    bool isVotingActive,
    StyleChallengesController controller,
  ) {
    // Challenge details are already loaded at this point
    final challenge = widget.challenge;

    return submissionsState.when(
      data: (submissions) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Challenge header/banner
              _buildChallengeHeader(context),
              
              // Challenge details card
              _buildChallengeDetailsCard(context),
              
              // Submissions section
              _buildSubmissionsSection(context, submissions, isVotingActive),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading submissions...'),
          ],
        ),
      ),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text('Error loading submissions: ${error.toString()}'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => controller.retryLoadChallengeDetail(challenge.id),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final challenge = widget.challenge;

    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        image: challenge.imageUrl != null
            ? DecorationImage(
                image: NetworkImage(challenge.imageUrl!),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3),
                  BlendMode.darken,
                ),
              )
            : null,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (challenge.imageUrl == null) ...[
              Icon(
                Icons.style,
                size: 64,
                color: colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              challenge.title,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: challenge.imageUrl != null ? Colors.white : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            _buildStatusChip(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final challenge = widget.challenge;
    
    late Color backgroundColor;
    late Color textColor;
    late String label;
    late IconData iconData;
    
    switch (challenge.status) {
      case ChallengeStatus.active:
        backgroundColor = colorScheme.primaryContainer;
        textColor = colorScheme.onPrimaryContainer;
        label = 'Active Challenge';
        iconData = Icons.timer;
        break;
      case ChallengeStatus.upcoming:
        backgroundColor = colorScheme.tertiaryContainer;
        textColor = colorScheme.onTertiaryContainer;
        label = 'Upcoming Challenge';
        iconData = Icons.calendar_month;
        break;
      case ChallengeStatus.voting:
        backgroundColor = colorScheme.secondaryContainer;
        textColor = colorScheme.onSecondaryContainer;
        label = 'Voting in Progress';
        iconData = Icons.how_to_vote;
        break;
      case ChallengeStatus.past:
        backgroundColor = colorScheme.surfaceVariant;
        textColor = colorScheme.onSurfaceVariant;
        label = 'Past Challenge';
        iconData = Icons.history;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: 18,
            color: textColor,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeDetailsCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final challenge = widget.challenge;
    final hasSubmitted = ref.watch(styleChallengesControllerProvider).hasUserSubmittedToSelectedChallenge;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description
            Text(
              'About this Challenge',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              challenge.description,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Dates
            Text(
              'Timeline',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildTimelineItem(
              context,
              'Started',
              _formatDate(challenge.startTime),
              Icons.play_circle_outline,
              colorScheme.primary,
            ),
            if (challenge.status == ChallengeStatus.voting) ...[
              _buildTimelineItem(
                context,
                'Voting Started',
                _formatDate(challenge.votingStartTime),
                Icons.how_to_vote,
                colorScheme.secondary,
              ),
            ] else if (challenge.status != ChallengeStatus.past) ...[
              _buildTimelineItem(
                context,
                'Voting Starts',
                _formatDate(challenge.votingStartTime),
                Icons.how_to_vote_outlined,
                colorScheme.onSurfaceVariant,
              ),
            ],
            _buildTimelineItem(
              context,
              challenge.status == ChallengeStatus.past ? 'Ended' : 'Ends',
              _formatDate(challenge.endTime),
              challenge.status == ChallengeStatus.past
                  ? Icons.event_available
                  : Icons.event_outlined,
              challenge.status == ChallengeStatus.past
                  ? colorScheme.tertiary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),

            // Prize
            Text(
              'Prize',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.emoji_events,
                  color: colorScheme.tertiary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    challenge.prizeDescription,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),

            // Participation badge if participating or has submitted
            if (challenge.isParticipating || hasSubmitted) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'You are participating',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    String label,
    String date,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            date,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionsSection(BuildContext context, List<ChallengeSubmission> submissions, bool isVotingActive) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Submissions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (submissions.isNotEmpty) ...[
                Chip(
                  label: Text('${submissions.length}'),
                  avatar: const Icon(Icons.people_outline, size: 18),
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  labelStyle: theme.textTheme.labelMedium,
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          SubmissionsGridView(
            submissions: submissions,
            onSubmissionTap: (submission) {
              // This will later navigate to submission detail
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Viewing submission by ${submission.username ?? "Anonymous"}')),
              );
            },
            isVotingActive: isVotingActive,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final month = _getMonthName(date.month);
    return '$month ${date.day}, ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}

// Named route for ChallengeDetailScreen
class ChallengeDetailRoute {
  static const String name = '/style-challenges/:id';

  // For named route navigation in RouteGenerator
  static Widget builder({
    required StyleChallenge challenge,
  }) {
    return ChallengeDetailScreen(challenge: challenge);
  }
}
