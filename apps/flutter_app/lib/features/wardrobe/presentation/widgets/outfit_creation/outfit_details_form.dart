import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// OutfitDetailsForm allows users to enter details for their outfit
/// including title, description, tags, occasion, and season.
/// 
/// Features:
/// - Required title field with validation
/// - Optional description field
/// - Tag input with chips
/// - Occasion and season dropdowns
/// - Form validation and visual feedback
class OutfitDetailsForm extends ConsumerStatefulWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final List<String> tags;
  final String? selectedOccasion;
  final String? selectedSeason;
  final void Function(String) onTitleChanged;
  final void Function(String) onDescriptionChanged;
  final void Function(List<String>) onTagsChanged;
  final void Function(String?) onOccasionChanged;
  final void Function(String?) onSeasonChanged;

  const OutfitDetailsForm({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.tags,
    required this.selectedOccasion,
    required this.selectedSeason,
    required this.onTitleChanged,
    required this.onDescriptionChanged,
    required this.onTagsChanged,
    required this.onOccasionChanged,
    required this.onSeasonChanged,
  });

  @override
  ConsumerState<OutfitDetailsForm> createState() => _OutfitDetailsFormState();
}

class _OutfitDetailsFormState extends ConsumerState<OutfitDetailsForm> {
  final _tagController = TextEditingController();
  final _tagFocusNode = FocusNode();

  // Predefined options for dropdowns
  final List<String> _occasions = [
    'Casual',
    'Work',
    'Formal',
    'Party',
    'Date',
    'Sports',
    'Travel',
    'Wedding',
    'Business',
    'Evening',
  ];

  final List<String> _seasons = [
    'Spring',
    'Summer',
    'Fall',
    'Winter',
    'All Year',
  ];

  @override
  void dispose() {
    _tagController.dispose();
    _tagFocusNode.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty && !widget.tags.contains(trimmedTag)) {
      final updatedTags = [...widget.tags, trimmedTag];
      widget.onTagsChanged(updatedTags);
      _tagController.clear();
    }
  }

  void _removeTag(String tag) {
    final updatedTags = widget.tags.where((t) => t != tag).toList();
    widget.onTagsChanged(updatedTags);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text(
          'Outfit Details',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),

        // Title field (required)
        TextFormField(
          controller: widget.titleController,
          decoration: InputDecoration(
            labelText: 'Outfit Title *',
            hintText: 'Enter a name for your outfit',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.title),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter an outfit title';
            }
            if (value.trim().length < 2) {
              return 'Title must be at least 2 characters';
            }
            return null;
          },
          onChanged: widget.onTitleChanged,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),

        // Description field (optional)
        TextFormField(
          controller: widget.descriptionController,
          decoration: InputDecoration(
            labelText: 'Description',
            hintText: 'Describe your outfit or when you\'d wear it',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.description),
          ),
          maxLines: 3,
          onChanged: widget.onDescriptionChanged,
          textInputAction: TextInputAction.newline,
        ),
        const SizedBox(height: 16),

        // Tags section
        Text(
          'Tags',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        // Tag input field
        TextField(
          controller: _tagController,
          focusNode: _tagFocusNode,
          decoration: InputDecoration(
            hintText: 'Add tags (e.g., casual, work, trendy)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.label),
            suffixIcon: IconButton(
              onPressed: () => _addTag(_tagController.text),
              icon: const Icon(Icons.add),
            ),
          ),
          onSubmitted: _addTag,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 8),

        // Display current tags
        if (widget.tags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.tags.map((tag) => 
              Chip(
                label: Text(tag),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => _removeTag(tag),
                backgroundColor: colorScheme.primaryContainer,
                labelStyle: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ).toList(),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.5),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'No tags added yet. Tags help you find and organize your outfits.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        const SizedBox(height: 16),

        // Occasion and Season dropdowns
        Row(
          children: [
            // Occasion dropdown
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Occasion',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: widget.selectedOccasion,
                    decoration: InputDecoration(
                      hintText: 'Select occasion',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.event),
                    ),
                    items: _occasions.map((occasion) =>
                      DropdownMenuItem(
                        value: occasion,
                        child: Text(occasion),
                      ),
                    ).toList(),
                    onChanged: widget.onOccasionChanged,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // Season dropdown
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Season',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: widget.selectedSeason,
                    decoration: InputDecoration(
                      hintText: 'Select season',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.wb_sunny),
                    ),
                    items: _seasons.map((season) =>
                      DropdownMenuItem(
                        value: season,
                        child: Text(season),
                      ),
                    ).toList(),
                    onChanged: widget.onSeasonChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Form validation hint
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Only the outfit title is required. Other details help you organize and find your outfits later.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
