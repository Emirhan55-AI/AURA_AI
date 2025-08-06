import 'package:flutter/material.dart';
import '../../../../core/ui/system_state_widget.dart';
import '../widgets/settings/settings_section.dart';
import '../widgets/settings/settings_tile.dart';
import '../widgets/settings/settings_switch_tile.dart';
import '../widgets/settings/settings_list_tile.dart';
import '../widgets/settings/settings_slider_tile.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

/// SettingsScreen - Screen for managing app settings and user preferences
/// 
/// This screen provides a comprehensive interface for users to manage:
/// - Account settings and profile preferences
/// - Notification and privacy controls
/// - App preferences and customization options
/// - Legal documents and app information
/// 
/// Features:
/// - Organized sections for different setting categories
/// - Multiple tile types for different setting interactions
/// - Material 3 design with consistent theming
/// - Responsive layout for different screen sizes
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Mock state for demonstration - will be replaced with real state management
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _inAppSounds = true;
  bool _vibration = true;
  bool _dataAnalytics = false;
  bool _adPersonalization = false;
  bool _locationAccess = true;
  bool _twoFactorAuth = false;
  double _notificationVolume = 0.7;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'System';
  String _selectedUnits = 'Metric';
  
  bool _isLoading = false;
  bool _hasError = false;

  void _showFeatureComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showLanguageSelection() {
    showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', 'Spanish', 'French', 'German', 'Turkish']
              .map((language) => RadioListTile<String>(
                    title: Text(language),
                    value: language,
                    groupValue: _selectedLanguage,
                    onChanged: (value) {
                      setState(() {
                        _selectedLanguage = value!;
                      });
                      Navigator.of(context).pop();
                    },
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showThemeSelection() {
    showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Light', 'Dark', 'System']
              .map((theme) => RadioListTile<String>(
                    title: Text(theme),
                    value: theme,
                    groupValue: _selectedTheme,
                    onChanged: (value) {
                      setState(() {
                        _selectedTheme = value!;
                      });
                      Navigator.of(context).pop();
                    },
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showUnitsSelection() {
    showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Units'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Metric', 'Imperial']
              .map((unit) => RadioListTile<String>(
                    title: Text(unit),
                    value: unit,
                    groupValue: _selectedUnits,
                    onChanged: (value) {
                      setState(() {
                        _selectedUnits = value!;
                      });
                      Navigator.of(context).pop();
                    },
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showFeatureComingSoon('Logout');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountConfirmation() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and will permanently delete all your data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showFeatureComingSoon('Delete Account');
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        elevation: 0,
        title: Text(
          'Settings',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            fontFamily: 'Urbanist',
          ),
        ),
        centerTitle: false,
      ),
      body: _buildContent(context, theme, colorScheme),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading Settings...'),
          ],
        ),
      );
    }

    if (_hasError) {
      return SystemStateWidget(
        title: 'Failed to Load Settings',
        message: 'Please check your connection and try again.',
        icon: Icons.error_outline,
        onRetry: () {
          setState(() {
            _hasError = false;
            _isLoading = true;
          });
          // Simulate loading
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          });
        },
        retryText: 'Try Again',
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Account Section
          SettingsSection(
            title: 'Account',
            tiles: [
              SettingsListTile(
                title: 'Edit Profile',
                subtitle: 'Update your profile information',
                leading: const Icon(Icons.person_outline),
                onTap: () => _showFeatureComingSoon('Edit Profile'),
              ),
              SettingsListTile(
                title: 'Change Password',
                subtitle: 'Update your account password',
                leading: const Icon(Icons.lock_outline),
                onTap: () => _showFeatureComingSoon('Change Password'),
              ),
              SettingsSwitchTile(
                title: 'Two-Factor Authentication',
                subtitle: 'Add an extra layer of security',
                leading: const Icon(Icons.security),
                value: _twoFactorAuth,
                onChanged: (value) {
                  setState(() {
                    _twoFactorAuth = value;
                  });
                  _showFeatureComingSoon('Two-Factor Authentication');
                },
              ),
              SettingsListTile(
                title: 'Linked Accounts',
                subtitle: 'Manage connected social accounts',
                leading: const Icon(Icons.link),
                onTap: () => _showFeatureComingSoon('Linked Accounts'),
              ),
            ],
          ),

          // Notifications Section
          SettingsSection(
            title: 'Notifications',
            tiles: [
              SettingsSwitchTile(
                title: 'Push Notifications',
                subtitle: 'Receive notifications on your device',
                leading: const Icon(Icons.notifications_outlined),
                value: _pushNotifications,
                onChanged: (value) {
                  setState(() {
                    _pushNotifications = value;
                  });
                },
              ),
              SettingsSwitchTile(
                title: 'Email Notifications',
                subtitle: 'Receive notifications via email',
                leading: const Icon(Icons.email_outlined),
                value: _emailNotifications,
                onChanged: (value) {
                  setState(() {
                    _emailNotifications = value;
                  });
                },
              ),
              SettingsSwitchTile(
                title: 'In-App Sounds',
                subtitle: 'Play sounds for in-app actions',
                leading: const Icon(Icons.volume_up_outlined),
                value: _inAppSounds,
                onChanged: (value) {
                  setState(() {
                    _inAppSounds = value;
                  });
                },
              ),
              SettingsSliderTile(
                title: 'Notification Volume',
                subtitle: 'Adjust notification sound volume',
                leading: const Icon(Icons.volume_down_outlined),
                value: _notificationVolume,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                onChanged: (value) {
                  setState(() {
                    _notificationVolume = value;
                  });
                },
                valueFormatter: (value) => '${(value * 100).round()}%',
              ),
              SettingsSwitchTile(
                title: 'Vibration',
                subtitle: 'Enable haptic feedback',
                leading: const Icon(Icons.vibration),
                value: _vibration,
                onChanged: (value) {
                  setState(() {
                    _vibration = value;
                  });
                },
              ),
            ],
          ),

          // Privacy Section
          SettingsSection(
            title: 'Privacy & Security',
            tiles: [
              SettingsListTile(
                title: 'Privacy Policy',
                subtitle: 'View our privacy policy',
                leading: const Icon(Icons.privacy_tip_outlined),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
              ),
              SettingsSwitchTile(
                title: 'Data & Analytics',
                subtitle: 'Help improve the app with usage data',
                leading: const Icon(Icons.analytics_outlined),
                value: _dataAnalytics,
                onChanged: (value) {
                  setState(() {
                    _dataAnalytics = value;
                  });
                },
              ),
              SettingsSwitchTile(
                title: 'Ad Personalization',
                subtitle: 'Show personalized advertisements',
                leading: const Icon(Icons.ads_click_outlined),
                value: _adPersonalization,
                onChanged: (value) {
                  setState(() {
                    _adPersonalization = value;
                  });
                },
              ),
              SettingsSwitchTile(
                title: 'Location Access',
                subtitle: 'Allow app to access your location',
                leading: const Icon(Icons.location_on_outlined),
                value: _locationAccess,
                onChanged: (value) {
                  setState(() {
                    _locationAccess = value;
                  });
                },
              ),
            ],
          ),

          // App Preferences Section
          SettingsSection(
            title: 'App Preferences',
            tiles: [
              SettingsListTile(
                title: 'Language',
                subtitle: 'Select your preferred language',
                leading: const Icon(Icons.language_outlined),
                value: _selectedLanguage,
                onTap: _showLanguageSelection,
              ),
              SettingsListTile(
                title: 'Theme',
                subtitle: 'Choose your preferred theme',
                leading: const Icon(Icons.palette_outlined),
                value: _selectedTheme,
                onTap: _showThemeSelection,
              ),
              SettingsListTile(
                title: 'Units',
                subtitle: 'Measurement system preference',
                leading: const Icon(Icons.straighten_outlined),
                value: _selectedUnits,
                onTap: _showUnitsSelection,
              ),
              SettingsListTile(
                title: 'Default Location',
                subtitle: 'Set your default location',
                leading: const Icon(Icons.place_outlined),
                onTap: () => _showFeatureComingSoon('Default Location'),
              ),
            ],
          ),

          // About Section
          SettingsSection(
            title: 'About',
            tiles: [
              SettingsListTile(
                title: 'About Aura',
                subtitle: 'Learn more about the app',
                leading: const Icon(Icons.info_outline),
                onTap: () => _showFeatureComingSoon('About Aura'),
              ),
              SettingsListTile(
                title: 'Terms of Service',
                subtitle: 'View our terms of service',
                leading: const Icon(Icons.description_outlined),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const TermsOfServiceScreen(),
                    ),
                  );
                },
              ),
              SettingsListTile(
                title: 'Open Source Licenses',
                subtitle: 'View third-party licenses',
                leading: const Icon(Icons.code_outlined),
                onTap: () => _showFeatureComingSoon('Open Source Licenses'),
              ),
              SettingsListTile(
                title: 'Version Info',
                subtitle: 'App version and build information',
                leading: const Icon(Icons.system_update_outlined),
                value: '1.0.0',
                showArrow: false,
                onTap: () => _showFeatureComingSoon('Version Info'),
              ),
              SettingsListTile(
                title: 'Contact Us',
                subtitle: 'Get in touch with support',
                leading: const Icon(Icons.contact_support_outlined),
                onTap: () => _showFeatureComingSoon('Contact Us'),
              ),
              SettingsListTile(
                title: 'Rate the App',
                subtitle: 'Leave a review on the app store',
                leading: const Icon(Icons.star_outline),
                onTap: () => _showFeatureComingSoon('Rate the App'),
              ),
            ],
          ),

          // Danger Zone Section
          SettingsSection(
            title: 'Account Actions',
            tiles: [
              SettingsTile(
                title: 'Logout',
                subtitle: 'Sign out of your account',
                leading: Icon(
                  Icons.logout,
                  color: colorScheme.error,
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: colorScheme.error,
                ),
                onTap: _showLogoutConfirmation,
              ),
              SettingsTile(
                title: 'Delete Account',
                subtitle: 'Permanently delete your account and data',
                leading: Icon(
                  Icons.delete_forever,
                  color: colorScheme.error,
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: colorScheme.error,
                ),
                onTap: _showDeleteAccountConfirmation,
              ),
            ],
          ),

          // Bottom padding
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
