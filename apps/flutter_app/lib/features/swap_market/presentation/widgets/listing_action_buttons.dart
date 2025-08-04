import 'package:flutter/material.dart';
import '../../domain/entities/swap_listing.dart';

/// Widget for action buttons on listing detail screen
class ListingActionButtons extends StatelessWidget {
  final SwapListing listing;
  final bool isCurrentUserListing;
  final VoidCallback? onContact;
  final VoidCallback? onSave;
  final VoidCallback? onShare;
  final VoidCallback? onReport;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ListingActionButtons({
    super.key,
    required this.listing,
    this.isCurrentUserListing = false,
    this.onContact,
    this.onSave,
    this.onShare,
    this.onReport,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isCurrentUserListing) {
      return _buildOwnerActions(context, theme);
    } else {
      return _buildBuyerActions(context, theme);
    }
  }

  Widget _buildBuyerActions(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        // Primary action button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: listing.status == SwapListingStatus.active ? onContact : null,
            icon: Icon(
              listing.type == SwapListingType.swap 
                ? Icons.swap_horiz 
                : Icons.message,
            ),
            label: Text(
              listing.status == SwapListingStatus.active
                ? (listing.type == SwapListingType.swap 
                    ? 'Propose Swap' 
                    : 'Message Seller')
                : _getStatusText(listing.status),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Secondary actions
        Row(
          children: [
            // Save button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onSave,
                icon: Icon(
                  listing.isSavedByCurrentUser 
                    ? Icons.favorite 
                    : Icons.favorite_border,
                  color: listing.isSavedByCurrentUser 
                    ? Colors.red 
                    : null,
                ),
                label: Text(
                  listing.isSavedByCurrentUser ? 'Saved' : 'Save',
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Share button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.share),
                label: const Text('Share'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Report button
        TextButton.icon(
          onPressed: onReport,
          icon: Icon(
            Icons.flag_outlined,
            size: 16,
            color: theme.colorScheme.error,
          ),
          label: Text(
            'Report listing',
            style: TextStyle(
              color: theme.colorScheme.error,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOwnerActions(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        // Status indicator
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getStatusColor(listing.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getStatusColor(listing.status).withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _getStatusIcon(listing.status),
                color: _getStatusColor(listing.status),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your listing is ${_getStatusText(listing.status).toLowerCase()}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: _getStatusColor(listing.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _getStatusDescription(listing.status),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Owner actions
        Row(
          children: [
            // Edit button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: listing.status == SwapListingStatus.active ? onEdit : null,
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Share button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.share),
                label: const Text('Share'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Delete button
        TextButton.icon(
          onPressed: onDelete,
          icon: Icon(
            Icons.delete_outline,
            size: 16,
            color: theme.colorScheme.error,
          ),
          label: Text(
            'Delete listing',
            style: TextStyle(
              color: theme.colorScheme.error,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(SwapListingStatus status) {
    switch (status) {
      case SwapListingStatus.active:
        return Colors.green;
      case SwapListingStatus.sold:
      case SwapListingStatus.swapped:
        return Colors.blue;
      case SwapListingStatus.pending:
        return Colors.orange;
      case SwapListingStatus.deleted:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(SwapListingStatus status) {
    switch (status) {
      case SwapListingStatus.active:
        return Icons.check_circle;
      case SwapListingStatus.sold:
        return Icons.shopping_bag;
      case SwapListingStatus.swapped:
        return Icons.swap_horiz;
      case SwapListingStatus.pending:
        return Icons.hourglass_empty;
      case SwapListingStatus.deleted:
        return Icons.delete;
    }
  }

  String _getStatusText(SwapListingStatus status) {
    switch (status) {
      case SwapListingStatus.active:
        return 'Active';
      case SwapListingStatus.sold:
        return 'Sold';
      case SwapListingStatus.swapped:
        return 'Swapped';
      case SwapListingStatus.pending:
        return 'Pending';
      case SwapListingStatus.deleted:
        return 'Deleted';
    }
  }

  String _getStatusDescription(SwapListingStatus status) {
    switch (status) {
      case SwapListingStatus.active:
        return 'Visible to other users';
      case SwapListingStatus.sold:
        return 'Item has been sold';
      case SwapListingStatus.swapped:
        return 'Item has been swapped';
      case SwapListingStatus.pending:
        return 'Transaction in progress';
      case SwapListingStatus.deleted:
        return 'No longer visible';
    }
  }
}
