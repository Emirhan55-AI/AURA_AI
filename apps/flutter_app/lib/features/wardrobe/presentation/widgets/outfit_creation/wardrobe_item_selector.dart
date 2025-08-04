import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/ui/system_state_widget.dart';
import '../../../domain/entities/clothing_item.dart';

/// WardrobeItemSelector allows users to browse and select clothing items
/// from their wardrobe to include in an outfit.
/// 
/// Features:
/// - Grid/list view of clothing items
/// - Category filtering
/// - Search functionality
/// - Multi-selection with visual feedback
/// - Loading and error states
class WardrobeItemSelector extends ConsumerStatefulWidget {
  final List<ClothingItem> wardrobeItems;
  final List<String> selectedItemIds;
  final void Function(String itemId, bool isSelected) onItemSelected;

  const WardrobeItemSelector({
    super.key,
    required this.wardrobeItems,
    required this.selectedItemIds,
    required this.onItemSelected,
  });

  @override
  ConsumerState<WardrobeItemSelector> createState() => _WardrobeItemSelectorState();
}

class _WardrobeItemSelectorState extends ConsumerState<WardrobeItemSelector> {
  // Local state for filtering and search
  final _searchController = TextEditingController();
  String? _selectedCategory;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ClothingItem> get _filteredItems {
    List<ClothingItem> filtered = widget.wardrobeItems;

    // Filter by category
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      filtered = filtered.where((item) => item.category == _selectedCategory).toList();
    }

    // Filter by search query
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.name.toLowerCase().contains(query) ||
               (item.brand?.toLowerCase().contains(query) ?? false) ||
               (item.color?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return filtered;
  }

  List<String> get _availableCategories {
    final categories = widget.wardrobeItems
        .map((item) => item.category)
        .where((category) => category != null)
        .cast<String>()
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text(
          'Select Items',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),

        // Search and filter controls
        Row(
          children: [
            // Search field
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search items...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            
            // View toggle button
            IconButton(
              onPressed: () => setState(() => _isGridView = !_isGridView),
              icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
              tooltip: _isGridView ? 'List view' : 'Grid view',
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Category filter
        if (_availableCategories.isNotEmpty) ...[
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _availableCategories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('All'),
                      selected: _selectedCategory == null,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? null : _selectedCategory;
                        });
                      },
                    ),
                  );
                }
                
                final category = _availableCategories[index - 1];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category : null;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Items display
        if (_filteredItems.isEmpty)
          SystemStateWidget(
            icon: Icons.checkroom_outlined,
            title: _searchController.text.isNotEmpty || _selectedCategory != null
                ? 'No items found'
                : 'No items in wardrobe',
            message: _searchController.text.isNotEmpty || _selectedCategory != null
                ? 'Try adjusting your search or filter criteria.'
                : 'Add some clothing items to your wardrobe to create outfits.',
          )
        else
          SizedBox(
            height: 300, // Fixed height for the items container
            child: _isGridView ? _buildGridView() : _buildListView(),
          ),
      ],
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        final isSelected = widget.selectedItemIds.contains(item.id);
        
        return _ClothingItemCard(
          item: item,
          isSelected: isSelected,
          onTap: () => widget.onItemSelected(item.id, !isSelected),
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      itemCount: _filteredItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        final isSelected = widget.selectedItemIds.contains(item.id);
        
        return _ClothingItemListTile(
          item: item,
          isSelected: isSelected,
          onTap: () => widget.onItemSelected(item.id, !isSelected),
        );
      },
    );
  }
}

class _ClothingItemCard extends StatelessWidget {
  final ClothingItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _ClothingItemCard({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? colorScheme.primary.withOpacity(0.1) : colorScheme.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image container
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                  color: colorScheme.surfaceVariant,
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                      child: item.imageUrl != null
                          ? Image.network(
                              item.imageUrl!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                            )
                          : _buildImagePlaceholder(),
                    ),
                    if (isSelected)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            size: 16,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Item details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.brand != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.brand!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (item.color != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.color!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[200],
      child: const Icon(
        Icons.checkroom,
        size: 48,
        color: Colors.grey,
      ),
    );
  }
}

class _ClothingItemListTile extends StatelessWidget {
  final ClothingItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _ClothingItemListTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? colorScheme.primary : colorScheme.outline,
          width: isSelected ? 2 : 1,
        ),
        color: isSelected ? colorScheme.primary.withOpacity(0.1) : colorScheme.surface,
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: colorScheme.surfaceVariant,
          ),
          child: item.imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.imageUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.checkroom,
                      color: Colors.grey,
                    ),
                  ),
                )
              : const Icon(
                  Icons.checkroom,
                  color: Colors.grey,
                ),
        ),
        title: Text(item.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.brand != null) Text(item.brand!),
            if (item.color != null) Text(item.color!),
          ],
        ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: colorScheme.primary,
              )
            : Icon(
                Icons.circle_outlined,
                color: colorScheme.outline,
              ),
      ),
    );
  }
}
