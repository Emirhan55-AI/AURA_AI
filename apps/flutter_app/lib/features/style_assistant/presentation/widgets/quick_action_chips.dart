import 'package:flutter/material.dart';

/// Quick Action Chips - Predefined buttons for common style queries
/// 
/// This widget displays a collection of chips representing common questions
/// or actions users might want to perform with the style assistant.
class QuickActionChips extends StatelessWidget {
  final void Function(String) onChipTap;

  const QuickActionChips({
    super.key,
    required this.onChipTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final quickActions = [
      {
        'label': 'What should I wear today?',
        'icon': Icons.wb_sunny_outlined,
      },
      {
        'label': 'Help me create an outfit',
        'icon': Icons.auto_awesome,
      },
      {
        'label': 'Show my style analytics',
        'icon': Icons.analytics_outlined,
      },
      {
        'label': 'Suggest new clothing',
        'icon': Icons.shopping_bag_outlined,
      },
      {
        'label': 'Plan my wardrobe',
        'icon': Icons.calendar_today_outlined,
      },
      {
        'label': 'Style inspiration',
        'icon': Icons.lightbulb_outline,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Try asking me about:',
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickActions.map((action) {
            return _QuickActionChip(
              label: action['label'] as String,
              icon: action['icon'] as IconData,
              onTap: () => onChipTap(action['label'] as String),
              theme: theme,
              colorScheme: colorScheme,
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Individual quick action chip
class _QuickActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _QuickActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(
        icon,
        size: 16,
        color: colorScheme.onSecondaryContainer,
      ),
      label: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: colorScheme.secondaryContainer,
      side: BorderSide(
        color: colorScheme.outline.withOpacity(0.2),
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      visualDensity: VisualDensity.compact,
    );
  }
}
