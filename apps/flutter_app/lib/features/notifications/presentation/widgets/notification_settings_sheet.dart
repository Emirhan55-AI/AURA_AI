import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings sheet for notification preferences
class NotificationSettingsSheet extends ConsumerStatefulWidget {
  const NotificationSettingsSheet({super.key});

  @override
  ConsumerState<NotificationSettingsSheet> createState() => _NotificationSettingsSheetState();
}

class _NotificationSettingsSheetState extends ConsumerState<NotificationSettingsSheet> {
  // Local settings state
  bool _pushNotificationsEnabled = true;
  bool _inAppNotificationsEnabled = true;
  bool _emailNotificationsEnabled = false;
  
  // Category settings
  bool _socialNotifications = true;
  bool _systemNotifications = true;
  bool _swapNotifications = true;
  bool _wardrobeNotifications = true;
  bool _challengeNotifications = true;
  bool _messageNotifications = true;
  
  // Advanced settings
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _groupSimilarNotifications = true;
  
  // Quiet hours
  TimeOfDay? _quietHoursStart;
  TimeOfDay? _quietHoursEnd;
  Set<int> _quietDays = {};

  @override
  void initState() {
    super.initState();
    // Initialize with default values
    _quietHoursStart = const TimeOfDay(hour: 22, minute: 0);
    _quietHoursEnd = const TimeOfDay(hour: 8, minute: 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.tune,
                  color: colorScheme.onSurface,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Notification Settings',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Settings content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Global Settings
                  _buildSectionTitle('General', theme),
                  const SizedBox(height: 8),
                  _buildGlobalSettings(colorScheme),
                  
                  const SizedBox(height: 24),
                  
                  // Category Settings
                  _buildSectionTitle('Categories', theme),
                  const SizedBox(height: 8),
                  _buildCategorySettings(colorScheme),
                  
                  const SizedBox(height: 24),
                  
                  // Advanced Settings
                  _buildSectionTitle('Advanced', theme),
                  const SizedBox(height: 8),
                  _buildAdvancedSettings(colorScheme),
                  
                  const SizedBox(height: 24),
                  
                  // Quiet Hours
                  _buildSectionTitle('Quiet Hours', theme),
                  const SizedBox(height: 8),
                  _buildQuietHoursSettings(context, colorScheme),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          
          // Action buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _saveSettings,
                    child: const Text('Save Settings'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildGlobalSettings(ColorScheme colorScheme) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Push Notifications'),
          subtitle: const Text('Receive notifications even when app is closed'),
          value: _pushNotificationsEnabled,
          onChanged: (value) {
            setState(() {
              _pushNotificationsEnabled = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('In-App Notifications'),
          subtitle: const Text('Show notifications while using the app'),
          value: _inAppNotificationsEnabled,
          onChanged: (value) {
            setState(() {
              _inAppNotificationsEnabled = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Email Notifications'),
          subtitle: const Text('Receive important updates via email'),
          value: _emailNotificationsEnabled,
          onChanged: (value) {
            setState(() {
              _emailNotificationsEnabled = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCategorySettings(ColorScheme colorScheme) {
    return Column(
      children: [
        _buildCategoryTile(
          title: 'Social',
          subtitle: 'Likes, comments, follows',
          icon: Icons.people,
          value: _socialNotifications,
          onChanged: (value) => setState(() => _socialNotifications = value),
        ),
        _buildCategoryTile(
          title: 'System',
          subtitle: 'App updates, maintenance',
          icon: Icons.settings,
          value: _systemNotifications,
          onChanged: (value) => setState(() => _systemNotifications = value),
        ),
        _buildCategoryTile(
          title: 'Swap Market',
          subtitle: 'Swap requests, matches',
          icon: Icons.swap_horiz,
          value: _swapNotifications,
          onChanged: (value) => setState(() => _swapNotifications = value),
        ),
        _buildCategoryTile(
          title: 'Wardrobe',
          subtitle: 'Outfit suggestions, reminders',
          icon: Icons.checkroom,
          value: _wardrobeNotifications,
          onChanged: (value) => setState(() => _wardrobeNotifications = value),
        ),
        _buildCategoryTile(
          title: 'Challenges',
          subtitle: 'Style challenges, competitions',
          icon: Icons.star,
          value: _challengeNotifications,
          onChanged: (value) => setState(() => _challengeNotifications = value),
        ),
        _buildCategoryTile(
          title: 'Messages',
          subtitle: 'Direct messages, chats',
          icon: Icons.message,
          value: _messageNotifications,
          onChanged: (value) => setState(() => _messageNotifications = value),
        ),
      ],
    );
  }

  Widget _buildCategoryTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildAdvancedSettings(ColorScheme colorScheme) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Sound'),
          subtitle: const Text('Play sound for notifications'),
          value: _soundEnabled,
          onChanged: (value) {
            setState(() {
              _soundEnabled = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Vibration'),
          subtitle: const Text('Vibrate for notifications'),
          value: _vibrationEnabled,
          onChanged: (value) {
            setState(() {
              _vibrationEnabled = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Group Similar'),
          subtitle: const Text('Bundle similar notifications together'),
          value: _groupSimilarNotifications,
          onChanged: (value) {
            setState(() {
              _groupSimilarNotifications = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildQuietHoursSettings(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.bedtime),
          title: const Text('Start Time'),
          subtitle: Text(_quietHoursStart?.format(context) ?? 'Not set'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _selectQuietHourTime(context, true),
        ),
        ListTile(
          leading: const Icon(Icons.wb_sunny),
          title: const Text('End Time'),
          subtitle: Text(_quietHoursEnd?.format(context) ?? 'Not set'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _selectQuietHourTime(context, false),
        ),
        const SizedBox(height: 16),
        Text(
          'Quiet Days',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _buildQuietDaysSelector(colorScheme),
      ],
    );
  }

  Widget _buildQuietDaysSelector(ColorScheme colorScheme) {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    
    return Wrap(
      spacing: 8,
      children: List.generate(7, (index) {
        final isSelected = _quietDays.contains(index);
        return FilterChip(
          label: Text(days[index]),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _quietDays.add(index);
              } else {
                _quietDays.remove(index);
              }
            });
          },
        );
      }),
    );
  }

  Future<void> _selectQuietHourTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime 
          ? (_quietHoursStart ?? const TimeOfDay(hour: 22, minute: 0))
          : (_quietHoursEnd ?? const TimeOfDay(hour: 8, minute: 0)),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _quietHoursStart = picked;
        } else {
          _quietHoursEnd = picked;
        }
      });
    }
  }

  void _saveSettings() {
    // Here you would typically call a service to save the settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification settings saved'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop();
  }
}
