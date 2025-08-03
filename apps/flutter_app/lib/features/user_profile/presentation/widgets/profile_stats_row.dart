import 'package:flutter/material.dart';
import '../controllers/user_profile_controller.dart';

/// Profile Stats Row Widget - Displays key user statistics in a horizontal row
/// 
/// Shows:
/// - Number of combinations created
/// - Number of favorites saved
/// - Number of followers
/// - Number of following
/// Each stat is clickable and navigates to detailed view
class ProfileStatsRow extends StatelessWidget {
  final UserStatsData stats;
  final void Function(String) onStatsPressed;

  const ProfileStatsRow({
    super.key,
    required this.stats,
    required this.onStatsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Combinations
            Expanded(
              child: _buildStatItem(
                'Combinations',
                stats.combinations,
                Icons.checkroom_outlined,
                colorScheme.primary,
                theme,
                () => onStatsPressed('combinations'),
              ),
            ),

            // Divider
            _buildDivider(colorScheme),

            // Favorites
            Expanded(
              child: _buildStatItem(
                'Favorites',
                stats.favorites,
                Icons.favorite_outline,
                colorScheme.error,
                theme,
                () => onStatsPressed('favorites'),
              ),
            ),

            // Divider
            _buildDivider(colorScheme),

            // Followers
            Expanded(
              child: _buildStatItem(
                'Followers',
                stats.followers,
                Icons.people_outline,
                colorScheme.secondary,
                theme,
                () => onStatsPressed('followers'),
              ),
            ),

            // Divider
            _buildDivider(colorScheme),

            // Following
            Expanded(
              child: _buildStatItem(
                'Following',
                stats.following,
                Icons.person_add_outlined,
                colorScheme.tertiary,
                theme,
                () => onStatsPressed('following'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds individual stat item with icon, number, and label
  Widget _buildStatItem(
    String label,
    int value,
    IconData icon,
    Color iconColor,
    ThemeData theme,
    VoidCallback onTap,
  ) {
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 8),

            // Number
            Text(
              _formatNumber(value),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
                fontFamily: 'Urbanist',
              ),
            ),
            const SizedBox(height: 2),

            // Label
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds vertical divider between stats
  Widget _buildDivider(ColorScheme colorScheme) {
    return Container(
      width: 1,
      height: 48,
      decoration: BoxDecoration(
        color: colorScheme.outline.withOpacity(0.2),
      ),
    );
  }

  /// Formats numbers for display (e.g., 1.2K for 1200)
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }
}
