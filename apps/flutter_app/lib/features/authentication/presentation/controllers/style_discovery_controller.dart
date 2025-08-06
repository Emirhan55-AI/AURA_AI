import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';

part 'style_discovery_controller.g.dart';

/// Question types for the style discovery quiz
enum QuestionType {
  multipleChoice,
  singleChoice,
  colorPicker,
  imageUpload,
  slider,
  tinder,
}

/// Answer types for different question formats
enum AnswerType {
  text,
  number,
  color,
  image,
  list,
}

/// Data class for style questions
@immutable
class StyleQuestion {
  final String id;
  final String title;
  final String? description;
  final String? subtitle;
  final QuestionType type;
  final List<String>? options;
  final String? imageUrl;
  final int? minValue;
  final int? maxValue;
  final double? defaultValue;
  final bool isRequired;
  final Map<String, dynamic>? metadata;

  const StyleQuestion({
    required this.id,
    required this.title,
    this.description,
    this.subtitle,
    required this.type,
    this.options,
    this.imageUrl,
    this.minValue,
    this.maxValue,
    this.defaultValue,
    this.isRequired = true,
    this.metadata,
  });
}

/// Data class for user answers
@immutable
class StyleAnswer {
  final String questionId;
  final AnswerType type;
  final dynamic value;

  const StyleAnswer({
    required this.questionId,
    required this.type,
    required this.value,
  });
}

/// State for the style discovery process
@immutable
class StyleDiscoveryState {
  final List<StyleQuestion> questions;
  final Map<String, StyleAnswer> answers;
  final int currentQuestionIndex;
  final bool isLoading;
  final bool isCompleted;
  final String? errorMessage;
  final Map<String, dynamic>? generatedProfile;

  const StyleDiscoveryState({
    this.questions = const [],
    this.answers = const {},
    this.currentQuestionIndex = 0,
    this.isLoading = false,
    this.isCompleted = false,
    this.errorMessage,
    this.generatedProfile,
  });

  StyleDiscoveryState copyWith({
    List<StyleQuestion>? questions,
    Map<String, StyleAnswer>? answers,
    int? currentQuestionIndex,
    bool? isLoading,
    bool? isCompleted,
    String? errorMessage,
    Map<String, dynamic>? generatedProfile,
  }) {
    return StyleDiscoveryState(
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      isLoading: isLoading ?? this.isLoading,
      isCompleted: isCompleted ?? this.isCompleted,
      errorMessage: errorMessage,
      generatedProfile: generatedProfile ?? this.generatedProfile,
    );
  }

  double get progress {
    if (questions.isEmpty) return 0.0;
    return answers.length / questions.length;
  }

  StyleQuestion? get currentQuestion {
    if (currentQuestionIndex >= questions.length) return null;
    return questions[currentQuestionIndex];
  }

  bool get canGoNext {
    final current = currentQuestion;
    if (current == null) return false;
    if (!current.isRequired) return true;
    return answers.containsKey(current.id);
  }

  bool get canGoPrevious => currentQuestionIndex > 0;
}

/// Controller for the style discovery quiz
/// Handles the gamified questionnaire experience
@riverpod
class StyleDiscoveryController extends _$StyleDiscoveryController {
  @override
  StyleDiscoveryState build() {
    _loadQuestions();
    return const StyleDiscoveryState(isLoading: true);
  }

  /// Loads the style discovery questions
  void _loadQuestions() async {
    try {
      // Simulate loading delay for better UX
      await Future<void>.delayed(const Duration(milliseconds: 500));

      final questions = _getStyleQuestions();
      
      state = state.copyWith(
        questions: questions,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load questions. Please try again.',
      );
    }
  }

