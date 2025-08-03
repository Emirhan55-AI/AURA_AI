import 'package:flutter/material.dart';

/// A widget for users to input and submit new comments
/// Provides a text field and send button with basic input validation
class CommentInput extends StatefulWidget {
  final void Function(String)? onCommentSubmitted;
  final String? placeholder;

  const CommentInput({
    super.key,
    this.onCommentSubmitted,
    this.placeholder,
  });

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isCommentValid = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final isValid = _controller.text.trim().isNotEmpty;
    if (isValid != _isCommentValid) {
      setState(() {
        _isCommentValid = isValid;
      });
    }
  }

  void _submitComment() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onCommentSubmitted?.call(text);
      _controller.clear();
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // User avatar (current user)
              CircleAvatar(
                radius: 16,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(
                  Icons.person,
                  size: 16,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Text input field
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _focusNode.hasFocus 
                        ? colorScheme.primary
                        : colorScheme.outline.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: widget.placeholder ?? 'Add a comment...',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 3,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: _isCommentValid ? (_) => _submitComment() : null,
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Send button
              IconButton(
                onPressed: _isCommentValid ? _submitComment : null,
                icon: Icon(
                  Icons.send,
                  color: _isCommentValid 
                    ? colorScheme.primary 
                    : colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
                tooltip: 'Send comment',
                style: IconButton.styleFrom(
                  backgroundColor: _isCommentValid 
                    ? colorScheme.primaryContainer.withOpacity(0.3)
                    : null,
                ),
              ),
              
              // Optional: Emoji picker button
              IconButton(
                onPressed: () {
                  // TODO: Implement emoji picker
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Emoji picker coming soon'),
                      backgroundColor: colorScheme.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: Icon(
                  Icons.emoji_emotions_outlined,
                  color: colorScheme.onSurfaceVariant,
                ),
                tooltip: 'Add emoji',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
