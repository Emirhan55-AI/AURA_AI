import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/clothing_item.dart';
import '../../domain/entities/styling_suggestion.dart';

part 'styling_suggestion_dto.freezed.dart';
part 'styling_suggestion_dto.g.dart';

/// Data Transfer Object for styling suggestion API requests
@freezed
class StylingSuggestionRequestDto with _$StylingSuggestionRequestDto {
  const factory StylingSuggestionRequestDto({
    /// List of clothing items to generate suggestions for
    required List<ClothingItemDto> wardrobeItems,
    
    /// Optional occasion filter for suggestions
    String? occasion,
    
    /// Optional season filter for suggestions
    String? season,
    
    /// Optional style preferences
    @Default([]) List<String> stylePreferences,
    
    /// Maximum number of suggestions to generate
    @Default(10) int maxSuggestions,
  }) = _StylingSuggestionRequestDto;

  factory StylingSuggestionRequestDto.fromJson(Map<String, dynamic> json) => 
      _$StylingSuggestionRequestDtoFromJson(json);
}

/// Simplified clothing item DTO for API requests
@freezed
class ClothingItemDto with _$ClothingItemDto {
  const factory ClothingItemDto({
    required String id,
    required String name,
    String? category,
    String? color,
    String? pattern,
    String? brand,
    String? size,
    List<String>? tags,
    Map<String, dynamic>? aiTags,
    String? imageUrl,
  }) = _ClothingItemDto;

  factory ClothingItemDto.fromJson(Map<String, dynamic> json) => 
      _$ClothingItemDtoFromJson(json);

  /// Convert from domain entity to DTO
  factory ClothingItemDto.fromEntity(ClothingItem item) {
    return ClothingItemDto(
      id: item.id,
      name: item.name,
      category: item.category,
      color: item.color,
      pattern: item.pattern,
      brand: item.brand,
      size: item.size,
      tags: item.tags,
      aiTags: item.aiTags,
      imageUrl: item.imageUrl,
    );
  }
}

/// Data Transfer Object for styling suggestion API responses
@freezed
class StylingSuggestionResponseDto with _$StylingSuggestionResponseDto {
  const factory StylingSuggestionResponseDto({
    required String id,
    required String title,
    required String description,
    required List<String> itemIds,
    String? imageUrl,
    @Default(0.0) double confidenceScore,
    String? occasion,
    String? season,
    @Default([]) List<String> styleTags,
    required String createdAt,
    @Default({}) Map<String, dynamic> metadata,
  }) = _StylingSuggestionResponseDto;

  factory StylingSuggestionResponseDto.fromJson(Map<String, dynamic> json) => 
      _$StylingSuggestionResponseDtoFromJson(json);
}

/// Extension for converting DTO to domain entity
extension StylingSuggestionResponseDtoExtension on StylingSuggestionResponseDto {
  /// Convert from DTO to domain entity
  StylingSuggestion toDomainEntity() {
    return StylingSuggestion(
      id: id,
      title: title,
      description: description,
      itemIds: itemIds,
      imageUrl: imageUrl,
      confidenceScore: confidenceScore,
      occasion: occasion,
      season: season,
      styleTags: styleTags,
      createdAt: DateTime.parse(createdAt),
      metadata: metadata,
    );
  }
}

/// API response wrapper for styling suggestions
@freezed
class StylingSuggestionsApiResponse with _$StylingSuggestionsApiResponse {
  const factory StylingSuggestionsApiResponse({
    required bool success,
    required List<StylingSuggestionResponseDto> suggestions,
    String? message,
    @Default({}) Map<String, dynamic> metadata,
  }) = _StylingSuggestionsApiResponse;

  factory StylingSuggestionsApiResponse.fromJson(Map<String, dynamic> json) => 
      _$StylingSuggestionsApiResponseFromJson(json);
}
