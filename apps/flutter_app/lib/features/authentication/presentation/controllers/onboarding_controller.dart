import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/onboarding_state.dart';
import '../../../../core/services/preferences_service.dart';

part 'onboarding_controller.g.dart';

/// Controller for managing onboarding flow state and user interactions
/// Handles progress tracking, preference collection, and flow navigation
@riverpod
class OnboardingController extends _$OnboardingController {
  @override
  OnboardingState build() {
    return const OnboardingState();
  }

  /// Move to next step in onboarding
  void nextStep() {
    if (state.canGoNext) {
      state = state.copyWith(
        currentStep: state.currentStep + 1,
        currentQuestionType: _getQuestionTypeForStep(state.currentStep + 1),
      );
    }
  }

  /// Move to previous step in onboarding
  void previousStep() {
    if (state.canGoBack) {
      state = state.copyWith(
        currentStep: state.currentStep - 1,
        currentQuestionType: _getQuestionTypeForStep(state.currentStep - 1),
      );
    }
  }

  /// Jump to specific step
  void goToStep(int step) {
    if (step >= 0 && step < state.totalSteps) {
      state = state.copyWith(
        currentStep: step,
        currentQuestionType: _getQuestionTypeForStep(step),
      );
    }
  }

  /// Update user preference
  void updatePreference(String key, dynamic value) {
    final updatedPreferences = Map<String, dynamic>.from(state.userPreferences);
    updatedPreferences[key] = value;
    
    state = state.copyWith(userPreferences: updatedPreferences);
  }

  /// Update multiple preferences at once
  void updatePreferences(Map<String, dynamic> preferences) {
    final updatedPreferences = Map<String, dynamic>.from(state.userPreferences);
    updatedPreferences.addAll(preferences);
    
    state = state.copyWith(userPreferences: updatedPreferences);
  }

  /// Complete onboarding process
  Future<void> completeOnboarding() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Save onboarding completion status
      final preferencesService = ref.read(preferencesServiceProvider);
      await preferencesService.setOnboardingComplete(true);
      await preferencesService.setHasSeenOnboarding(true);
      
      // TODO: Save user preferences to backend
      // final profileService = ref.read(profileServiceProvider);
      // await profileService.saveStyleProfile(state.userPreferences);
      
      state = state.copyWith(
        isComplete: true,
        isLoading: false,
        currentStep: state.totalSteps,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  /// Skip onboarding and apply default profile
  Future<void> skipOnboarding() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final preferencesService = ref.read(preferencesServiceProvider);
      await preferencesService.setOnboardingComplete(true);
      await preferencesService.setHasSeenOnboarding(true);
      
      // Apply default style profile
      final defaultPreferences = _getDefaultStyleProfile();
      
      // TODO: Save default profile to backend
      // final profileService = ref.read(profileServiceProvider);
      // await profileService.saveStyleProfile(defaultPreferences);
      
      state = state.copyWith(
        isComplete: true,
        isSkipped: true,
        isLoading: false,
        userPreferences: defaultPreferences,
        currentStep: state.totalSteps,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  /// Reset onboarding state
  void reset() {
    state = const OnboardingState();
  }

  /// Set error state
  void setError(String error) {
    state = state.copyWith(error: error);
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Get question type for specific step
  OnboardingQuestionType _getQuestionTypeForStep(int step) {
    switch (step) {
      case 0:
        return OnboardingQuestionType.welcome;
      case 1:
        return OnboardingQuestionType.stylePreference;
      case 2:
        return OnboardingQuestionType.colorSelection;
      case 3:
        return OnboardingQuestionType.brandPreference;
      case 4:
        return OnboardingQuestionType.budgetRange;
      case 5:
        return OnboardingQuestionType.occasionTypes;
      case 6:
        return OnboardingQuestionType.bodyMeasurements;
      case 7:
        return OnboardingQuestionType.shoppingHabits;
      case 8:
        return OnboardingQuestionType.personalityType;
      case 9:
        return OnboardingQuestionType.completion;
      default:
        return OnboardingQuestionType.welcome;
    }
  }

  /// Get default style profile for skipped onboarding
  Map<String, dynamic> _getDefaultStyleProfile() {
    return {
      'mood': 'neutral',
      'style': 'casual',
      'colors': ['beige', 'gray', 'navy'],
      'budget': 'medium',
      'formality': 0.3,
      'brands': ['generic'],
      'occasions': ['everyday', 'work'],
      'shopping_frequency': 'monthly',
      'size_preference': 'regular',
      'personality_type': 'balanced',
    };
  }
}

/// Provider for checking if user has seen onboarding
@riverpod
Future<bool> hasSeenOnboarding(HasSeenOnboardingRef ref) async {
  final preferencesService = ref.read(preferencesServiceProvider);
  return await preferencesService.getHasSeenOnboarding();
}
