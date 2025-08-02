// Privacy Data Management Screen
// Provides users control over their personal data
// Implements GDPR rights: access, rectification, erasure, portability

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/privacy_service.dart';

class PrivacyDataManagementScreen extends ConsumerStatefulWidget {
  const PrivacyDataManagementScreen({super.key});

  @override
  ConsumerState<PrivacyDataManagementScreen> createState() => _PrivacyDataManagementScreenState();
}

class _PrivacyDataManagementScreenState extends ConsumerState<PrivacyDataManagementScreen> {
  String? _exportedFilePath;
  bool _isExporting = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    // Initialize privacy controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(privacyControllerProvider.notifier).initialize();
    });
  }

  Future<void> _exportData(ExportFormat format) async {
    setState(() {
      _isExporting = true;
    });

    try {
      // In a real app, get actual user ID
      const userId = 'current_user_id';
      await ref.read(privacyControllerProvider.notifier).exportData(userId, format);
      
      final state = ref.read(privacyControllerProvider);
      if (state.exportedFile != null) {
        setState(() {
          _exportedFilePath = state.exportedFile!.path;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Data exported successfully to ${state.exportedFile!.path}'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'View',
                onPressed: () {
                  // In a real app, you could open the file or show path
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('File saved at: ${state.exportedFile!.path}')),
                  );
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  Future<void> _deleteAllData() async {
    final confirmed = await _showDeleteConfirmationDialog();
    if (!confirmed) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      const userId = 'current_user_id';
      await ref.read(privacyControllerProvider.notifier).deleteAllData(userId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data deleted successfully'),
            backgroundColor: Colors.orange,
          ),
        );
        
        // Navigate to onboarding or login
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deletion failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isDeleting = false;
      });
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete All Data'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This action cannot be undone. All your data will be permanently deleted, including:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Personal profile information'),
            Text('• Wardrobe items and photos'),
            Text('• Outfit combinations'),
            Text('• App preferences and settings'),
            Text('• Analytics and usage data'),
            SizedBox(height: 16),
            Text(
              'Are you sure you want to proceed?',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete All Data'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final privacyState = ref.watch(privacyControllerProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Management'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Data Rights',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your personal data and exercise your privacy rights.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),

            // Current Consent Status
            if (privacyState.consent != null) ...[
              _buildConsentStatusCard(privacyState.consent!),
              const SizedBox(height: 24),
            ],

            // Data Export Section
            _buildDataExportSection(),
            const SizedBox(height: 24),

            // Data Correction Section
            _buildDataCorrectionSection(),
            const SizedBox(height: 24),

            // Data Deletion Section
            _buildDataDeletionSection(),
            const SizedBox(height: 24),

            // Privacy Policy Section
            _buildPrivacyPolicySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildConsentStatusCard(PrivacyConsent consent) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.verified_user, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Current Consent Status',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildConsentRow('Necessary', consent.necessary, Colors.red, true),
            _buildConsentRow('Functional', consent.functional, Colors.blue, false),
            _buildConsentRow('Analytics', consent.analytics, Colors.green, false),
            _buildConsentRow('Marketing', consent.marketing, Colors.orange, false),
            const SizedBox(height: 16),
            Text(
              'Last updated: ${_formatDate(consent.consentDate)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/privacy-consent'),
              icon: const Icon(Icons.edit),
              label: const Text('Update Preferences'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsentRow(String title, bool value, Color color, bool required) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: value ? color : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          Text(
            required ? 'Required' : (value ? 'Enabled' : 'Disabled'),
            style: TextStyle(
              color: required ? Colors.red : (value ? Colors.green : Colors.grey),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataExportSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.download, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Export Your Data',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Download a copy of all your personal data stored in the app.',
            ),
            const SizedBox(height: 16),
            if (_exportedFilePath != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Last export: $_exportedFilePath',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isExporting ? null : () => _exportData(ExportFormat.json),
                    icon: _isExporting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.code),
                    label: const Text('JSON'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isExporting ? null : () => _exportData(ExportFormat.csv),
                    icon: _isExporting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.table_chart),
                    label: const Text('CSV'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCorrectionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Correct Your Data',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Request corrections to your personal information if it\'s inaccurate or incomplete.',
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/profile-edit'),
              icon: const Icon(Icons.person_outline),
              label: const Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataDeletionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.delete_forever, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Delete Your Data',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Permanently delete all your personal data and close your account.',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone. All your data will be permanently deleted.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isDeleting ? null : _deleteAllData,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              icon: _isDeleting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.delete_forever),
              label: const Text('Delete All Data'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyPolicySection() {
    return Card(
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
                  'Privacy Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Learn more about how we protect and use your personal information.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed('/privacy-policy'),
                    icon: const Icon(Icons.description),
                    label: const Text('Privacy Policy'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed('/terms-of-service'),
                    icon: const Icon(Icons.gavel),
                    label: const Text('Terms of Service'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
