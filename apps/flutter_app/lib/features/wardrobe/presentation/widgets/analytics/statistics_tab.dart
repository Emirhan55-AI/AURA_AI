import 'package:flutter/material.dart';
import 'models.dart';
import 'chart_widgets.dart';

/// Tab widget for displaying wardrobe statistics with charts and key metrics
class StatisticsTab extends StatelessWidget {
  final WardrobeAnalyticsData? data;
  final TimeRange selectedTimeRange;
  final ValueChanged<TimeRange>? onTimeRangeChanged;

  const StatisticsTab({
    super.key,
    this.data,
    required this.selectedTimeRange,
    this.onTimeRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (data == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time range selector
          _buildTimeRangeSelector(context, theme, colorScheme),
          
          const SizedBox(height: 24),
          
          // Key metrics row
          _buildKeyMetrics(context, theme, colorScheme),
          
          const SizedBox(height: 24),
          
          // Category distribution pie chart
          PieChartWidget(
            data: data!.categoryDistribution,
            title: 'Category Distribution',
          ),
          
          const SizedBox(height: 24),
          
          // Color palette section
          _buildColorPalette(context, theme, colorScheme),
          
          const SizedBox(height: 24),
          
          // Wear frequency bar chart
          BarChartWidget(
            data: data!.wearFrequency,
            title: 'Most Worn Items',
          ),
          
          const SizedBox(height: 24),
          
          // Additional stats
          _buildAdditionalStats(context, theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Card(
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
              'Time Range',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<TimeRange>(
              selected: {selectedTimeRange},
              onSelectionChanged: (Set<TimeRange> newSelection) {
                if (newSelection.isNotEmpty && onTimeRangeChanged != null) {
                  onTimeRangeChanged!(newSelection.first);
                }
              },
              segments: TimeRange.values.map((range) {
                return ButtonSegment<TimeRange>(
                  value: range,
                  label: Text(
                    range.displayName,
                    style: theme.textTheme.labelMedium,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyMetrics(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context,
            theme,
            colorScheme,
            'Total Items',
            data!.totalItems.toString(),
            Icons.checkroom_outlined,
            colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            context,
            theme,
            colorScheme,
            'Avg. Wear Count',
            data!.averageWearCount.toStringAsFixed(1),
            Icons.repeat_outlined,
            colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPalette(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Card(
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
              'Color Palette',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: data!.colorPalette.take(12).map((colorData) {
                return _buildColorItem(context, theme, colorScheme, colorData);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorItem(BuildContext context, ThemeData theme, ColorScheme colorScheme, ColorData colorData) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(int.parse(colorData.colorHex.substring(1), radix: 16) + 0xFF000000),
            shape: BoxShape.circle,
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${colorData.itemCount}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalStats(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Card(
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
              'Quick Stats',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Most worn category', 
                data!.categoryDistribution.categories.first.name, 
                theme, colorScheme),
            const SizedBox(height: 8),
            _buildStatRow('Dominant color', 
                '${data!.colorPalette.first.itemCount} items', 
                theme, colorScheme),
            const SizedBox(height: 8),
            _buildStatRow('Least used items', 
                '${data!.wearFrequency.where((item) => item.wearCount == 0).length} items', 
                theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, ThemeData theme, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
