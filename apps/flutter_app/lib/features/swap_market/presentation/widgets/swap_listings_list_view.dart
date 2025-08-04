import 'package:flutter/material.dart';
import '../../domain/entities/swap_listing.dart';
import 'swap_listing_card.dart';

/// List view widget for displaying swap listings
class SwapListingsListView extends StatelessWidget {
  final List<SwapListing> listings;
  final ValueChanged<SwapListing> onListingTap;
  final ValueChanged<SwapListing> onSaveTap;

  const SwapListingsListView({
    super.key,
    required this.listings,
    required this.onListingTap,
    required this.onSaveTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: listings.length,
      itemBuilder: (context, index) {
        final listing = listings[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SwapListingCard(
            listing: listing,
            onTap: () => onListingTap(listing),
            onSaveTap: () => onSaveTap(listing),
            displayMode: SwapListingCardDisplayMode.list,
          ),
        );
      },
    );
  }
}
