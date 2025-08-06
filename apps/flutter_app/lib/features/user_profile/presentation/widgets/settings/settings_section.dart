import 'package:flutter/material.dart';

/// SettingsSection - Groups related settings under a common section title
/// 
/// This widget provides a visual grouping for related settings tiles
/// with a section title and proper spacing.
class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> tiles;
  final EdgeInsets? padding;
  final bool showDivider;

  const SettingsSection({
    super.key,
    required this.title,
    required this.tiles,
    this.padding,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          
          // Settings Tiles
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ...tiles.asMap().entries.map((entry) {
                  final index = entry.key;
                  final tile = entry.value;
                  
                  return Column(
                    children: [
                      tile,
                      if (showDivider && index < tiles.length - 1)
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          indent: 16,
                          endIndent: 16,
                          color: colorScheme.outline.withOpacity(0.2),
                        ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
