import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/error/failure.dart';

/// Aura AI API Service for image processing and style recommendations
/// 
/// This service handles communication with the Aura AI backend:
/// - Image processing for clothing analysis
/// - Personalized style recommendations
class AuraAiService {
  static const String _baseUrl = 'https://aura-one-sigma.vercel.app';
  static const String _processImageEndpoint = '/process-image/';
  static const String _getRecommendationEndpoint = '/get-recommendation/';
  
  final http.Client _httpClient;
  
  AuraAiService({http.Client? httpClient}) 
      : _httpClient = httpClient ?? http.Client();

  /// Process clothing image to extract features and categories
  /// 
  /// Sends image to AI for analysis and returns structured data about:
  /// - Clothing category (shirt, pants, dress, etc.)
  /// - Colors detected in the image
  /// - Style attributes (casual, formal, sporty, etc.)
  /// - Season appropriateness
  /// - Material detection
  Future<Either<Failure, ClothingAnalysisResult>> processImage(File imageFile) async {
    try {
      final uri = Uri.parse('$_baseUrl$_processImageEndpoint');
      
      final request = http.MultipartRequest('POST', uri);
      // Backend expects 'file' field name
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );
      
      final streamedResponse = await _httpClient.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        return Right(ClothingAnalysisResult.fromJson(data));
      } else if (response.statusCode == 400) {
        // Bad Request - Invalid image file
        final Map<String, dynamic> errorData = json.decode(response.body) as Map<String, dynamic>;
        return Left(ValidationFailure(
          message: 'Invalid image file',
          details: errorData['detail'] as String? ?? 'Please upload a valid image file.',
        ));
      } else if (response.statusCode == 500) {
        // Internal Server Error - AI processing failed
        final Map<String, dynamic> errorData = json.decode(response.body) as Map<String, dynamic>;
        return Left(UnknownFailure(
          message: 'AI processing failed',
          details: errorData['detail'] as String? ?? 'Server error occurred while processing image.',
        ));
      } else {
        return Left(NetworkFailure(
          message: 'Failed to process image',
          code: response.statusCode.toString(),
          details: response.body,
        ));
      }
    } on SocketException {
      return Left(NetworkFailure(
        message: 'No internet connection',
        details: 'Please check your internet connection and try again.',
      ));
    } on FormatException {
      return Left(ValidationFailure(
        message: 'Invalid response format',
        details: 'The server returned an invalid response.',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Unexpected error occurred',
        details: e.toString(),
      ));
    }
  }

  /// Process clothing image from XFile (web compatible)
  Future<Either<Failure, ClothingAnalysisResult>> processImageFromXFile(XFile imageFile) async {
    try {
      final uri = Uri.parse('$_baseUrl$_processImageEndpoint');
      
      final request = http.MultipartRequest('POST', uri);
      final bytes = await imageFile.readAsBytes();
      
      // Backend expects 'file' field name, not 'image'
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',  // Backend beklediği field name
          bytes,
          filename: imageFile.name,
        ),
      );
      
      // Content-Type multipart/form-data olarak ayarlanacak otomatik
      final streamedResponse = await _httpClient.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        return Right(ClothingAnalysisResult.fromJson(data));
      } else if (response.statusCode == 400) {
        // Bad Request - Invalid image file
        final Map<String, dynamic> errorData = json.decode(response.body) as Map<String, dynamic>;
        return Left(ValidationFailure(
          message: 'Invalid image file',
          details: errorData['detail'] as String? ?? 'Please upload a valid image file.',
        ));
      } else if (response.statusCode == 500) {
        // Internal Server Error - AI processing failed
        final Map<String, dynamic> errorData = json.decode(response.body) as Map<String, dynamic>;
        return Left(UnknownFailure(
          message: 'AI processing failed',
          details: errorData['detail'] as String? ?? 'Server error occurred while processing image.',
        ));
      } else {
        return Left(NetworkFailure(
          message: 'Failed to process image',
          code: response.statusCode.toString(),
          details: response.body,
        ));
      }
    } on SocketException {
      return Left(NetworkFailure(
        message: 'No internet connection',
        details: 'Please check your internet connection and try again.',
      ));
    } on FormatException {
      return Left(ValidationFailure(
        message: 'Invalid response format',
        details: 'The server returned an invalid response.',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Unexpected error occurred',
        details: e.toString(),
      ));
    }
  }

  /// Get personalized style recommendations
  /// 
  /// Sends user ID and query to get AI-powered style advice:
  /// - Outfit combinations based on wardrobe
  /// - Style suggestions for occasions
  /// - Color coordination advice
  /// - Shopping recommendations
  Future<Either<Failure, StyleRecommendationResult>> getRecommendation({
    required String userId,
    required String query,
    Map<String, dynamic>? context,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$_getRecommendationEndpoint');
      
      final body = {
        'user_id': userId,
        'query': query,
        if (context != null) 'context': context,
      };
      
      final response = await _httpClient.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        return Right(StyleRecommendationResult.fromJson(data));
      } else {
        return Left(NetworkFailure(
          message: 'Failed to get recommendation',
          code: response.statusCode.toString(),
          details: response.body,
        ));
      }
    } on SocketException {
      return Left(NetworkFailure(
        message: 'No internet connection',
        details: 'Please check your internet connection and try again.',
      ));
    } on FormatException {
      return Left(ValidationFailure(
        message: 'Invalid response format',
        details: 'The server returned an invalid response.',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Unexpected error occurred',
        details: e.toString(),
      ));
    }
  }

  /// Test API connectivity
  Future<Either<Failure, bool>> testConnection() async {
    try {
      final uri = Uri.parse('$_baseUrl/');
      final response = await _httpClient.get(uri).timeout(
        const Duration(seconds: 10),
      );
      // Accept 200 OK, 404 Not Found, or 405 Method Not Allowed (service is running)
      return Right(response.statusCode == 200 || 
                   response.statusCode == 404 || 
                   response.statusCode == 405);
    } catch (e) {
      return Left(NetworkFailure(
        message: 'Failed to connect to AI service',
        details: e.toString(),
      ));
    }
  }

  void dispose() {
    _httpClient.close();
  }
}

