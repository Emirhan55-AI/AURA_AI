// Privacy Consent Screen
// Implements GDPR-compliant consent collection interface
// Provides granular consent options and clear privacy policy access

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/privacy_service.dart';

class PrivacyConsentScreen extends ConsumerStatefulWidget {
  const PrivacyConsentScreen({super.key});

  @override
  ConsumerState<PrivacyConsentScreen> createState() => _PrivacyConsentScreenState();
}

class _PrivacyConsentScreenState extends ConsumerState<PrivacyConsentScreen> {
  bool _necessary = true; // Always required
  bool _functional = false;
  bool _analytics = false;
  bool _marketing = false;
  bool _hasReadPrivacyPolicy = false;

  @override
  void initState() {
    super.initState();
    _checkExistingConsent();
  }

  Future<void> _checkExistingConsent() async {
    final privacyService = ref.read(privacyServiceProvider);
    final existingConsent = await privacyService.getConsent();
    
    if (existingConsent != null) {
      setState(() {
        _functional = existingConsent.functional;
        _analytics = existingConsent.analytics;
        _marketing = existingConsent.marketing;
      });
    }
  }

  Future<void> _saveConsent() async {
    if (!_hasReadPrivacyPolicy) {
      _showPrivacyPolicyDialog();
      return;
    }

    final consent = PrivacyConsent(
      necessary: _necessary,
      functional: _functional,
      analytics: _analytics,
      marketing: _marketing,
      consentDate: DateTime.now(),
      version: '1.0.0',
    );

    try {
      await ref.read(privacyControllerProvider.notifier).giveInitialConsent(consent);
      
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save consent: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => PrivacyPolicyDialog(
        onAccepted: () {
          setState(() {
            _hasReadPrivacyPolicy = true;
          });
          Navigator.of(context).pop();
          _saveConsent();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final privacyState = ref.watch(privacyControllerProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: privacyState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Privacy Matters',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'We respect your privacy and want to be transparent about how we use your data. Please review and customize your privacy preferences below.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 32),
                  
                  // Necessary Cookies (Always Required)
                  ConsentTile(
                    title: 'Necessary',
                    subtitle: 'Required for basic app functionality and security',
                    value: _necessary,
                    enabled: false, // Cannot be disabled
                    onChanged: null,
                    icon: Icons.security,
                    iconColor: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  
                  // Functional Preferences
                  ConsentTile(
                    title: 'Functional',
                    subtitle: 'Remembers your preferences and settings',
                    value: _functional,
                    onChanged: (value) => setState(() => _functional = value),
                    icon: Icons.settings,
                    iconColor: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  
                  // Analytics
                  ConsentTile(
                    title: 'Analytics',
                    subtitle: 'Helps us understand how you use the app to improve it',
                    value: _analytics,
                    onChanged: (value) => setState(() => _analytics = value),
                    icon: Icons.analytics,
                    iconColor: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  
                  // Marketing
                  ConsentTile(
                    title: 'Marketing',
                    subtitle: 'Personalized recommendations and promotional content',
                    value: _marketing,
                    onChanged: (value) => setState(() => _marketing = value),
                    icon: Icons.campaign,
                    iconColor: Colors.orange,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Privacy Policy Link
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.policy, color: Theme.of(context).primaryColor),
                              const SizedBox(width: 8),
                              Text(
                                'Privacy Policy',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Please read our privacy policy to understand how we collect, use, and protect your personal information.',
                          ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: _showPrivacyPolicyDialog,
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('Read Privacy Policy'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.go('/onboarding'),
                          child: const Text('Back'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _hasReadPrivacyPolicy ? _saveConsent : _showPrivacyPolicyDialog,
                          child: Text(_hasReadPrivacyPolicy ? 'Save Preferences' : 'Accept & Continue'),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  if (!_hasReadPrivacyPolicy)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info, color: Colors.amber),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Please read the privacy policy before continuing.',
                              style: TextStyle(color: Colors.amber),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class ConsentTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool>? onChanged;
  final IconData icon;
  final Color iconColor;

  const ConsentTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    this.enabled = true,
    required this.onChanged,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: enabled ? onChanged : null,
            ),
          ],
        ),
      ),
    );
  }
}

class PrivacyPolicyDialog extends ConsumerWidget {
  final VoidCallback onAccepted;

  const PrivacyPolicyDialog({
    super.key,
    required this.onAccepted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.policy, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Privacy Policy',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: FutureBuilder<String>(
                  future: ref.read(privacyServiceProvider).getPrivacyPolicyText(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (snapshot.hasError) {
                      return Text('Error loading privacy policy: ${snapshot.error}');
                    }
                    
                    return Text(
                      snapshot.data ?? 'Privacy policy not available',
                      style: Theme.of(context).textTheme.bodyMedium,
                    );
                  },
                ),
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onAccepted,
                  child: const Text('I Understand'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
