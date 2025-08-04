import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/style_challenges_controller.dart';
import '../widgets/challenges/challenge_card.dart';

/// Screen for displaying and interacting with style challenges
class StyleChallengesScreen extends ConsumerWidget {
  const StyleChallengesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styleChallengesState = ref.watch(styleChallengesControllerProvider);
    final styleChallengesController = ref.read(styleChallengesControllerProvider.notifier);
    
    return DefaultTabController(
      length: 3, // Active, Upcoming, Past
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Style Challenges'),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
            onTap: (index) {
              // Convert index to ChallengeStatus and change tab
              final status = _indexToStatus(index);
              styleChallengesController.changeTab(status);
            },
          ),
        ),
        body: TabBarView(
          children: [
            // Active challenges tab
            _buildChallengesTab(
              context,
              styleChallengesState.activeChallenges,
              ChallengeStatus.active,
              styleChallengesController,
            ),
            
            // Upcoming challenges tab
            _buildChallengesTab(
              context,
              styleChallengesState.upcomingChallenges,
              ChallengeStatus.upcoming,
              styleChallengesController,
            ),
            
            // Past challenges tab
            _buildChallengesTab(
              context,
              styleChallengesState.pastChallenges,
              ChallengeStatus.past,
              styleChallengesController,
            ),
          ],
        ),
        floatingActionButton: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              heroTag: 'refresh_challenges',
              onPressed: () => styleChallengesController.refreshAll(),
              tooltip: 'Refresh Challenges',
              child: const Icon(Icons.refresh),
            ),
            const SizedBox(width: 16),
            FloatingActionButton.extended(
              onPressed: () {
                // This will later navigate to create challenge screen or join a challenge
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Create Challenge feature coming soon!')),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create'),
              heroTag: 'create_challenge',
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to convert tab index to ChallengeStatus
  ChallengeStatus _indexToStatus(int index) {
    switch (index) {
      case 0:
        return ChallengeStatus.active;
      case 1:
        return ChallengeStatus.upcoming;
      case 2:
        return ChallengeStatus.past;
      default:
        return ChallengeStatus.active;
    }
  }

  Widget _buildChallengesTab(
    BuildContext context, 
    AsyncValue<List<StyleChallenge>> challengesValue,
    ChallengeStatus status,
    StyleChallengesController controller,
  ) {
    final tabLabel = _statusToLabel(status);
    
    return challengesValue.when(
      data: (challenges) {
        if (challenges.isEmpty) {
          return _buildEmptyState(context, tabLabel);
        }
        return _buildChallengesGrid(context, challenges);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => _buildErrorState(context, error, status, controller),
    );
  }
  
  // Helper method to convert ChallengeStatus to display label
  String _statusToLabel(ChallengeStatus status) {
    switch (status) {
      case ChallengeStatus.active:
        return 'Active';
      case ChallengeStatus.upcoming:
        return 'Upcoming';
      case ChallengeStatus.past:
        return 'Past';
      case ChallengeStatus.voting:
        return 'Voting';
    }
  }

  Widget _buildErrorState(
    BuildContext context,
    Object error,
    ChallengeStatus status,
    StyleChallengesController controller,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tabLabel = _statusToLabel(status);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: colorScheme.error.withOpacity(0.8),
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load challenges',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => controller.retryLoadChallenges(status),
            icon: const Icon(Icons.refresh),
            label: Text('Retry Loading ${tabLabel} Challenges'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String tabLabel) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String message;
    String description;
    IconData iconData;

    switch (tabLabel) {
      case 'Active':
        message = 'No active challenges';
        description = 'Check back soon for new challenges or create your own!';
        iconData = Icons.event_busy;
      case 'Upcoming':
        message = 'No upcoming challenges';
        description = 'New challenges will be announced soon.';
        iconData = Icons.calendar_month;
      case 'Past':
        message = 'No past challenges';
        description = 'Completed challenges will appear here.';
        iconData = Icons.history;
      default:
        message = 'No challenges found';
        description = 'Check back later for new challenges.';
        iconData = Icons.style;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            size: 64,
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesGrid(BuildContext context, List<StyleChallenge> challenges) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        return ChallengeCard(
          challenge: challenge,
          onTap: () {
            // Navigate to challenge detail screen using GoRouter
            context.pushNamed(
              'challengeDetail',
              pathParameters: {'id': challenge.id},
              extra: challenge,
            );
          },
        );
      },
    );
  }


}

/// Route generator for StyleChallengesScreen
class StyleChallengesRoute {
  static const String name = '/style-challenges';

  static Route<void> route() {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: name),
      builder: (context) => const StyleChallengesScreen(),
    );
  }
}

/// Extension for easy navigation
extension StyleChallengesNavigation on NavigatorState {
  Future<void> pushStyleChallenges() {
    return push(StyleChallengesRoute.route());
  }
}