  /// Returns the list of style discovery questions
  List<StyleQuestion> _getStyleQuestions() {
    return [
      // Welcome & Basic Style
      const StyleQuestion(
        id: 'style_vibe',
        title: 'What\'s your overall style vibe?',
        subtitle: 'Swipe right on styles that speak to you!',
        type: QuestionType.tinder,
        options: [
          'Minimalist Chic',
          'Bohemian Free',
          'Classic Elegant',
          'Street Smart',
          'Vintage Charm',
          'Sporty Active',
          'Edgy Bold',
          'Romantic Soft',
        ],
      ),

      // Color Preferences
      const StyleQuestion(
        id: 'favorite_colors',
        title: 'Which colors make you feel amazing?',
        subtitle: 'Pick all that resonate with you',
        type: QuestionType.multipleChoice,
        options: [
          'Deep Black',
          'Pure White', 
          'Navy Blue',
          'Forest Green',
          'Wine Red',
          'Blush Pink',
          'Camel Brown',
          'Golden Yellow',
          'Lavender Purple',
          'Sage Green',
        ],
      ),

      // Patterns & Textures
      const StyleQuestion(
        id: 'pattern_love',
        title: 'What patterns catch your eye?',
        type: QuestionType.multipleChoice,
        options: [
          'Solid Colors',
          'Classic Stripes',
          'Floral Prints',
          'Geometric Shapes',
          'Animal Prints',
          'Polka Dots',
          'Plaid/Checkered',
          'Abstract Art',
        ],
      ),

      // Lifestyle Questions
      const StyleQuestion(
        id: 'lifestyle',
        title: 'How would you describe your lifestyle?',
        type: QuestionType.singleChoice,
        options: [
          'Corporate Professional',
          'Creative Freelancer',
          'Active & Outdoorsy',
          'Social Butterfly',
          'Homebody Comfort',
          'Busy Parent',
          'Student Life',
          'Entrepreneur',
        ],
      ),

      // Budget Preference
      const StyleQuestion(
        id: 'budget_range',
        title: 'What\'s your comfort zone for clothing budget?',
        subtitle: 'Per item average',
        type: QuestionType.singleChoice,
        options: [
          'Under 50 dollars - Budget Friendly',
          '50-100 dollars - Moderate',
          '100-200 dollars - Mid-Range',
          '200-500 dollars - Premium',
          '500+ dollars - Luxury',
        ],
      ),

      // Body Confidence
      const StyleQuestion(
        id: 'body_confidence',
        title: 'What makes you feel most confident?',
        type: QuestionType.multipleChoice,
        options: [
          'Fitted Silhouettes',
          'Flowy & Loose',
          'High Waisted',
          'Cropped Styles',
          'Layered Looks',
          'Statement Sleeves',
          'Bold Necklines',
          'Comfortable Fabrics',
        ],
      ),

      // Occasion Priorities
      const StyleQuestion(
        id: 'occasions',
        title: 'What occasions do you dress for most?',
        type: QuestionType.multipleChoice,
        options: [
          'Work/Professional',
          'Casual Daily',
          'Date Nights',
          'Social Events',
          'Travel',
          'Exercise/Active',
          'Special Occasions',
          'Home Comfort',
        ],
      ),

      // Fashion Icons
      const StyleQuestion(
        id: 'style_icons',
        title: 'Whose style inspires you?',
        subtitle: 'Choose your style inspirations',
        type: QuestionType.tinder,
        options: [
          'Zendaya - Bold & Versatile',
          'Emma Stone - Classic & Playful',
          'Rihanna - Edgy & Fearless',
          'Blake Lively - Elegant & Chic',
          'Billie Eilish - Unique & Comfortable',
          'Meghan Markle - Sophisticated',
          'Gigi Hadid - Model Off-Duty',
          'Lupita Nyong\'o - Colorful & Artistic',
        ],
      ),

      // Shopping Preferences
      const StyleQuestion(
        id: 'shopping_style',
        title: 'How do you prefer to shop?',
        type: QuestionType.singleChoice,
        options: [
          'Quick & Efficient',
          'Browse & Explore',
          'Planned & Researched',
          'Spontaneous & Fun',
          'Online Only',
          'In-Store Experience',
          'With Friends',
          'Personal Stylist Help',
        ],
      ),

      // Comfort vs Style
      const StyleQuestion(
        id: 'comfort_vs_style',
        title: 'On the comfort vs style spectrum...',
        subtitle: 'Slide to show your preference',
        type: QuestionType.slider,
        minValue: 0,
        maxValue: 100,
        defaultValue: 50,
      ),

      // Investment Pieces
      const StyleQuestion(
        id: 'investment_pieces',
        title: 'Which pieces are worth investing in?',
        type: QuestionType.multipleChoice,
        options: [
          'Perfect Fitting Jeans',
          'Quality Blazer',
          'Comfortable Shoes',
          'Versatile Dress',
          'Cozy Outerwear',
          'Statement Accessories',
          'Luxury Handbag',
          'Classic White Shirt',
        ],
      ),

      // Color Psychology
      const StyleQuestion(
        id: 'color_mood',
        title: 'What\'s your go-to color when you want to feel powerful?',
        type: QuestionType.colorPicker,
      ),

      // Trend Following
      const StyleQuestion(
        id: 'trend_follower',
        title: 'How do you feel about fashion trends?',
        type: QuestionType.singleChoice,
        options: [
          'Love trying new trends',
          'Pick and choose selectively',
          'Prefer timeless classics',
          'Create my own trends',
          'Don\'t really follow trends',
        ],
      ),

      // Style Goals
      const StyleQuestion(
        id: 'style_goals',
        title: 'What are your style goals?',
        type: QuestionType.multipleChoice,
        options: [
          'Look more professional',
          'Express my personality',
          'Feel more confident',
          'Simplify my wardrobe',
          'Try new styles',
          'Build a capsule wardrobe',
          'Dress for my body type',
          'Sustainable fashion choices',
        ],
      ),

      // Final Touch - Style Inspiration Image
      const StyleQuestion(
        id: 'inspiration_image',
        title: 'Share a style inspiration image! 📸',
        subtitle: 'Optional - but helps me understand your vision better',
        type: QuestionType.imageUpload,
        isRequired: false,
      ),
    ];
  }

