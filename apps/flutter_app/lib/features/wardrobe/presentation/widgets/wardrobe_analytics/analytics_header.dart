import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/extensions/context_extensions.dart';
import '../../../domain/models/wardrobe_analytics.dart';

class AnalyticsHeader extends StatelessWidget {
  final AnalyticsPeriod selectedPeriod;
  final Function(AnalyticsPeriod) onPeriodChanged;
  final bool isLoading;

  const AnalyticsHeader({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Analytics Period',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Period Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: AnalyticsPeriod.values.map((period) {
                final isSelected = period == selectedPeriod;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_getPeriodLabel(period)),
                    selected: isSelected,
                    onSelected: isLoading ? null : (_) => onPeriodChanged(period),
                    backgroundColor: AppTheme.surface,
                    selectedColor: AppTheme.primary.withOpacity(0.12),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primary : AppTheme.outline,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primary : AppTheme.onSurface,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _getPeriodLabel(AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.week:
        return 'This Week';
      case AnalyticsPeriod.month:
        return 'This Month';
      case AnalyticsPeriod.quarter:
        return 'This Quarter';
      case AnalyticsPeriod.year:
        return 'This Year';
      case AnalyticsPeriod.allTime:
        return 'All Time';
    }
  }
}
