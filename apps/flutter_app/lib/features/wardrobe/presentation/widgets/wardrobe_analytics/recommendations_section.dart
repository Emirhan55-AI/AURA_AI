import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/extensions/context_extensions.dart';
import '../../../domain/models/wardrobe_analytics.dart';

class RecommendationsSection extends StatelessWidget {
  final List<WardrobeRecommendation> recommendations;
  final bool showViewMore;
  final VoidCallback? onViewMore;

  const RecommendationsSection({
    super.key,
    required this.recommendations,
    this.showViewMore = false,
    this.onViewMore,
  });

  const RecommendationsSection.loading({super.key})
      : recommendations = const [],
        showViewMore = false,
        onViewMore = null;

  const RecommendationsSection.error(String error, {super.key})
      : recommendations = const [],
        showViewMore = false,
        onViewMore = null;

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty && onViewMore == null) {
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
                      Icons.recommend_outlined,
                      size: 20,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Recommendations',
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
            
            if (recommendations.isEmpty)
              _buildEmptyState(context)
            else
              ...recommendations.asMap().entries.map((entry) {
                final index = entry.key;
                final recommendation = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < recommendations.length - 1 ? 16 : 0,
                  ),
                  child: _buildRecommendationItem(context, recommendation),
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
                  Icons.recommend_outlined,
                  size: 20,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recommendations',
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
            ...List.generate(2, (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                height: 80,
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
              Icons.recommend_outlined,
              size: 48,
              color: AppTheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No recommendations available',
              style: context.textTheme.titleMedium?.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Use your wardrobe more to get personalized recommendations',
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

  Widget _buildRecommendationItem(BuildContext context, WardrobeRecommendation recommendation) {
    final typeColor = _getRecommendationTypeColor(recommendation.type);
    final typeIcon = _getRecommendationTypeIcon(recommendation.type);
    final priorityColor = _getPriorityColor(recommendation.priority);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: typeColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  typeIcon,
                  size: 18,
                  color: typeColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            recommendation.title,
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: priorityColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: priorityColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            recommendation.priority.name.toUpperCase(),
                            style: context.textTheme.bodySmall?.copyWith(
                              color: priorityColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getRecommendationTypeLabel(recommendation.type),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: typeColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            recommendation.description,
            style: context.textTheme.bodyMedium?.copyWith(
              height: 1.4,
            ),
          ),
          if (recommendation.actionItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: recommendation.actionItems.take(3).map((action) {
                return Chip(
                  label: Text(
                    action,
                    style: context.textTheme.bodySmall,
                  ),
                  backgroundColor: AppTheme.surfaceVariant.withOpacity(0.5),
                  side: BorderSide.none,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Color _getRecommendationTypeColor(RecommendationType type) {
    switch (type) {
      case RecommendationType.purchase:
        return Colors.blue;
      case RecommendationType.styling:
        return AppTheme.primary;
      case RecommendationType.maintenance:
        return Colors.orange;
      case RecommendationType.organization:
        return Colors.green;
      case RecommendationType.sustainability:
        return Colors.teal;
      case RecommendationType.seasonal:
        return Colors.purple;
    }
  }

  IconData _getRecommendationTypeIcon(RecommendationType type) {
    switch (type) {
      case RecommendationType.purchase:
        return Icons.shopping_bag_outlined;
      case RecommendationType.styling:
        return Icons.style_outlined;
      case RecommendationType.maintenance:
        return Icons.build_outlined;
      case RecommendationType.organization:
        return Icons.folder_outlined;
      case RecommendationType.sustainability:
        return Icons.eco_outlined;
      case RecommendationType.seasonal:
        return Icons.wb_sunny_outlined;
    }
  }

  String _getRecommendationTypeLabel(RecommendationType type) {
    switch (type) {
      case RecommendationType.purchase:
        return 'Shopping Suggestion';
      case RecommendationType.styling:
        return 'Style Tip';
      case RecommendationType.maintenance:
        return 'Care & Maintenance';
      case RecommendationType.organization:
        return 'Organization';
      case RecommendationType.sustainability:
        return 'Sustainability';
      case RecommendationType.seasonal:
        return 'Seasonal Advice';
    }
  }

  Color _getPriorityColor(RecommendationPriority priority) {
    switch (priority) {
      case RecommendationPriority.high:
        return Colors.red;
      case RecommendationPriority.medium:
        return Colors.orange;
      case RecommendationPriority.low:
        return Colors.green;
    }
  }
}
