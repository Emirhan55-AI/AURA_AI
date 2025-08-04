import 'package:flutter/material.dart';
import '../../domain/entities/swap_listing.dart';

/// Filter bar widget for the swap market screen
class SwapMarketFilterBar extends StatefulWidget {
  final SwapFilterOptions filters;
  final ValueChanged<SwapFilterOptions> onFiltersChanged;

  const SwapMarketFilterBar({
    super.key,
    required this.filters,
    required this.onFiltersChanged,
  });

  @override
  State<SwapMarketFilterBar> createState() => _SwapMarketFilterBarState();
}

class _SwapMarketFilterBarState extends State<SwapMarketFilterBar> {
  late SwapFilterOptions _currentFilters;

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.filters;
  }

  @override
  void didUpdateWidget(SwapMarketFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filters != widget.filters) {
      _currentFilters = widget.filters;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search listings...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              final updatedFilters = _currentFilters.copyWith(
                searchQuery: value.trim().isEmpty ? null : value.trim(),
              );
              _updateFilters(updatedFilters);
            },
          ),
          
          const SizedBox(height: 12),
          
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Type filter
                _buildFilterChip(
                  label: 'All',
                  isSelected: _currentFilters.type == null,
                  onTap: () => _updateFilters(_currentFilters.copyWith(type: null)),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'For Sale',
                  isSelected: _currentFilters.type == SwapListingType.sale,
                  onTap: () => _updateFilters(_currentFilters.copyWith(type: SwapListingType.sale)),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'For Swap',
                  isSelected: _currentFilters.type == SwapListingType.swap,
                  onTap: () => _updateFilters(_currentFilters.copyWith(type: SwapListingType.swap)),
                ),
                const SizedBox(width: 8),
                
                // Saved only filter
                _buildFilterChip(
                  label: 'Saved',
                  isSelected: _currentFilters.savedOnly,
                  onTap: () => _updateFilters(_currentFilters.copyWith(savedOnly: !_currentFilters.savedOnly)),
                ),
                const SizedBox(width: 8),
                
                // More filters button
                _buildFilterChip(
                  label: 'More Filters',
                  isSelected: false,
                  onTap: () => _showMoreFiltersDialog(context),
                  icon: Icons.tune,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateFilters(SwapFilterOptions filters) {
    setState(() {
      _currentFilters = filters;
    });
    widget.onFiltersChanged(filters);
  }

  void _showMoreFiltersDialog(BuildContext context) async {
    final result = await showDialog<SwapFilterOptions>(
      context: context,
      builder: (context) => _MoreFiltersDialog(
        initialFilters: _currentFilters,
      ),
    );
    
    if (result != null) {
      _updateFilters(result);
    }
  }
}

/// Dialog for additional filter options
class _MoreFiltersDialog extends StatefulWidget {
  final SwapFilterOptions initialFilters;

  const _MoreFiltersDialog({
    required this.initialFilters,
  });

  @override
  State<_MoreFiltersDialog> createState() => _MoreFiltersDialogState();
}

class _MoreFiltersDialogState extends State<_MoreFiltersDialog> {
  late SwapFilterOptions _filters;
  late RangeValues _priceRange;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
    _priceRange = RangeValues(
      _filters.minPrice ?? 0,
      _filters.maxPrice ?? 1000,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: const Text('Filter Options'),
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price range
            Text(
              'Price Range',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 1000,
              divisions: 20,
              labels: RangeLabels(
                '\$${_priceRange.start.round()}',
                '\$${_priceRange.end.round()}',
              ),
              onChanged: (values) {
                setState(() {
                  _priceRange = values;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Sort by
            Text(
              'Sort By',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _filters.sortBy ?? 'newest',
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'newest', child: Text('Newest First')),
                DropdownMenuItem(value: 'oldest', child: Text('Oldest First')),
                DropdownMenuItem(value: 'price_low_high', child: Text('Price: Low to High')),
                DropdownMenuItem(value: 'price_high_low', child: Text('Price: High to Low')),
                DropdownMenuItem(value: 'most_saved', child: Text('Most Saved')),
              ],
              onChanged: (value) {
                setState(() {
                  _filters = _filters.copyWith(sortBy: value);
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final updatedFilters = _filters.copyWith(
              minPrice: _priceRange.start > 0 ? _priceRange.start : null,
              maxPrice: _priceRange.end < 1000 ? _priceRange.end : null,
            );
            Navigator.of(context).pop(updatedFilters);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
