import 'package:flutter/material.dart';

/// Custom camera capture button with animation
class CameraCaptureButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isCapturing;
  final double size;

  const CameraCaptureButton({
    super.key,
    required this.onTap,
    this.isCapturing = false,
    this.size = 80,
  });

  @override
  State<CameraCaptureButton> createState() => _CameraCaptureButtonState();
}

class _CameraCaptureButtonState extends State<CameraCaptureButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CameraCaptureButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCapturing != oldWidget.isCapturing) {
      if (widget.isCapturing) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (!widget.isCapturing) {
          _animationController.forward();
        }
      },
      onTapUp: (_) {
        if (!widget.isCapturing) {
          _animationController.reverse();
          widget.onTap();
        }
      },
      onTapCancel: () {
        if (!widget.isCapturing) {
          _animationController.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isCapturing ? Colors.red : Colors.white,
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: widget.isCapturing
                    ? const Icon(
                        Icons.stop,
                        color: Colors.white,
                        size: 32,
                      )
                    : Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.isCapturing ? Colors.red : Colors.white,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
