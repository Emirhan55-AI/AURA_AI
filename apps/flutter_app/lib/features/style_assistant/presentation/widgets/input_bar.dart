import 'package:flutter/material.dart';

/// Input Bar - Chat input interface with text, voice, and image options
/// 
/// This widget provides the bottom input interface for the chat screen,
/// allowing users to type messages, use voice input, and share images.
class InputBar extends StatefulWidget {
  final void Function(String text, {String? imageUrl}) onSendMessage;
  final VoidCallback onVoiceInput;
  final VoidCallback onImageInput;
  final bool isVoiceModeActive;
  final bool isListening;
  final bool enabled;

  const InputBar({
    super.key,
    required this.onSendMessage,
    required this.onVoiceInput,
    required this.onImageInput,
    this.isVoiceModeActive = false,
    this.isListening = false,
    this.enabled = true,
  });

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _textController.text.trim().isNotEmpty;
    });
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      widget.onSendMessage(text);
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Image input button
          IconButton(
            onPressed: widget.enabled ? widget.onImageInput : null,
            icon: Icon(
              Icons.photo,
              color: widget.enabled ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.3),
            ),
            tooltip: 'Share image',
          ),
          
          const SizedBox(width: 8),
          
          // Text input field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      enabled: widget.enabled,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.send,
                      onSubmitted: widget.enabled ? (_) => _sendMessage() : null,
                      decoration: InputDecoration(
                        hintText: widget.isVoiceModeActive && widget.isListening
                            ? 'Listening...'
                            : 'Ask Aura anything...',
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: widget.enabled 
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSurfaceVariant.withOpacity(0.3),
                      ),
                      minLines: 1,
                      maxLines: 4,
                    ),
                  ),
                  
                  // Voice input button (when voice mode is active)
                  if (widget.isVoiceModeActive)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        onPressed: widget.enabled ? widget.onVoiceInput : null,
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: widget.isListening
                              ? Icon(
                                  Icons.stop,
                                  key: const ValueKey('stop'),
                                  color: colorScheme.error,
                                )
                              : Icon(
                                  Icons.mic,
                                  key: const ValueKey('mic'),
                                  color: widget.enabled 
                                      ? colorScheme.primary 
                                      : colorScheme.onSurface.withOpacity(0.3),
                                ),
                        ),
                        tooltip: widget.isListening ? 'Stop listening' : 'Start voice input',
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Send button
          IconButton(
            onPressed: widget.enabled && _hasText ? _sendMessage : null,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.enabled && _hasText 
                    ? colorScheme.primary 
                    : colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.send,
                size: 20,
                color: widget.enabled && _hasText 
                    ? colorScheme.onPrimary 
                    : colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
            ),
            tooltip: 'Send message',
          ),
        ],
      ),
    );
  }
}
