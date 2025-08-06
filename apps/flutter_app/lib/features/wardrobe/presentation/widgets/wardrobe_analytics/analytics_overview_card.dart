import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/extensions/context_extensions.dart';
import '../../../domain/models/wardrobe_analytics.dart';

class AnalyticsOverviewCard extends StatelessWidget {
  final WardrobeAnalytics analytics;
  final VoidCallback? onViewDetails;

  const AnalyticsOverviewCard({
    super.key,
    required this.analytics,
    this.onViewDetails,
  });

  const AnalyticsOverviewCard.loading({
    super.key,
  }) : analytics = const WardrobeAnalytics(
          userId: '',
          period: AnalyticsPeriod.month,
          generatedAt: '',
          usageStats: WardrobeUsageStats(
            totalItemsWorn: 0,
            averageDailyUsage: 0,
            peakUsageDay: '',
            mostWornCategory: '',
            leastWornCategory: '',
          ),
          categoryStats: {},
          colorAnalysis: {},
          outfitFrequency: [],
          itemFrequency: [],
        ),
        onViewDetails = null;

  AnalyticsOverviewCard.error(String error, {super.key})
      : analytics = const WardrobeAnalytics(
          userId: '',
          period: AnalyticsPeriod.month,
          generatedAt: '',
          usageStats: WardrobeUsageStats(
            totalItemsWorn: 0,
            averageDailyUsage: 0,
            peakUsageDay: '',
            mostWornCategory: '',
            leastWornCategory: '',
          ),
          categoryStats: {},
          colorAnalysis: {},
          outfitFrequency: [],
          itemFrequency: [],
        ),
        onViewDetails = null;

  @override
  Widget build(BuildContext context) {
    if (analytics.userId.isEmpty) {
      return _buildLoadingCard(context);
    }

    return Card(
      elevation: 0,
      color: AppTheme.surfaceVariant.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overview',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (onViewDetails != null)
                  TextButton.icon(
                    onPressed: onViewDetails,
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('View Details'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Quick Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildStatItem(
                  context,
                  'Items Worn',
                  '${analytics.usageStats.totalItemsWorn}',
                  Icons.checkroom_outlined,
                  AppTheme.primary,
                ),
                _buildStatItem(
                  context,
                  'Daily Average',
                  '${analytics.usageStats.averageDailyUsage.toStringAsFixed(1)}',
                  Icons.calendar_today_outlined,
                  AppTheme.secondary,
                ),
                _buildStatItem(
                  context,
                  'Categories',
                  '${analytics.categoryStats.length}',
                  Icons.category_outlined,
                  AppTheme.tertiary,
                ),
                _buildStatItem(
                  context,
                  'Top Color',
                  analytics.colorAnalysis.isNotEmpty
                      ? analytics.colorAnalysis.keys.first
                      : 'N/A',
                  Icons.palette_outlined,
                  Colors.orange,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Most Worn Category
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primary.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Most Worn Category',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          analytics.usageStats.mostWornCategory,
                          style: context.textTheme.bodyLarge?.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppTheme.surfaceVariant.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overview',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Loading skeletons
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: List.generate(4, (index) => _buildLoadingSkeleton()),
            ),
            
            const SizedBox(height: 16),
            
            // Loading skeleton for most worn category
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
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
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: context.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
