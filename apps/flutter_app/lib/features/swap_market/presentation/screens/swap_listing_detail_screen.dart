import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ui/system_state_widget.dart';
import '../../domain/entities/swap_listing.dart';
import '../providers/swap_market_providers.dart';
import '../widgets/listing_image_gallery.dart';
import '../widgets/listing_details_section.dart';
import '../widgets/seller_info_card.dart';
import '../widgets/listing_action_buttons.dart';

/// Screen showing detailed view of a specific swap listing
class SwapListingDetailScreen extends ConsumerWidget {
  final String listingId;

  const SwapListingDetailScreen({
    super.key,
    required this.listingId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingAsync = ref.watch(swapListingDetailProvider(listingId));

    return Scaffold(
      body: listingAsync.when(
        loading: () => const SystemStateWidget(
          icon: Icons.hourglass_empty,
          message: 'Loading listing details...',
          iconColor: Colors.orange,
        ),
        error: (error, stackTrace) => SystemStateWidget(
          icon: Icons.error_outline,
          title: 'Failed to load listing',
          message: error.toString(),
          iconColor: Colors.red,
          onRetry: () => ref.invalidate(swapListingDetailProvider(listingId)),
          retryText: 'Try Again',
        ),
        data: (listing) {
          if (listing == null) {
            return SystemStateWidget(
              icon: Icons.search_off,
              title: 'Listing not found',
              message: 'This listing may have been removed or is no longer available.',
              iconColor: Colors.grey,
              onCTA: () => context.go('/swap-market'),
              ctaText: 'Back to Market',
            );
          }

          return _buildContent(context, ref, listing);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, SwapListing listing) {
    // TODO: Check if current user is the owner
    final isOwner = false; // Replace with actual ownership check
    
    return CustomScrollView(
      slivers: [
        // App bar with image background
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: ListingImageGallery(
              imageUrls: listing.imageUrls,
            ),
          ),
          actions: [
            // Save button
            IconButton(
              onPressed: () {
                // TODO: Implement save/unsave functionality
                final marketNotifier = ref.read(swapMarketNotifierProvider.notifier);
                if (listing.isSavedByCurrentUser) {
                  marketNotifier.unsaveListing(listing.id);
                } else {
                  marketNotifier.saveListing(listing.id);
                }
              },
              icon: Icon(
                listing.isSavedByCurrentUser
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: listing.isSavedByCurrentUser
                    ? Colors.red
                    : null,
              ),
            ),
            
            // Share button
            IconButton(
              onPressed: () {
                // TODO: Implement share functionality
                _showShareDialog(context, listing);
              },
              icon: const Icon(Icons.share),
            ),
            
            // Owner actions menu (for future use when owner detection is implemented)
            // TODO: Enable when user authentication is ready
            // if (isOwner) ...[
            //   PopupMenuButton<String>(...)
            // ],
          ],
        ),
        
        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Listing details
                ListingDetailsSection(listing: listing),
                
                const SizedBox(height: 24),
                
                // Seller info
                SellerInfoCard(listing: listing),
                
                const SizedBox(height: 24),
                
                // Action buttons (only for non-owners)
                if (!isOwner)
                  ListingActionButtons(
                    listing: listing,
                    onContact: () => _onMessage(context, listing),
                    onSave: () {
                      final marketNotifier = ref.read(swapMarketNotifierProvider.notifier);
                      if (listing.isSavedByCurrentUser) {
                        marketNotifier.unsaveListing(listing.id);
                      } else {
                        marketNotifier.saveListing(listing.id);
                      }
                    },
                    onShare: () => _showShareDialog(context, listing),
                  ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showShareDialog(BuildContext context, SwapListing listing) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Listing'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy Link'),
              onTap: () {
                // TODO: Copy listing URL to clipboard
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied to clipboard')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Share via Message'),
              onTap: () {
                // TODO: Open messaging app
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.more_horiz),
              title: const Text('More Options'),
              onTap: () {
                // TODO: Open system share sheet
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _onMessage(BuildContext context, SwapListing listing) {
    // TODO: Implement messaging functionality
    // For now, show a placeholder dialog
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Seller'),
        content: Text(
          'Message ${listing.sellerName} about this ${listing.type == SwapListingType.sale ? 'item for sale' : 'swap opportunity'}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Open messaging screen or chat
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening chat with ${listing.sellerName}...'),
                ),
              );
            },
            child: const Text('Send Message'),
          ),
        ],
      ),
    );
  }
}
