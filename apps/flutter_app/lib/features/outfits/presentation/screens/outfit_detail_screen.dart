import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/outfit.dart';
import '../../../wardrobe/domain/entities/clothing_item.dart';

class OutfitDetailScreen extends ConsumerStatefulWidget {
  final String outfitId;

  const OutfitDetailScreen({
    super.key,
    required this.outfitId,
  });

  @override
  ConsumerState<OutfitDetailScreen> createState() => _OutfitDetailScreenState();
}

class _OutfitDetailScreenState extends ConsumerState<OutfitDetailScreen> {
  Outfit? outfit;
  List<ClothingItem> clothingItems = [];
  bool isLoading = true;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadOutfitData();
  }

  Future<void> _loadOutfitData() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        outfit = _createMockOutfit();
        clothingItems = _createMockClothingItems();
        isLoading = false;
      });
    }
  }

  Outfit _createMockOutfit() {
    final now = DateTime.now();
    return Outfit(
      id: widget.outfitId,
      userId: 'user123',
      name: 'Casual Weekend Look',
      description: 'Perfect for a relaxed weekend stroll in the park.',
      clothingItemIds: ['item1', 'item2', 'item3'],
      occasion: 'Casual',
      season: 'Spring',
      weather: 'Mild',
      style: 'Casual',
      tags: ['comfortable', 'stylish', 'weekend'],
      imageUrl: 'https://images.unsplash.com/photo-1434389677669-e08b4cac3105',
      isFavorite: isFavorite,
      isPublic: true,
      wearCount: 5,
      lastWorn: now.subtract(const Duration(days: 3)),
      rating: 4.5,
      colors: ['blue', 'white', 'denim'],
      createdAt: now.subtract(const Duration(days: 30)),
      updatedAt: now.subtract(const Duration(days: 1)),
    );
  }

  List<ClothingItem> _createMockClothingItems() {
    final now = DateTime.now();
    return [
      ClothingItem(
        id: 'item1',
        userId: 'user123',
        name: 'Blue Denim Jeans',
        category: 'Bottoms',
        brand: 'Levi\'s',
        color: 'Blue',
        size: 'M',
        price: 89.99,
        imageUrl: 'https://images.unsplash.com/photo-1542272604-787c3835535d',
        tags: ['denim', 'casual', 'comfortable'],
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
      ClothingItem(
        id: 'item2',
        userId: 'user123',
        name: 'White Cotton T-Shirt',
        category: 'Tops',
        brand: 'H&M',
        color: 'White',
        size: 'M',
        price: 19.99,
        imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab',
        tags: ['basic', 'cotton', 'everyday'],
        createdAt: now.subtract(const Duration(days: 90)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      ClothingItem(
        id: 'item3',
        userId: 'user123',
        name: 'Black Sneakers',
        category: 'Footwear',
        brand: 'Nike',
        color: 'Black',
        size: '10',
        price: 129.99,
        imageUrl: 'https://images.unsplash.com/photo-1549298916-b41d501d3772',
        tags: ['athletic', 'comfortable', 'versatile'],
        createdAt: now.subtract(const Duration(days: 120)),
        updatedAt: now.subtract(const Duration(days: 15)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState(context);
    }

    if (outfit == null) {
      return _buildNotFoundState(context);
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          _buildOutfitActions(context),
          _buildOutfitInformation(context),
          _buildClothingItemsGrid(context),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => _shareOutfit(),
        ),
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit Outfit'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete Outfit', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            image: outfit?.imageUrl != null
                ? DecorationImage(
                    image: NetworkImage(outfit!.imageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
            gradient: outfit?.imageUrl == null
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                    ],
                  )
                : null,
          ),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black26],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      outfit!.name,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          const Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 3,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                    if (outfit!.description != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        outfit!.description!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          shadows: [
                            const Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 3,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutfitActions(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            FilledButton.tonalIcon(
              onPressed: () => _toggleFavorite(),
              icon: Icon(
                outfit!.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: outfit!.isFavorite ? Colors.red : null,
              ),
              label: Text(outfit!.isFavorite ? 'Favorited' : 'Add to Favorites'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _shareOutfit(),
                icon: const Icon(Icons.share),
                label: const Text('Share'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutfitInformation(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Outfit Details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildMetadataCards(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataCards(BuildContext context) {
    final metadata = [
      {'label': 'Occasion', 'value': outfit!.occasion, 'icon': Icons.event},
      {'label': 'Season', 'value': outfit!.season, 'icon': Icons.ac_unit},
      {'label': 'Weather', 'value': outfit!.weather, 'icon': Icons.wb_sunny},
      {'label': 'Style', 'value': outfit!.style, 'icon': Icons.palette},
      {'label': 'Worn', 'value': '${outfit!.wearCount} times', 'icon': Icons.repeat},
      {'label': 'Rating', 'value': '${outfit!.rating}/5', 'icon': Icons.star},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: metadata.map((item) => _buildMetadataCard(
        context,
        label: item['label'] as String,
        value: item['value'] as String,
        icon: item['icon'] as IconData,
      )).toList(),
    );
  }

  Widget _buildMetadataCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClothingItemsGrid(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Clothing Items',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${clothingItems.length} items',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: clothingItems.length,
              itemBuilder: (context, index) {
                final item = clothingItems[index];
                return _buildClothingItemCard(context, item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClothingItemCard(BuildContext context, ClothingItem item) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _navigateToItemDetail(item.id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  image: item.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(item.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: item.imageUrl == null
                      ? Theme.of(context).colorScheme.surfaceVariant
                      : null,
                ),
                child: item.imageUrl == null
                    ? Icon(
                        Icons.checkroom,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      )
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.category ?? 'Unknown',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (item.brand != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.brand!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outfit Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildNotFoundState(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outfit Not Found'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_dissatisfied,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Outfit not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The outfit you\'re looking for doesn\'t exist or has been removed.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
      outfit = outfit!.copyWith(isFavorite: isFavorite);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite ? 'Added to favorites' : 'Removed from favorites',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareOutfit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing outfit...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        context.push('/outfits/${outfit!.id}/edit');
        break;
      case 'delete':
        _showDeleteConfirmation();
        break;
    }
  }

  void _showDeleteConfirmation() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Outfit'),
        content: const Text('Are you sure you want to delete this outfit? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteOutfit();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteOutfit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Outfit deleted'),
        duration: Duration(seconds: 2),
      ),
    );
    context.pop();
  }

  void _navigateToItemDetail(String itemId) {
    context.push('/wardrobe/items/$itemId/detail');
  }
}
