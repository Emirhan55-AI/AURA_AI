import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/ai_styling_service.dart';
import '../../domain/usecases/generate_styling_suggestions_use_case.dart';
import '../../domain/entities/styling_suggestion.dart';
import '../../providers/repository_providers.dart';

/// Provider for AI Styling Service
/// Creates a singleton instance configured with Supabase client for authentication
final aiStylingServiceProvider = Provider<AiStylingService>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return AiStylingService(supabaseClient);
});

/// Provider for Generate Styling Suggestions Use Case
/// Combines wardrobe repository and AI styling service to create the use case
final generateStylingSuggestionsUseCaseProvider = Provider<GenerateStylingSuggestionsUseCase>((ref) {
  final wardrobeRepository = ref.watch(wardrobeRepositoryProvider);
  final aiStylingService = ref.watch(aiStylingServiceProvider);
  
  return GenerateStylingSuggestionsUseCase(
    wardrobeRepository,
    aiStylingService,
  );
});

/// Provider for use case parameters - can be overridden for different contexts
final suggestionsParamsProvider = StateProvider<GenerateSuggestionsParams>((ref) {
  return const GenerateSuggestionsParams();
});

/// Provider for managing suggestions generation state
final suggestionsGenerationProvider = StateNotifierProvider<SuggestionsGenerationNotifier, SuggestionsGenerationState>((ref) {
  final generateSuggestionsUseCase = ref.watch(generateStylingSuggestionsUseCaseProvider);
  return SuggestionsGenerationNotifier(generateSuggestionsUseCase);
});

/// State class for suggestions generation
class SuggestionsGenerationState {
  final bool isLoading;
  final List<StylingSuggestion> suggestions;
  final String? error;
  final bool hasError;

  const SuggestionsGenerationState({
    this.isLoading = false,
    this.suggestions = const [],
    this.error,
    this.hasError = false,
  });

  SuggestionsGenerationState copyWith({
    bool? isLoading,
    List<StylingSuggestion>? suggestions,
    String? error,
    bool? hasError,
  }) {
    return SuggestionsGenerationState(
      isLoading: isLoading ?? this.isLoading,
      suggestions: suggestions ?? this.suggestions,
      error: error ?? this.error,
      hasError: hasError ?? this.hasError,
    );
  }
}

/// State notifier for managing suggestions generation
class SuggestionsGenerationNotifier extends StateNotifier<SuggestionsGenerationState> {
  final GenerateStylingSuggestionsUseCase _generateSuggestionsUseCase;

  SuggestionsGenerationNotifier(this._generateSuggestionsUseCase) 
      : super(const SuggestionsGenerationState());

  /// Generates styling suggestions with the provided parameters
  Future<void> generateSuggestions(GenerateSuggestionsParams params) async {
    state = state.copyWith(isLoading: true, hasError: false, error: null);

    final result = await _generateSuggestionsUseCase.call(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          hasError: true,
          error: failure.message,
        );
      },
      (suggestions) {
        state = state.copyWith(
          isLoading: false,
          suggestions: suggestions,
          hasError: false,
          error: null,
        );
      },
    );
  }

  /// Clears current suggestions and error state
  void clearSuggestions() {
    state = const SuggestionsGenerationState();
  }

  /// Refreshes suggestions with current parameters
  Future<void> refresh(GenerateSuggestionsParams params) async {
    await generateSuggestions(params);
  }
}
