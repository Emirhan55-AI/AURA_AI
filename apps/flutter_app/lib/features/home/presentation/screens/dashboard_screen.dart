import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../providers/home_providers.dart';
import '../widgets/welcome_section.dart';
import '../widgets/quick_stats_section.dart';
import '../widgets/daily_suggestion_card.dart';
import '../widgets/recent_activity_section.dart';
import '../widgets/quick_actions_section.dart';
import '../widgets/weather_card.dart';
import '../../data/models/dashboard_data.dart';

/// Dashboard Screen - Home tab content with personalized dashboard
/// Displays welcome message, quick stats, AI suggestions, and quick actions
/// Follows Material Design 3 principles with accessibility support
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsyncValue = ref.watch(homeControllerProvider);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
            tooltip: 'Search',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.read(dashboardRefreshProvider)();
          },
          child: homeAsyncValue.when(
            data: (data) => _buildDashboardContent(context, data),
            loading: () => _buildLoadingView(context),
            error: (error, stack) => _buildErrorView(context, error, ref),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/wardrobe/add-item'),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
        tooltip: 'Add new clothing item',
      ),
    );
  }

  /// Builds the main dashboard content with all sections
  Widget _buildDashboardContent(BuildContext context, DashboardData data) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          WelcomeSection(userName: data.userName)
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0),
          
          const SizedBox(height: 24),
          
          // Weather Card
          WeatherCard(weather: data.weather)
              .animate(delay: 100.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0),
          
          const SizedBox(height: 24),
          
          // Quick Stats
          QuickStatsSection(stats: data.stats)
              .animate(delay: 200.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0),
          
          const SizedBox(height: 24),
          
          // Daily Suggestions
          if (data.suggestions.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Suggestions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/style-assistant'),
                  child: Text(
                    'See All',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...data.suggestions.take(2).map<Widget>((suggestion) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DailySuggestionCard(
                  suggestion: suggestion,
                  onTap: () {
                    // Navigate to outfit detail
                    context.push('/outfits/${suggestion.id}');
                  },
                ).animate(delay: 300.ms)
                 .fadeIn(duration: 400.ms)
                 .slideY(begin: 0.1, end: 0),
              ),
            ).toList(),
            const SizedBox(height: 24),
          ],
          
          // Quick Actions
          QuickActionsSection()
              .animate(delay: 400.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0),
          
          const SizedBox(height: 24),
          
          // Recent Activities
          RecentActivitySection(activities: data.activities)
              .animate(delay: 500.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Builds loading view with shimmer effects
  Widget _buildLoadingView(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Loading shimmer for welcome section
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 24),
          
          // Loading shimmer for weather card
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 24),
          
          // Loading shimmer for stats
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 24),
          
          // Loading shimmer for suggestions
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds error view with retry option
  Widget _buildErrorView(BuildContext context, Object error, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'We couldn\'t load your dashboard. Please try again.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                ref.read(dashboardRefreshProvider)();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // TODO: Navigate to support or report issue
              },
              child: const Text('Report Issue'),
            ),
          ],
        ),
      ),
    );
  }
}
