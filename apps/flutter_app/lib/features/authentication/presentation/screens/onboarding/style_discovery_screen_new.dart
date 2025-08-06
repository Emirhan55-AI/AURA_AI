import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/ui/system_state_widget.dart';
import '../../controllers/style_discovery_controller.dart';

/// Enhanced StyleDiscoveryScreen - Gamified onboarding experience
/// 
/// Features:
/// - 15 curated style questions
/// - Progress tracking
/// - Real-time style profile generation
/// - Beautiful animations and transitions  
class StyleDiscoveryScreen extends ConsumerStatefulWidget {
  const StyleDiscoveryScreen({super.key});

  @override
  ConsumerState<StyleDiscoveryScreen> createState() => _StyleDiscoveryScreenState();
}

class _StyleDiscoveryScreenState extends ConsumerState<StyleDiscoveryScreen> 
    with TickerProviderStateMixin {
  
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(styleDiscoveryControllerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Update progress animation when progress changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _progressController.animateTo(state.progress);
    });

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header with progress
            _buildHeader(theme, colorScheme, state),
            
            // Main content
            Expanded(
              child: _buildContent(state, theme, colorScheme),
            ),
            
            // Navigation buttons
            if (!state.isCompleted) _buildNavigationButtons(state, theme, colorScheme),
          ],
        ),
      ),
    );
  }

  /// Builds the header section with progress indicator
  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme, StyleDiscoveryState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Top bar with back button and progress
          Row(
            children: [
              IconButton(
                onPressed: state.canGoPrevious 
                    ? () => ref.read(styleDiscoveryControllerProvider.notifier).previousQuestion()
                    : () => context.pop(),
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Style Discovery',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Question ${state.currentQuestionIndex + 1} of ${state.questions.length}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Progress indicator
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Container(
                height: 6,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.tertiary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Builds the main content area
  Widget _buildContent(StyleDiscoveryState state, ThemeData theme, ColorScheme colorScheme) {
    if (state.isLoading) {
      return _buildLoadingState(theme, colorScheme);
    }
    
    if (state.isCompleted) {
      return _buildCompletionState(state, theme, colorScheme);
    }
    
    if (state.errorMessage != null) {
      return _buildErrorState(state.errorMessage!, theme, colorScheme);
    }
    
    final currentQuestion = state.currentQuestion;
    if (currentQuestion == null) {
      return _buildErrorState('No questions available', theme, colorScheme);
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.3, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(currentQuestion.id),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _buildQuestionCard(currentQuestion, state, theme, colorScheme),
      ),
    );
  }

  /// Builds question card based on type
  Widget _buildQuestionCard(
    StyleQuestion question, 
    StyleDiscoveryState state, 
    ThemeData theme, 
    ColorScheme colorScheme
  ) {
    final currentAnswer = state.answers[question.id];
    
    return _buildGenericQuestionCard(question, currentAnswer, theme, colorScheme);
  }

  /// Builds a generic question card for all question types
  Widget _buildGenericQuestionCard(
    StyleQuestion question,
    StyleAnswer? currentAnswer,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question title
        Text(
          question.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        
        if (question.description != null) ...[
          const SizedBox(height: 12),
          Text(
            question.description!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
              height: 1.4,
            ),
          ),
        ],
        
        const SizedBox(height: 32),
        
        // Options based on question type
        Expanded(
          child: _buildOptionsForType(question, currentAnswer, theme, colorScheme),
        ),
      ],
    );
  }

  Widget _buildOptionsForType(
    StyleQuestion question,
    StyleAnswer? currentAnswer,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    switch (question.type) {
      case QuestionType.singleChoice:
        return _buildSingleChoiceOptions(question, currentAnswer, theme, colorScheme);
      case QuestionType.multipleChoice:
        return _buildMultipleChoiceOptions(question, currentAnswer, theme, colorScheme);
      case QuestionType.slider:
        return _buildSliderOption(question, currentAnswer, theme, colorScheme);
      case QuestionType.tinder:
        return _buildTinderOptions(question, currentAnswer, theme, colorScheme);
      case QuestionType.colorPicker:
        return _buildColorPickerOptions(question, currentAnswer, theme, colorScheme);
      case QuestionType.imageUpload:
        return _buildImageUploadOption(question, currentAnswer, theme, colorScheme);
    }
  }

  Widget _buildSingleChoiceOptions(
    StyleQuestion question,
    StyleAnswer? currentAnswer,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return ListView.builder(
      itemCount: question.options?.length ?? 0,
      itemBuilder: (context, index) {
        final option = question.options![index];
        final isSelected = currentAnswer?.value == option;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _handleAnswer(question.id, AnswerType.text, option),
              borderRadius: BorderRadius.circular(16),
              child: Container(
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildMultipleChoiceOptions(
    StyleQuestion question,
    StyleAnswer? currentAnswer,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final selectedOptions = (currentAnswer?.value as List<String>?)?.toSet() ?? <String>{};
    
    return ListView.builder(
      itemCount: question.options?.length ?? 0,
      itemBuilder: (context, index) {
        final option = question.options![index];
        final isSelected = selectedOptions.contains(option);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                final newSelection = Set<String>.from(selectedOptions);
                if (isSelected) {
                  newSelection.remove(option);
                } else {
                  newSelection.add(option);
                }
                _handleAnswer(question.id, AnswerType.list, newSelection.toList());
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
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
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? colorScheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
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
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliderOption(
    StyleQuestion question,
    StyleAnswer? currentAnswer,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final minValue = question.metadata?['min']?.toDouble() ?? 0.0;
    final maxValue = question.metadata?['max']?.toDouble() ?? 100.0;
    final currentValue = (currentAnswer?.value as double?) ?? 
                        question.metadata?['default']?.toDouble() ?? 
                        (minValue + maxValue) / 2;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(
                'Your Selection',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                currentValue.round().toString(),
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        Slider(
          value: currentValue,
          min: minValue,
          max: maxValue,
          divisions: (maxValue - minValue).round(),
          onChanged: (value) {
            _handleAnswer(question.id, AnswerType.number, value);
          },
        ),
      ],
    );
  }

  Widget _buildTinderOptions(
    StyleQuestion question,
    StyleAnswer? currentAnswer,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final likedOptions = (currentAnswer?.value as List<String>?) ?? [];
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Swipe through styles!',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Liked ${likedOptions.length} styles',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Simulate liking some options
              final mockLikes = question.options?.take(3).toList() ?? [];
              _handleAnswer(question.id, AnswerType.list, mockLikes);
            },
            child: const Text('Simulate Swiping'),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPickerOptions(
    StyleQuestion question,
    StyleAnswer? currentAnswer,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final selectedColors = (currentAnswer?.value as List<String>?) ?? [];
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Choose your favorite colors!',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Selected ${selectedColors.length} colors',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Simulate color selection
              final mockColors = ['#FF5722', '#2196F3', '#4CAF50'];
              _handleAnswer(question.id, AnswerType.list, mockColors);
            },
            child: const Text('Select Colors'),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadOption(
    StyleQuestion question,
    StyleAnswer? currentAnswer,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final hasImage = currentAnswer?.value != null;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: hasImage 
                  ? colorScheme.primary.withOpacity(0.1)
                  : colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: hasImage 
                    ? colorScheme.primary.withOpacity(0.3)
                    : colorScheme.outline.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              hasImage ? Icons.image : Icons.cloud_upload_outlined,
              size: 48,
              color: hasImage 
                  ? colorScheme.primary
                  : colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            hasImage ? 'Image Uploaded ✓' : 'Upload Image',
            style: theme.textTheme.titleLarge?.copyWith(
              color: hasImage 
                  ? colorScheme.primary
                  : colorScheme.onSurface.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Simulate image upload
              _handleAnswer(question.id, AnswerType.image, 'mock_image_path');
            },
            child: Text(hasImage ? 'Change Image' : 'Upload Image'),
          ),
        ],
      ),
    );
  }

  /// Handles answering a question
  void _handleAnswer(String questionId, AnswerType type, dynamic value) {
    ref.read(styleDiscoveryControllerProvider.notifier).answerQuestion(
      questionId, 
      type, 
      value,
    );
    
    // Auto-advance for single-choice questions
    final state = ref.read(styleDiscoveryControllerProvider);
    final question = state.currentQuestion;
    
    if (question?.type == QuestionType.singleChoice) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          ref.read(styleDiscoveryControllerProvider.notifier).nextQuestion();
        }
      });
    }
  }

  /// Builds loading state
  Widget _buildLoadingState(ThemeData theme, ColorScheme colorScheme) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading your style journey...'),
        ],
      ),
    );
  }

  /// Builds completion state
  Widget _buildCompletionState(StyleDiscoveryState state, ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success animation placeholder
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 60,
                color: Colors.green,
              ),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'Your Style Profile is Ready! ✨',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'We\'ve analyzed your preferences and created a personalized style profile just for you.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 40),
            
            // Profile summary
            if (state.generatedProfile != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'Your Primary Style',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.generatedProfile!['primaryStyle'] ?? 'Unique',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
            ],
            
            // Continue button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to main app
                  context.go('/main');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Continue to Aura',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds error state
  Widget _buildErrorState(String message, ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(styleDiscoveryControllerProvider.notifier).resetQuiz();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds navigation buttons
  Widget _buildNavigationButtons(StyleDiscoveryState state, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Previous button
          if (state.canGoPrevious)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ref.read(styleDiscoveryControllerProvider.notifier).previousQuestion();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Previous',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          
          if (state.canGoPrevious) const SizedBox(width: 16),
          
          // Next/Skip button
          Expanded(
            flex: state.canGoPrevious ? 1 : 2,
            child: ElevatedButton(
              onPressed: state.canGoNext
                  ? () => ref.read(styleDiscoveryControllerProvider.notifier).nextQuestion()
                  : (state.currentQuestion?.isRequired == false)
                      ? () => ref.read(styleDiscoveryControllerProvider.notifier).skipQuestion()
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                state.canGoNext 
                    ? (state.currentQuestionIndex == state.questions.length - 1 ? 'Finish' : 'Next')
                    : 'Skip',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
