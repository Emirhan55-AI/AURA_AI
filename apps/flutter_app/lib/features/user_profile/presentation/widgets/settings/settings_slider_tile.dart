import 'package:flutter/material.dart';

/// SettingsSliderTile - Specialized tile for numeric value adjustment with a slider
/// 
/// This widget extends SettingsTile to provide a slider control
/// for adjusting numeric values within a specified range.
class SettingsSliderTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double>? onChanged;
  final bool enabled;
  final String Function(double)? valueFormatter;
  final EdgeInsets? contentPadding;

  const SettingsSliderTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    required this.value,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.onChanged,
    this.enabled = true,
    this.valueFormatter,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Leading Icon Row
          Row(
            children: [
              if (leading != null) ...[
                IconTheme(
                  data: IconThemeData(
                    color: enabled 
                        ? colorScheme.onSurfaceVariant 
                        : colorScheme.onSurfaceVariant.withOpacity(0.6),
                    size: 24,
                  ),
                  child: leading!,
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: enabled 
                            ? colorScheme.onSurface 
                            : colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: enabled 
                              ? colorScheme.onSurfaceVariant 
                              : colorScheme.onSurfaceVariant.withOpacity(0.6),
                        ),
                      ),
                  ],
                ),
              ),
              // Current Value Display
              Text(
                valueFormatter?.call(value) ?? value.toStringAsFixed(1),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: enabled 
                      ? colorScheme.primary 
                      : colorScheme.primary.withOpacity(0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: colorScheme.primary,
              inactiveTrackColor: colorScheme.outline.withOpacity(0.3),
              thumbColor: colorScheme.primary,
              overlayColor: colorScheme.primary.withOpacity(0.1),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ],
      ),
    );
  }
}
