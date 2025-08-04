import 'dart:async';
import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/style_assistant_repository.dart';
import '../services/style_assistant_ai_service.dart';

/// Implementation of StyleAssistantRepository using AI backend service
/// 
/// This repository implements the domain interface and coordinates with
/// the AI service to provide style assistant functionality
class StyleAssistantRepositoryImpl implements StyleAssistantRepository {
  final StyleAssistantAiService _aiService;

  const StyleAssistantRepositoryImpl({
    required StyleAssistantAiService aiService,
  }) : _aiService = aiService;

  @override
  Stream<AiMessage> getAiResponseStream(UserMessage userMessage) {
    developer.log('Repository: Getting AI response stream for message: ${userMessage.text}');
    
    // Directly return the service stream
    // The service handles all error conversion to exceptions
    return _aiService.getAiResponseStream(userMessage);
  }

  @override
  Future<Either<Failure, AiMessage>> sendMessage(UserMessage userMessage) async {
    try {
      developer.log('Repository: Sending message and waiting for complete response');
      
      // Get the stream and collect all messages
      final stream = _aiService.getAiResponseStream(userMessage);
      AiMessage? finalMessage;
      
      // Listen to the stream and keep the last non-generating message
      await for (final message in stream) {
        finalMessage = message;
        
        // Stop when we get a complete message (not generating)
        if (!message.isGenerating) {
          break;
        }
      }
      
      if (finalMessage == null) {
        return const Left(
          ServiceFailure(message: 'No response received from AI service'),
        );
      }
      
      return Right(finalMessage);
      
    } catch (e) {
      developer.log('Repository: Error in sendMessage: $e');
      
      // Convert exceptions to domain failures
      final failure = FailureMapper.fromException(e is Exception ? e : Exception(e.toString()));
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, String>> uploadImage(String imagePath) async {
    try {
      developer.log('Repository: Uploading image: $imagePath');
      
      // Use the AI service to upload the image to the backend
      final imageUrl = await _aiService.uploadImage(imagePath);
      
      developer.log('Repository: Image uploaded successfully: $imageUrl');
      return Right(imageUrl);
      
    } catch (e) {
      developer.log('Repository: Error uploading image: $e');
      
      final failure = FailureMapper.fromException(e is Exception ? e : Exception(e.toString()));
      return Left(failure);
    }
  }

  /// Dispose of resources
  Future<void> dispose() async {
    await _aiService.dispose();
  }
}
