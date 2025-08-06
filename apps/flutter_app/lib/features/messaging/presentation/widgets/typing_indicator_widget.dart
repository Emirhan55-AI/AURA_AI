import 'package:flutter/material.dart';

import '../../domain/entities/chat_message.dart';

/// Typing indicator widget showing who is typing
class TypingIndicatorWidget extends StatefulWidget {
  final List<TypingIndicator> typingIndicators;

  const TypingIndicatorWidget({
    super.key,
    required this.typingIndicators,
  });

  @override
  State<TypingIndicatorWidget> createState() => _TypingIndicatorWidgetState();
}

class _TypingIndicatorWidgetState extends State<TypingIndicatorWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.typingIndicators.isNotEmpty) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(TypingIndicatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.typingIndicators.isNotEmpty && oldWidget.typingIndicators.isEmpty) {
      _animationController.repeat();
    } else if (widget.typingIndicators.isEmpty && oldWidget.typingIndicators.isNotEmpty) {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.typingIndicators.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.grey.shade300,
            child: Text(
              widget.typingIndicators.first.userName.isNotEmpty
                  ? widget.typingIndicators.first.userName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Typing message and dots
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getTypingText(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  
                  const SizedBox(width: 4),
                  
                  // Animated typing dots
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTypingDot(0, _animation.value),
                          const SizedBox(width: 2),
                          _buildTypingDot(1, _animation.value),
                          const SizedBox(width: 2),
                          _buildTypingDot(2, _animation.value),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 40), // Space for alignment
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index, double animationValue) {
    // Create staggered animation for each dot
    final delayedValue = (animationValue - (index * 0.2)).clamp(0.0, 1.0);
    final opacity = (delayedValue * 2).clamp(0.0, 1.0);
    
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[600]?.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }

  String _getTypingText() {
    final count = widget.typingIndicators.length;
    
    if (count == 1) {
      return '${widget.typingIndicators.first.userName} is typing';
    } else if (count == 2) {
      return '${widget.typingIndicators.first.userName} and ${widget.typingIndicators[1].userName} are typing';
    } else {
      return '${widget.typingIndicators.first.userName} and ${count - 1} others are typing';
    }
  }
}
