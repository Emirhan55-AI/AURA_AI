import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/search_result.dart';

abstract class BaseSearchResultTile extends StatelessWidget {
  final SearchResult result;

  const BaseSearchResultTile({
    super.key,
    required this.result,
  });

  @protected
  Widget buildTileContent(BuildContext context);

  @protected
  void onTap(BuildContext context);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => onTap(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: buildTileContent(context),
        ),
      ),
    );
  }
}

class ClothingSearchResultTile extends BaseSearchResultTile {
  const ClothingSearchResultTile({
    super.key,
    required super.result,
  });

  @override
  Widget buildTileContent(BuildContext context) {
    final theme = Theme.of(context);
    final metadata = result.metadata;
    
    return Row(
      children: [
        // Image placeholder
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: result.imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    result.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.checkroom,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : Icon(
                  Icons.checkroom,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
        ),
        const SizedBox(width: 12),
        
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                result.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (metadata['category'] != null || metadata['color'] != null) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: [
                    if (metadata['category'] != null)
                      _buildMetadataChip(context, metadata['category'] as String),
                    if (metadata['color'] != null)
                      _buildMetadataChip(context, metadata['color'] as String),
                  ],
                ),
              ],
            ],
          ),
        ),
        
        // Arrow icon
        Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }

  @override
  void onTap(BuildContext context) {
    // Navigate to clothing item detail
    context.push('/wardrobe/item/${result.id}');
  }

  Widget _buildMetadataChip(BuildContext context, String text) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}

class CombinationSearchResultTile extends BaseSearchResultTile {
  const CombinationSearchResultTile({
    super.key,
    required super.result,
  });

  @override
  Widget buildTileContent(BuildContext context) {
    final theme = Theme.of(context);
    final metadata = result.metadata;
    
    return Row(
      children: [
        // Image placeholder
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: result.imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    result.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.style,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : Icon(
                  Icons.style,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
        ),
        const SizedBox(width: 12),
        
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                result.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (metadata['style'] != null || metadata['occasion'] != null) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: [
                    if (metadata['style'] != null)
                      _buildMetadataChip(context, metadata['style'] as String),
                    if (metadata['occasion'] != null)
                      _buildMetadataChip(context, metadata['occasion'] as String),
                  ],
                ),
              ],
            ],
          ),
        ),
        
        // Arrow icon
        Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }

  @override
  void onTap(BuildContext context) {
    // Navigate to outfit detail
    context.push('/outfits/${result.id}');
  }

  Widget _buildMetadataChip(BuildContext context, String text) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onTertiaryContainer,
        ),
      ),
    );
  }
}

class SocialPostSearchResultTile extends BaseSearchResultTile {
  const SocialPostSearchResultTile({
    super.key,
    required super.result,
  });

  @override
  Widget buildTileContent(BuildContext context) {
    final theme = Theme.of(context);
    final metadata = result.metadata;
    
    return Row(
      children: [
        // Image placeholder
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: result.imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    result.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.article,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : Icon(
                  Icons.article,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
        ),
        const SizedBox(width: 12),
        
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              if (metadata['author'] != null) ...[
                Text(
                  'by ${metadata['author']}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
              ],
              Text(
                result.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (metadata['likes'] != null || metadata['comments'] != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (metadata['likes'] != null) ...[
                      Icon(
                        Icons.favorite_border,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${metadata['likes']}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (metadata['comments'] != null) ...[
                      Icon(
                        Icons.comment_outlined,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${metadata['comments']}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
        
        // Arrow icon
        Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }

  @override
  void onTap(BuildContext context) {
    // Navigate to social post detail
    context.push('/social/post/${result.id}');
  }
}

class UserSearchResultTile extends BaseSearchResultTile {
  const UserSearchResultTile({
    super.key,
    required super.result,
  });

  @override
  Widget buildTileContent(BuildContext context) {
    final theme = Theme.of(context);
    final metadata = result.metadata;
    
    return Row(
      children: [
        // Avatar
        CircleAvatar(
          radius: 28,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          backgroundImage: result.imageUrl != null 
              ? NetworkImage(result.imageUrl!) 
              : null,
          child: result.imageUrl == null
              ? Icon(
                  Icons.person,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 32,
                )
              : null,
        ),
        const SizedBox(width: 12),
        
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                result.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (metadata['followers'] != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${metadata['followers']} followers',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (metadata['posts'] != null) ...[
                      const SizedBox(width: 12),
                      Icon(
                        Icons.grid_view,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${metadata['posts']} posts',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
        
        // Follow button or arrow
        OutlinedButton(
          onPressed: () {
            // Handle follow action
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Follow functionality coming soon!')),
            );
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(60, 32),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          ),
          child: Text(
            'Follow',
            style: theme.textTheme.labelSmall,
          ),
        ),
      ],
    );
  }

  @override
  void onTap(BuildContext context) {
    // Navigate to user profile
    context.push('/social/user/${result.id}');
  }
}

class SwapListingSearchResultTile extends BaseSearchResultTile {
  const SwapListingSearchResultTile({
    super.key,
    required super.result,
  });

  @override
  Widget buildTileContent(BuildContext context) {
    final theme = Theme.of(context);
    final metadata = result.metadata;
    
    return Row(
      children: [
        // Image placeholder
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: result.imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    result.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.swap_horiz,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : Icon(
                  Icons.swap_horiz,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
        ),
        const SizedBox(width: 12),
        
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      result.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (metadata['value'] != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      metadata['value'] as String,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                result.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (metadata['type'] != null || metadata['condition'] != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (metadata['type'] != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          metadata['type'] as String,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (metadata['condition'] != null)
                      Text(
                        metadata['condition'] as String,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        
        // Arrow icon
        Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }

  @override
  void onTap(BuildContext context) {
    // Navigate to swap listing detail
    context.push('/swap/listing/${result.id}');
  }
}
