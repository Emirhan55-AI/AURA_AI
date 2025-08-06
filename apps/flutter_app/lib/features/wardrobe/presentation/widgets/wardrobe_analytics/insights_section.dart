import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/extensions/context_extensions.dart';

class InsightsSection extends StatelessWidget {
  final List<String> insights;
  final bool showViewMore;
  final VoidCallback? onViewMore;

  const InsightsSection({
    super.key,
    required this.insights,
    this.showViewMore = false,
    this.onViewMore,
  });

  const InsightsSection.loading({super.key})
      : insights = const [],
        showViewMore = false,
        onViewMore = null;

  const InsightsSection.error(String error, {super.key})
      : insights = const [],
        showViewMore = false,
        onViewMore = null;

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty && onViewMore == null) {
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
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outlined,
                      size: 20,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Wardrobe Insights',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (showViewMore && onViewMore != null)
                  TextButton.icon(
                    onPressed: onViewMore,
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('View More'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (insights.isEmpty)
              _buildEmptyState(context)
            else
              ...insights.asMap().entries.map((entry) {
                final index = entry.key;
                final insight = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < insights.length - 1 ? 12 : 0,
                  ),
                  child: _buildInsightItem(context, insight, index),
                );
              }).toList(),
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
              children: [
                Icon(
                  Icons.lightbulb_outlined,
                  size: 20,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Wardrobe Insights',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Loading skeletons
            ...List.generate(3, (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.insights_outlined,
              size: 48,
              color: AppTheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No insights available',
              style: context.textTheme.titleMedium?.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Use your wardrobe more to generate personalized insights',
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(BuildContext context, String insight, int index) {
    final insightIcon = _getInsightIcon(insight);
    final insightColor = _getInsightColor(index);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: insightColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: insightColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: insightColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              insightIcon,
              size: 16,
              color: insightColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              insight,
              style: context.textTheme.bodyMedium?.copyWith(
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getInsightIcon(String insight) {
    final lowerInsight = insight.toLowerCase();
    
    if (lowerInsight.contains('wear') || lowerInsight.contains('usage')) {
      return Icons.trending_up_outlined;
    } else if (lowerInsight.contains('color') || lowerInsight.contains('style')) {
      return Icons.palette_outlined;
    } else if (lowerInsight.contains('season') || lowerInsight.contains('weather')) {
      return Icons.wb_sunny_outlined;
    } else if (lowerInsight.contains('cost') || lowerInsight.contains('money')) {
      return Icons.attach_money_outlined;
    } else if (lowerInsight.contains('sustainability') || lowerInsight.contains('eco')) {
      return Icons.eco_outlined;
    } else if (lowerInsight.contains('category') || lowerInsight.contains('type')) {
      return Icons.category_outlined;
    } else {
      return Icons.lightbulb_outlined;
    }
  }

  Color _getInsightColor(int index) {
    final colors = [
      AppTheme.primary,
      Colors.green,
      Colors.orange,
      AppTheme.secondary,
      Colors.purple,
      AppTheme.tertiary,
    ];
    return colors[index % colors.length];
  }
}
