import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:http/http.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/chat_message.dart';

/// Service for communicating with the AI backend via WebSocket
/// 
/// This service handles:
/// - WebSocket connection establishment
/// - Authentication with user JWT
/// - Message serialization/deserialization
/// - Stream management for real-time AI responses
/// - Error handling and connection cleanup
class StyleAssistantAiService {
  final String _baseUrl;
  final Future<String?> Function() _getAuthToken;
  
  WebSocketChannel? _channel;
  StreamController<AiMessage>? _messageController;

  StyleAssistantAiService({
    required String baseUrl,
    required Future<String?> Function() getAuthToken,
  }) : _baseUrl = baseUrl,
       _getAuthToken = getAuthToken;

  /// Get AI response stream for a user message
  /// 
  /// [userMessage] - The user's message to send to AI
  /// 
  /// Returns a stream of AI message chunks/responses
  /// Throws [AiBackendException] on connection or communication errors
  Stream<AiMessage> getAiResponseStream(UserMessage userMessage) async* {
    try {
      developer.log('Starting AI response stream for message: ${userMessage.text}');
      
      // Get authentication token
      final token = await _getAuthToken();
      if (token == null) {
        throw NetworkException(
          message: 'User not authenticated - no auth token available',
          code: 'AUTH_TOKEN_MISSING',
        );
      }

      // Construct WebSocket URL
      final wsUrl = _baseUrl.replaceFirst('http', 'ws') + '/api/v1/chat';
      developer.log('Connecting to WebSocket: $wsUrl');

      // Establish WebSocket connection with auth token
      _channel = IOWebSocketChannel.connect(
        Uri.parse(wsUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // Create message stream controller
      _messageController = StreamController<AiMessage>();

      // Listen to WebSocket messages
      _channel!.stream.listen(
        (dynamic data) {
          try {
            developer.log('Received WebSocket message: $data');
            final jsonData = json.decode(data as String) as Map<String, dynamic>;
            final aiMessage = _deserializeAiMessage(jsonData);
            _messageController!.add(aiMessage);
          } catch (e) {
            developer.log('Error deserializing AI message: $e');
            _messageController!.addError(
              NetworkException(
                message: 'Failed to parse AI response: ${e.toString()}',
                code: 'DESERIALIZATION_ERROR',
                originalException: e is Exception ? e : Exception(e.toString()),
              ),
            );
          }
        },
        onError: (Object error) {
          developer.log('WebSocket stream error: $error');
          _messageController!.addError(
            NetworkException(
              message: 'WebSocket communication error: ${error.toString()}',
              code: 'WEBSOCKET_ERROR',
              originalException: error is Exception ? error : Exception(error.toString()),
            ),
          );
        },
        onDone: () {
          developer.log('WebSocket stream closed');
          _messageController!.close();
        },
      );

      // Send user message to AI backend
      final messageData = _serializeUserMessage(userMessage);
      final messageJson = json.encode(messageData);
      developer.log('Sending message to AI: $messageJson');
      
      _channel!.sink.add(messageJson);

      // Yield messages from the stream controller
      yield* _messageController!.stream;

    } catch (e) {
      developer.log('Error in AI response stream: $e');
      
      // Clean up resources
      await _cleanup();
      
      if (e is NetworkException) {
        rethrow;
      } else {
        throw NetworkException(
          message: 'Failed to communicate with AI backend: ${e.toString()}',
          code: 'AI_SERVICE_ERROR',
          originalException: e is Exception ? e : Exception(e.toString()),
        );
      }
    } finally {
      // Ensure cleanup happens
      await _cleanup();
    }
  }

  /// Serialize user message for backend consumption
  Map<String, dynamic> _serializeUserMessage(UserMessage userMessage) {
    return {
      'type': 'user_message',
      'data': {
        'id': userMessage.id,
        'text': userMessage.text,
        'imageUrl': userMessage.imageUrl,
        'timestamp': userMessage.timestamp.toIso8601String(),
      },
    };
  }

  /// Deserialize AI message from backend response
  AiMessage _deserializeAiMessage(Map<String, dynamic> jsonData) {
    // Handle different message types from backend
    final messageType = jsonData['type'] as String?;
    final data = jsonData['data'] as Map<String, dynamic>? ?? {};

    switch (messageType) {
      case 'ai_message_chunk':
        return AiMessage(
          id: data['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: data['timestamp'] != null 
              ? DateTime.parse(data['timestamp'] as String)
              : DateTime.now(),
          text: data['text'] as String?,
          isGenerating: data['isGenerating'] as bool? ?? false,
        );
        
      case 'ai_message_complete':
        return AiMessage(
          id: data['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: data['timestamp'] != null 
              ? DateTime.parse(data['timestamp'] as String)
              : DateTime.now(),
          text: data['text'] as String?,
          outfits: _deserializeOutfits(data['outfits'] as List?),
          products: _deserializeProducts(data['products'] as List?),
          isGenerating: false,
        );
        
      case 'ai_thinking':
        return AiMessage(
          id: data['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: DateTime.now(),
          isGenerating: true,
        );
        
      case 'error':
        throw NetworkException(
          message: data['message'] as String? ?? 'Unknown AI backend error',
          code: data['code'] as String? ?? 'AI_ERROR',
        );
        
      default:
        // Default to treating as a text chunk
        return AiMessage(
          id: data['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: data['timestamp'] != null 
              ? DateTime.parse(data['timestamp'] as String)
              : DateTime.now(),
          text: data['text'] as String? ?? jsonData.toString(),
          isGenerating: data['isGenerating'] as bool? ?? false,
        );
    }
  }

  /// Deserialize outfit data from backend response
  List<Outfit>? _deserializeOutfits(List<dynamic>? outletsData) {
    if (outletsData == null || outletsData.isEmpty) return null;
    
    return outletsData.map((outfitJson) {
      final outfit = outfitJson as Map<String, dynamic>;
      return Outfit(
        id: outfit['id'] as String,
        name: outfit['name'] as String,
        coverImageUrl: outfit['coverImageUrl'] as String?,
        clothingItemIds: (outfit['clothingItemIds'] as List?)?.cast<String>() ?? [],
        createdAt: outfit['createdAt'] != null 
            ? DateTime.parse(outfit['createdAt'] as String)
            : DateTime.now(),
        isFavorite: outfit['isFavorite'] as bool? ?? false,
      );
    }).toList();
  }

  /// Deserialize product data from backend response
  List<Product>? _deserializeProducts(List<dynamic>? productsData) {
    if (productsData == null || productsData.isEmpty) return null;
    
    return productsData.map((productJson) {
      final product = productJson as Map<String, dynamic>;
      return Product(
        id: product['id'] as String,
        name: product['name'] as String,
        imageUrl: product['imageUrl'] as String,
        price: (product['price'] as num).toDouble(),
        currency: product['currency'] as String? ?? 'USD',
        seller: product['seller'] as String,
        externalUrl: product['externalUrl'] as String,
        carbonFootprintKg: (product['carbonFootprintKg'] as num?)?.toDouble(),
        greenScore: product['greenScore'] as int? ?? 0,
      );
    }).toList();
  }

  /// Clean up WebSocket resources
  Future<void> _cleanup() async {
    try {
      await _messageController?.close();
      await _channel?.sink.close();
    } catch (e) {
      developer.log('Error during cleanup: $e');
    } finally {
      _messageController = null;
      _channel = null;
    }
  }

  /// Upload an image to the AI backend
  /// 
  /// [imagePath] - Path to the image file on the device
  /// 
  /// Returns the URL of the uploaded image, which can be used in chat messages
  Future<String> uploadImage(String imagePath) async {
    try {
      developer.log('Uploading image: $imagePath');
      
      // Get authentication token
      final token = await _getAuthToken();
      if (token == null) {
        throw NetworkException(
          message: 'User not authenticated - no auth token available',
          code: 'AUTH_TOKEN_MISSING',
        );
      }
      
      // Prepare multipart request
      final uri = Uri.parse('$_baseUrl/api/v1/chat/upload-image');
      final request = MultipartRequest('POST', uri);
      
      // Add auth headers
      request.headers['Authorization'] = 'Bearer $token';
      
      // Add the file
      final filename = imagePath.split('/').last;
      request.files.add(
        await MultipartFile.fromPath('image', imagePath, filename: filename),
      );
      
      // Send the request
      final response = await request.send();
      
      // Parse the response
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseString = await response.stream.bytesToString();
        final responseData = json.decode(responseString) as Map<String, dynamic>;
        
        if (responseData['imageUrl'] != null) {
          final imageUrl = responseData['imageUrl'] as String;
          developer.log('Image uploaded successfully: $imageUrl');
          return imageUrl;
        } else {
          throw NetworkException(
            message: 'Image upload succeeded but no URL was returned',
            code: 'NO_IMAGE_URL',
          );
        }
      } else {
        throw NetworkException(
          message: 'Failed to upload image (${response.statusCode})',
          code: 'UPLOAD_ERROR',
          details: {'statusCode': response.statusCode},
        );
      }
      
    } catch (e) {
      developer.log('Error uploading image: $e');
      if (e is NetworkException) {
        rethrow;
      } else {
        throw NetworkException(
          message: 'Failed to upload image: ${e.toString()}',
          code: 'UPLOAD_ERROR',
          originalException: e is Exception ? e : Exception(e.toString()),
        );
      }
    }
  }

  /// Close the service and clean up resources
  Future<void> dispose() async {
    await _cleanup();
  }
}
