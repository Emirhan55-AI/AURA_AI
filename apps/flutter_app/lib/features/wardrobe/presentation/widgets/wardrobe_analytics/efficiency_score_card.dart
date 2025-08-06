import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/extensions/context_extensions.dart';

class EfficiencyScoreCard extends StatelessWidget {
  final double score;
  final VoidCallback? onTap;

  const EfficiencyScoreCard({
    super.key,
    required this.score,
    this.onTap,
  });

  const EfficiencyScoreCard.loading({super.key})
      : score = 0.0,
        onTap = null;

  const EfficiencyScoreCard.error(String error, {super.key})
      : score = 0.0,
        onTap = null;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppTheme.surfaceVariant.withOpacity(0.3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: score == 0.0 && onTap == null
              ? _buildLoadingContent(context)
              : _buildScoreContent(context),
        ),
      ),
    );
  }

  Widget _buildLoadingContent(BuildContext context) {
    return Column(
      children: [
        Text(
          'Wardrobe Efficiency Score',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(),
        ),
        const SizedBox(height: 16),
        Text(
          'Analyzing your wardrobe...',
          style: context.textTheme.bodyMedium?.copyWith(
            color: AppTheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildScoreContent(BuildContext context) {
    final scoreColor = _getScoreColor(score);
    final scoreLabel = _getScoreLabel(score);
    
    return Column(
      children: [
        Text(
          'Wardrobe Efficiency Score',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        
        // Score Circle
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                value: score / 100,
                strokeWidth: 8,
                backgroundColor: AppTheme.outline.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
              ),
            ),
            Column(
              children: [
                Text(
                  '${score.toStringAsFixed(0)}%',
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scoreColor,
                  ),
                ),
                Text(
                  scoreLabel,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: scoreColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Score Description
        Text(
          _getScoreDescription(score),
          style: context.textTheme.bodyMedium?.copyWith(
            color: AppTheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 16),
        
        // Score Breakdown
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildScoreMetric(context, 'Usage', _getUsageScore(score), scoreColor),
            _buildScoreMetric(context, 'Variety', _getVarietyScore(score), scoreColor),
            _buildScoreMetric(context, 'Balance', _getBalanceScore(score), scoreColor),
          ],
        ),
        
        if (onTap != null) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'View Details',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward,
                size: 16,
                color: AppTheme.primary,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildScoreMetric(
    BuildContext context,
    String label,
    double value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          '${value.toStringAsFixed(0)}%',
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: AppTheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getScoreLabel(double score) {
    if (score >= 90) return 'Excellent';
    if (score >= 80) return 'Great';
    if (score >= 70) return 'Good';
    if (score >= 60) return 'Fair';
    if (score >= 50) return 'Poor';
    return 'Very Poor';
  }

  String _getScoreDescription(double score) {
    if (score >= 80) {
      return 'Your wardrobe is highly efficient! You make great use of your items with good variety and balance.';
    } else if (score >= 60) {
      return 'Your wardrobe efficiency is good. There\'s room for improvement in usage patterns or variety.';
    } else {
      return 'Your wardrobe could be more efficient. Consider reviewing your usage patterns and item selection.';
    }
  }

  double _getUsageScore(double overallScore) {
    // Mock calculation - in real app would come from analytics
    return overallScore * 0.9 + (overallScore * 0.1 * (0.5 - 0.25));
  }

  double _getVarietyScore(double overallScore) {
    // Mock calculation - in real app would come from analytics
    return overallScore * 1.1 - 5;
  }

  double _getBalanceScore(double overallScore) {
    // Mock calculation - in real app would come from analytics
    return overallScore * 0.95;
  }
}
