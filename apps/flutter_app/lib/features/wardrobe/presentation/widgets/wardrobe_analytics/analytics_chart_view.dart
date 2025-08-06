import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/extensions/context_extensions.dart';
import '../../../domain/models/wardrobe_analytics.dart';

class AnalyticsChartView extends StatelessWidget {
  final WardrobeAnalytics analytics;
  final String chartType;
  final Function(String) onChartTypeChanged;

  const AnalyticsChartView({
    super.key,
    required this.analytics,
    required this.chartType,
    required this.onChartTypeChanged,
  });

  static void _defaultOnChanged(String type) {}

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
                  'Category Usage',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _buildChartTypeSelector(),
              ],
            ),
            const SizedBox(height: 16),
            
            SizedBox(
              height: 300,
              child: _buildChart(),
            ),
            
            const SizedBox(height: 16),
            
            // Legend
            if (analytics.categoryStats.isNotEmpty)
              _buildLegend(context),
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
                  'Category Usage',
                  style: context.textTheme.titleMedium?.copyWith(
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
            
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartTypeSelector() {
    return Row(
      children: [
        _buildChartTypeButton('bar', Icons.bar_chart_outlined),
        const SizedBox(width: 4),
        _buildChartTypeButton('pie', Icons.pie_chart_outline_outlined),
        const SizedBox(width: 4),
        _buildChartTypeButton('line', Icons.show_chart_outlined),
      ],
    );
  }

  Widget _buildChartTypeButton(String type, IconData icon) {
    final isSelected = chartType == type;
    return IconButton(
      onPressed: () => onChartTypeChanged(type),
      icon: Icon(icon),
      color: isSelected ? AppTheme.primary : AppTheme.onSurfaceVariant,
      style: IconButton.styleFrom(
        backgroundColor: isSelected
            ? AppTheme.primary.withOpacity(0.12)
            : Colors.transparent,
      ),
    );
  }

  Widget _buildChart() {
    switch (chartType) {
      case 'pie':
        return _buildPieChart();
      case 'line':
        return _buildLineChart();
      case 'bar':
      default:
        return _buildBarChart();
    }
  }

  Widget _buildBarChart() {
    final categories = analytics.categoryStats.entries.take(6).toList();
    if (categories.isEmpty) return const Center(child: Text('No data available'));

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: categories.map((e) => e.value.itemCount.toDouble()).reduce((a, b) => a > b ? a : b) * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final category = categories[group.x];
              return BarTooltipItem(
                '${category.key}\n${category.value.itemCount} items',
                TextStyle(
                  color: AppTheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= categories.length) return const Text('');
                final category = categories[value.toInt()];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    category.key.length > 8
                        ? '${category.key.substring(0, 8)}...'
                        : category.key,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.onSurfaceVariant,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: categories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: category.value.itemCount.toDouble(),
                color: _getCategoryColor(index),
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPieChart() {
    final categories = analytics.categoryStats.entries.take(6).toList();
    if (categories.isEmpty) return const Center(child: Text('No data available'));

    final total = categories.fold(0, (sum, entry) => sum + entry.value.itemCount);

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 60,
        sections: categories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          final percentage = (category.value.itemCount / total * 100);
          
          return PieChartSectionData(
            color: _getCategoryColor(index),
            value: category.value.itemCount.toDouble(),
            title: '${percentage.toStringAsFixed(1)}%',
            radius: 80,
            titleStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.onPrimary,
            ),
          );
        }).toList(),
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {},
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    // For line chart, we'll show usage over time (mock data for now)
    final data = List.generate(7, (index) => index * 2.0 + 5);
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppTheme.outline.withOpacity(0.3),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                if (value.toInt() >= days.length) return const Text('');
                return Text(
                  days[value.toInt()],
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.onSurfaceVariant,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.onSurfaceVariant,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value);
            }).toList(),
            isCurved: true,
            color: AppTheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppTheme.primary,
                  strokeWidth: 2,
                  strokeColor: AppTheme.surface,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    final categories = analytics.categoryStats.entries.take(6).toList();
    
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: categories.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getCategoryColor(index),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              category.key,
              style: context.textTheme.bodySmall?.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Color _getCategoryColor(int index) {
    final colors = [
      AppTheme.primary,
      AppTheme.secondary,
      AppTheme.tertiary,
      Colors.orange,
      Colors.green,
      Colors.purple,
    ];
    return colors[index % colors.length];
  }
}
