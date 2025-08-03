import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/chat_message.dart';

part 'style_assistant_controller.g.dart';

/// Style Assistant State class to manage both messages and voice mode
@immutable
class StyleAssistantState {
  final List<ChatMessage> messages;
  final bool isVoiceMode;
  final bool isLoading;
  final String? error;

  const StyleAssistantState({
    this.messages = const [],
    this.isVoiceMode = false,
    this.isLoading = false,
    this.error,
  });

  StyleAssistantState copyWith({
    List<ChatMessage>? messages,
    bool? isVoiceMode,
    bool? isLoading,
    String? error,
  }) {
    return StyleAssistantState(
      messages: messages ?? this.messages,
      isVoiceMode: isVoiceMode ?? this.isVoiceMode,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StyleAssistantState &&
           listEquals(other.messages, messages) &&
           other.isVoiceMode == isVoiceMode &&
           other.isLoading == isLoading &&
           other.error == error;
  }

  @override
  int get hashCode => messages.hashCode ^ isVoiceMode.hashCode ^ isLoading.hashCode ^ error.hashCode;
}

/// Style Assistant Controller - Manages chat state and user interactions
/// 
/// This controller handles the style assistant chat interface including:
/// - Chat message history management
/// - Voice mode state
/// - User message sending
/// - Image sharing functionality
/// - Quick action handling
/// - Error recovery through retry mechanism
/// 
/// Follows Riverpod v2 patterns with AsyncNotifier for async state management
@riverpod
class StyleAssistantController extends _$StyleAssistantController {
  @override
  Future<StyleAssistantState> build() async {
    // Initialize with empty state
    // In future iterations, this could load chat history from storage
    return const StyleAssistantState();
  }

  /// Current voice mode state
  bool get isVoiceMode => state.valueOrNull?.isVoiceMode ?? false;

  /// Send a text message from the user
  /// 
  /// [text] - The message content to send
  /// 
  /// This method adds the user message to the chat and triggers AI response
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    try {
      final currentState = state.valueOrNull ?? const StyleAssistantState();
      
      // Add user message immediately for optimistic UI update
      final userMessage = UserMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        text: text.trim(),
      );

      // Update state with new user message
      state = AsyncData(currentState.copyWith(
        messages: [...currentState.messages, userMessage],
        isLoading: true,
      ));

      // Simulate AI thinking state
      final aiThinkingMessage = AiMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        isGenerating: true,
      );

      // Add thinking indicator
      final updatedState = state.value!;
      state = AsyncData(updatedState.copyWith(
        messages: [...updatedState.messages, aiThinkingMessage],
      ));

