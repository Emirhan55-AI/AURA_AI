import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../controllers/image_cropper_controller.dart';

/// Screen for cropping and editing images
class ImageCropperScreen extends ConsumerStatefulWidget {
  final XFile? imageFile;
  final void Function(String)? onImageProcessed;

  const ImageCropperScreen({
    super.key, 
    this.imageFile,
    this.onImageProcessed,
  });

  @override
  ConsumerState<ImageCropperScreen> createState() => _ImageCropperScreenState();
}

class _ImageCropperScreenState extends ConsumerState<ImageCropperScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.imageFile != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(imageCropperControllerProvider.notifier).cropImage(widget.imageFile!.path);
      });
    }
  }

  @override
  void dispose() {
    ref.invalidate(imageCropperControllerProvider);
    super.dispose();
  }

  void _handleSave() {
    final state = ref.read(imageCropperControllerProvider);
    if (state.imagePath != null) {
      if (widget.onImageProcessed != null) {
        widget.onImageProcessed!(state.imagePath!);
      }
      context.pop(state.imagePath);
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(imageCropperControllerProvider);
    final controller = ref.read(imageCropperControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Image'),
        actions: [
          if (state.imagePath != null)
            TextButton(
              onPressed: _handleSave,
              child: Text(
                'Save',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _buildMainContent(state, controller, colorScheme),
            ),
            _buildBottomActions(state, controller, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(
    ImageCropperState state,
    ImageCropperController controller,
    ColorScheme colorScheme,
  ) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: TextStyle(
                color: colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.pickImage,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (state.imagePath != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: Image.file(
          File(state.imagePath!),
          fit: BoxFit.contain,
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 64,
            color: colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Select an image to start editing',
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: controller.pickImage,
            child: const Text('Select Image'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(
    ImageCropperState state,
    ImageCropperController controller,
    ColorScheme colorScheme,
  ) {
    if (state.imagePath == null || state.isLoading) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.crop,
            label: 'Recrop',
            onTap: () => controller.cropImage(state.imagePath!),
          ),
          _buildActionButton(
            icon: Icons.refresh,
            label: 'New Image',
            onTap: controller.pickImage,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }
}
