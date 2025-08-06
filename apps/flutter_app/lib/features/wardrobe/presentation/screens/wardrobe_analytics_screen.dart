import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/wardrobe_analytics_controller.dart';
import '../widgets/wardrobe_analytics/analytics_header.dart';
import '../widgets/wardrobe_analytics/analytics_overview_card.dart';
import '../widgets/wardrobe_analytics/analytics_chart_view.dart';
import '../widgets/wardrobe_analytics/recommendations_section.dart';
import '../widgets/wardrobe_analytics/efficiency_score_card.dart';
import '../widgets/wardrobe_analytics/insights_section.dart';
import '../widgets/wardrobe_analytics/export_options_dialog.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class WardrobeAnalyticsScreen extends ConsumerStatefulWidget {
  const WardrobeAnalyticsScreen({super.key});

  @override
  ConsumerState<WardrobeAnalyticsScreen> createState() => _WardrobeAnalyticsScreenState();
}

class _WardrobeAnalyticsScreenState extends ConsumerState<WardrobeAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wardrobeAnalyticsControllerProvider);
    final controller = ref.read(wardrobeAnalyticsControllerProvider.notifier);
    final viewMode = ref.watch(analyticsViewModeProvider);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshAnalytics(),
        child: CustomScrollView(
          slivers: [
            // Header with period selector and quick stats
            SliverToBoxAdapter(
              child: AnalyticsHeader(
                selectedPeriod: state.selectedPeriod,
                onPeriodChanged: controller.changePeriod,
                isLoading: state.analytics.isLoading,
              ),
            ),
            
            // Main content based on view mode
            if (viewMode == 'overview') ...[
              _buildOverviewContent(state, controller),
            ] else if (viewMode == 'detailed') ...[
              _buildDetailedContent(state, controller),
            ] else if (viewMode == 'insights') ...[
              _buildInsightsContent(state, controller),
            ] else if (viewMode == 'recommendations') ...[
              _buildRecommendationsContent(state, controller),
            ],
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context, controller),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final viewMode = ref.watch(analyticsViewModeProvider);
    final viewModeController = ref.read(analyticsViewModeProvider.notifier);
    
    return AppBar(
      title: Text(
        'Wardrobe Analytics',
        style: context.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: AppTheme.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.view_module_outlined),
          onSelected: viewModeController.setMode,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'overview',
              child: Row(
                children: [
                  Icon(
                    Icons.dashboard_outlined,
                    color: viewMode == 'overview' ? AppTheme.primary : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Overview',
                    style: TextStyle(
                      color: viewMode == 'overview' ? AppTheme.primary : null,
                      fontWeight: viewMode == 'overview' ? FontWeight.w500 : null,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'detailed',
              child: Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    color: viewMode == 'detailed' ? AppTheme.primary : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Detailed',
                    style: TextStyle(
                      color: viewMode == 'detailed' ? AppTheme.primary : null,
                      fontWeight: viewMode == 'detailed' ? FontWeight.w500 : null,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'insights',
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outlined,
                    color: viewMode == 'insights' ? AppTheme.primary : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Insights',
                    style: TextStyle(
                      color: viewMode == 'insights' ? AppTheme.primary : null,
                      fontWeight: viewMode == 'insights' ? FontWeight.w500 : null,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'recommendations',
              child: Row(
                children: [
                  Icon(
                    Icons.recommend_outlined,
                    color: viewMode == 'recommendations' ? AppTheme.primary : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Recommendations',
                    style: TextStyle(
                      color: viewMode == 'recommendations' ? AppTheme.primary : null,
                      fontWeight: viewMode == 'recommendations' ? FontWeight.w500 : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildOverviewContent(
    WardrobeAnalyticsState state,
    WardrobeAnalyticsController controller,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // Efficiency Score Card
          state.efficiencyScore.when(
            data: (score) => EfficiencyScoreCard(
              score: score,
              onTap: () => ref.read(analyticsViewModeProvider.notifier).setMode('detailed'),
            ),
            loading: () => const EfficiencyScoreCard.loading(),
            error: (error, _) => EfficiencyScoreCard.error(error.toString()),
          ),
          
          const SizedBox(height: 16),
          
          // Analytics Overview
          state.analytics.when(
            data: (analytics) => Column(
              children: [
                AnalyticsOverviewCard(
                  analytics: analytics,
                  onViewDetails: () => ref.read(analyticsViewModeProvider.notifier).setMode('detailed'),
                ),
                const SizedBox(height: 16),
                AnalyticsChartView(
                  analytics: analytics,
                  chartType: ref.watch(analyticsChartTypeProvider),
                  onChartTypeChanged: ref.read(analyticsChartTypeProvider.notifier).setType,
                ),
              ],
            ),
            loading: () => Column(
              children: [
                AnalyticsOverviewCard.loading(),
                const SizedBox(height: 16),
                Card(
                  child: Container(
                    height: 200,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ],
            ),
            error: (error, _) => Column(
              children: [
                Card(
                  child: Container(
                    height: 150,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(height: 8),
                          Text('Failed to load analytics'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Container(
                    height: 200,
                    child: Center(
                      child: Text('Chart unavailable'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Top Insights Preview
          state.insights.when(
            data: (insights) => InsightsSection(
              insights: insights.take(3).toList(),
              showViewMore: insights.length > 3,
              onViewMore: () => ref.read(analyticsViewModeProvider.notifier).setMode('insights'),
            ),
            loading: () => const InsightsSection.loading(),
            error: (error, _) => InsightsSection.error(error.toString()),
          ),
          
          const SizedBox(height: 16),
          
          // Top Recommendations Preview
          state.recommendations.when(
            data: (recommendations) => RecommendationsSection(
              recommendations: recommendations.take(2).toList(),
              showViewMore: recommendations.length > 2,
              onViewMore: () => ref.read(analyticsViewModeProvider.notifier).setMode('recommendations'),
            ),
            loading: () => const RecommendationsSection.loading(),
            error: (error, _) => RecommendationsSection.error(error.toString()),
          ),
          
          const SizedBox(height: 100), // Space for FAB
        ]),
      ),
    );
  }

  Widget _buildDetailedContent(
    WardrobeAnalyticsState state,
    WardrobeAnalyticsController controller,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          state.analytics.when(
            data: (analytics) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detailed Analytics',
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Usage Statistics
                _buildDetailedSection(
                  'Usage Statistics',
                  Icons.bar_chart_outlined,
                  [
                    _buildStatRow('Total Items', '${analytics.usageStats.totalItems}'),
                    _buildStatRow('Worn Items', '${analytics.usageStats.wornItems}'),
                    _buildStatRow('Usage Rate', '${analytics.usageStats.usagePercentage.toStringAsFixed(1)}%'),
                    _buildStatRow('Average Wear/Item', '${analytics.usageStats.averageWearPerItem}'),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Category Breakdown
                _buildDetailedSection(
                  'Category Analysis',
                  Icons.category_outlined,
                  analytics.categoryStats.map((category) => 
                    _buildStatRow('${category.category}', '${category.totalItems} items (${category.usageRate.toStringAsFixed(1)}% used)')
                  ).toList(),
                ),
                
                const SizedBox(height: 24),
                
                // Color Analysis
                _buildDetailedSection(
                  'Color Distribution',
                  Icons.palette_outlined,
                  analytics.colorAnalysis.map((color) => 
                    _buildStatRow(color.colorName, '${color.itemCount} items (${color.percentage.toStringAsFixed(1)}%)')
                  ).toList(),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(64),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load detailed analytics',
                      style: context.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => controller.generateAnalytics(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 100), // Space for FAB
        ]),
      ),
    );
  }

  Widget _buildInsightsContent(
    WardrobeAnalyticsState state,
    WardrobeAnalyticsController controller,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Text(
            'Wardrobe Insights',
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          state.insights.when(
            data: (insights) => InsightsSection(
              insights: insights,
              showViewMore: false,
            ),
            loading: () => const InsightsSection.loading(),
            error: (error, _) => InsightsSection.error(error.toString()),
          ),
          
          const SizedBox(height: 100), // Space for FAB
        ]),
      ),
    );
  }

  Widget _buildRecommendationsContent(
    WardrobeAnalyticsState state,
    WardrobeAnalyticsController controller,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Text(
            'Personalized Recommendations',
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          state.recommendations.when(
            data: (recommendations) => RecommendationsSection(
              recommendations: recommendations,
              showViewMore: false,
            ),
            loading: () => const RecommendationsSection.loading(),
            error: (error, _) => RecommendationsSection.error(error.toString()),
          ),
          
          const SizedBox(height: 100), // Space for FAB
        ]),
      ),
    );
  }

  Widget _buildDetailedSection(
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Card(
      elevation: 0,
      color: AppTheme.surfaceVariant.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton(
    BuildContext context,
    WardrobeAnalyticsController controller,
  ) {
    final state = ref.watch(wardrobeAnalyticsControllerProvider);
    
    return FloatingActionButton.extended(
      onPressed: state.isExporting ? null : () => _showExportDialog(context, controller),
      icon: state.isExporting
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.download_outlined),
      label: Text(state.isExporting ? 'Exporting...' : 'Export'),
      backgroundColor: state.isExporting ? AppTheme.surfaceVariant : AppTheme.primary,
    );
  }

  void _showExportDialog(
    BuildContext context,
    WardrobeAnalyticsController controller,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => ExportOptionsDialog(
        onExport: (sections, format) {
          controller.exportAnalytics(sections: sections, format: format);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
