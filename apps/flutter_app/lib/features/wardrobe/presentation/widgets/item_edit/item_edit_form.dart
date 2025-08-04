import 'package:flutter/material.dart';
import '../../../domain/entities/clothing_item.dart';

/// Widget containing the editable form fields for a clothing item
/// Handles all item properties like name, category, color, tags, etc.
class ItemEditForm extends StatefulWidget {
  final ClothingItem item;
  final String? nameError;
  final String? categoryError;
  final String? colorError;
  final ValueChanged<String>? onNameChanged;
  final ValueChanged<String>? onDescriptionChanged;
  final ValueChanged<String>? onCategoryChanged;
  final ValueChanged<String>? onColorChanged;
  final ValueChanged<String>? onBrandChanged;
  final ValueChanged<String>? onSizeChanged;
  final ValueChanged<Set<String>>? onSeasonsChanged;
  final ValueChanged<List<String>>? onTagsChanged;

  const ItemEditForm({
    super.key,
    required this.item,
    this.nameError,
    this.categoryError,
    this.colorError,
    this.onNameChanged,
    this.onDescriptionChanged,
    this.onCategoryChanged,
    this.onColorChanged,
    this.onBrandChanged,
    this.onSizeChanged,
    this.onSeasonsChanged,
    this.onTagsChanged,
  });

  @override
  State<ItemEditForm> createState() => _ItemEditFormState();
}

class _ItemEditFormState extends State<ItemEditForm> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _brandController;
  late TextEditingController _sizeController;
  late TextEditingController _tagController;
  
  String? _selectedCategory;
  String? _selectedColor;
  Set<String> _selectedSeasons = {};
  List<String> _tags = [];

  // Available options
  final List<String> _categories = [
    'Tops',
    'Bottoms',
    'Outerwear',
    'Dresses',
    'Shoes',
    'Accessories',
    'Undergarments',
    'Swimwear',
    'Sleepwear',
    'Activewear',
  ];

  final List<Map<String, dynamic>> _colors = [
    {'name': 'Black', 'value': Colors.black},
    {'name': 'White', 'value': Colors.white},
    {'name': 'Gray', 'value': Colors.grey},
    {'name': 'Red', 'value': Colors.red},
    {'name': 'Blue', 'value': Colors.blue},
    {'name': 'Green', 'value': Colors.green},
    {'name': 'Yellow', 'value': Colors.yellow},
    {'name': 'Orange', 'value': Colors.orange},
    {'name': 'Purple', 'value': Colors.purple},
    {'name': 'Pink', 'value': Colors.pink},
    {'name': 'Brown', 'value': Colors.brown},
    {'name': 'Navy', 'value': Colors.indigo},
    {'name': 'Beige', 'value': const Color(0xFFF5F5DC)},
  ];

  final List<Map<String, dynamic>> _seasons = [
    {'name': 'Spring', 'icon': Icons.local_florist},
    {'name': 'Summer', 'icon': Icons.wb_sunny},
    {'name': 'Autumn', 'icon': Icons.eco},
    {'name': 'Winter', 'icon': Icons.ac_unit},
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.item.name);
    _descriptionController = TextEditingController(text: widget.item.notes ?? '');
    _brandController = TextEditingController(text: widget.item.brand ?? '');
    _sizeController = TextEditingController(text: widget.item.size ?? '');
    _tagController = TextEditingController();
    
    _selectedCategory = widget.item.category;
    _selectedColor = widget.item.color;
    _tags = List<String>.from(widget.item.tags ?? []);
    
    // For simplicity, we'll extract seasons from tags if they exist
    // In a real implementation, this might be a separate field
    _selectedSeasons = _tags.where((tag) => 
      ['Spring', 'Summer', 'Autumn', 'Winter'].contains(tag)
    ).toSet();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _brandController.dispose();
    _sizeController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Item Details',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Item Name Field
            _buildTextField(
              controller: _nameController,
              label: 'Item Name',
              hint: 'Enter item name',
              required: true,
              errorText: widget.nameError,
              onChanged: widget.onNameChanged,
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            _buildCategoryDropdown(theme, colorScheme),
            const SizedBox(height: 16),

            // Color Selection
            _buildColorSelection(theme, colorScheme),
            const SizedBox(height: 16),

            // Brand and Size Row
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _brandController,
                    label: 'Brand',
                    hint: 'Enter brand',
                    onChanged: widget.onBrandChanged,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _sizeController,
                    label: 'Size',
                    hint: 'Enter size',
                    onChanged: widget.onSizeChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Season Selection
            _buildSeasonSelection(theme, colorScheme),
            const SizedBox(height: 16),

            // Description Field
            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Add notes about this item',
              maxLines: 3,
              onChanged: widget.onDescriptionChanged,
            ),
            const SizedBox(height: 16),

            // Tags Section
            _buildTagsSection(theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool required = false,
    String? errorText,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        errorText: errorText,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      textCapitalization: TextCapitalization.words,
      onChanged: onChanged,
    );
  }

  Widget _buildCategoryDropdown(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category *',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: InputDecoration(
            hintText: 'Select category',
            errorText: widget.categoryError,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: _categories.map((category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
            if (value != null) {
              widget.onCategoryChanged?.call(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildColorSelection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (widget.colorError != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.colorError!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _colors.map((colorData) {
            final colorName = colorData['name'] as String;
            final colorValue = colorData['value'] as Color;
            final isSelected = _selectedColor == colorName;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = colorName;
                });
                widget.onColorChanged?.call(colorName);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorValue,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outline.withValues(alpha: 0.3),
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: _getContrastColor(colorValue),
                        size: 20,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSeasonSelection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seasons',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _seasons.map((seasonData) {
            final seasonName = seasonData['name'] as String;
            final seasonIcon = seasonData['icon'] as IconData;
            final isSelected = _selectedSeasons.contains(seasonName);

            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    seasonIcon,
                    size: 16,
                    color: isSelected 
                        ? colorScheme.onSecondaryContainer 
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(seasonName),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedSeasons.add(seasonName);
                  } else {
                    _selectedSeasons.remove(seasonName);
                  }
                });
                widget.onSeasonsChanged?.call(_selectedSeasons);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTagsSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        
        // Tag input field
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                decoration: const InputDecoration(
                  hintText: 'Add a tag',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                textCapitalization: TextCapitalization.words,
                onSubmitted: _addTag,
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: () => _addTag(_tagController.text),
              icon: const Icon(Icons.add),
              tooltip: 'Add Tag',
            ),
          ],
        ),
        
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) {
              return InputChip(
                label: Text(tag),
                onDeleted: () => _removeTag(tag),
                deleteIcon: const Icon(Icons.close, size: 18),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  void _addTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty && !_tags.contains(trimmedTag)) {
      setState(() {
        _tags.add(trimmedTag);
        _tagController.clear();
      });
      widget.onTagsChanged?.call(_tags);
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
    widget.onTagsChanged?.call(_tags);
  }

  Color _getContrastColor(Color color) {
    // Simple contrast calculation
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
