import 'package:flutter/material.dart';

/// Third onboarding page focusing on personalized style discovery
/// Culminates the onboarding with a call to action for getting started
class Page3 extends StatelessWidget {
  const Page3({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration representing personalized style combinations
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.tertiary.withOpacity(0.1),
                  colorScheme.primary.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: colorScheme.tertiary.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Multiple style elements arranged in a pattern
                Positioned(
                  top: 30,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _StyleElement(
                        icon: Icons.style,
                        color: colorScheme.primaryContainer,
                        onColor: colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      _StyleElement(
                        icon: Icons.colorize,
                        color: colorScheme.secondaryContainer,
                        onColor: colorScheme.onSecondaryContainer,
                      ),
                    ],
                  ),
                ),
                
                // Central heart representing personalization
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: colorScheme.tertiary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.tertiary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.favorite,
                    size: 40,
                    color: colorScheme.onTertiary,
                  ),
                ),
                
                Positioned(
                  bottom: 30,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _StyleElement(
                        icon: Icons.star,
                        color: colorScheme.tertiaryContainer,
                        onColor: colorScheme.onTertiaryContainer,
                      ),
                      const SizedBox(width: 8),
                      _StyleElement(
                        icon: Icons.auto_awesome,
                        color: colorScheme.primaryContainer,
                        onColor: colorScheme.onPrimaryContainer,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Main title
          Text(
            'Let\'s find your style with personalized combinations.',
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
            'Ready to transform your wardrobe experience? Create your account and let Aura curate your perfect style journey.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Benefits summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                _BenefitItem(
                  icon: Icons.person_search,
                  text: 'Personalized recommendations',
                  colorScheme: colorScheme,
                  theme: theme,
                ),
                const SizedBox(height: 12),
                _BenefitItem(
                  icon: Icons.psychology,
                  text: 'AI-powered style insights',
                  colorScheme: colorScheme,
                  theme: theme,
                ),
                const SizedBox(height: 12),
                _BenefitItem(
                  icon: Icons.timeline,
                  text: 'Continuous style evolution',
                  colorScheme: colorScheme,
                  theme: theme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StyleElement extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color onColor;

  const _StyleElement({
    required this.icon,
    required this.color,
    required this.onColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        icon,
        size: 16,
        color: onColor,
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _BenefitItem({
    required this.icon,
    required this.text,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: colorScheme.tertiary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
