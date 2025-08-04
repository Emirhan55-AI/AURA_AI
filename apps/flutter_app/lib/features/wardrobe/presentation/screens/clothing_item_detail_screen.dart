import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/clothing_item.dart';
import '../../../outfits/domain/entities/outfit.dart';
import '../controllers/clothing_item_detail_controller.dart';
import '../widgets/item_detail/item_image_gallery.dart';
import '../widgets/item_detail/item_details_section.dart';
import '../widgets/item_detail/item_actions.dart';
import '../widgets/item_detail/outfit_previews.dart';

/// Screen for displaying detailed information about a clothing item
/// Supports viewing item details, related outfits, and user actions
class ClothingItemDetailScreen extends ConsumerWidget {
  final String itemId;
  final bool isPreviewMode;

  const ClothingItemDetailScreen({
    super.key,
    required this.itemId,
    this.isPreviewMode = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Watch the controller state for this specific item
    final detailState = ref.watch(clothingItemDetailControllerProvider(itemId));

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: _buildContent(context, ref, theme, colorScheme, detailState),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context, theme, colorScheme, null),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Image gallery skeleton
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 24),
              
              // Details skeleton
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 24),
              
              // Actions skeleton
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    ColorScheme colorScheme,
    ClothingItemDetailState state,
  ) {
    return state.itemDetail.when(
      loading: () => _buildLoadingSkeleton(context, theme, colorScheme),
      error: (error, stack) => _buildItemErrorState(context, ref, theme, colorScheme, error.toString()),
      data: (item) {
        if (item == null) {
          return _buildNotFoundState(context, theme, colorScheme);
        }
        
        return CustomScrollView(
          slivers: [
            _buildAppBar(context, theme, colorScheme, item),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Image Gallery
                  ItemImageGallery(
                    imageUrls: item.imageUrl != null ? [item.imageUrl!] : [],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Item Details
                  ItemDetailsSection(
                    item: item,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Item Actions
                  if (!isPreviewMode)
                    ItemActions(
                      item: item,
                      onEdit: () => _handleEdit(context, ref, item),
                      onToggleFavorite: () => _handleToggleFavorite(ref),
                      onShare: () => _handleShare(context, ref),
                      onDelete: () => _handleDelete(context, ref, item),
                    ),
                  
                  if (!isPreviewMode) const SizedBox(height: 24),
                  
                  // Outfit Previews
                  _buildOutfitPreviews(context, ref, theme, colorScheme, item, state),
                  
                  // Bottom padding for safe area
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildItemErrorState(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    ColorScheme colorScheme,
    String errorMessage,
  ) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context, theme, colorScheme, null),
        SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error Loading Item',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () {
                      ref.read(clothingItemDetailControllerProvider(itemId).notifier)
                          .retryLoadItemDetails();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotFoundState(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context, theme, colorScheme, null),
        SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Item Not Found',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The clothing item you\'re looking for doesn\'t exist.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOutfitPreviews(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    ColorScheme colorScheme,
    ClothingItem item,
    ClothingItemDetailState state,
  ) {
    return state.relatedOutfits.when(
      loading: () => Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.checkroom_outlined,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Related Outfits',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      error: (error, stack) => Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.checkroom_outlined,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Related Outfits',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Failed to load outfits',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(clothingItemDetailControllerProvider(itemId).notifier)
                            .retryLoadRelatedOutfits();
                      },
                      child: Text(
                        'Retry',
                        style: TextStyle(color: colorScheme.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      data: (outfits) => OutfitPreviews(
        item: item,
        outfits: outfits,
        onViewAllOutfits: () => _handleViewAllOutfits(context, item),
        onOutfitTap: (outfit) => _handleOutfitTap(context, outfit),
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    ClothingItem? item,
  ) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: item != null
          ? Text(
              item.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
      actions: item != null && !isPreviewMode
          ? [
              Consumer(
                builder: (context, ref, child) {
                  return IconButton(
                    icon: Icon(
                      item.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: item.isFavorite ? Colors.red : null,
                    ),
                    onPressed: () => _handleToggleFavorite(ref),
                  );
                },
              ),
              Consumer(
                builder: (context, ref, child) {
                  return PopupMenuButton<String>(
                    onSelected: (value) => _handleMenuAction(context, ref, item, value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.share),
                            SizedBox(width: 12),
                            Text('Share'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 12),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 12),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ]
          : null,
    );
  }

  // Event Handlers
  void _handleEdit(BuildContext context, WidgetRef ref, ClothingItem item) {
    ref.read(clothingItemDetailControllerProvider(itemId).notifier).prepareForEdit();
    _showComingSoon(context, 'Edit functionality');
  }

  Future<void> _handleToggleFavorite(WidgetRef ref) async {
    try {
      await ref.read(clothingItemDetailControllerProvider(itemId).notifier).toggleFavorite();
    } catch (e) {
      // Error handling is done in the controller
    }
  }

  void _handleShare(BuildContext context, WidgetRef ref) {
    ref.read(clothingItemDetailControllerProvider(itemId).notifier).shareItem();
    _showComingSoon(context, 'Share functionality');
  }

  void _handleDelete(BuildContext context, WidgetRef ref, ClothingItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text(
          'Are you sure you want to delete "${item.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(clothingItemDetailControllerProvider(itemId).notifier).deleteItem();
        if (context.mounted) {
          Navigator.of(context).pop(); // Return to previous screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item deleted successfully'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete item'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, ClothingItem item, String action) {
    switch (action) {
      case 'share':
        _handleShare(context, ref);
        break;
      case 'edit':
        _handleEdit(context, ref, item);
        break;
      case 'delete':
        _handleDelete(context, ref, item);
        break;
    }
  }

  void _handleViewAllOutfits(BuildContext context, ClothingItem item) {
    _showComingSoon(context, 'View all outfits functionality');
  }

  void _handleOutfitTap(BuildContext context, Outfit outfit) {
    _showComingSoon(context, 'Outfit detail functionality');
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Route generator for ClothingItemDetailScreen
class ClothingItemDetailRoute {
  static const String name = '/clothing-item-detail';

  static Route<void> route({
    required String itemId,
    bool isPreviewMode = false,
  }) {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: name),
      builder: (context) => ClothingItemDetailScreen(
        itemId: itemId,
        isPreviewMode: isPreviewMode,
      ),
    );
  }
}

/// Extension for easy navigation
extension ClothingItemDetailNavigation on NavigatorState {
  Future<void> pushClothingItemDetail({
    required String itemId,
    bool isPreviewMode = false,
  }) {
    return push(
      ClothingItemDetailRoute.route(
        itemId: itemId,
        isPreviewMode: isPreviewMode,
      ),
    );
  }
}
