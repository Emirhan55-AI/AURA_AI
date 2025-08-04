import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/chat_list_view.dart';
import '../widgets/input_bar.dart';
import '../widgets/quick_action_chips.dart';
import '../controllers/style_assistant_controller.dart';
import '../../domain/entities/chat_message.dart';
import '../../../../core/ui/system_state_widget.dart';

/// Style Assistant Screen - Chat interface for AI-powered style assistance
/// 
/// This screen provides a fundamental chat interface where users can:
/// - Communicate with the personal style assistant via natural language
/// - Engage in voice communication
/// - View AI-generated combination/product suggestions
/// - Share images for style advice
/// - Access quick actions for common style queries
/// 
/// The screen follows Material 3 design system with Aura's warm, friendly theme
class StyleAssistantScreen extends ConsumerStatefulWidget {
  const StyleAssistantScreen({super.key});

  @override
  ConsumerState<StyleAssistantScreen> createState() => _StyleAssistantScreenState();
}

class _StyleAssistantScreenState extends ConsumerState<StyleAssistantScreen> {
  // Local UI state (voice listening state)
  bool _isListening = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Watch the style assistant state
    final styleAssistantAsync = ref.watch(styleAssistantControllerProvider);

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: _buildAppBar(context, theme, colorScheme),
      body: styleAssistantAsync.when(
        data: (state) => _buildBody(context, theme, colorScheme, state),
        loading: () => _buildLoadingBody(context, theme, colorScheme),
        error: (error, stackTrace) => _buildErrorBody(context, theme, colorScheme, error.toString()),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    // Get voice mode state from controller
    final isVoiceMode = ref.read(styleAssistantControllerProvider.notifier).isVoiceMode;
    
    return AppBar(
      title: Text(
        'Style Assistant',
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onPrimary,
        ),
      ),
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 0,
      scrolledUnderElevation: 2,
      actions: [
        IconButton(
          icon: Icon(
            isVoiceMode ? Icons.mic : Icons.mic_none_outlined,
            color: isVoiceMode ? colorScheme.secondary : colorScheme.onPrimary,
          ),
          onPressed: _toggleVoiceMode,
          tooltip: isVoiceMode ? 'Turn off voice mode' : 'Turn on voice mode',
        ),
        IconButton(
          icon: const Icon(Icons.style),
          onPressed: () => context.push('/style-challenges'),
          tooltip: 'Style Challenges',
        ),
        IconButton(
          icon: const Icon(Icons.refresh_outlined),
          onPressed: _startNewChat,
          tooltip: 'New Chat',
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme, ColorScheme colorScheme, StyleAssistantState state) {
    // Show error state if there's an error
    if (state.error != null) {
      return SystemStateWidget(
        icon: Icons.error_outline,
        iconColor: colorScheme.error,
        title: 'Connection Error',
        message: state.error!,
        onRetry: () => ref.read(styleAssistantControllerProvider.notifier).retry(),
        retryText: 'Try Again',
      );
    }

    // Show initial empty state for new chat
    if (state.messages.isEmpty && !state.isLoading) {
      return _buildEmptyState(context, theme, colorScheme);
    }

    // Show main chat interface
    return Column(
      children: [
        // Chat messages area
        Expanded(
          child: ChatListView(
            messages: _convertDomainMessagesToUI(state.messages),
            isLoading: state.isLoading,
          ),
        ),
        
        // Input area
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: InputBar(
              onSendMessage: _sendMessage,
              onVoiceInput: _handleVoiceInput,
              onImageInput: _handleImageInput,
              isVoiceModeActive: state.isVoiceMode,
              isListening: _isListening,
              enabled: !state.isLoading,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          
          // Welcome message
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.secondaryContainer.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 64,
                  color: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(height: 16),
                Text(
                  'Hi, I\'m Aura! 👋',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your personal style assistant is here to help! Ask me anything about fashion, get outfit suggestions, or let me help you organize your wardrobe.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Quick action chips for common queries
          QuickActionChips(
            onChipTap: _sendQuickAction,
          ),
          
          const SizedBox(height: 100), // Space for input bar
        ],
      ),
    );
  }

  Widget _buildLoadingBody(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorBody(BuildContext context, ThemeData theme, ColorScheme colorScheme, String error) {
    return SystemStateWidget(
      icon: Icons.error_outline,
      iconColor: colorScheme.error,
      title: 'Connection Error',
      message: error,
      onRetry: () => ref.read(styleAssistantControllerProvider.notifier).retry(),
      retryText: 'Try Again',
    );
  }

  /// Convert domain ChatMessage entities to UI-compatible format
  List<Map<String, dynamic>> _convertDomainMessagesToUI(List<ChatMessage> messages) {
    return messages.map<Map<String, dynamic>>((message) {
      if (message is UserMessage) {
        return <String, dynamic>{
          'id': message.id,
          'type': 'user',
          'text': message.text,
          'timestamp': message.timestamp,
          'imageUrl': message.imageUrl,
        };
      } else if (message is AiMessage) {
        return <String, dynamic>{
          'id': message.id,
          'type': 'ai',
          'text': message.text,
          'timestamp': message.timestamp,
          'isGenerating': message.isGenerating,
          'outfits': message.outfits?.map((Outfit outfit) => <String, dynamic>{
            'id': outfit.id,
            'name': outfit.name,
            'coverImageUrl': outfit.coverImageUrl,
            'clothingItemIds': outfit.clothingItemIds,
            'createdAt': outfit.createdAt,
            'isFavorite': outfit.isFavorite,
          }).toList(),
          'products': message.products?.map((Product product) => <String, dynamic>{
            'id': product.id,
            'name': product.name,
            'price': product.price,
            'currency': product.currency,
            'imageUrl': product.imageUrl,
            'seller': product.seller,
            'externalUrl': product.externalUrl,
            'carbonFootprintKg': product.carbonFootprintKg,
            'greenScore': product.greenScore,
          }).toList(),
        };
      }
      return <String, dynamic>{};
    }).toList();
  }

  // Controller callback methods
  void _toggleVoiceMode() {
    ref.read(styleAssistantControllerProvider.notifier).toggleVoiceMode();
  }

  void _startNewChat() {
    ref.read(styleAssistantControllerProvider.notifier).clearChat();
  }

  void _sendMessage(String text, {String? imageUrl}) {
    if (text.trim().isEmpty && imageUrl == null) return;
    ref.read(styleAssistantControllerProvider.notifier).sendMessage(text);
  }

  void _sendQuickAction(String actionText) {
    ref.read(styleAssistantControllerProvider.notifier).sendQuickAction(actionText);
  }

  void _handleVoiceInput() {
    final isVoiceMode = ref.read(styleAssistantControllerProvider.notifier).isVoiceMode;
    if (!isVoiceMode) return;
    
    setState(() {
      _isListening = !_isListening;
    });
    
    // TODO: Implement STT service integration
    // For now, just toggle listening state
  }

  void _handleImageInput() async {
    // TODO: Implement image picker and upload
    // For now, simulate image sharing
    ref.read(styleAssistantControllerProvider.notifier).pickImageAndSend();
  }
}

