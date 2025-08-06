import 'package:flutter/material.dart';

/// SettingsTile - Base widget for individual setting options
/// 
/// This widget provides a consistent interface for settings items
/// with support for icons, titles, subtitles, and custom trailing widgets.
class SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;
  final EdgeInsets? contentPadding;
  final Color? titleColor;

  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.contentPadding,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: titleColor ?? (enabled ? colorScheme.onSurface : colorScheme.onSurface.withOpacity(0.6)),
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: enabled 
                    ? colorScheme.onSurfaceVariant 
                    : colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
            )
          : null,
      leading: leading != null
          ? IconTheme(
              data: IconThemeData(
                color: enabled ? colorScheme.onSurfaceVariant : colorScheme.onSurfaceVariant.withOpacity(0.6),
                size: 24,
              ),
              child: leading!,
            )
          : null,
      trailing: trailing,
      onTap: enabled ? onTap : null,
      contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enableFeedback: enabled,
    );
  }
}
