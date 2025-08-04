import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/chat_message.dart';

/// Repository interface for Style Assistant operations
/// 
/// This interface defines the contract for style assistant data operations
/// following the Repository pattern and Dependency Inversion Principle
abstract class StyleAssistantRepository {
  /// Get AI response stream for a user message
  /// 
  /// [userMessage] - The user's message to send to AI
  /// 
  /// Returns a stream of AI message chunks/responses
  /// Streams can emit multiple AiMessage objects as the response is built up
  /// The final message in the stream will have isGenerating = false
  Stream<AiMessage> getAiResponseStream(UserMessage userMessage);

  /// Send a message to the AI and get a complete response
  /// 
  /// [userMessage] - The user's message to send to AI
  /// 
  /// Returns [Right(AiMessage)] on successful AI response
  /// Returns [Left(Failure)] on communication failure
  /// 
  /// This is a convenience method for when you want a single response
  /// rather than a stream. Internally calls getAiResponseStream and
  /// collects the final message.
  Future<Either<Failure, AiMessage>> sendMessage(UserMessage userMessage);

  /// Upload an image and get its URL for use in messages
  /// 
  /// [imagePath] - Local path to the image file
  /// 
  /// Returns [Right(String)] with the uploaded image URL on success
  /// Returns [Left(Failure)] on upload failure
  /// 
  /// Note: This might be implemented differently depending on backend
  /// (direct upload to storage service vs sending through AI endpoint)
  Future<Either<Failure, String>> uploadImage(String imagePath);
}
