import 'package:flutter/material.dart';
import '../screens/wardrobe_analytics_screen.dart';

/// Example navigation helper to demonstrate how to navigate to WardrobeAnalyticsScreen
/// This could be used from various parts of the app like UserProfile or main Wardrobe section
class WardrobeAnalyticsNavigation {
  static void navigateToAnalytics(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const WardrobeAnalyticsScreen(),
      ),
    );
  }

  static void navigateToAnalyticsReplacement(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => const WardrobeAnalyticsScreen(),
      ),
    );
  }
}

/// Example widget showing how to trigger navigation to analytics
class AnalyticsNavigationExample extends StatelessWidget {
  const AnalyticsNavigationExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Wardrobe Analytics',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'View insights about your wardrobe usage, color distribution, and get personalized shopping recommendations.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => WardrobeAnalyticsNavigation.navigateToAnalytics(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('View Analytics'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
