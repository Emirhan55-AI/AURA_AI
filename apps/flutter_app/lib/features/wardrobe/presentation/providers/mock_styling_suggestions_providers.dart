import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/app_exception.dart';
import '../../domain/usecases/generate_styling_suggestions_use_case.dart';
import '../../domain/entities/styling_suggestion.dart';
import '../../domain/entities/clothing_item.dart';
import '../../domain/repositories/wardrobe_repository.dart';
import '../../data/services/mock_ai_styling_service.dart';
import '../../providers/repository_providers.dart';
import 'styling_suggestions_providers.dart';

/// Mock Provider for AI Styling Service (Development/Testing)
/// Uses mock implementation instead of real API calls
final mockAiStylingServiceProvider = Provider<MockAiStylingService>((ref) {
  return MockAiStylingService();
});

/// Mock Provider for Generate Styling Suggestions Use Case
/// Combines wardrobe repository with mock AI service for development
final mockGenerateStylingSuggestionsUseCaseProvider = Provider<MockGenerateStylingSuggestionsUseCase>((ref) {
  final wardrobeRepository = ref.watch(wardrobeRepositoryProvider);
  final aiStylingService = ref.watch(mockAiStylingServiceProvider);
  
  return MockGenerateStylingSuggestionsUseCase(
    wardrobeRepository,
    aiStylingService,
  );
});

/// Provider for managing mock suggestions generation state
final mockSuggestionsGenerationProvider = StateNotifierProvider<MockSuggestionsGenerationNotifier, SuggestionsGenerationState>((ref) {
  final generateSuggestionsUseCase = ref.watch(mockGenerateStylingSuggestionsUseCaseProvider);
  return MockSuggestionsGenerationNotifier(generateSuggestionsUseCase);
});

/// Mock Use Case that uses MockAiStylingService instead of real API
class MockGenerateStylingSuggestionsUseCase {
  final WardrobeRepository _wardrobeRepository;
  final MockAiStylingService _mockAiStylingService;

  const MockGenerateStylingSuggestionsUseCase(
    this._wardrobeRepository,
    this._mockAiStylingService,
  );

  /// Executes mock styling suggestions generation process
  Future<Either<Failure, List<StylingSuggestion>>> call(
    GenerateSuggestionsParams params,
  ) async {
    try {
      // Get user's wardrobe items from repository
      final wardrobeResult = await _wardrobeRepository.getClothingItems();
      
      final wardrobeItems = wardrobeResult.fold<List<ClothingItem>>(
        (Failure failure) => throw failure,
        (List<ClothingItem> items) => items,
      );

      // Filter items based on parameters
      final filteredItems = _filterWardrobe(wardrobeItems, params);

      // Generate mock AI suggestions
      final suggestions = await _mockAiStylingService.generateSuggestions(
        filteredItems,
        occasion: params.occasion,
        season: params.seasons,
        stylePreferences: params.stylePreferences,
        maxSuggestions: params.maxSuggestions,
      );

      return Right(suggestions);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ServerException(message: 'Failed to generate styling suggestions: $e') as Failure);
    }
  }

  /// Filter wardrobe items based on generation parameters
  List<ClothingItem> _filterWardrobe(
    List<ClothingItem> items,
    GenerateSuggestionsParams params,
  ) {
    var filtered = items.where((item) => item.deletedAt == null);

    // Filter by favorites if requested
    if (params.showOnlyFavorites == true) {
      filtered = filtered.where((item) => item.isFavorite);
    }

    // Filter by season if specified
    if (params.seasons?.isNotEmpty == true) {
      // TODO: Implement season-based filtering logic based on item tags/metadata
      // For now, return all items
    }

    return filtered.toList();
  }
}

/// Mock State Notifier for managing suggestions generation
class MockSuggestionsGenerationNotifier extends StateNotifier<SuggestionsGenerationState> {
  final MockGenerateStylingSuggestionsUseCase _generateSuggestionsUseCase;

  MockSuggestionsGenerationNotifier(this._generateSuggestionsUseCase) 
      : super(const SuggestionsGenerationState());

  /// Generates mock styling suggestions with the provided parameters
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

  /// Regenerates suggestions with the same parameters
  Future<void> regenerate() async {
    if (state.isLoading != true) {
      // Re-run with last known parameters or default
      await generateSuggestions(const GenerateSuggestionsParams());
    }
  }
}
