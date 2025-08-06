import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../wardrobe/presentation/controllers/wardrobe_controller.dart';
import '../../../wardrobe/domain/entities/clothing_item.dart';
import '../widgets/wardrobe_multi_select_toolbar.dart';
import '../widgets/wardrobe_filter_bottom_sheet.dart';
import '../widgets/clothing_item_card.dart';
import '../../../../core/ui/loading_view.dart';
import '../../../../core/ui/error_view.dart';

class WardrobeHomeScreen extends ConsumerStatefulWidget {
  const WardrobeHomeScreen({super.key});

  @override
  ConsumerState<WardrobeHomeScreen> createState() => _WardrobeHomeScreenState();
}

class _WardrobeHomeScreenState extends ConsumerState<WardrobeHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(wardrobeControllerProvider.notifier).loadItems(isRefresh: true);
    });
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wardrobeAsync = ref.watch(wardrobeControllerProvider);
    final controller = ref.watch(wardrobeControllerProvider.notifier);
    final theme = Theme.of(context);
    final isMultiSelectMode = controller.isMultiSelectMode;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('My Wardrobe'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.grid_view : Icons.list),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
              final filters = await showModalBottomSheet<Map<String, dynamic>>(
                context: context,
                builder: (context) => const WardrobeFilterBottomSheet(),
              );
              if (filters != null) {
                controller.updateFilters(
                  categoryIds: (filters['categories'] as List<dynamic>?)?.cast<String>(),
                  seasons: (filters['seasons'] as List<dynamic>?)?.cast<String>(),
                  showOnlyFavorites: filters['favorites'] as bool?,
                  sortBy: filters['sortBy'] as String?,
                );
              }
            },
          ),
        ],
      ),
      body: wardrobeAsync.when(
        data: (items) => _buildWardrobeContent(items, theme),
        loading: () => const LoadingView(),
        error: (error, stackTrace) => ErrorView(error: error, stackTrace: stackTrace),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/wardrobe/camera');
        },
        child: const Icon(Icons.camera_alt),
        tooltip: 'Add Item with Camera',
      ),
    );
  }

  Widget _buildWardrobeContent(List<ClothingItem> items, ThemeData theme) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'Your wardrobe is empty. Add some items!',
          style: theme.textTheme.bodyLarge,
        ),
      );
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _isGridView ? 2 : 1,
        childAspectRatio: _isGridView ? 0.8 : 2.5,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ClothingItemCard(item: item);
      },
    );
  }
}
