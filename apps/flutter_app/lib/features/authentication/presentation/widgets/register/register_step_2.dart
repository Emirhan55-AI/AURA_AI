import 'package:flutter/material.dart';
import 'style_preferences_widget.dart';

/// RegisterStep2 - Style preferences collection
/// 
/// This widget handles the second step of registration:
/// - Style preference selection
/// - Interest areas
/// - Fashion goals
class RegisterStep2 extends StatefulWidget {
  final Map<String, dynamic> formData;
  final void Function(Map<String, dynamic>) onDataChanged;
  final VoidCallback onNext;

  const RegisterStep2({
    super.key,
    required this.formData,
    required this.onDataChanged,
    required this.onNext,
  });

  @override
  State<RegisterStep2> createState() => _RegisterStep2State();
}

class _RegisterStep2State extends State<RegisterStep2> {
  late List<String> _selectedPreferences;

  @override
  void initState() {
    super.initState();
    _selectedPreferences = List<String>.from(
      (widget.formData['stylePreferences'] as List<dynamic>?) ?? [],
    );
  }

  void _updateFormData() {
    widget.onDataChanged({
      'stylePreferences': _selectedPreferences,
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome text
          Text(
            'What\'s Your Style?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select your favorite styles to get personalized recommendations',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),

          // Style Preferences Widget
          StylePreferencesWidget(
            selectedPreferences: _selectedPreferences,
            onPreferencesChanged: (updatedPreferences) {
              setState(() {
                _selectedPreferences = updatedPreferences;
              });
              _updateFormData();
            },
          ),

          const SizedBox(height: 32),

          // Continue Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _selectedPreferences.isNotEmpty ? widget.onNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Continue (${_selectedPreferences.length} selected)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Style preference data model
class StylePreference {
  final String id;
  final String title;
  final IconData icon;
  final String description;

  const StylePreference(this.id, this.title, this.icon, this.description);
}
