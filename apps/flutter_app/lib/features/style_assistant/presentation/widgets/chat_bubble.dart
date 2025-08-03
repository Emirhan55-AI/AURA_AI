import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'image_preview.dart';
import 'outfit_card.dart';
import 'product_card.dart';

/// Chat Bubble - Individual message container for user and AI messages
/// 
/// This widget displays individual messages in the chat with appropriate styling
/// for user vs AI messages, and handles different message types including text,
/// images, outfit suggestions, and product recommendations.
class ChatBubble extends StatelessWidget {
  final Map<String, dynamic> message;

  const ChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isUser = message['type'] == 'user';

    return Padding(
      padding: EdgeInsets.only(
        top: 4,
        bottom: 4,
        left: isUser ? 32 : 0,
        right: isUser ? 0 : 32,
      ),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAvatar(context, colorScheme, isUser),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: _buildMessageContent(context, theme, colorScheme, isUser),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            _buildAvatar(context, colorScheme, isUser),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, ColorScheme colorScheme, bool isUser) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isUser ? colorScheme.primary : colorScheme.secondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        isUser ? Icons.person : Icons.auto_awesome,
        color: isUser ? colorScheme.onPrimary : colorScheme.onSecondary,
        size: 18,
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context, ThemeData theme, ColorScheme colorScheme, bool isUser) {
    return GestureDetector(
      onLongPress: () => _showMessageOptions(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? colorScheme.primary : colorScheme.surfaceVariant,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Message text
            if (message['text'] != null && message['text'].toString().isNotEmpty)
              Text(
                message['text'].toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isUser ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            
            // Image preview if message contains image
            if (message['imageUrl'] != null) ...[
              if (message['text'] != null && message['text'].toString().isNotEmpty)
                const SizedBox(height: 8),
              ImagePreview(
                imageUrl: message['imageUrl'].toString(),
                onTap: () => _showFullImage(context, message['imageUrl'].toString()),
              ),
            ],
            
            // AI-specific content (outfit suggestions, products, etc.)
            if (!isUser) ...[
              if (message['outfits'] != null && (message['outfits'] as List).isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildOutfitSuggestions(context, theme, colorScheme),
              ],
              if (message['products'] != null && (message['products'] as List).isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildProductSuggestions(context, theme, colorScheme),
              ],
            ],
            
            // Timestamp
            const SizedBox(height: 8),
            Text(
              _formatTimestamp(message['timestamp']),
              style: theme.textTheme.bodySmall?.copyWith(
                color: isUser 
                    ? colorScheme.onPrimary.withOpacity(0.7)
                    : colorScheme.onSurfaceVariant.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutfitSuggestions(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    final outfits = message['outfits'] as List? ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Outfit Suggestions:',
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: outfits.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: index < outfits.length - 1 ? 12 : 0),
                child: OutfitCard(
                  outfit: outfits[index] as Map<String, dynamic>,
                  width: 120,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductSuggestions(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    final products = message['products'] as List? ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Recommendations:',
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: index < products.length - 1 ? 12 : 0),
                child: ProductCard(
                  product: products[index] as Map<String, dynamic>,
                  width: 140,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    
    final DateTime dateTime = timestamp is DateTime 
        ? timestamp 
        : DateTime.parse(timestamp.toString());
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  void _showMessageOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _MessageOptionsBottomSheet(message: message),
    );
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: InteractiveViewer(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet for message options (copy, delete, etc.)
class _MessageOptionsBottomSheet extends StatelessWidget {
  final Map<String, dynamic> message;

  const _MessageOptionsBottomSheet({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isUser = message['type'] == 'user';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          
          ListTile(
            leading: Icon(Icons.copy, color: colorScheme.onSurface),
            title: const Text('Copy Message'),
            onTap: () {
              Clipboard.setData(ClipboardData(text: (message['text'] ?? '').toString()));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Message copied to clipboard')),
              );
            },
          ),
          
          if (isUser) ...[
            ListTile(
              leading: Icon(Icons.edit, color: colorScheme.onSurface),
              title: const Text('Edit Message'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement edit functionality
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: colorScheme.error),
              title: Text(
                'Delete Message',
                style: TextStyle(color: colorScheme.error),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement delete functionality
              },
            ),
          ],
        ],
      ),
    );
  }
}
