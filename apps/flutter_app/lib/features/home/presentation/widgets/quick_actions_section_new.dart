import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Quick actions section with common tasks
/// Provides shortcuts to frequently used features
class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flash_on,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Quick Actions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildActionButton(
                  context,
                  'Add Item',
                  Icons.add_circle_outline,
                  colorScheme.primary,
                  () => context.push('/wardrobe/add-item'),
                ),
                _buildActionButton(
                  context,
                  'Create Outfit',
                  Icons.style_outlined,
                  colorScheme.secondary,
                  () => context.push('/wardrobe/create-outfit'),
                ),
                _buildActionButton(
                  context,
                  'Style Assistant',
                  Icons.auto_awesome_outlined,
                  colorScheme.tertiary,
                  () => context.go('/main'),
                ),
                _buildActionButton(
                  context,
                  'Swap Market',
                  Icons.swap_horiz_outlined,
                  colorScheme.primaryContainer,
                  () => context.push('/swap-market'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a quick action button
  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
