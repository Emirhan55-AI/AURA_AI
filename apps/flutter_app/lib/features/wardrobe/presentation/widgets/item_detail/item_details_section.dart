import 'package:flutter/material.dart';
import '../../../domain/entities/clothing_item.dart';

/// Widget for displaying structured details of a clothing item
/// Shows name, category, color, season, tags, description and other attributes
class ItemDetailsSection extends StatelessWidget {
  final ClothingItem item;

  const ItemDetailsSection({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
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
            // Item name
            Text(
              item.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Basic attributes
            _buildAttributeGrid(context, theme, colorScheme),
            
            // Tags section
            if (item.tags?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              _buildTagsSection(context, theme, colorScheme),
            ],

            // AI Tags section
            if (item.aiTags?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              _buildAiTagsSection(context, theme, colorScheme),
            ],

            // Description
            if (item.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              _buildDescriptionSection(context, theme, colorScheme),
            ],

            // Additional details
            const SizedBox(height: 16),
            _buildAdditionalDetails(context, theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildAttributeGrid(
    BuildContext context, 
    ThemeData theme, 
    ColorScheme colorScheme
  ) {
    final attributes = [
      if (item.category != null) 
        _AttributeItem(
          icon: Icons.category_outlined,
          label: 'Category',
          value: item.category!,
        ),
      if (item.color != null)
        _AttributeItem(
          icon: Icons.palette_outlined,
          label: 'Color',
          value: item.color!,
        ),
      if (item.brand != null)
        _AttributeItem(
          icon: Icons.business_outlined,
          label: 'Brand',
          value: item.brand!,
        ),
      if (item.size != null)
        _AttributeItem(
          icon: Icons.straighten_outlined,
          label: 'Size',
          value: item.size!,
        ),
      if (item.condition != null)
        _AttributeItem(
          icon: Icons.star_outline,
          label: 'Condition',
          value: item.condition!,
        ),
      if (item.pattern != null)
        _AttributeItem(
          icon: Icons.texture_outlined,
          label: 'Pattern',
          value: item.pattern!,
        ),
    ];

    if (attributes.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: attributes.length,
      itemBuilder: (context, index) {
        final attribute = attributes[index];
        return _buildAttributeItem(
          context, 
          theme, 
          colorScheme, 
          attribute,
        );
      },
    );
  }

  Widget _buildAttributeItem(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    _AttributeItem attribute,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            attribute.icon,
            size: 16,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  attribute.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  attribute.value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection(
    BuildContext context, 
    ThemeData theme, 
    ColorScheme colorScheme
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: item.tags!.map((tag) {
            return Chip(
              label: Text(
                tag,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
              backgroundColor: colorScheme.secondaryContainer,
              side: BorderSide.none,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAiTagsSection(
    BuildContext context, 
    ThemeData theme, 
    ColorScheme colorScheme
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.auto_awesome,
              size: 16,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              'AI Insights',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: item.aiTags!.entries.map((entry) {
            return Chip(
              avatar: Icon(
                Icons.smart_toy,
                size: 16,
                color: colorScheme.onTertiaryContainer,
              ),
              label: Text(
                '${entry.key}: ${entry.value}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onTertiaryContainer,
                ),
              ),
              backgroundColor: colorScheme.tertiaryContainer,
              side: BorderSide.none,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(
    BuildContext context, 
    ThemeData theme, 
    ColorScheme colorScheme
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            item.notes!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalDetails(
    BuildContext context, 
    ThemeData theme, 
    ColorScheme colorScheme
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Purchase details
          if (item.purchaseDate != null || item.purchaseLocation != null || item.price != null) ...[
            _buildDetailRow(
              context,
              theme,
              colorScheme,
              'Purchase Info',
              _buildPurchaseInfo(),
            ),
            const SizedBox(height: 8),
          ],
          
          // Usage details
          _buildDetailRow(
            context,
            theme,
            colorScheme,
            'Usage',
            _buildUsageInfo(),
          ),
          
          const SizedBox(height: 8),
          
          // Timestamps
          _buildDetailRow(
            context,
            theme,
            colorScheme,
            'Added',
            _formatDate(item.createdAt),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  String _buildPurchaseInfo() {
    final parts = <String>[];
    
    if (item.price != null) {
      parts.add('${item.currency ?? 'USD'} ${item.price!.toStringAsFixed(0)}');
    }
    
    if (item.purchaseLocation != null) {
      parts.add('from ${item.purchaseLocation}');
    }
    
    if (item.purchaseDate != null) {
      parts.add('on ${_formatDate(item.purchaseDate!)}');
    }
    
    return parts.isNotEmpty ? parts.join(' ') : 'No purchase info';
  }

  String _buildUsageInfo() {
    if (item.lastWornDate != null) {
      return 'Last worn ${_formatDate(item.lastWornDate!)}';
    }
    return 'Never worn';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else if (difference < 30) {
      final weeks = (difference / 7).round();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    } else if (difference < 365) {
      final months = (difference / 30).round();
      return '$months month${months == 1 ? '' : 's'} ago';
    } else {
      final years = (difference / 365).round();
      return '$years year${years == 1 ? '' : 's'} ago';
    }
  }
}

/// Helper class for attribute items
class _AttributeItem {
  final IconData icon;
  final String label;
  final String value;

  const _AttributeItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}