/// Result model for clothing image analysis
class ClothingAnalysisResult {
  final bool success;
  final String message;
  final String category;
  final String color;
  final String pattern;
  final String style;
  final String season;
  final String material;

  const ClothingAnalysisResult({
    required this.success,
    required this.message,
    required this.category,
    required this.color,
    required this.pattern,
    required this.style,
    required this.season,
    required this.material,
  });

  factory ClothingAnalysisResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return ClothingAnalysisResult(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      category: data['kategori'] as String? ?? 'unknown',
      color: data['renk'] as String? ?? 'unknown',
      pattern: data['desen'] as String? ?? 'unknown',
      style: data['stil'] as String? ?? 'unknown',
      season: data['mevsim'] as String? ?? 'unknown',
      material: data['kumas'] as String? ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': {
        'kategori': category,
        'renk': color,
        'desen': pattern,
        'stil': style,
        'mevsim': season,
        'kumas': material,
      },
    };
  }
}

/// Result model for style recommendations
class StyleRecommendationResult {
  final String recommendation;
  final List<OutfitSuggestion> outfits;
  final List<String> tips;
  final double confidence;
  final Map<String, dynamic> context;

  const StyleRecommendationResult({
    required this.recommendation,
    required this.outfits,
    required this.tips,
    required this.confidence,
    this.context = const {},
  });

  factory StyleRecommendationResult.fromJson(Map<String, dynamic> json) {
    return StyleRecommendationResult(
      recommendation: json['recommendation'] as String? ?? '',
      outfits: (json['outfits'] as List? ?? [])
          .map<OutfitSuggestion>((outfit) => OutfitSuggestion.fromJson(outfit as Map<String, dynamic>))
          .toList(),
      tips: List<String>.from(json['tips'] as List? ?? []),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      context: json['context'] as Map<String, dynamic>? ?? {},
    );
  }
}

/// Outfit suggestion from AI
class OutfitSuggestion {
  final String id;
  final String description;
  final List<String> items;
  final String occasion;
  final double suitability;

  const OutfitSuggestion({
    required this.id,
    required this.description,
    required this.items,
    required this.occasion,
    required this.suitability,
  });

  factory OutfitSuggestion.fromJson(Map<String, dynamic> json) {
    return OutfitSuggestion(
      id: json['id'] as String? ?? '',
      description: json['description'] as String? ?? '',
      items: List<String>.from(json['items'] as List? ?? []),
      occasion: json['occasion'] as String? ?? '',
      suitability: (json['suitability'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
