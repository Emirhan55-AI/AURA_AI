import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AiTaggingService {
  static const String _apiBaseUrl = 'https://api.clarifai.com/v2';
  static const String _apiKey = 'YOUR_CLARIFAI_API_KEY'; // Replace with actual API key
  
  /// Analyzes clothing image and returns category, color, and other attributes
  Future<Map<String, dynamic>> analyzeClothingImage(String imageUrl) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/models/apparel-analysis/outputs'),
        headers: {
          'Authorization': 'Key $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'inputs': [
            {
              'data': {
                'image': {
                  'url': imageUrl,
                }
              }
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return _parseAnalysisResults(data);
      } else {
        throw Exception('AI tagging failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('AI tagging error: $e');
    }
  }

  /// Analyzes clothing image from file bytes
  Future<Map<String, dynamic>> analyzeClothingImageFromFile(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/models/apparel-analysis/outputs'),
        headers: {
          'Authorization': 'Key $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'inputs': [
            {
              'data': {
                'image': {
                  'base64': base64Image,
                }
              }
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return _parseAnalysisResults(data);
      } else {
        throw Exception('AI tagging failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('AI tagging error: $e');
    }
  }

  /// Parses Clarifai API response and extracts relevant clothing attributes
  Map<String, dynamic> _parseAnalysisResults(Map<String, dynamic> data) {
    final concepts = data['outputs']?[0]?['data']?['concepts'] as List<dynamic>? ?? [];
    
    String? category;
    String? color;
    String? material;
    String? season;
    
    for (final concept in concepts) {
      final name = concept['name'] as String;
      final value = concept['value'] as double;
      
      if (value > 0.7) { // High confidence threshold
        if (_isCategory(name) && category == null) {
          category = _normalizeCategory(name);
        } else if (_isColor(name) && color == null) {
          color = _normalizeColor(name);
        } else if (_isMaterial(name) && material == null) {
          material = _normalizeMaterial(name);
        } else if (_isSeason(name) && season == null) {
          season = _normalizeSeason(name);
        }
      }
    }
    
    return {
      'category': category ?? 'Other',
      'color': color ?? 'Unknown',
      'material': material,
      'season': season,
      'confidence': concepts.isNotEmpty ? concepts.first['value'] : 0.0,
    };
  }

  bool _isCategory(String name) {
    const categories = [
      'shirt', 'pants', 'dress', 'jacket', 'shoes', 'accessory',
      'top', 'bottom', 'outerwear', 'footwear', 'blouse', 'skirt',
      'shorts', 'sweater', 'coat', 'hat', 'bag', 'belt'
    ];
    return categories.any((cat) => name.toLowerCase().contains(cat));
  }

  bool _isColor(String name) {
    const colors = [
      'red', 'blue', 'green', 'yellow', 'black', 'white', 'gray',
      'pink', 'purple', 'orange', 'brown', 'beige', 'navy', 'maroon'
    ];
    return colors.any((color) => name.toLowerCase().contains(color));
  }

  bool _isMaterial(String name) {
    const materials = [
      'cotton', 'silk', 'wool', 'leather', 'denim', 'polyester',
      'linen', 'cashmere', 'velvet', 'satin'
    ];
    return materials.any((material) => name.toLowerCase().contains(material));
  }

  bool _isSeason(String name) {
    const seasons = ['summer', 'winter', 'spring', 'autumn', 'fall'];
    return seasons.any((season) => name.toLowerCase().contains(season));
  }

  String _normalizeCategory(String name) {
    if (name.toLowerCase().contains('shirt') || name.toLowerCase().contains('blouse') || name.toLowerCase().contains('top')) {
      return 'Tops';
    } else if (name.toLowerCase().contains('pants') || name.toLowerCase().contains('bottom')) {
      return 'Bottoms';
    } else if (name.toLowerCase().contains('dress')) {
      return 'Dresses';
    } else if (name.toLowerCase().contains('jacket') || name.toLowerCase().contains('coat') || name.toLowerCase().contains('outerwear')) {
      return 'Outerwear';
    } else if (name.toLowerCase().contains('shoes') || name.toLowerCase().contains('footwear')) {
      return 'Footwear';
    } else if (name.toLowerCase().contains('accessory') || name.toLowerCase().contains('bag') || name.toLowerCase().contains('hat') || name.toLowerCase().contains('belt')) {
      return 'Accessories';
    }
    return 'Other';
  }

  String _normalizeColor(String name) {
    final color = name.toLowerCase();
    if (color.contains('red')) return 'Red';
    if (color.contains('blue')) return 'Blue';
    if (color.contains('green')) return 'Green';
    if (color.contains('yellow')) return 'Yellow';
    if (color.contains('black')) return 'Black';
    if (color.contains('white')) return 'White';
    if (color.contains('gray') || color.contains('grey')) return 'Gray';
    if (color.contains('pink')) return 'Pink';
    if (color.contains('purple')) return 'Purple';
    if (color.contains('orange')) return 'Orange';
    if (color.contains('brown')) return 'Brown';
    if (color.contains('beige')) return 'Beige';
    if (color.contains('navy')) return 'Navy';
    if (color.contains('maroon')) return 'Maroon';
    return name;
  }

  String _normalizeMaterial(String name) {
    final material = name.toLowerCase();
    if (material.contains('cotton')) return 'Cotton';
    if (material.contains('silk')) return 'Silk';
    if (material.contains('wool')) return 'Wool';
    if (material.contains('leather')) return 'Leather';
    if (material.contains('denim')) return 'Denim';
    if (material.contains('polyester')) return 'Polyester';
    if (material.contains('linen')) return 'Linen';
    if (material.contains('cashmere')) return 'Cashmere';
    if (material.contains('velvet')) return 'Velvet';
    if (material.contains('satin')) return 'Satin';
    return name;
  }

  String _normalizeSeason(String name) {
    final season = name.toLowerCase();
    if (season.contains('summer')) return 'Summer';
    if (season.contains('winter')) return 'Winter';
    if (season.contains('spring')) return 'Spring';
    if (season.contains('autumn') || season.contains('fall')) return 'Autumn';
    return name;
  }
}
