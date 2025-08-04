import 'package:flutter/material.dart';
import 'preference_question_card.dart';

/// OnboardingChatInterface - Widget for displaying the style preference questions
/// in a chat-like interface during onboarding.
///
/// This widget simulates a conversation with the AI style assistant where it asks
/// questions about style preferences and displays the user's answers.
class OnboardingChatInterface extends StatefulWidget {
  /// List of questions to display in the chat interface
  final List<StylePreference> preferences;
  
  /// List of user answers to display in the chat interface
  final List<UserStyleAnswer> answers;
  
  /// Whether the AI is "typing" a response
  final bool isAiTyping;

  const OnboardingChatInterface({
    super.key,
    required this.preferences,
    required this.answers,
    this.isAiTyping = false,
  });

  @override
  State<OnboardingChatInterface> createState() => _OnboardingChatInterfaceState();
}

class _OnboardingChatInterfaceState extends State<OnboardingChatInterface> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(OnboardingChatInterface oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Auto-scroll to bottom when new messages are added
    if (widget.answers.length > oldWidget.answers.length || 
        widget.isAiTyping != oldWidget.isAiTyping) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Combine preferences and answers to create a conversation flow
    final List<Widget> conversationWidgets = [];

    // Welcome message
    conversationWidgets.add(
      PreferenceQuestionCard(
        questionText: 'Hi there! Let\'s discover your unique style together! I\'ll ask you a few questions to understand your preferences better.',
        isWelcomeMessage: true,
      ),
    );

    // Add spacing after welcome message
    conversationWidgets.add(const SizedBox(height: 16));

    // Add all question-answer pairs in sequence
    for (int i = 0; i < widget.preferences.length; i++) {
      final question = widget.preferences[i];
      
      // Add the question
      conversationWidgets.add(PreferenceQuestionCard(
        questionText: question.questionText,
        questionId: question.questionId,
        answerType: question.answerType,
        options: question.options,
      ));
      
      // Add spacing between question and answer
      conversationWidgets.add(const SizedBox(height: 12));
      
      // If user has answered this question, show the answer
      if (i < widget.answers.length) {
        final answer = widget.answers[i];
        conversationWidgets.add(_buildUserAnswer(
          answer,
          theme,
          colorScheme,
          question.answerType,
        ));
        
        // Add spacing after answer
        conversationWidgets.add(const SizedBox(height: 20));
      }
    }

    // Show AI typing indicator if needed
    if (widget.isAiTyping) {
      conversationWidgets.add(_buildTypingIndicator(theme, colorScheme));
    }

    // Add extra space at bottom for better scrolling
    conversationWidgets.add(const SizedBox(height: 16));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        controller: _scrollController,
        children: conversationWidgets,
      ),
    );
  }

  Widget _buildUserAnswer(
    UserStyleAnswer answer, 
    ThemeData theme, 
    ColorScheme colorScheme,
    AnswerType answerType,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 260),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: _buildAnswerContent(answer, theme, colorScheme, answerType),
        ),
        const SizedBox(width: 8),
        // User Avatar
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.person,
            color: colorScheme.onPrimary,
            size: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerContent(
    UserStyleAnswer answer, 
    ThemeData theme, 
    ColorScheme colorScheme,
    AnswerType answerType,
  ) {
    switch (answerType) {
      case AnswerType.textInput:
        return Text(
          answer.answers.first,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onPrimary,
          ),
        );
        
      case AnswerType.singleChoice:
      case AnswerType.multiChoice:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: answer.answers.map((choice) => 
            Text(
              choice,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimary,
              ),
            ),
          ).toList(),
        );
        
      case AnswerType.imageUpload:
        return Column(
          children: [
            if (answer.answers.isNotEmpty) 
              Text(
                'Image uploaded',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimary,
                ),
              ),
            const SizedBox(height: 8),
            const Icon(
              Icons.image,
              color: Colors.white70,
              size: 40,
            ),
          ],
        );
        
      case AnswerType.colorPicker:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              answer.answers.first,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimary,
              ),
            ),
          ],
        );
    }
  }

  Widget _buildTypingIndicator(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      child: Row(
        children: [
          // AI Avatar
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colorScheme.secondary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.auto_awesome,
              color: colorScheme.onSecondary,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Aura is thinking...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Enum representing the different types of answers a question can have
enum AnswerType {
  singleChoice,
  multiChoice,
  textInput,
  imageUpload,
  colorPicker,
}

/// Data class for a style preference question
class StylePreference {
  final String questionId;
  final String questionText;
  final AnswerType answerType;
  final List<String> options;
  final bool isRequired;

  const StylePreference({
    required this.questionId,
    required this.questionText,
    required this.answerType,
    this.options = const [],
    this.isRequired = true,
  });
}

/// Data class for a user's answer to a style preference question
class UserStyleAnswer {
  final String questionId;
  final List<String> answers;

  const UserStyleAnswer({
    required this.questionId,
    required this.answers,
  });
}
