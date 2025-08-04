import 'package:flutter/material.dart';
import 'onboarding_chat_interface.dart';

/// PreferenceQuestionCard - Widget to display a question or statement from the AI assistant
/// 
/// This widget displays a chat bubble for AI messages with questions about style preferences.
/// It supports different question types and displays them in a visually appealing way.
class PreferenceQuestionCard extends StatelessWidget {
  /// The text of the question
  final String questionText;
  
  /// Optional ID of the question
  final String? questionId;
  
  /// Optional type of answer expected for this question
  final AnswerType? answerType;
  
  /// Optional list of options for single/multi-choice questions
  final List<String>? options;
  
  /// Whether this is the welcome message
  final bool isWelcomeMessage;

  const PreferenceQuestionCard({
    super.key,
    required this.questionText,
    this.questionId,
    this.answerType,
    this.options,
    this.isWelcomeMessage = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI Avatar
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isWelcomeMessage ? colorScheme.primary : colorScheme.secondary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.auto_awesome,
            color: isWelcomeMessage ? colorScheme.onPrimary : colorScheme.onSecondary,
            size: 18,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isWelcomeMessage ? colorScheme.primary.withOpacity(0.9) : colorScheme.surfaceVariant,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: isWelcomeMessage ? [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ] : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  questionText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isWelcomeMessage ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                
                // Display visual aids for specific question types
                if (answerType != null && !isWelcomeMessage) ...[
                  const SizedBox(height: 12),
                  _buildQuestionVisual(context, theme, colorScheme),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionVisual(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    switch (answerType) {
      case AnswerType.imageUpload:
        return Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.5),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_outlined,
                size: 40,
                color: colorScheme.primary.withOpacity(0.7),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to upload an image',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
        
      case AnswerType.colorPicker:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildColorSample(Colors.red.shade300, 'Red'),
            _buildColorSample(Colors.blue.shade300, 'Blue'),
            _buildColorSample(Colors.green.shade300, 'Green'),
            _buildColorSample(Colors.purple.shade300, 'Purple'),
            _buildColorSample(Colors.orange.shade300, 'Orange'),
          ],
        );
        
      case AnswerType.singleChoice:
      case AnswerType.multiChoice:
        if (options != null && options!.isNotEmpty) {
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options!.map((option) => 
              Chip(
                label: Text(option),
                backgroundColor: colorScheme.surface,
                side: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
              ),
            ).toList(),
          );
        }
        
      default:
        return const SizedBox.shrink();
    }
    return const SizedBox.shrink();
  }

  Widget _buildColorSample(Color color, String name) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}