      // TODO: Replace with actual AI service integration
      await _simulateAiResponse(text, aiThinkingMessage.id);

    } catch (error) {
      final currentState = state.valueOrNull ?? const StyleAssistantState();
      state = AsyncData(currentState.copyWith(
        isLoading: false,
        error: error.toString(),
      ));
    }
  }

  /// Pick an image and send it as a message
  /// 
  /// This method handles image selection and uploading
  Future<void> pickImageAndSend() async {
    try {
      final currentState = state.valueOrNull ?? const StyleAssistantState();
      
      // TODO: Implement actual image picker integration
      // For now, simulate image sending
      
      final userMessage = UserMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        text: "I'd like style advice for this image",
        imageUrl: "https://example.com/user-uploaded-image.jpg", // Simulated
      );

      state = AsyncData(currentState.copyWith(
        messages: [...currentState.messages, userMessage],
        isLoading: true,
      ));

      // Simulate AI processing the image
      final aiThinkingMessage = AiMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        isGenerating: true,
      );

      final updatedState = state.value!;
      state = AsyncData(updatedState.copyWith(
        messages: [...updatedState.messages, aiThinkingMessage],
      ));

      // TODO: Replace with actual image analysis AI service
      await _simulateAiImageResponse(aiThinkingMessage.id);

    } catch (error) {
      final currentState = state.valueOrNull ?? const StyleAssistantState();
      state = AsyncData(currentState.copyWith(
        isLoading: false,
        error: error.toString(),
      ));
    }
  }

  /// Toggle voice input mode
  /// 
  /// This switches between text and voice input modes
  void toggleVoiceMode() {
    final currentState = state.valueOrNull ?? const StyleAssistantState();
    state = AsyncData(currentState.copyWith(
      isVoiceMode: !currentState.isVoiceMode,
    ));
  }

  /// Send a quick action query
  /// 
  /// [query] - Predefined query text from quick action chips
  Future<void> sendQuickAction(String query) async {
    // Quick actions are treated the same as regular text messages
    await sendMessage(query);
  }

  /// Retry the last failed operation
  /// 
  /// This method attempts to recover from errors by retrying the last action
  Future<void> retry() async {
    try {
      final currentState = state.valueOrNull ?? const StyleAssistantState();
      state = AsyncData(currentState.copyWith(
        error: null,
        isLoading: false,
      ));
      
    } catch (error) {
      final currentState = state.valueOrNull ?? const StyleAssistantState();
      state = AsyncData(currentState.copyWith(
        isLoading: false,
        error: error.toString(),
      ));
    }
  }

  /// Clear chat history and start fresh
  /// 
  /// This method resets the chat to initial state
  Future<void> clearChat() async {
    try {
      state = const AsyncData(StyleAssistantState());
    } catch (error) {
      final currentState = state.valueOrNull ?? const StyleAssistantState();
      state = AsyncData(currentState.copyWith(
        isLoading: false,
        error: error.toString(),
      ));
    }
  }

  // PRIVATE HELPER METHODS

  /// Simulate AI response generation
  /// 
  /// This is a placeholder for actual AI service integration
  /// TODO: Replace with real AI API calls in future iterations
  Future<void> _simulateAiResponse(String userText, String thinkingMessageId) async {
    // Simulate processing delay
    await Future<void>.delayed(const Duration(seconds: 2));

    try {
      final currentState = state.value!;
      
      // Remove the thinking message and add actual response
      final messagesWithoutThinking = currentState.messages
          .where((ChatMessage msg) => msg.id != thinkingMessageId)
          .toList();

      final aiResponse = AiMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        text: _generateMockAiResponse(userText),
        isGenerating: false,
      );

      state = AsyncData(currentState.copyWith(
        messages: [...messagesWithoutThinking, aiResponse],
        isLoading: false,
      ));

    } catch (error) {
      final currentState = state.valueOrNull ?? const StyleAssistantState();
      state = AsyncData(currentState.copyWith(
        isLoading: false,
        error: error.toString(),
      ));
    }
  }

  /// Simulate AI image analysis response
  /// 
  /// This is a placeholder for actual image analysis AI service
  /// TODO: Replace with real image analysis API calls
  Future<void> _simulateAiImageResponse(String thinkingMessageId) async {
    await Future<void>.delayed(const Duration(seconds: 3));

    try {
      final currentState = state.value!;
      
      final messagesWithoutThinking = currentState.messages
          .where((ChatMessage msg) => msg.id != thinkingMessageId)
          .toList();

      // Mock outfit recommendations
      final mockOutfits = [
        Outfit(
          id: "outfit_1",
          name: "Casual Chic",
          coverImageUrl: "https://example.com/outfit1.jpg",
          clothingItemIds: ["item_1", "item_2", "item_3"],
          createdAt: DateTime.now(),
          isFavorite: false,
        ),
        Outfit(
          id: "outfit_2", 
          name: "Professional Look",
          coverImageUrl: "https://example.com/outfit2.jpg",
          clothingItemIds: ["item_4", "item_5", "item_6"],
          createdAt: DateTime.now(),
          isFavorite: false,
        ),
      ];

      final aiResponse = AiMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        text: "Based on your image, I've created some outfit suggestions for you!",
        outfits: mockOutfits,
        isGenerating: false,
      );

      state = AsyncData(currentState.copyWith(
        messages: [...messagesWithoutThinking, aiResponse],
        isLoading: false,
      ));

    } catch (error) {
      final currentState = state.valueOrNull ?? const StyleAssistantState();
      state = AsyncData(currentState.copyWith(
        isLoading: false,
        error: error.toString(),
      ));
    }
  }

  /// Generate mock AI response text
  /// 
  /// This creates varied responses based on user input
  /// TODO: Replace with actual AI service responses
  String _generateMockAiResponse(String userText) {
    final lowerText = userText.toLowerCase();
    
    if (lowerText.contains('outfit') || lowerText.contains('what to wear')) {
      return "I'd love to help you put together an outfit! Based on your style preferences and wardrobe, here are some suggestions...";
    } else if (lowerText.contains('color') || lowerText.contains('colors')) {
      return "Great question about colors! For your skin tone and style, I recommend exploring these color combinations...";
    } else if (lowerText.contains('occasion') || lowerText.contains('event')) {
      return "Let me help you dress for the occasion! Tell me more about the event and I'll suggest perfect outfits.";
    } else if (lowerText.contains('weather') || lowerText.contains('season')) {
      return "Weather-appropriate styling is so important! Here's what I recommend for current conditions...";
    } else {
      // Generic helpful response
      return "That's a great style question! I'm here to help you look and feel your best. Let me think about the best recommendations for you...";
    }
  }
}
