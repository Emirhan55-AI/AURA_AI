import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Navigation helper for Style Assistant screen
/// Provides centralized navigation methods for style-related screens
class StyleAssistantNavigation {
  static const String _baseRoute = '/style-assistant';

  // Route constants
  static const String homeRoute = _baseRoute;
  static const String quizRoute = '$_baseRoute/quiz';
  static const String generateOutfitRoute = '$_baseRoute/generate';
  static const String weatherOutfitsRoute = '$_baseRoute/weather';
  static const String outfitHistoryRoute = '$_baseRoute/history';
  static const String wardrobeRoute = '/wardrobe';
  static const String addClothingRoute = '/wardrobe/add';
  static const String outfitDetailsRoute = '$_baseRoute/outfit';

  /// Navigate to style quiz
  static void toStyleQuiz(BuildContext context) {
    context.push(quizRoute);
  }

  /// Navigate to outfit generator
  static void toGenerateOutfit(BuildContext context) {
    context.push(generateOutfitRoute);
  }

  /// Navigate to weather-based outfits
  static void toWeatherOutfits(BuildContext context) {
    context.push(weatherOutfitsRoute);
  }

  /// Navigate to outfit history
  static void toOutfitHistory(BuildContext context) {
    context.push(outfitHistoryRoute);
  }

  /// Navigate to wardrobe
  static void toWardrobe(BuildContext context) {
    context.push(wardrobeRoute);
  }

  /// Navigate to add clothing item
  static void toAddClothing(BuildContext context) {
    context.push(addClothingRoute);
  }

  /// Navigate to outfit details
  static void toOutfitDetails(BuildContext context, String outfitId) {
    context.push('$outfitDetailsRoute/$outfitId');
  }

  /// Navigate to specific style inspiration
  static void toStyleDetails(BuildContext context, String styleId) {
    context.push('$_baseRoute/style/$styleId');
  }

  /// Open AI chat overlay
  static void openAiChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AiChatBottomSheet(),
    );
  }
}

/// AI Chat Bottom Sheet Widget
/// Modal bottom sheet for AI style assistant conversations
class AiChatBottomSheet extends StatefulWidget {
  const AiChatBottomSheet({super.key});

  @override
  State<AiChatBottomSheet> createState() => _AiChatBottomSheetState();
}

class _AiChatBottomSheetState extends State<AiChatBottomSheet> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Add welcome message
    _messages.add(
      ChatMessage(
        text: "Hi! I'm Aura, your personal style assistant. How can I help you with your style today? 🌟",
        isFromUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.8,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.secondary],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: colorScheme.onPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aura Assistant',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Online • Ready to help',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          // Messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator(colorScheme);
                }
                return _buildMessage(_messages[index], theme, colorScheme);
              },
            ),
          ),
          
          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask Aura about your style...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: colorScheme.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: colorScheme.primary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.secondary],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: IconButton(
                    onPressed: () => _sendMessage(_messageController.text),
                    icon: Icon(
                      Icons.send,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isFromUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.secondary],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.auto_awesome,
                color: colorScheme.onPrimary,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isFromUser 
                  ? colorScheme.primary 
                  : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: message.isFromUser ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight: message.isFromUser ? const Radius.circular(4) : const Radius.circular(16),
                ),
              ),
              child: Text(
                message.text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: message.isFromUser 
                    ? colorScheme.onPrimary 
                    : colorScheme.onSurface,
                ),
              ),
            ),
          ),
          if (message.isFromUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.person,
                color: colorScheme.onSurface,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.secondary],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.auto_awesome,
              color: colorScheme.onPrimary,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 40,
                  height: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(3, (index) {
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 600 + (index * 200)),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 0.5 + (value * 0.5),
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: colorScheme.onSurfaceVariant,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    
    setState(() {
      _messages.add(
        ChatMessage(
          text: text.trim(),
          isFromUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
    });

    _messageController.clear();

    // Simulate AI response
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(
            ChatMessage(
              text: _generateAiResponse(text),
              isFromUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
      }
    });
  }

  String _generateAiResponse(String userMessage) {
    // Simple response generation - replace with actual AI integration
    final responses = [
      "That's a great style question! Based on your wardrobe, I'd recommend...",
      "I love helping with outfit choices! For that occasion, you might consider...",
      "Style is all about expressing yourself! Here's what I think would work...",
      "Let me think about your style preferences... I'd suggest...",
      "That's an interesting styling challenge! Here's my recommendation...",
    ];
    return responses[DateTime.now().millisecond % responses.length];
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

/// Chat message model
class ChatMessage {
  final String text;
  final bool isFromUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isFromUser,
    required this.timestamp,
  });
}
