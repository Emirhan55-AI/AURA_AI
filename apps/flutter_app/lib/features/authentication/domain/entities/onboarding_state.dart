/// State model for onboarding flow
/// Tracks user progress through onboarding and style discovery
class OnboardingState {
  const OnboardingState({
    this.currentStep = 0,
    this.totalSteps = 10,
    this.userPreferences = const {},
    this.isComplete = false,
    this.isSkipped = false,
    this.isLoading = false,
    this.error,
    this.currentQuestionType,
  });

  /// Current step in the onboarding process
  final int currentStep;
  
  /// Total number of steps in onboarding
  final int totalSteps;
  
  /// User preferences collected during onboarding
  final Map<String, dynamic> userPreferences;
  
  /// Whether onboarding is complete
  final bool isComplete;
  
  /// Whether onboarding was skipped
  final bool isSkipped;
  
  /// Whether currently loading/processing
  final bool isLoading;
  
  /// Error message if any
  final String? error;
  
  /// Current question type being displayed
  final OnboardingQuestionType? currentQuestionType;

  /// Create a copy with updated fields
  OnboardingState copyWith({
    int? currentStep,
    int? totalSteps,
    Map<String, dynamic>? userPreferences,
    bool? isComplete,
    bool? isSkipped,
    bool? isLoading,
    String? error,
    OnboardingQuestionType? currentQuestionType,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      userPreferences: userPreferences ?? this.userPreferences,
      isComplete: isComplete ?? this.isComplete,
      isSkipped: isSkipped ?? this.isSkipped,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentQuestionType: currentQuestionType ?? this.currentQuestionType,
    );
  }

  /// Calculate progress percentage
  double get progressPercentage => totalSteps > 0 ? currentStep / totalSteps : 0.0;
  
  /// Check if this is the first step
  bool get isFirstStep => currentStep == 0;
  
  /// Check if this is the last step
  bool get isLastStep => currentStep >= totalSteps - 1;
  
  /// Check if can go to next step
  bool get canGoNext => currentStep < totalSteps - 1;
  
  /// Check if can go to previous step
  bool get canGoBack => currentStep > 0;
  
  /// Check if onboarding has started
  bool get hasStarted => currentStep > 0 || userPreferences.isNotEmpty;
}

/// Types of questions in the onboarding flow
enum OnboardingQuestionType {
  welcome,
  stylePreference,
  colorSelection,
  brandPreference,
  budgetRange,
  occasionTypes,
  bodyMeasurements,
  shoppingHabits,
  personalityType,
  completion,
}
