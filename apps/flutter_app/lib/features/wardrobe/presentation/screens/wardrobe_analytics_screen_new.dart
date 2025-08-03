import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/system_state_widget.dart';
import '../widgets/analytics/models.dart';
import '../widgets/analytics/statistics_tab.dart';
import '../widgets/analytics/insights_tab.dart';
import '../widgets/analytics/shopping_guide_tab.dart';
import '../controllers/wardrobe_analytics_controller.dart';

/// Wardrobe Analytics Screen - Displays statistical summaries, insights, and shopping suggestions
/// 
/// This screen provides:
/// - Statistical analysis of wardrobe items (category distribution, color palette, wear frequency)
/// - Personalized insights and recommendations
/// - Shopping guide with AI-powered suggestions
/// - Tabbed interface for easy navigation between different analytics views
class WardrobeAnalyticsScreen extends ConsumerStatefulWidget {
  const WardrobeAnalyticsScreen({super.key});

  @override
  ConsumerState<WardrobeAnalyticsScreen> createState() => _WardrobeAnalyticsScreenState();
}

class _WardrobeAnalyticsScreenState extends ConsumerState<WardrobeAnalyticsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  static const List<String> _tabLabels = [
    'Statistics',
    'Insights',
    'Shopping Guide',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabLabels.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Watch the controller state
    final analyticsState = ref.watch(wardrobeAnalyticsControllerProvider);
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(theme, colorScheme),
      body: _buildBody(context, theme, colorScheme, analyticsState),
    );
  }

  /// Builds the app bar with title and refresh action
  PreferredSizeWidget _buildAppBar(ThemeData theme, ColorScheme colorScheme) {
    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: colorScheme.surfaceTint,
      title: Text(
        'Wardrobe Analytics',
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          onPressed: () {
            ref.read(wardrobeAnalyticsControllerProvider.notifier).refreshAnalytics();
          },
          icon: Icon(
            Icons.refresh_outlined,
            color: colorScheme.onSurfaceVariant,
          ),
          tooltip: 'Refresh Analytics',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// Builds the main body with loading, error, and content states
  Widget _buildBody(BuildContext context, ThemeData theme, ColorScheme colorScheme, WardrobeAnalyticsState analyticsState) {
    // Handle overall loading state (when analytics data is loading)
    if (analyticsState.analyticsData.isLoading && 
        analyticsState.insights.isLoading && 
        analyticsState.shoppingGuides.isLoading) {
      return const SystemStateWidget(
        message: 'Analyzing your wardrobe...',
        icon: Icons.analytics_outlined,
      );
    }

    // Handle overall error state (when analytics data failed)
    if (analyticsState.analyticsData.hasError) {
      return SystemStateWidget(
        title: 'Unable to load analytics',
        message: analyticsState.analyticsData.error.toString(),
        icon: Icons.error_outline,
        iconColor: colorScheme.error,
        onRetry: () {
          ref.read(wardrobeAnalyticsControllerProvider.notifier).retryLoadAnalytics();
        },
        retryText: 'Try Again',
      );
    }

    // Build the main content with tabs
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(wardrobeAnalyticsControllerProvider.notifier).refreshAnalytics();
      },
      child: Column(
        children: [
          // Tab bar
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: _tabLabels.map((label) => Tab(text: label)).toList(),
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              indicatorColor: colorScheme.primary,
              indicatorWeight: 2,
              labelStyle: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              onTap: (index) {
                final tabName = _getTabNameByIndex(index);
                ref.read(wardrobeAnalyticsControllerProvider.notifier).selectTab(tabName);
              },
            ),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Statistics Tab
                StatisticsTab(
                  data: analyticsState.analyticsData.value,
                  selectedTimeRange: analyticsState.currentTimeRange,
                  onTimeRangeChanged: (newRange) {
                    ref.read(wardrobeAnalyticsControllerProvider.notifier).changeTimeRange(newRange);
                  },
                ),
                
                // Insights Tab
                InsightsTab(
                  insights: analyticsState.insights.value,
                  isLoading: analyticsState.insights.isLoading,
                  errorMessage: analyticsState.insights.hasError 
                      ? analyticsState.insights.error.toString() 
                      : null,
                  onFavoriteToggle: (insight) {
                    ref.read(wardrobeAnalyticsControllerProvider.notifier).toggleInsightFavorite(insight.id);
                  },
                  onInsightAction: (insight) {
                    // TODO: Handle insight actions
                  },
                  onRefresh: () {
                    ref.read(wardrobeAnalyticsControllerProvider.notifier).retryLoadInsights();
                  },
                ),
                
                // Shopping Guide Tab  
                ShoppingGuideTab(
                  items: analyticsState.shoppingGuides.value,
                  isLoading: analyticsState.shoppingGuides.isLoading,
                  errorMessage: analyticsState.shoppingGuides.hasError 
                      ? analyticsState.shoppingGuides.error.toString() 
                      : null,
                  hasMore: analyticsState.hasMoreShoppingGuides,
                  onItemTap: (item) {
                    // TODO: Handle shopping guide item actions
                  },
                  onLoadMore: () {
                    ref.read(wardrobeAnalyticsControllerProvider.notifier).loadMoreShoppingGuides();
                  },
                  onRefresh: () {
                    ref.read(wardrobeAnalyticsControllerProvider.notifier).retryLoadShoppingGuides();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Gets tab name by index for controller
  String _getTabNameByIndex(int index) {
    switch (index) {
      case 0:
        return 'statistics';
      case 1:
        return 'insights';
      case 2:
        return 'shopping';
      default:
        return 'statistics';
    }
  }
}
