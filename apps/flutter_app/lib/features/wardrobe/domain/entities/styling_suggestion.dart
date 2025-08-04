import 'package:freezed_annotation/freezed_annotation.dart';

part 'styling_suggestion.freezed.dart';
part 'styling_suggestion.g.dart';

/// Domain entity representing an AI-generated styling suggestion
/// Contains information about how to style specific clothing items together
@freezed
class StylingSuggestion with _$StylingSuggestion {
  const factory StylingSuggestion({
    /// Unique identifier for the suggestion
    required String id,
    
    /// Human-readable title for the styling suggestion
    required String title,
    
    /// Detailed description of the styling suggestion
    required String description,
    
    /// List of clothing item IDs included in this suggestion
    required List<String> itemIds,
    
    /// Optional URL to a generated outfit preview image
    String? imageUrl,
    
    /// AI confidence score for this suggestion (0.0 to 1.0)
    @Default(0.0) double confidenceScore,
    
    /// Optional occasion or context for this styling suggestion
    String? occasion,
    
    /// Optional season recommendation for this styling
    String? season,
    
    /// List of style tags associated with this suggestion
    @Default([]) List<String> styleTags,
    
    /// Timestamp when this suggestion was generated
    required DateTime createdAt,
    
    /// Optional additional metadata from the AI model
    @Default({}) Map<String, dynamic> metadata,
  }) = _StylingSuggestion;

  factory StylingSuggestion.fromJson(Map<String, dynamic> json) => 
      _$StylingSuggestionFromJson(json);
}
