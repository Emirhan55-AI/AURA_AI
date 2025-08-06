import 'package:flutter/material.dart';

/// Floating Action Button for messaging screen
class MessagingFAB extends StatelessWidget {
  final VoidCallback onPressed;

  const MessagingFAB({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      child: const Icon(Icons.chat_bubble_outline),
      backgroundColor: Theme.of(context).primaryColor,
      heroTag: "messaging_fab",
    );
  }
}
