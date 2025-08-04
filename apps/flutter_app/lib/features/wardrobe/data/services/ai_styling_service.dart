import 'dart:convert';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/clothing_item.dart';
import '../../domain/entities/styling_suggestion.dart';
import '../models/styling_suggestion_dto.dart';

/// Service class for handling AI-powered styling suggestions
/// Communicates with the custom FastAPI backend to generate outfit recommendations
/// based on the user's wardrobe items and preferences
class AiStylingService {
  final SupabaseClient _supabaseClient;
  
  // TODO: Move to configuration/environment variables
  static const String _baseUrl = 'http://127.0.0.1:8000';
  static const String _apiVersion = 'v1';
  static const String _stylingSuggestionsEndpoint = '/api/$_apiVersion/style-suggestions';

  const AiStylingService(this._supabaseClient);

  /// Generates AI-powered styling suggestions based on wardrobe items
  /// 
  /// [wardrobeItems] - List of clothing items to generate suggestions for
  /// [occasion] - Optional occasion filter (e.g., 'casual', 'formal', 'business')
  /// [season] - Optional season filter (e.g., 'spring', 'summer', 'fall', 'winter')
  /// [stylePreferences] - Optional list of style preferences
  /// [maxSuggestions] - Maximum number of suggestions to generate (default: 10)
  /// 
  /// Returns a list of [StylingSuggestion] objects
  /// Throws [AiServiceException] on API errors
  /// Throws [ServerException] on server communication failures
  Future<List<StylingSuggestion>> generateSuggestions(
    List<ClothingItem> wardrobeItems, {
    String? occasion,
    String? season,
    List<String>? stylePreferences,
    int maxSuggestions = 10,
  }) async {
    try {
      // Validate input
      if (wardrobeItems.isEmpty) {
        throw const AiServiceException(
          message: 'Cannot generate suggestions with empty wardrobe',
          code: 'EMPTY_WARDROBE',
        );
      }

      // Get authentication token
      final session = _supabaseClient.auth.currentSession;
      if (session?.accessToken == null) {
        throw const AiServiceException(
          message: 'User authentication required for AI suggestions',
          code: 'AUTH_REQUIRED',
        );
      }

      // Prepare request payload
      final requestDto = StylingSuggestionRequestDto(
        wardrobeItems: wardrobeItems
            .map((item) => ClothingItemDto.fromEntity(item))
            .toList(),
        occasion: occasion,
        season: season,
        stylePreferences: stylePreferences ?? [],
        maxSuggestions: maxSuggestions,
      );

      // Prepare HTTP request
      final url = '$_baseUrl$_stylingSuggestionsEndpoint';
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${session!.accessToken}',
      };
      
      final body = jsonEncode(requestDto.toJson());

      // Make HTTP request using Supabase's HTTP client
      final httpClient = HttpClient();
      final request = await httpClient.postUrl(Uri.parse(url));
      
      // Set headers
      headers.forEach((key, value) {
        request.headers.set(key, value);
      });
      
      // Write body
      request.write(body);
      
      // Get response
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      // Handle response
      if (response.statusCode == 200) {
        return _parseSuccessResponse(responseBody);
      } else {
        await _handleErrorResponse(response.statusCode, responseBody);
        // This line should never be reached due to exception throwing above
        return [];
      }
    } on AiServiceException {
      // Re-throw AI service exceptions
      rethrow;
    } on SocketException catch (e) {
      throw ServerException(
        message: 'Unable to connect to styling service. Please check your internet connection.',
        code: 'NETWORK_ERROR',
        details: e.toString(),
      );
    } on FormatException catch (e) {
      throw const ServerException(
        message: 'Invalid response format from styling service',
        code: 'INVALID_RESPONSE_FORMAT',
      );
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error occurred while generating styling suggestions',
        code: 'UNKNOWN_ERROR',
        details: e.toString(),
      );
    }
  }

  /// Parses successful API response into domain entities
  List<StylingSuggestion> _parseSuccessResponse(String responseBody) {
    try {
      final jsonData = jsonDecode(responseBody) as Map<String, dynamic>;
      final apiResponse = StylingSuggestionsApiResponse.fromJson(jsonData);
      
      if (!apiResponse.success) {
        throw AiServiceException(
          message: apiResponse.message ?? 'AI service returned unsuccessful response',
          code: 'AI_SERVICE_ERROR',
        );
      }

      return apiResponse.suggestions
          .map((dto) => dto.toDomainEntity())
          .toList();
    } on FormatException {
      throw const ServerException(
        message: 'Invalid JSON response from styling service',
        code: 'INVALID_JSON',
      );
    }
  }

  /// Handles API error responses
  Future<void> _handleErrorResponse(int statusCode, String responseBody) async {
    String errorMessage;
    String errorCode;

    try {
      final jsonData = jsonDecode(responseBody) as Map<String, dynamic>;
      errorMessage = jsonData['message'] as String? ?? 'Unknown error occurred';
      errorCode = jsonData['code'] as String? ?? 'UNKNOWN_ERROR';
    } catch (_) {
      errorMessage = 'Server error occurred';
      errorCode = 'SERVER_ERROR';
    }

    switch (statusCode) {
      case 400:
        throw AiServiceException(
          message: 'Invalid request: $errorMessage',
          code: 'BAD_REQUEST',
        );
      case 401:
        throw const AiServiceException(
          message: 'Authentication failed. Please sign in again.',
          code: 'UNAUTHORIZED',
        );
      case 403:
        throw const AiServiceException(
          message: 'Access denied to styling service',
          code: 'FORBIDDEN',
        );
      case 429:
        throw const AiServiceException(
          message: 'Too many requests. Please wait before generating more suggestions.',
          code: 'RATE_LIMIT_EXCEEDED',
        );
      case 500:
        throw const AiServiceException(
          message: 'Styling service is temporarily unavailable',
          code: 'SERVER_ERROR',
        );
      case 503:
        throw const AiServiceException(
          message: 'Styling service is under maintenance',
          code: 'SERVICE_UNAVAILABLE',
        );
      default:
        throw AiServiceException(
          message: errorMessage,
          code: errorCode,
        );
    }
  }
}

/// Exception class for AI styling service errors
class AiServiceException extends AppException {
  const AiServiceException({
    required String message,
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code,
          details: details,
        );
}
