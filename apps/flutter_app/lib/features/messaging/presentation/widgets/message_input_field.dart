import 'package:flutter/material.dart';

import '../../domain/entities/chat_message.dart';

/// Message input field with media and outfit sharing capabilities
class MessageInputField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ChatMessage? replyingToMessage;
  final ValueChanged<String>? onMessageChanged;
  final VoidCallback? onSend;
  final VoidCallback? onClearReply;
  final VoidCallback? onAttachMedia;
  final VoidCallback? onSendOutfit;

  const MessageInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.replyingToMessage,
    this.onMessageChanged,
    this.onSend,
    this.onClearReply,
    this.onAttachMedia,
    this.onSendOutfit,
  });

  @override
  State<MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<MessageInputField> {
  final int _maxLines = 5;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
    widget.onMessageChanged?.call(widget.controller.text);
  }

  bool get _canSend => widget.controller.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Reply preview
          if (widget.replyingToMessage != null)
            _buildReplyPreview(context),
          
          // Input area
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Attachment button
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _showAttachmentOptions,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      shape: const CircleBorder(),
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Text input
                  Expanded(
                    child: Container(
                      constraints: BoxConstraints(
                        minHeight: 40,
                        maxHeight: _maxLines * 24.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: widget.focusNode.hasFocus
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: widget.controller,
                        focusNode: widget.focusNode,
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        style: Theme.of(context).textTheme.bodyMedium,
                        onChanged: widget.onMessageChanged,
                        onSubmitted: (_) {
                          if (_canSend) {
                            widget.onSend?.call();
                          }
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Send button
                  IconButton(
                    icon: Icon(
                      _canSend ? Icons.send : Icons.mic,
                      color: _canSend 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey[600],
                    ),
                    onPressed: _canSend 
                        ? widget.onSend 
                        : _startVoiceRecording,
                    style: IconButton.styleFrom(
                      backgroundColor: _canSend 
                          ? Theme.of(context).primaryColor.withOpacity(0.1)
                          : Colors.grey.shade100,
                      shape: const CircleBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyPreview(BuildContext context) {
    final replyMessage = widget.replyingToMessage!;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          left: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 3,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Replying to ${replyMessage.senderName}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 2),
                
                Text(
                  replyMessage.previewText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: widget.onClearReply,
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Share Content',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Media options
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.photo_camera, color: Colors.blue.shade700),
              ),
              title: const Text('Camera'),
              subtitle: const Text('Take a photo or video'),
              onTap: () {
                Navigator.pop(context);
                _handleCameraAction();
              },
            ),
            
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.photo_library, color: Colors.green.shade700),
              ),
              title: const Text('Photo & Video'),
              subtitle: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                widget.onAttachMedia?.call();
              },
            ),
            
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.insert_drive_file, color: Colors.orange.shade700),
              ),
              title: const Text('File'),
              subtitle: const Text('Share documents'),
              onTap: () {
                Navigator.pop(context);
                _handleFileAction();
              },
            ),
            
            const Divider(),
            
            // Aura-specific options
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.checkroom,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              title: const Text('Share Outfit'),
              subtitle: const Text('From your wardrobe'),
              onTap: () {
                Navigator.pop(context);
                widget.onSendOutfit?.call();
              },
            ),
            
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.swap_horiz, color: Colors.purple.shade700),
              ),
              title: const Text('Swap Request'),
              subtitle: const Text('Propose a clothing swap'),
              onTap: () {
                Navigator.pop(context);
                _handleSwapRequest();
              },
            ),
            
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.location_on, color: Colors.red.shade700),
              ),
              title: const Text('Location'),
              subtitle: const Text('Share your current location'),
              onTap: () {
                Navigator.pop(context);
                _handleLocationShare();
              },
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _startVoiceRecording() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice recording feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleCameraAction() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Camera feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleFileAction() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File sharing feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleSwapRequest() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Swap request feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleLocationShare() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location sharing feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
