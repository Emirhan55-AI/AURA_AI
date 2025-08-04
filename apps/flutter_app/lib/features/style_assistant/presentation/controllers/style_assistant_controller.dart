import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/image_picker_provider.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/upload_image_usecase.dart';
import '../../providers.dart';

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
/// - Real-time AI response streaming
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

      // Add AI thinking indicator
      final aiThinkingMessage = AiMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        isGenerating: true,
      );

      final updatedState = state.value!;
      state = AsyncData(updatedState.copyWith(
        messages: [...updatedState.messages, aiThinkingMessage],
      ));

      // Get AI response stream from use case
      await _handleAiResponseStream(userMessage, aiThinkingMessage.id);

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
      
      // Show loading state
      state = AsyncData(currentState.copyWith(isLoading: true));

      // Use image_picker to get image
      final imagePicker = ref.read<ImagePicker>(imagePickerProvider);
      final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile == null) {
        // User cancelled the picker
        state = AsyncData(currentState.copyWith(isLoading: false));
        return;
      }
      
      // Upload the image
      final uploadImageUseCase = ref.read<UploadImageUseCase>(uploadImageUseCaseProvider);
      final result = await uploadImageUseCase(pickedFile.path);
      
      return result.fold(
        (failure) => state = AsyncData(currentState.copyWith(
            isLoading: false,
            error: failure.toString(),
          )),
        (String imageUrl) async {
          // Create and send message with uploaded image URL
          final userMessage = UserMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            timestamp: DateTime.now(),
            text: "I'd like style advice for this image",
            imageUrl: imageUrl.toString(),
          );

          // Update state with user message
          state = AsyncData(currentState.copyWith(
            messages: [...currentState.messages, userMessage],
            isLoading: true,
          ));

          // Add AI thinking indicator for image processing
          final aiThinkingMessage = AiMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            timestamp: DateTime.now(),
            isGenerating: true,
          );

          final updatedState = state.value!;
          state = AsyncData(updatedState.copyWith(
            messages: [...updatedState.messages, aiThinkingMessage],
          ));

          // Use the same AI response stream for image analysis
          await _handleAiResponseStream(userMessage, aiThinkingMessage.id);
        },
      );
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

  /// Handle AI response stream from the backend
  /// 
  /// This method manages the real-time streaming of AI responses
  /// Updates the UI as chunks arrive and finalizes when complete
  Future<void> _handleAiResponseStream(UserMessage userMessage, String thinkingMessageId) async {
    try {
      // Get the AI response stream use case
      final getAiResponseStreamUseCase = ref.read(getAiResponseStreamUseCaseProvider);
      
      // Listen to the AI response stream
      final aiResponseStream = getAiResponseStreamUseCase(userMessage);
      
      AiMessage? lastMessage;
      
      await for (final aiMessageChunk in aiResponseStream) {
        final currentState = state.value!;
        
        // Remove the thinking message if this is the first real chunk
        List<ChatMessage> updatedMessages = currentState.messages;
        if (lastMessage == null) {
          updatedMessages = currentState.messages
              .where((msg) => msg.id != thinkingMessageId)
              .toList();
        } else {
          // Replace the previous AI message with the updated chunk
          updatedMessages = currentState.messages
              .where((msg) => msg.id != lastMessage!.id)
              .toList();
        }
        
        // Add the new AI message chunk
        updatedMessages.add(aiMessageChunk);
        lastMessage = aiMessageChunk;
        
        // Update the state with the new message
        state = AsyncData(currentState.copyWith(
          messages: updatedMessages,
          isLoading: aiMessageChunk.isGenerating, // Stop loading when AI finishes
        ));
      }
      
    } catch (error) {
      // Handle stream errors
      final currentState = state.value!;
      
      // Remove thinking message and show error
      final messagesWithoutThinking = currentState.messages
          .where((msg) => msg.id != thinkingMessageId)
          .toList();
      
      // Add error message as AI response
      final errorMessage = AiMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        text: "I'm having trouble connecting right now. Please try again in a moment.",
        isGenerating: false,
      );
      
      state = AsyncData(currentState.copyWith(
        messages: [...messagesWithoutThinking, errorMessage],
        isLoading: false,
        error: 'Failed to get AI response: ${error.toString()}',
      ));
    }
  }
}
