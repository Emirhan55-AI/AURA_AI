import 'package:flutter/material.dart';
import '../../../controllers/style_discovery_controller.dart';

/// SingleChoiceCard - Single selection interface for style preferences
/// 
/// Allows users to select one option from a list of style preferences.
class SingleChoiceCard extends StatefulWidget {
  final StyleQuestion question;
  final StyleAnswer? currentAnswer;
  final void Function(String) onAnswer;

  const SingleChoiceCard({
    super.key,
    required this.question,
    required this.currentAnswer,
    required this.onAnswer,
  });

  @override
  State<SingleChoiceCard> createState() => _SingleChoiceCardState();
}

class _SingleChoiceCardState extends State<SingleChoiceCard> {
  String? _selectedOption;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.currentAnswer?.textValue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question title
        _buildQuestionTitle(theme, colorScheme),
        
        const SizedBox(height: 32),
        
        // Options
        Expanded(
          child: _buildOptionsList(theme, colorScheme),
        ),
      ],
    );
  }

  Widget _buildQuestionTitle(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.question.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          if (widget.question.description != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.question.description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'Choose one option',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsList(ThemeData theme, ColorScheme colorScheme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: widget.question.options.length,
      itemBuilder: (context, index) {
        final option = widget.question.options[index];
        final isSelected = _selectedOption == option;
        
        return _buildOptionItem(option, isSelected, theme, colorScheme);
      },
    );
  }

  Widget _buildOptionItem(String option, bool isSelected, ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectOption(option),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected 
                  ? colorScheme.primaryContainer.withOpacity(0.7)
                  : colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected 
                    ? colorScheme.primary
                    : colorScheme.outline.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Selection indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? colorScheme.primary
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected 
                          ? colorScheme.primary
                          : colorScheme.outline.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: colorScheme.onPrimary,
                        )
                      : null,
                ),
                
                const SizedBox(width: 16),
                
                // Option text
                Expanded(
                  child: Text(
                    option,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isSelected 
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                      fontWeight: isSelected 
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                
                // Selection animation
                if (isSelected)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectOption(String option) {
    setState(() {
      _selectedOption = option;
    });
    
    widget.onAnswer(option);
  }
}
