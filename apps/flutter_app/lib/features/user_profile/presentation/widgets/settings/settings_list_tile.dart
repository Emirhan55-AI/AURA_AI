import 'package:flutter/material.dart';
import 'settings_tile.dart';

/// SettingsListTile - Specialized tile that navigates to detail screens or options
/// 
/// This widget extends SettingsTile to provide navigation indicators
/// and handles tiles that open detail screens or selection dialogs.
class SettingsListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? value; // Current selected value to display
  final Widget? leading;
  final VoidCallback? onTap;
  final bool enabled;
  final bool showArrow;
  final EdgeInsets? contentPadding;
  final Color? titleColor;

  const SettingsListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.value,
    this.leading,
    this.onTap,
    this.enabled = true,
    this.showArrow = true,
    this.contentPadding,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget? trailingWidget;
    
    if (value != null || showArrow) {
      trailingWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null) ...[
            Text(
              value!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: enabled 
                    ? colorScheme.onSurfaceVariant 
                    : colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (showArrow)
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: enabled 
                  ? colorScheme.onSurfaceVariant 
                  : colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
        ],
      );
    }

    return SettingsTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: trailingWidget,
      onTap: onTap,
      enabled: enabled,
      contentPadding: contentPadding,
      titleColor: titleColor,
    );
  }
}