  /// Answers a question and moves to next if applicable
  void answerQuestion(String questionId, AnswerType type, dynamic value) {
    final newAnswers = Map<String, StyleAnswer>.from(state.answers);
    newAnswers[questionId] = StyleAnswer(
      questionId: questionId,
      type: type,
      value: value,
    );

    state = state.copyWith(
      answers: newAnswers,
      errorMessage: null,
    );
  }

  /// Handles user answers and updates the state
  void answerQuestion(String questionId, dynamic answer) {
    final updatedAnswers = Map<String, dynamic>.from(state.answers)
      ..[questionId] = answer;

    state = state.copyWith(
      answers: updatedAnswers,
      currentQuestionIndex: state.currentQuestionIndex + 1,
    );

    if (state.currentQuestionIndex >= state.questions.length) {
      _generateStyleProfile();
    }
  }

  /// Goes to the next question
  void nextQuestion() {
    if (!state.canGoNext) return;

    final nextIndex = state.currentQuestionIndex + 1;
    
    if (nextIndex >= state.questions.length) {
      _completeQuiz();
    } else {
      state = state.copyWith(currentQuestionIndex: nextIndex);
    }
  }

  /// Goes to the previous question
  void previousQuestion() {
    if (!state.canGoPrevious) return;
    
    state = state.copyWith(
      currentQuestionIndex: state.currentQuestionIndex - 1,
    );
  }

  /// Jumps to a specific question
  void goToQuestion(int index) {
    if (index < 0 || index >= state.questions.length) return;
    
    state = state.copyWith(currentQuestionIndex: index);
  }

  /// Completes the quiz and generates style profile
  void _completeQuiz() async {
    state = state.copyWith(isLoading: true);

    try {
      // Simulate profile generation
      await Future<void>.delayed(const Duration(seconds: 2));

      final profile = _generateStyleProfile();
      
      state = state.copyWith(
        isLoading: false,
        isCompleted: true,
        generatedProfile: profile,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to generate your style profile. Please try again.',
      );
    }
  }

  /// Generates the style profile based on user answers
  Map<String, dynamic> _generateStyleProfile() {
    // Extract style preferences
    final styleVibe = _getAnswerValue('style_vibe') as List<String>? ?? [];
    final favoriteColors = _getAnswerValue('favorite_colors') as List<String>? ?? [];
    final lifestyle = _getAnswerValue('lifestyle') as String?;
    final budget = _getAnswerValue('budget_range') as String?;

    return {
      'styleVibe': styleVibe,
      'favoriteColors': favoriteColors,
      'lifestyle': lifestyle,
      'budget': budget,
    };
  }

  /// Helper to get answer value by question ID
  dynamic _getAnswerValue(String questionId) {
    return state.answers[questionId]?.value;
  }

  /// Resets the entire quiz
  void resetQuiz() {
    state = const StyleDiscoveryState(isLoading: true);
    _loadQuestions();
  }

  /// Skips the current question (if not required)
  void skipQuestion() {
    final current = state.currentQuestion;
    if (current?.isRequired == true) return;
    
    nextQuestion();
  }

  /// Submits the user's answers to the backend
  Future<void> submitAnswers() async {
    try {
      // Simulate backend submission
      await Future<void>.delayed(const Duration(seconds: 1));
      // Assume success
    } catch (e) {
      throw Exception('Failed to submit answers');
    }
  }

  /// Generates a style profile based on the user's answers
  Future<Map<String, dynamic>> generateProfile() async {
    try {
      // Simulate profile generation
      await Future<void>.delayed(const Duration(seconds: 1));
      return {
        'primaryStyle': 'Minimalist Chic',
        'secondaryStyle': 'Bohemian Free',
      };
    } catch (e) {
      throw Exception('Failed to generate profile');
    }
  }
}
