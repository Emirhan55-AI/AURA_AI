import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/wardrobe_controller.dart';

class WardrobeFilterBottomSheet extends ConsumerStatefulWidget {
  const WardrobeFilterBottomSheet({super.key});

  @override
  ConsumerState<WardrobeFilterBottomSheet> createState() => _WardrobeFilterBottomSheetState();
}

class _WardrobeFilterBottomSheetState extends ConsumerState<WardrobeFilterBottomSheet> {
  // Local state for filter selections
  Set<String> _selectedCategories = <String>{};
  Set<String> _selectedSeasons = <String>{};
  bool _showOnlyFavorites = false;
  String _sortBy = 'created_at';

  // Available options
  final List<String> _allCategories = [
    'Tops',
    'Bottoms', 
    'Outerwear',
    'Dresses',
    'Shoes',
    'Accessories',
    'Activewear',
    'Sleepwear',
  ];

  final List<String> _allSeasons = [
    'Spring',
    'Summer',
    'Autumn',
    'Winter',
  ];

  final Map<String, String> _sortOptions = {
    'created_at': 'Date Added',
    'name': 'Name',
    'category': 'Category',
    'color': 'Color',
    'last_worn': 'Last Worn',
  };

  @override
  void initState() {
    super.initState();
    // Initialize with current filter state
    final controller = ref.read(wardrobeControllerProvider.notifier);
    _selectedCategories = controller.selectedCategoryIds.toSet();
    _selectedSeasons = controller.selectedSeasons.toSet();
    _showOnlyFavorites = controller.showOnlyFavorites;
    _sortBy = controller.sortBy;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      'Filters',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _resetFilters,
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Categories section
                      _buildSectionTitle('Categories'),
                      const SizedBox(height: 8),
                      _buildCategoryChips(),
                      const SizedBox(height: 24),
                      
                      // Seasons section
                      _buildSectionTitle('Seasons'),  
                      const SizedBox(height: 8),
                      _buildSeasonChips(),
                      const SizedBox(height: 24),
                      
                      // Favorites toggle
                      _buildFavoritesToggle(),
                      const SizedBox(height: 24),
                      
                      // Sort section
                      _buildSectionTitle('Sort By'),
                      const SizedBox(height: 8),
                      _buildSortOptions(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              
              // Action buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: _applyFilters,
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _allCategories.map((category) {
        final isSelected = _selectedCategories.contains(category);
        return FilterChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedCategories.add(category);
              } else {
                _selectedCategories.remove(category);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildSeasonChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _allSeasons.map((season) {
        final isSelected = _selectedSeasons.contains(season);
        return FilterChip(
          label: Text(season),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedSeasons.add(season);
              } else {
                _selectedSeasons.remove(season);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildFavoritesToggle() {
    return SwitchListTile(
      title: const Text('Show only favorites'),
      subtitle: const Text('Display only items marked as favorites'),
      value: _showOnlyFavorites,
      onChanged: (value) {
        setState(() {
          _showOnlyFavorites = value;
        });
      },
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSortOptions() {
    return Column(
      children: _sortOptions.entries.map((entry) {
        return RadioListTile<String>(
          title: Text(entry.value),
          value: entry.key,
          groupValue: _sortBy,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _sortBy = value;
              });
            }
          },
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedCategories.clear();
      _selectedSeasons.clear();
      _showOnlyFavorites = false;
      _sortBy = 'created_at';
    });
  }

  void _applyFilters() {
    final controller = ref.read(wardrobeControllerProvider.notifier);
    controller.applyFilters(
      categoryIds: _selectedCategories.toList(),
      seasons: _selectedSeasons.toList(),
      showOnlyFavorites: _showOnlyFavorites,
      sortBy: _sortBy,
    );
    Navigator.of(context).pop();
  }
}
