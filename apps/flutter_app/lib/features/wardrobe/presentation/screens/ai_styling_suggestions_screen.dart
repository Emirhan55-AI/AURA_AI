import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/generate_styling_suggestions_use_case.dart';
import '../providers/mock_styling_suggestions_providers.dart';

/// Example screen demonstrating AI Styling Suggestions usage
/// This shows how to integrate the AI styling feature into a real screen
class AiStylingSuggestionsScreen extends ConsumerStatefulWidget {
  const AiStylingSuggestionsScreen({super.key});

  @override
  ConsumerState<AiStylingSuggestionsScreen> createState() => _AiStylingSuggestionsScreenState();
}

class _AiStylingSuggestionsScreenState extends ConsumerState<AiStylingSuggestionsScreen> {
  String? selectedOccasion;
  String? selectedSeason;
  bool showOnlyFavorites = false;
  final List<String> selectedStylePreferences = [];

  @override
  Widget build(BuildContext context) {
    final suggestionsState = ref.watch(mockSuggestionsGenerationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Style Suggestions'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            const Text(
              'Get AI-Powered Style Suggestions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Configure your preferences and let our AI create amazing outfit suggestions from your wardrobe.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Filters Section
            _buildFiltersSection(),
            const SizedBox(height: 24),

            // Generate Button
            ElevatedButton(
              onPressed: suggestionsState.isLoading ? null : _generateSuggestions,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: suggestionsState.isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Generating Suggestions...'),
                      ],
                    )
                  : const Text(
                      'Generate AI Suggestions',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
            const SizedBox(height: 24),

            // Results Section
            if (suggestionsState.hasError) _buildErrorSection(suggestionsState.error!),
            if (suggestionsState.suggestions.isNotEmpty) _buildSuggestionsSection(suggestionsState.suggestions),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preferences',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // Occasion Filter
            DropdownButtonFormField<String>(
              value: selectedOccasion,
              decoration: const InputDecoration(
                labelText: 'Occasion',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'casual', child: Text('Casual')),
                DropdownMenuItem(value: 'business', child: Text('Business')),
                DropdownMenuItem(value: 'formal', child: Text('Formal')),
                DropdownMenuItem(value: 'party', child: Text('Party')),
                DropdownMenuItem(value: 'date', child: Text('Date')),
                DropdownMenuItem(value: 'workout', child: Text('Workout')),
              ],
              onChanged: (value) => setState(() => selectedOccasion = value),
            ),
            const SizedBox(height: 16),

            // Season Filter
            DropdownButtonFormField<String>(
              value: selectedSeason,
              decoration: const InputDecoration(
                labelText: 'Season',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'spring', child: Text('Spring')),
                DropdownMenuItem(value: 'summer', child: Text('Summer')),
                DropdownMenuItem(value: 'fall', child: Text('Fall')),
                DropdownMenuItem(value: 'winter', child: Text('Winter')),
              ],
              onChanged: (value) => setState(() => selectedSeason = value),
            ),
            const SizedBox(height: 16),

            // Favorites Only Checkbox
            CheckboxListTile(
              title: const Text('Use only favorite items'),
              subtitle: const Text('Generate suggestions from your favorited wardrobe items'),
              value: showOnlyFavorites,
              onChanged: (value) => setState(() => showOnlyFavorites = value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorSection(String error) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Error',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsSection(List<dynamic> suggestions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI Suggestions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        ...suggestions.map((suggestion) => _buildSuggestionCard(suggestion)).toList(),
      ],
    );
  }

  Widget _buildSuggestionCard(dynamic suggestion) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    suggestion.title ?? 'Untitled Suggestion',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (suggestion.confidenceScore != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(suggestion.confidenceScore * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
              ],
            ),
            if (suggestion.description != null) ...[
              const SizedBox(height: 8),
              Text(
                suggestion.description!,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
            const SizedBox(height: 12),
            if (suggestion.styleTags != null && suggestion.styleTags.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                children: suggestion.styleTags
                    .map<Widget>((tag) => Chip(
                          label: Text(tag),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                if (suggestion.occasion != null)
                  Chip(
                    label: Text(suggestion.occasion!),
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                  ),
                if (suggestion.season != null) ...[
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(suggestion.season!),
                    backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _generateSuggestions() {
    final params = GenerateSuggestionsParams(
      occasion: selectedOccasion,
      seasons: selectedSeason,
      showOnlyFavorites: showOnlyFavorites,
      stylePreferences: selectedStylePreferences,
      maxSuggestions: 5, // Limit to 5 suggestions for demo
    );

    ref.read(mockSuggestionsGenerationProvider.notifier).generateSuggestions(params);
  }
}
