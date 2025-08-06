import 'package:flutter/material.dart';

/// Flash control button for camera
class CameraFlashButton extends StatelessWidget {
  final VoidCallback onTap;
  final String flashMode; // 'off', 'auto', 'on', 'torch'
  final double size;

  const CameraFlashButton({
    super.key,
    required this.onTap,
    required this.flashMode,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor = Colors.white;

    switch (flashMode.toLowerCase()) {
      case 'off':
        iconData = Icons.flash_off;
        break;
      case 'auto':
        iconData = Icons.flash_auto;
        break;
      case 'on':
      case 'always':
        iconData = Icons.flash_on;
        iconColor = Colors.yellow;
        break;
      case 'torch':
        iconData = Icons.flashlight_on;
        iconColor = Colors.yellow;
        break;
      default:
        iconData = Icons.flash_off;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          iconData,
          color: iconColor,
          size: size * 0.5,
        ),
      ),
    );
  }
}
