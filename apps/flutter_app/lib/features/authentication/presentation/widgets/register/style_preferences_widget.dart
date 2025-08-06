import 'package:flutter/material.dart';

class StylePreferencesWidget extends StatelessWidget {
  final List<String> selectedPreferences;
  final void Function(List<String>) onPreferencesChanged;

  const StylePreferencesWidget({
    Key? key,
    required this.selectedPreferences,
    required this.onPreferencesChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final availablePreferences = [
      'Casual',
      'Formal',
      'Sporty',
      'Vintage',
      'Bohemian',
      'Chic',
      'Streetwear',
      'Minimalist',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Your Style Preferences',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availablePreferences.map((preference) {
            final isSelected = selectedPreferences.contains(preference);
            return FilterChip(
              label: Text(preference),
              selected: isSelected,
              onSelected: (selected) {
                final updatedPreferences = List<String>.from(selectedPreferences);
                if (selected) {
                  updatedPreferences.add(preference);
                } else {
                  updatedPreferences.remove(preference);
                }
                onPreferencesChanged(updatedPreferences);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
