import 'dart:math';

import '../../domain/entities/clothing_item.dart';
import '../../domain/entities/styling_suggestion.dart';

/// Mock AI Styling Service for development and testing
/// Provides realistic styling suggestions without external API dependencies
class MockAiStylingService {
  static const int _defaultSuggestionsCount = 5;
  static const double _minConfidenceScore = 0.65;
  static const double _maxConfidenceScore = 0.95;
  
  static final Random _random = Random();

  /// Generates mock AI-powered styling suggestions based on wardrobe items
  /// 
  /// [wardrobeItems] - List of clothing items to generate suggestions for
  /// [occasion] - Optional occasion filter
  /// [season] - Optional season filter  
  /// [stylePreferences] - Optional list of style preferences
  /// [maxSuggestions] - Maximum number of suggestions to generate
  /// 
  /// Returns a realistic list of [StylingSuggestion] objects with mock data
  Future<List<StylingSuggestion>> generateSuggestions(
    List<ClothingItem> wardrobeItems, {
    String? occasion,
    String? season,
    List<String>? stylePreferences,
    int maxSuggestions = _defaultSuggestionsCount,
  }) async {
    // Simulate network delay for realistic behavior
    await Future<void>.delayed(const Duration(milliseconds: 1200));

    if (wardrobeItems.isEmpty) {
      return [];
    }

    final suggestions = <StylingSuggestion>[];
    final availableItems = wardrobeItems.where((item) => item.deletedAt == null).toList();
    
    if (availableItems.isEmpty) {
      return suggestions;
    }

    // Generate suggestions based on available items
    for (int i = 0; i < maxSuggestions && i < _mockSuggestionTemplates.length; i++) {
      final template = _mockSuggestionTemplates[i];
      
      // Filter template by occasion and season if specified
      if (occasion != null && !template.occasion.toLowerCase().contains(occasion.toLowerCase())) {
        continue;
      }
      
      if (season != null && !template.season.toLowerCase().contains(season.toLowerCase())) {
        continue;
      }

      // Select random items that match the template categories
      final selectedItems = _selectItemsForTemplate(availableItems, template);
      
      if (selectedItems.isEmpty) continue;

      final suggestion = StylingSuggestion(
        id: 'mock_suggestion_${DateTime.now().millisecondsSinceEpoch}_$i',
        title: template.title,
        description: template.description,
        itemIds: selectedItems.map((item) => item.id).toList(),
        imageUrl: template.imageUrl,
        confidenceScore: _generateConfidenceScore(),
        occasion: template.occasion,
        season: template.season,
        styleTags: template.styleTags,
        createdAt: DateTime.now(),
        metadata: {
          'generated_by': 'mock_ai_service',
          'item_count': selectedItems.length,
          'primary_category': selectedItems.first.category,
          'style_compatibility': _random.nextDouble(),
          'color_palette': template.colorPalette,
        },
      );

      suggestions.add(suggestion);
    }

    // Sort by confidence score (highest first)
    suggestions.sort((a, b) => b.confidenceScore.compareTo(a.confidenceScore));
    
    return suggestions;
  }

  /// Select clothing items that match the template requirements
  List<ClothingItem> _selectItemsForTemplate(
    List<ClothingItem> availableItems,
    _MockSuggestionTemplate template,
  ) {
    final selectedItems = <ClothingItem>[];
    
    for (final requiredCategory in template.requiredCategories) {
      final matchingItems = availableItems.where(
        (item) => item.category?.toLowerCase() == requiredCategory.toLowerCase(),
      ).toList();
      
      if (matchingItems.isNotEmpty) {
        // Pick random item from matching category
        selectedItems.add(matchingItems[_random.nextInt(matchingItems.length)]);
      }
    }

    // Add some optional items if available
    final remainingItems = availableItems.where(
      (item) => !selectedItems.contains(item),
    ).toList();
    
    final optionalCount = _random.nextInt(2) + 1; // 1-2 optional items
    for (int i = 0; i < optionalCount && i < remainingItems.length; i++) {
      selectedItems.add(remainingItems[_random.nextInt(remainingItems.length)]);
    }

    return selectedItems;
  }

  /// Generate a realistic confidence score
  double _generateConfidenceScore() {
    return _minConfidenceScore + 
           (_maxConfidenceScore - _minConfidenceScore) * _random.nextDouble();
  }
}

/// Internal template class for generating consistent mock data
class _MockSuggestionTemplate {
  final String title;
  final String description;
  final String occasion;
  final String season;
  final List<String> requiredCategories;
  final List<String> styleTags;
  final List<String> colorPalette;
  final String? imageUrl;

  const _MockSuggestionTemplate({
    required this.title,
    required this.description,
    required this.occasion,
    required this.season,
    required this.requiredCategories,
    required this.styleTags,
    required this.colorPalette,
    this.imageUrl,
  });
}

