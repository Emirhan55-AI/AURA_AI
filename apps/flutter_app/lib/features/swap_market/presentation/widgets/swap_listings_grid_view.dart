import 'package:flutter/material.dart';
import '../../domain/entities/swap_listing.dart';
import 'swap_listing_card.dart';

/// Grid view widget for displaying swap listings
class SwapListingsGridView extends StatelessWidget {
  final List<SwapListing> listings;
  final ValueChanged<SwapListing> onListingTap;
  final ValueChanged<SwapListing> onSaveTap;

  const SwapListingsGridView({
    super.key,
    required this.listings,
    required this.onListingTap,
    required this.onSaveTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75, // Adjust based on card design
      ),
      itemCount: listings.length,
      itemBuilder: (context, index) {
        final listing = listings[index];
        return SwapListingCard(
          listing: listing,
          onTap: () => onListingTap(listing),
          onSaveTap: () => onSaveTap(listing),
          displayMode: SwapListingCardDisplayMode.grid,
        );
      },
    );
  }
}
