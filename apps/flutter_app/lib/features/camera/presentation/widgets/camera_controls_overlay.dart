import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

/// Camera controls overlay widget
class CameraControlsOverlay extends StatelessWidget {
  final bool isRecording;
  final FlashMode flashMode;
  final double zoomLevel;
  final VoidCallback onFlashToggle;
  final VoidCallback onCameraSwitch;
  final ValueChanged<double> onZoomChanged;

  const CameraControlsOverlay({
    super.key,
    required this.isRecording,
    required this.flashMode,
    required this.zoomLevel,
    required this.onFlashToggle,
    required this.onCameraSwitch,
    required this.onZoomChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: kToolbarHeight + MediaQuery.of(context).padding.top,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Flash Control
          _FlashButton(
            flashMode: flashMode,
            onTap: onFlashToggle,
          ),
          
          // Zoom Indicator
          _ZoomIndicator(
            zoomLevel: zoomLevel,
            onZoomChanged: onZoomChanged,
          ),
          
          // Grid Toggle (placeholder for now)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.grid_3x3,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

/// Flash control button
class _FlashButton extends StatelessWidget {
  final FlashMode flashMode;
  final VoidCallback onTap;

  const _FlashButton({
    required this.flashMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor = Colors.white;

    switch (flashMode) {
      case FlashMode.off:
        iconData = Icons.flash_off;
        break;
      case FlashMode.auto:
        iconData = Icons.flash_auto;
        break;
      case FlashMode.always:
        iconData = Icons.flash_on;
        iconColor = Colors.yellow;
        break;
      case FlashMode.torch:
        iconData = Icons.flashlight_on;
        iconColor = Colors.yellow;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          iconData,
          color: iconColor,
          size: 20,
        ),
      ),
    );
  }
}

/// Zoom level indicator
class _ZoomIndicator extends StatelessWidget {
  final double zoomLevel;
  final ValueChanged<double> onZoomChanged;

  const _ZoomIndicator({
    required this.zoomLevel,
    required this.onZoomChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${zoomLevel.toStringAsFixed(1)}x',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
