import 'package:flutter/material.dart';
import '../../../../../core/ui/system_state_widget.dart';
import 'models.dart';
import 'insight_card.dart';

/// Tab widget for displaying personalized insights and recommendations
class InsightsTab extends StatelessWidget {
  final List<Insight>? insights;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRefresh;
  final ValueChanged<Insight>? onFavoriteToggle;
  final ValueChanged<Insight>? onInsightAction;

  const InsightsTab({
    super.key,
    this.insights,
    this.isLoading = false,
    this.errorMessage,
    this.onRefresh,
    this.onFavoriteToggle,
    this.onInsightAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isLoading) {
      return const SystemStateWidget(
        message: 'Analyzing your wardrobe...',
        icon: Icons.analytics_outlined,
      );
    }

    if (errorMessage != null) {
      return SystemStateWidget(
        title: 'Unable to load insights',
        message: errorMessage!,
        icon: Icons.error_outline,
        iconColor: colorScheme.error,
        onRetry: onRefresh,
        retryText: 'Try Again',
      );
    }

    if (insights == null || insights!.isEmpty) {
      return SystemStateWidget(
        title: 'No insights available',
        message: 'Add more items to your wardrobe to get personalized insights and recommendations.',
        icon: Icons.lightbulb_outline,
        onCTA: () {
          // TODO: Navigate to add items
        },
        ctaText: 'Add Items',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        onRefresh?.call();
      },
      child: CustomScrollView(
        slivers: [
          // Header with insights count and filters
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildHeader(context, theme, colorScheme),
            ),
          ),
          
          // Insights list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final insight = insights![index];
                return InsightCard(
                  insight: insight,
                  onFavoriteToggle: () => onFavoriteToggle?.call(insight),
                  onActionPressed: () => onInsightAction?.call(insight),
                );
              },
              childCount: insights!.length,
            ),
          ),
          
          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    final totalInsights = insights?.length ?? 0;
    final favoriteInsights = insights?.where((insight) => insight.isFavorite).length ?? 0;
    final highPriorityInsights = insights?.where((insight) => insight.priority == 'high').length ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Insights summary
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Insights Summary',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryItem(
                        context,
                        theme,
                        colorScheme,
                        'Total',
                        totalInsights.toString(),
                        Icons.insights_outlined,
                        colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryItem(
                        context,
                        theme,
                        colorScheme,
                        'High Priority',
                        highPriorityInsights.toString(),
                        Icons.priority_high,
                        colorScheme.error,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryItem(
                        context,
                        theme,
                        colorScheme,
                        'Favorited',
                        favoriteInsights.toString(),
                        Icons.favorite,
                        Colors.pink,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                context,
                theme,
                colorScheme,
                'All',
                true,
                () {},
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                theme,
                colorScheme,
                'High Priority',
                false,
                () {},
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                theme,
                colorScheme,
                'Favorites',
                false,
                () {},
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                theme,
                colorScheme,
                'Shopping',
                false,
                () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => onTap(),
      selectedColor: colorScheme.primaryContainer,
      checkmarkColor: colorScheme.onPrimaryContainer,
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
