import 'package:flutter/material.dart';

/// Second onboarding page highlighting wardrobe potential discovery
/// Emphasizes the transformative aspect of Aura's capabilities
class Page2 extends StatelessWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration showing wardrobe discovery concept
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.secondary.withOpacity(0.1),
                  colorScheme.tertiary.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: colorScheme.secondary.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background elements representing clothes
                Positioned(
                  top: 40,
                  left: 40,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.checkroom,
                      size: 24,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Positioned(
                  top: 60,
                  right: 50,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.local_laundry_service,
                      size: 18,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 50,
                  left: 60,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(
                      Icons.accessibility_new,
                      size: 20,
                      color: colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
                
                // Central discovery icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: colorScheme.secondary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.secondary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.explore,
                    size: 50,
                    color: colorScheme.onSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Main title
          Text(
            'Discover the potential of your wardrobe.',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Description
          Text(
            'Unlock hidden outfit combinations and make the most of every piece you own. Aura reveals possibilities you never knew existed.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Discovery features
          Column(
            children: [
              _DiscoveryItem(
                icon: Icons.lightbulb_outline,
                text: 'Find new outfit combinations',
                colorScheme: colorScheme,
                theme: theme,
              ),
              const SizedBox(height: 16),
              _DiscoveryItem(
                icon: Icons.analytics_outlined,
                text: 'Analyze your style patterns',
                colorScheme: colorScheme,
                theme: theme,
              ),
              const SizedBox(height: 16),
              _DiscoveryItem(
                icon: Icons.trending_up_outlined,
                text: 'Maximize wardrobe potential',
                colorScheme: colorScheme,
                theme: theme,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DiscoveryItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _DiscoveryItem({
    required this.icon,
    required this.text,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: colorScheme.onSecondaryContainer,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
