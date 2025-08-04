import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/style_assistant_repository.dart';

/// Use case for getting AI response stream
/// 
/// This use case encapsulates the business logic for getting
/// streaming AI responses from user messages
class GetAiResponseStreamUseCase {
  final StyleAssistantRepository _repository;

  const GetAiResponseStreamUseCase(this._repository);

  /// Execute the use case to get an AI response stream
  /// 
  /// [userMessage] - The user's message to send to AI
  /// 
  /// Returns a stream of AI message chunks/responses
  /// The stream will emit multiple AiMessage objects as the AI builds its response
  /// The final message will have isGenerating = false
  Stream<AiMessage> call(UserMessage userMessage) {
    return _repository.getAiResponseStream(userMessage);
  }
}
