import 'package:flutter/material.dart';
import '../../domain/models/style_preferences.dart';

class RegisterStep2 extends StatelessWidget {
  final StylePreferences preferences;
  final ValueChanged<StylePreferences> onPreferencesChanged;
  final VoidCallback onNextPressed;

  const RegisterStep2({
    super.key,
    required this.preferences,
    required this.onPreferencesChanged,
    required this.onNextPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Stil Tercihlerini Seç',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildStyleCategories(context),
          const SizedBox(height: 16),
          _buildColorPreferences(context),
          const SizedBox(height: 16),
          _buildOccasions(context),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onNextPressed,
            child: const Text('Devam Et'),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleCategories(BuildContext context) {
    final availableStyles = [
      'Minimalist',
      'Casual',
      'Elegant',
      'Sporty',
      'Vintage',
      'Bohemian',
      'Street Style',
      'Business Casual',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tarz Kategorileri',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableStyles.map((style) {
            final isSelected = preferences.favoriteStyles.contains(style);
            return FilterChip(
              label: Text(style),
              selected: isSelected,
              onSelected: (selected) {
                final newStyles = List<String>.from(preferences.favoriteStyles);
                if (selected) {
                  newStyles.add(style);
                } else {
                  newStyles.remove(style);
                }
                onPreferencesChanged(preferences.copyWith(
                  favoriteStyles: newStyles,
                ));
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorPreferences(BuildContext context) {
    final availableColors = [
      'Black',
      'White',
      'Navy',
      'Beige',
      'Gray',
      'Brown',
      'Red',
      'Blue',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Renk Tercihleri',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableColors.map((color) {
            final isSelected = preferences.favoriteColors.contains(color);
            return FilterChip(
              label: Text(color),
              selected: isSelected,
              onSelected: (selected) {
                final newColors = List<String>.from(preferences.favoriteColors);
                if (selected) {
                  newColors.add(color);
                } else {
                  newColors.remove(color);
                }
                onPreferencesChanged(preferences.copyWith(
                  favoriteColors: newColors,
                ));
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOccasions(BuildContext context) {
    final availableOccasions = [
      'Daily',
      'Work',
      'Party',
      'Sport',
      'Special Occasion',
      'Travel',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kullanım Alanları',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableOccasions.map((occasion) {
            final isSelected = preferences.occasions.contains(occasion);
            return FilterChip(
              label: Text(occasion),
              selected: isSelected,
              onSelected: (selected) {
                final newOccasions = List<String>.from(preferences.occasions);
                if (selected) {
                  newOccasions.add(occasion);
                } else {
                  newOccasions.remove(occasion);
                }
                onPreferencesChanged(preferences.copyWith(
                  occasions: newOccasions,
                ));
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
