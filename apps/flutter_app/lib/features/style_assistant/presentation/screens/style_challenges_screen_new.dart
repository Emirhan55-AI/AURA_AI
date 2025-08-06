import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/style_challenge_new.dart';
import '../providers/style_challenges_providers_simple.dart';
import '../widgets/challenges/modern_challenge_card.dart';
import '../../../../shared/widgets/common/loading_widget.dart';
import '../../../../shared/widgets/common/error_widget.dart';
import '../../../../shared/widgets/common/empty_state_widget.dart';

/// Modern StyleChallengesScreen with production-ready features
class StyleChallengesScreen extends ConsumerStatefulWidget {
  const StyleChallengesScreen({super.key});

  @override
  ConsumerState<StyleChallengesScreen> createState() => _StyleChallengesScreenState();
}

class _StyleChallengesScreenState extends ConsumerState<StyleChallengesScreen> 
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    
    final status = _indexToStatus(_tabController.index);
    ref.read(currentChallengeTabProvider.notifier).state = status;
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = ref.watch(currentChallengeTabProvider);
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Style Challenges'),
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          indicatorColor: theme.colorScheme.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Voting'),
            Tab(text: 'Past'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showFilterSheet,
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Challenges',
          ),
          IconButton(
            onPressed: _refreshCurrentTab,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChallengesTab(ChallengeStatus.active),
          _buildChallengesTab(ChallengeStatus.upcoming),
          _buildChallengesTab(ChallengeStatus.voting),
          _buildChallengesTab(ChallengeStatus.past),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(currentTab),
    );
  }

  Widget _buildChallengesTab(ChallengeStatus status) {
    return Consumer(
      builder: (context, ref, child) {
        final AsyncValue<List<StyleChallenge>> challengesAsync;
        
        switch (status) {
          case ChallengeStatus.active:
            challengesAsync = ref.watch(activeChallengesProvider);
          case ChallengeStatus.upcoming:
            challengesAsync = ref.watch(upcomingChallengesProvider);
          case ChallengeStatus.past:
            challengesAsync = ref.watch(pastChallengesProvider);
          case ChallengeStatus.voting:
            // For voting, we'll filter from active challenges
            challengesAsync = ref.watch(activeChallengesProvider);
        }

        return challengesAsync.when(
          data: (challenges) {
            List<StyleChallenge> filteredChallenges = challenges;
            
            // Filter for voting status if needed
            if (status == ChallengeStatus.voting) {
              filteredChallenges = challenges.where((c) => c.isVotingOpen).toList();
            }
            
            if (filteredChallenges.isEmpty) {
              return _buildEmptyState(status);
            }
            
            return _buildChallengesGrid(filteredChallenges);
          },
          loading: () => const LoadingWidget(message: 'Loading challenges...'),
          error: (error, stackTrace) => _buildErrorState(error, status),
        );
      },
    );
  }

  Widget _buildChallengesGrid(List<StyleChallenge> challenges) {
    return RefreshIndicator(
      onRefresh: _refreshCurrentTab,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: challenges.length,
        itemBuilder: (context, index) {
          final challenge = challenges[index];
          return ModernChallengeCard(
            challenge: challenge,
            onTap: () => _navigateToChallengeDetail(challenge),
            onJoin: challenge.canParticipate ? () => _joinChallenge(challenge.id) : null,
            onLeave: challenge.isParticipating ? () => _leaveChallenge(challenge.id) : null,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ChallengeStatus status) {
    String title;
    String message;
    IconData iconData;
    String? actionText;
    VoidCallback? onAction;

    switch (status) {
      case ChallengeStatus.active:
        title = 'No Active Challenges';
        message = 'Check back soon for new challenges or explore upcoming ones!';
        iconData = Icons.event_busy;
        actionText = 'View Upcoming';
        onAction = () => _tabController.animateTo(1);
      case ChallengeStatus.upcoming:
        title = 'No Upcoming Challenges';
        message = 'New challenges will be announced soon. Stay tuned!';
        iconData = Icons.schedule;
      case ChallengeStatus.voting:
        title = 'No Voting Challenges';
        message = 'No challenges are currently in voting phase.';
        iconData = Icons.how_to_vote;
      case ChallengeStatus.past:
        title = 'No Past Challenges';
        message = 'Completed challenges will appear here once you participate.';
        iconData = Icons.history;
        actionText = 'Join Active Challenges';
        onAction = () => _tabController.animateTo(0);
    }

    return EmptyStateWidget(
      icon: iconData,
      title: title,
      message: message,
      actionText: actionText,
      onAction: onAction,
    );
  }

  Widget _buildErrorState(Object error, ChallengeStatus status) {
    return CustomErrorWidget(
      error: error,
      onRetry: () => _retryLoadChallenges(status),
      title: 'Failed to load challenges',
      message: 'There was an error loading the challenges. Please try again.',
    );
  }

  Widget? _buildFloatingActionButton(ChallengeStatus currentTab) {
    return FloatingActionButton.extended(
      onPressed: _refreshCurrentTab,
      icon: const Icon(Icons.refresh),
      label: const Text('Refresh'),
      tooltip: 'Refresh challenges',
    );
  }

  // Navigation and Actions
  void _navigateToChallengeDetail(StyleChallenge challenge) {
    context.pushNamed(
      'challengeDetail',
      pathParameters: {'challengeId': challenge.id},
      extra: challenge,
    );
  }

  Future<void> _joinChallenge(String challengeId) async {
    final actions = ref.read(styleChallengeActionsProvider.notifier);
    await actions.joinChallenge(challengeId);
    
    // Show feedback
    if (mounted) {
      final actionsState = ref.read(styleChallengeActionsProvider);
      actionsState.when(
        data: (_) => _showSnackBar('Successfully joined challenge!', isError: false),
        loading: () => {},
        error: (error, _) => _showSnackBar('Failed to join challenge: $error'),
      );
    }
  }

  Future<void> _leaveChallenge(String challengeId) async {
    final confirmed = await _showConfirmDialog(
      'Leave Challenge',
      'Are you sure you want to leave this challenge?',
    );
    
    if (confirmed == true) {
      final actions = ref.read(styleChallengeActionsProvider.notifier);
      await actions.leaveChallenge(challengeId);
      
      // Show feedback
      if (mounted) {
        final actionsState = ref.read(styleChallengeActionsProvider);
        actionsState.when(
          data: (_) => _showSnackBar('Left challenge successfully', isError: false),
          loading: () => {},
          error: (error, _) => _showSnackBar('Failed to leave challenge: $error'),
        );
      }
    }
  }

  Future<void> _refreshCurrentTab() async {
    final currentTab = ref.read(currentChallengeTabProvider);
    await _retryLoadChallenges(currentTab);
  }

  Future<void> _retryLoadChallenges(ChallengeStatus status) async {
    switch (status) {
      case ChallengeStatus.active:
        ref.invalidate(activeChallengesProvider);
      case ChallengeStatus.upcoming:
        ref.invalidate(upcomingChallengesProvider);
      case ChallengeStatus.past:
        ref.invalidate(pastChallengesProvider);
      case ChallengeStatus.voting:
        ref.invalidate(activeChallengesProvider);
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const ChallengeFilterSheet(),
    );
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError 
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<bool?> _showConfirmDialog(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  ChallengeStatus _indexToStatus(int index) {
    switch (index) {
      case 0:
        return ChallengeStatus.active;
      case 1:
        return ChallengeStatus.upcoming;
      case 2:
        return ChallengeStatus.voting;
      case 3:
        return ChallengeStatus.past;
      default:
        return ChallengeStatus.active;
    }
  }
}

/// Filter sheet for challenges
class ChallengeFilterSheet extends ConsumerWidget {
  const ChallengeFilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(challengeFiltersProvider);
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Challenges',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  ref.read(challengeFiltersProvider.notifier).clearFilters();
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Difficulty filter
          Text(
            'Difficulty',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ChallengeDifficulty.values.map((difficulty) {
              final isSelected = filters.difficulty == difficulty;
              return FilterChip(
                label: Text(_difficultyToString(difficulty)),
                selected: isSelected,
                onSelected: (selected) {
                  ref.read(challengeFiltersProvider.notifier).setDifficulty(
                    selected ? difficulty : null,
                  );
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: 20),
          
          // Popular tags
          Text(
            'Popular Tags',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _popularTags.map((tag) {
              final isSelected = filters.selectedTags.contains(tag);
              return FilterChip(
                label: Text(tag),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    ref.read(challengeFiltersProvider.notifier).addTag(tag);
                  } else {
                    ref.read(challengeFiltersProvider.notifier).removeTag(tag);
                  }
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: 20),
          
          // Apply button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Apply Filters'),
            ),
          ),
          
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  String _difficultyToString(ChallengeDifficulty difficulty) {
    switch (difficulty) {
      case ChallengeDifficulty.beginner:
        return 'Beginner';
      case ChallengeDifficulty.intermediate:
        return 'Intermediate';
      case ChallengeDifficulty.advanced:
        return 'Advanced';
    }
  }

  static const List<String> _popularTags = [
    'summer',
    'casual',
    'professional',
    'budget',
    'sustainable',
    'vintage',
    'streetwear',
    'formal',
  ];
}
