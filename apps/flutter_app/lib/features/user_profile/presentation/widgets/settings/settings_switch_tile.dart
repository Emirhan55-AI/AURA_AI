import 'package:flutter/material.dart';
import 'settings_tile.dart';

/// SettingsSwitchTile - Specialized tile for boolean settings with a switch
/// 
/// This widget extends SettingsTile to provide a switch control
/// for toggling boolean settings on and off.
class SettingsSwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;
  final EdgeInsets? contentPadding;

  const SettingsSwitchTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    required this.value,
    this.onChanged,
    this.enabled = true,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SettingsTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      enabled: enabled,
      contentPadding: contentPadding,
      trailing: Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
        activeColor: colorScheme.primary,
        inactiveThumbColor: colorScheme.outline,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onTap: enabled && onChanged != null
          ? () => onChanged!(!value)
          : null,
    );
  }
}
