import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ui/system_state_widget.dart';
import '../../domain/entities/swap_listing.dart';
import '../providers/swap_market_providers.dart';
import '../widgets/swap_market_filter_bar.dart';
import '../widgets/swap_listings_grid_view.dart';
import '../widgets/swap_listings_list_view.dart';

/// Main swap market screen where users can browse swap/sale listings
class SwapMarketScreen extends ConsumerStatefulWidget {
  const SwapMarketScreen({super.key});

  @override
  ConsumerState<SwapMarketScreen> createState() => _SwapMarketScreenState();
}

class _SwapMarketScreenState extends ConsumerState<SwapMarketScreen> {
  @override
  void initState() {
    super.initState();
    // Load listings when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(swapMarketNotifierProvider.notifier).loadListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final marketState = ref.watch(swapMarketNotifierProvider);
    final marketNotifier = ref.read(swapMarketNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Swap Market'),
        elevation: 0,
        centerTitle: true,
        actions: [
          // View mode toggle button
          IconButton(
            onPressed: () => marketNotifier.toggleViewMode(),
            icon: Icon(
              marketState.viewMode == SwapMarketViewMode.grid
                  ? Icons.list
                  : Icons.grid_view,
            ),
            tooltip: marketState.viewMode == SwapMarketViewMode.grid
                ? 'Switch to list view'
                : 'Switch to grid view',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await marketNotifier.loadListings(marketState.filters);
        },
        child: Column(
          children: [
            // Filter bar
            SwapMarketFilterBar(
              filters: marketState.filters,
              onFiltersChanged: (filters) {
                marketNotifier.updateFilters(filters);
              },
            ),
            
            // Listings content
            Expanded(
              child: _buildContent(context, marketState, marketNotifier),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to create listing screen
          context.push('/swap-market/create');
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Listing'),
        tooltip: 'Create a new swap listing',
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    SwapMarketState state,
    SwapMarketNotifier notifier,
  ) {
    // Show loading state
    if (state.isLoading && state.listings.isEmpty) {
      return const SystemStateWidget(
        icon: Icons.hourglass_empty,
        message: 'Loading swap listings...',
        iconColor: Colors.orange,
      );
    }

    // Show error state
    if (state.error != null && state.listings.isEmpty) {
      return SystemStateWidget(
        icon: Icons.error_outline,
        title: 'Oops! Something went wrong',
        message: state.error!,
        iconColor: Colors.red,
        onRetry: () => notifier.loadListings(state.filters),
        retryText: 'Try Again',
        isRetrying: state.isLoading,
      );
    }

    // Show empty state
    if (state.listings.isEmpty) {
      return SystemStateWidget(
        icon: Icons.shopping_bag_outlined,
        title: 'No listings found',
        message: state.filters == const SwapFilterOptions()
            ? 'Be the first to create a swap listing!\nShare your style with the community.'
            : 'No listings match your current filters.\nTry adjusting your search criteria.',
        iconColor: Theme.of(context).primaryColor,
        onCTA: () => context.push('/swap-market/create'),
        ctaText: 'Create Listing',
      );
    }

    // Show listings
    return Stack(
      children: [
        state.viewMode == SwapMarketViewMode.grid
            ? SwapListingsGridView(
                listings: state.listings,
                onListingTap: (listing) {
                  context.push('/swap-market/listing/${listing.id}');
                },
                onSaveTap: (listing) {
                  if (listing.isSavedByCurrentUser) {
                    notifier.unsaveListing(listing.id);
                  } else {
                    notifier.saveListing(listing.id);
                  }
                },
              )
            : SwapListingsListView(
                listings: state.listings,
                onListingTap: (listing) {
                  context.push('/swap-market/listing/${listing.id}');
                },
                onSaveTap: (listing) {
                  if (listing.isSavedByCurrentUser) {
                    notifier.unsaveListing(listing.id);
                  } else {
                    notifier.saveListing(listing.id);
                  }
                },
              ),
        
        // Loading overlay when refreshing
        if (state.isLoading && state.listings.isNotEmpty)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
      ],
    );
  }
}
