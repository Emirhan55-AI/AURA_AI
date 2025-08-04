import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/ui/system_state_widget.dart';
import '../../widgets/onboarding/style_discovery/onboarding_chat_interface.dart';
import '../../widgets/onboarding/style_discovery/answer_option_widget.dart';

/// StyleDiscoveryScreen - The onboarding screen for discovering user style preferences
/// 
/// This screen presents a gamified, chat-like questionnaire to collect the user's
/// style preferences during the onboarding process. The information collected is used
/// to initialize the user's AI stylist profile.
class StyleDiscoveryScreen extends StatefulWidget {
  const StyleDiscoveryScreen({super.key});

  @override
  State<StyleDiscoveryScreen> createState() => _StyleDiscoveryScreenState();
}

class _StyleDiscoveryScreenState extends State<StyleDiscoveryScreen> {
  // Current state of the questionnaire
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isAiTyping = false;
  
  // Index of the current question being displayed
  int _currentQuestionIndex = 0;
  
  // List of user's answers
  final List<UserStyleAnswer> _userAnswers = [];
  
  // Mock data for style preferences questions
  late List<StylePreference> _stylePreferences;

  @override
  void initState() {
    super.initState();
    _loadStylePreferences();
  }

  // Simulate loading the style preferences from a service
  Future<void> _loadStylePreferences() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate a network delay
      await Future<void>.delayed(const Duration(seconds: 1));
      
      // Mock data
      _stylePreferences = [
        const StylePreference(
          questionId: 'colors',
          questionText: 'What colors do you most often wear or prefer in your outfits?',
          answerType: AnswerType.multiChoice,
          options: ['Black', 'White', 'Blue', 'Red', 'Green', 'Yellow', 'Purple', 'Orange', 'Pink', 'Grey', 'Brown'],
        ),
        const StylePreference(
          questionId: 'patterns',
          questionText: 'Do you prefer any specific patterns or prints in your clothing?',
          answerType: AnswerType.multiChoice,
          options: ['Solid colors', 'Stripes', 'Floral', 'Polka dots', 'Plaid', 'Animal print', 'Geometric', 'Abstract'],
        ),
        const StylePreference(
          questionId: 'style',
          questionText: 'How would you describe your personal style?',
          answerType: AnswerType.singleChoice,
          options: ['Casual', 'Formal', 'Sporty', 'Bohemian', 'Minimalist', 'Vintage', 'Edgy', 'Classic'],
        ),
        const StylePreference(
          questionId: 'favorite_item',
          questionText: 'What\'s your favorite clothing item that you own?',
          answerType: AnswerType.textInput,
          options: [],
        ),
        const StylePreference(
          questionId: 'favorite_color',
          questionText: 'What\'s your absolute favorite color to wear?',
          answerType: AnswerType.colorPicker,
          options: [],
        ),
        const StylePreference(
          questionId: 'inspiration_image',
          questionText: 'If you have a style inspiration image, please share it with me! (optional)',
          answerType: AnswerType.imageUpload,
          options: [],
          isRequired: false,
        ),
      ];
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load style questionnaire. Please try again.';
      });
    }
  }

  // Handle when the user submits an answer
  void _handleAnswerSubmitted(List<String> answers) {
    if (_currentQuestionIndex < _stylePreferences.length) {
      final questionId = _stylePreferences[_currentQuestionIndex].questionId;
      
      setState(() {
        // Add the user's answer
        _userAnswers.add(UserStyleAnswer(
          questionId: questionId,
          answers: answers,
        ));
        
        // Simulate AI typing
        _isAiTyping = true;
      });

      // Simulate AI processing time
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() {
            _isAiTyping = false;
            
            // Move to the next question if not at the end
            if (_currentQuestionIndex < _stylePreferences.length - 1) {
              _currentQuestionIndex++;
            } else {
              // All questions answered, navigate to the next screen
              // This would be replaced with actual navigation logic
              _navigateToNextScreen();
            }
          });
        }
      });
    }
  }

  // Navigate to the next screen in the onboarding flow
  void _navigateToNextScreen() {
    // In a real implementation, this would save the user's preferences
    // and navigate to the next screen in the onboarding flow
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Style preferences saved! Moving to next screen...'),
        duration: Duration(seconds: 2),
      ),
    );

    // Delay to allow snackbar to show before navigation
    Future.delayed(const Duration(seconds: 2), () {
      // Navigate to login page or next onboarding screen
      context.go('/login');
    });
  }

  // Retry loading the style preferences if there was an error
  void _retryLoading() {
    setState(() {
      _hasError = false;
      _errorMessage = '';
    });
    _loadStylePreferences();
  }

  // Skip the style discovery process and proceed to next screen
  void _skipStyleDiscovery() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('We\'ll use default style settings for now. You can update them anytime!'),
        duration: Duration(seconds: 2),
      ),
    );
    
    // Navigate to login page or next onboarding screen
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Discover Your Style',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _skipStyleDiscovery,
            child: Text(
              'Skip',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(theme, colorScheme),
    );
  }

  Widget _buildBody(ThemeData theme, ColorScheme colorScheme) {
    // Show loading state
    if (_isLoading) {
      return const SystemStateWidget(
        icon: Icons.style,
        message: 'Setting up your style discovery experience...',
      );
    }
    
    // Show error state
    if (_hasError) {
      return SystemStateWidget(
        icon: Icons.error_outline,
        iconColor: colorScheme.error,
        message: _errorMessage,
        onRetry: _retryLoading,
        retryText: 'Try Again',
      );
    }

    // Main content
    return Column(
      children: [
        // Progress indicator
        LinearProgressIndicator(
          value: _userAnswers.isEmpty 
              ? 0 
              : _userAnswers.length / _stylePreferences.length,
          backgroundColor: colorScheme.surfaceVariant,
          color: colorScheme.primary,
          minHeight: 4,
        ),
        
        // Chat interface with questions and answers
        Expanded(
          child: OnboardingChatInterface(
            preferences: _stylePreferences.sublist(0, _currentQuestionIndex + 1),
            answers: _userAnswers,
            isAiTyping: _isAiTyping,
          ),
        ),
        
        // Input area for answering the current question
        if (_currentQuestionIndex < _stylePreferences.length && !_isAiTyping && _userAnswers.length <= _currentQuestionIndex)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: colorScheme.outline.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: AnswerOptionWidget(
                answerType: _stylePreferences[_currentQuestionIndex].answerType,
                options: _stylePreferences[_currentQuestionIndex].options,
                onAnswerSelected: _handleAnswerSubmitted,
                enabled: !_isAiTyping,
              ),
            ),
          ),
      ],
    );
  }
}
