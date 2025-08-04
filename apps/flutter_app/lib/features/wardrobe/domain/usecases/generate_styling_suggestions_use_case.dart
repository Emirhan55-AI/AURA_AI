import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/styling_suggestion.dart';
import '../entities/clothing_item.dart';
import '../repositories/wardrobe_repository.dart';
import '../../data/services/ai_styling_service.dart';

/// Use case for generating AI-powered styling suggestions
/// Orchestrates the process of fetching user's wardrobe and generating suggestions
/// following Clean Architecture principles
class GenerateStylingSuggestionsUseCase {
  final WardrobeRepository _wardrobeRepository;
  final AiStylingService _aiStylingService;

  const GenerateStylingSuggestionsUseCase(
    this._wardrobeRepository,
    this._aiStylingService,
  );

  /// Executes the styling suggestions generation process
  /// 
  /// [params] - Parameters for generating suggestions including filters and preferences
  /// 
  /// Returns [Right(List<StylingSuggestion>)] on success
  /// Returns [Left(Failure)] on any error during the process
  Future<Either<Failure, List<StylingSuggestion>>> call(
    GenerateSuggestionsParams params,
  ) async {
    try {
      // Step 1: Fetch user's wardrobe items
      // Note: Using simplified repository interface - filtering will be done in-memory
      final wardrobeResult = await _wardrobeRepository.getClothingItems();

      // Handle wardrobe fetch failure
      if (wardrobeResult.isLeft()) {
        return wardrobeResult.fold(
          (failure) => Left(failure),
          (_) => const Left(UnknownFailure()), // This should never happen
        );
      }

      // Extract wardrobe items
      final allWardrobeItems = wardrobeResult.fold(
        (_) => <ClothingItem>[], // This should never happen due to isLeft check
        (items) => items,
      );

      // Step 2: Apply in-memory filtering based on parameters
      var filteredItems = allWardrobeItems;

      // Apply search term filter
      if (params.searchTerm != null && params.searchTerm!.isNotEmpty) {
        filteredItems = filteredItems.where((item) {
          final searchTerm = params.searchTerm!.toLowerCase();
          return item.name.toLowerCase().contains(searchTerm) ||
              (item.brand?.toLowerCase().contains(searchTerm) ?? false) ||
              (item.notes?.toLowerCase().contains(searchTerm) ?? false);
        }).toList();
      }

      // Apply category filter
      if (params.categoryIds != null && params.categoryIds!.isNotEmpty) {
        filteredItems = filteredItems.where((item) {
          return params.categoryIds!.contains(item.category);
        }).toList();
      }

      // Apply season filter (using tags for seasons)
      if (params.seasons != null && params.seasons!.isNotEmpty) {
        filteredItems = filteredItems.where((item) {
          return item.tags?.contains(params.seasons) ?? false;
        }).toList();
      }

      // Apply favorites filter
      if (params.showOnlyFavorites) {
        filteredItems = filteredItems.where((item) => item.isFavorite).toList();
      }

      // Limit results
      if (filteredItems.length > params.maxWardrobeItems) {
        filteredItems = filteredItems.take(params.maxWardrobeItems).toList();
      }

      // Validate wardrobe items
      if (filteredItems.isEmpty) {
        return const Left(ValidationFailure(
          message: 'Cannot generate styling suggestions with empty wardrobe. Please add some clothing items first.',
          code: 'EMPTY_WARDROBE',
        ));
      }

      // Step 3: Generate AI styling suggestions
      final suggestions = await _aiStylingService.generateSuggestions(
        filteredItems,
        occasion: params.occasion,
        season: params.seasons,
        stylePreferences: params.stylePreferences,
        maxSuggestions: params.maxSuggestions,
      );

      return Right(suggestions);
    } on AiServiceException catch (e) {
      return Left(_mapAiServiceException(e));
    } on Exception catch (e) {
      return Left(ServiceFailure(
        message: 'Failed to generate styling suggestions',
        code: 'SUGGESTION_GENERATION_FAILED',
        details: e.toString(),
      ));
    }
  }

  /// Maps AI service exceptions to appropriate failure types
  Failure _mapAiServiceException(AiServiceException exception) {
    switch (exception.code) {
      case 'EMPTY_WARDROBE':
      case 'BAD_REQUEST':
        return ValidationFailure(
          message: exception.message,
          code: exception.code,
          details: exception.details,
        );
      case 'UNAUTHORIZED':
      case 'AUTH_REQUIRED':
        return AuthFailure(
          message: exception.message,
          code: exception.code,
          details: exception.details,
        );
      case 'FORBIDDEN':
        return const AuthFailure.forbidden();
      case 'RATE_LIMIT_EXCEEDED':
        return const ServiceFailure.rateLimited();
      case 'SERVER_ERROR':
      case 'SERVICE_UNAVAILABLE':
        return ServiceFailure(
          message: exception.message,
          code: exception.code,
          details: exception.details,
        );
      default:
        return ServiceFailure(
          message: exception.message,
          code: exception.code ?? 'AI_SERVICE_ERROR',
          details: exception.details,
        );
    }
  }
}

/// Parameters for generating styling suggestions
class GenerateSuggestionsParams {
  /// Optional search term to filter wardrobe items
  final String? searchTerm;
  
  /// Optional category filters for wardrobe items
  final List<String>? categoryIds;
  
  /// Optional season filter for wardrobe items and suggestions
  final String? seasons;
  
  /// Whether to only use favorite items from wardrobe
  final bool showOnlyFavorites;
  
  /// Maximum number of wardrobe items to consider
  final int maxWardrobeItems;
  
  /// Optional occasion filter for suggestions
  final String? occasion;
  
  /// Optional style preferences
  final List<String> stylePreferences;
  
  /// Maximum number of suggestions to generate
  final int maxSuggestions;

  const GenerateSuggestionsParams({
    this.searchTerm,
    this.categoryIds,
    this.seasons,
    this.showOnlyFavorites = false,
    this.maxWardrobeItems = 100,
    this.occasion,
    this.stylePreferences = const [],
    this.maxSuggestions = 10,
  });
}

/// Simple parameters class for cases where no specific filtering is needed
class NoParams {
  const NoParams();
}
