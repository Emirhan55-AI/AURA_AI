import 'package:flutter/material.dart';
import '../../domain/entities/swap_listing.dart';

/// Display modes for the swap listing card
enum SwapListingCardDisplayMode { grid, list }

/// Card widget for displaying a single swap listing
class SwapListingCard extends StatelessWidget {
  final SwapListing listing;
  final VoidCallback onTap;
  final VoidCallback onSaveTap;
  final SwapListingCardDisplayMode displayMode;

  const SwapListingCard({
    super.key,
    required this.listing,
    required this.onTap,
    required this.onSaveTap,
    this.displayMode = SwapListingCardDisplayMode.grid,
  });

  @override
  Widget build(BuildContext context) {
    return displayMode == SwapListingCardDisplayMode.grid
        ? _buildGridCard(context)
        : _buildListCard(context);
  }

  Widget _buildGridCard(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  _buildImage(),
                  // Save button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _buildSaveButton(context),
                  ),
                  // Type badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _buildTypeBadge(context),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    Text(
                      listing.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Price or swap info
                    Text(
                      _getPriceText(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Seller info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundImage: listing.sellerAvatarUrl != null
                              ? NetworkImage(listing.sellerAvatarUrl!)
                              : null,
                          child: listing.sellerAvatarUrl == null
                              ? Icon(
                                  Icons.person,
                                  size: 12,
                                  color: theme.colorScheme.onSurfaceVariant,
                                )
                              : null,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            listing.sellerName,
                            style: theme.textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Swap score
                        Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          listing.sellerSwapScore.toStringAsFixed(1),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: _buildImage(),
                    ),
                  ),
                  // Type badge
                  Positioned(
                    top: 4,
                    left: 4,
                    child: _buildTypeBadge(context),
                  ),
                ],
              ),
              
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    Text(
                      listing.description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Price or swap info
                    Text(
                      _getPriceText(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Seller info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundImage: listing.sellerAvatarUrl != null
                              ? NetworkImage(listing.sellerAvatarUrl!)
                              : null,
                          child: listing.sellerAvatarUrl == null
                              ? Icon(
                                  Icons.person,
                                  size: 14,
                                  color: theme.colorScheme.onSurfaceVariant,
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          listing.sellerName,
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          listing.sellerSwapScore.toStringAsFixed(1),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        // Stats
                        Row(
                          children: [
                            Icon(
                              Icons.visibility_outlined,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${listing.viewCount}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.favorite_outline,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${listing.saveCount}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Save button
              _buildSaveButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
      ),
      child: listing.imageUrls.isNotEmpty
          ? Image.network(
              listing.imageUrls.first,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.grey[400],
                  size: 48,
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            )
          : Icon(
              Icons.image_outlined,
              color: Colors.grey[400],
              size: 48,
            ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.9),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onSaveTap,
        icon: Icon(
          listing.isSavedByCurrentUser
              ? Icons.favorite
              : Icons.favorite_border,
          color: listing.isSavedByCurrentUser
              ? Colors.red
              : theme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
        constraints: const BoxConstraints(
          minWidth: 32,
          minHeight: 32,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildTypeBadge(BuildContext context) {
    final theme = Theme.of(context);
    final isSwap = listing.type == SwapListingType.swap;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isSwap ? Colors.green : theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        isSwap ? 'SWAP' : 'SALE',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getPriceText() {
    if (listing.type == SwapListingType.sale && listing.price != null) {
      return '\$${listing.price!.toStringAsFixed(0)}';
    } else if (listing.type == SwapListingType.swap && listing.swapWantedFor != null) {
      return 'Swap for: ${listing.swapWantedFor}';
    }
    return 'Contact seller';
  }
}