/// Mock suggestion templates for realistic data generation
const _mockSuggestionTemplates = [
  _MockSuggestionTemplate(
    title: 'Casual Weekend Comfort',
    description: 'Perfect for relaxed weekend activities with friends. Comfortable yet stylish, this combination works great for coffee dates, shopping trips, or casual outings.',
    occasion: 'Casual',
    season: 'All Seasons',
    requiredCategories: ['t-shirt', 'jeans', 'sneakers'],
    styleTags: ['comfortable', 'relaxed', 'casual', 'everyday'],
    colorPalette: ['neutral', 'denim', 'white'],
    imageUrl: 'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=400',
  ),

  _MockSuggestionTemplate(
    title: 'Business Professional',
    description: 'Sophisticated office look that commands respect and confidence. This ensemble is perfect for important meetings, presentations, or networking events.',
    occasion: 'Business',
    season: 'All Seasons',
    requiredCategories: ['blazer', 'dress shirt', 'dress pants'],
    styleTags: ['professional', 'sophisticated', 'formal', 'confident'],
    colorPalette: ['navy', 'white', 'black'],
    imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
  ),

  _MockSuggestionTemplate(
    title: 'Evening Elegance',
    description: 'Stunning formal attire for special occasions. This combination creates a polished, elegant look perfect for dinner dates, parties, or cultural events.',
    occasion: 'Formal',
    season: 'All Seasons',
    requiredCategories: ['dress', 'heels'],
    styleTags: ['elegant', 'sophisticated', 'classy', 'formal'],
    colorPalette: ['black', 'gold', 'silver'],
    imageUrl: 'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?w=400',
  ),

  _MockSuggestionTemplate(
    title: 'Summer Breeze Style',
    description: 'Light and airy combination perfect for warm summer days. This outfit keeps you cool while maintaining a fresh, put-together appearance.',
    occasion: 'Casual',
    season: 'Summer',
    requiredCategories: ['t-shirt', 'shorts', 'sandals'],
    styleTags: ['summer', 'light', 'breathable', 'fresh'],
    colorPalette: ['light blue', 'white', 'coral'],
    imageUrl: 'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=400',
  ),

  _MockSuggestionTemplate(
    title: 'Cozy Fall Layers',
    description: 'Warm and stylish layered look for autumn weather. This combination provides both comfort and style for crisp fall days.',
    occasion: 'Casual',
    season: 'Fall',
    requiredCategories: ['sweater', 'jeans', 'boots'],
    styleTags: ['cozy', 'layered', 'autumn', 'warm'],
    colorPalette: ['burgundy', 'brown', 'cream'],
    imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
  ),

  _MockSuggestionTemplate(
    title: 'Winter Chic',
    description: 'Stylish cold-weather ensemble that doesn\'t compromise on fashion. Perfect for winter events or daily wear during the colder months.',
    occasion: 'Casual',
    season: 'Winter',
    requiredCategories: ['coat', 'sweater', 'boots'],
    styleTags: ['winter', 'warm', 'chic', 'layered'],
    colorPalette: ['charcoal', 'camel', 'black'],
    imageUrl: 'https://images.unsplash.com/photo-1551488831-00ddcb6c6bd3?w=400',
  ),

  _MockSuggestionTemplate(
    title: 'Date Night Perfection',
    description: 'Romantic and alluring combination for special evenings out. This look strikes the perfect balance between elegance and charm.',
    occasion: 'Date',
    season: 'All Seasons',
    requiredCategories: ['blouse', 'skirt', 'heels'],
    styleTags: ['romantic', 'elegant', 'charming', 'sophisticated'],
    colorPalette: ['rose', 'cream', 'gold'],
    imageUrl: 'https://images.unsplash.com/photo-1487222477894-8943e31ef7b2?w=400',
  ),

  _MockSuggestionTemplate(
    title: 'Active Lifestyle',
    description: 'Functional athletic wear that transitions seamlessly from workout to casual errands. Comfortable and performance-focused styling.',
    occasion: 'Workout',
    season: 'All Seasons',
    requiredCategories: ['athletic top', 'leggings', 'athletic shoes'],
    styleTags: ['athletic', 'functional', 'comfortable', 'active'],
    colorPalette: ['black', 'gray', 'neon'],
    imageUrl: 'https://images.unsplash.com/photo-1506629905607-d52b19d0b5f5?w=400',
  ),

  _MockSuggestionTemplate(
    title: 'Brunch Ready',
    description: 'Perfect for weekend brunch with friends. This outfit is effortlessly chic and conversation-starter worthy.',
    occasion: 'Casual',
    season: 'Spring',
    requiredCategories: ['blouse', 'jeans', 'flats'],
    styleTags: ['brunch', 'chic', 'effortless', 'social'],
    colorPalette: ['pastels', 'white', 'nude'],
    imageUrl: 'https://images.unsplash.com/photo-1445205170230-053b83016050?w=400',
  ),

  _MockSuggestionTemplate(
    title: 'Creative Professional',
    description: 'Unique blend of professionalism and creativity. Perfect for creative industries where you need to look polished but still express your personality.',
    occasion: 'Business',
    season: 'All Seasons',
    requiredCategories: ['blazer', 'blouse', 'dress pants'],
    styleTags: ['creative', 'professional', 'unique', 'expressive'],
    colorPalette: ['jewel tones', 'black', 'metallic'],
    imageUrl: 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=400',
  ),
];
