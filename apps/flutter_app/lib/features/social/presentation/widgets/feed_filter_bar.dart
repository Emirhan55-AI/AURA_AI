import 'package:flutter/material.dart';

/// Feed Filter Bar - Horizontal filter chips for social feed content
/// 
/// This widget displays filter options as chips that users can tap
/// to filter the social feed by different categories or tags.
class FeedFilterBar extends StatelessWidget {
  final List<String> filters;
  final String? selectedFilter;
  final void Function(String?) onFilterSelected;

  const FeedFilterBar({
    super.key,
    required this.filters,
    this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length + 1, // +1 for "All" filter
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          // First item is "All" filter
          if (index == 0) {
            final isSelected = selectedFilter == null;
            return _buildFilterChip(
              context,
              theme,
              colorScheme,
              label: 'All',
              isSelected: isSelected,
              onTap: () => onFilterSelected(null),
            );
          }

          // Regular filter items
          final filter = filters[index - 1];
          final isSelected = selectedFilter == filter;
          
          return _buildFilterChip(
            context,
            theme,
            colorScheme,
            label: _formatFilterLabel(filter),
            isSelected: isSelected,
            onTap: () => onFilterSelected(filter),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? colorScheme.primary : colorScheme.surface,
      elevation: isSelected ? 2 : 0,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: isSelected
                ? null
                : Border.all(
                    color: colorScheme.outline.withOpacity(0.3),
                    width: 1,
                  ),
          ),
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isSelected 
                  ? colorScheme.onPrimary 
                  : colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  /// Formats filter labels for display
  String _formatFilterLabel(String filter) {
    return filter
        .split('_')
        .map((word) => word.isNotEmpty 
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : word)
        .join(' ');
  }

  /// Default filter options for social posts
  static const List<String> defaultFilters = [
    'trending',
    'recent',
    'following',
    'saved',
    'business',
    'casual',
    'formal',
    'athleisure',
    'date_night',
    'weekend',
    'seasonal',
  ];
}
