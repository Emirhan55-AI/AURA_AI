import 'package:flutter/material.dart';
import 'onboarding_chat_interface.dart';

/// AnswerOptionWidget - Widget for displaying different types of answer inputs
///
/// This widget renders different UI elements based on the answer type (single choice,
/// multi choice, text input, etc.) to collect user style preferences.
class AnswerOptionWidget extends StatefulWidget {
  /// The type of answer input to display
  final AnswerType answerType;
  
  /// List of options for single/multi-choice questions
  final List<String>? options;
  
  /// Callback when user selects an answer
  final void Function(List<String> answers) onAnswerSelected;
  
  /// Whether the widget is enabled for input
  final bool enabled;

  const AnswerOptionWidget({
    super.key,
    required this.answerType,
    this.options,
    required this.onAnswerSelected,
    this.enabled = true,
  });

  @override
  State<AnswerOptionWidget> createState() => _AnswerOptionWidgetState();
}

class _AnswerOptionWidgetState extends State<AnswerOptionWidget> {
  // For text input
  final TextEditingController _textController = TextEditingController();
  
  // For single/multi choice
  final List<String> _selectedOptions = [];
  
  // For color picker
  String _selectedColor = '';

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    switch (widget.answerType) {
      case AnswerType.textInput:
        return _buildTextInput(theme, colorScheme);
        
      case AnswerType.singleChoice:
        return _buildSingleChoice(theme, colorScheme);
        
      case AnswerType.multiChoice:
        return _buildMultiChoice(theme, colorScheme);
        
      case AnswerType.imageUpload:
        return _buildImageUploadButton(theme, colorScheme);
        
      case AnswerType.colorPicker:
        return _buildColorPicker(theme, colorScheme);
    }
  }

  Widget _buildTextInput(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              enabled: widget.enabled,
              decoration: InputDecoration(
                hintText: 'Type your answer here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, 
                  vertical: 14,
                ),
              ),
              style: theme.textTheme.bodyMedium,
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  widget.onAnswerSelected([value]);
                  _textController.clear();
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            color: colorScheme.primary,
            onPressed: widget.enabled ? () {
              final value = _textController.text.trim();
              if (value.isNotEmpty) {
                widget.onAnswerSelected([value]);
                _textController.clear();
              }
            } : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSingleChoice(ThemeData theme, ColorScheme colorScheme) {
    if (widget.options == null || widget.options!.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: widget.options!.map((option) {
          final isSelected = _selectedOptions.contains(option);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(option),
              selected: isSelected,
              showCheckmark: false,
              onSelected: widget.enabled ? (selected) {
                setState(() {
                  _selectedOptions.clear();
                  if (selected) {
                    _selectedOptions.add(option);
                    widget.onAnswerSelected(_selectedOptions);
                  }
                });
              } : null,
              backgroundColor: colorScheme.surface,
              selectedColor: colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMultiChoice(ThemeData theme, ColorScheme colorScheme) {
    if (widget.options == null || widget.options!.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: widget.options!.map((option) {
              final isSelected = _selectedOptions.contains(option);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: widget.enabled ? (selected) {
                    setState(() {
                      if (selected) {
                        _selectedOptions.add(option);
                      } else {
                        _selectedOptions.remove(option);
                      }
                    });
                  } : null,
                  backgroundColor: colorScheme.surface,
                  selectedColor: colorScheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, right: 16),
          child: Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: widget.enabled && _selectedOptions.isNotEmpty 
                ? () => widget.onAnswerSelected(_selectedOptions)
                : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: const Text('Confirm Choices'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUploadButton(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: widget.enabled ? () {
          // Simulate image upload
          widget.onAnswerSelected(['image_placeholder.jpg']);
        } : null,
        icon: const Icon(Icons.photo_camera),
        label: const Text('Upload Image'),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildColorPicker(ThemeData theme, ColorScheme colorScheme) {
    final colors = [
      {'color': Colors.black, 'name': 'Black'},
      {'color': Colors.white, 'name': 'White'},
      {'color': Colors.grey, 'name': 'Grey'},
      {'color': Colors.blue, 'name': 'Blue'},
      {'color': Colors.red, 'name': 'Red'},
      {'color': Colors.green, 'name': 'Green'},
      {'color': Colors.yellow, 'name': 'Yellow'},
      {'color': Colors.purple, 'name': 'Purple'},
      {'color': Colors.orange, 'name': 'Orange'},
      {'color': Colors.pink, 'name': 'Pink'},
      {'color': Colors.teal, 'name': 'Teal'},
      {'color': Colors.brown, 'name': 'Brown'},
    ];

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: colors.map((colorData) {
              final color = colorData['color'] as Color;
              final name = colorData['name'] as String;
              final isSelected = _selectedColor == name;
              
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: widget.enabled ? () {
                    setState(() {
                      _selectedColor = name;
                      widget.onAnswerSelected([name]);
                    });
                  } : null,
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected 
                                ? colorScheme.primary 
                                : Colors.grey.withOpacity(0.3),
                            width: isSelected ? 3 : 1,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ] : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
