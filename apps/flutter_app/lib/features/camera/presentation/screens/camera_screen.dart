import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../controllers/camera_controller.dart';
import '../widgets/camera_capture_button.dart';
import '../widgets/camera_controls_overlay.dart';
import '../widgets/camera_switch_button.dart';
import '../../../../shared/widgets/common/loading_widget.dart';

/// Camera Screen for capturing clothing item photos
/// Provides professional camera interface with various capture modes and controls
/// Supports both camera capture and gallery selection
class CameraScreen extends ConsumerStatefulWidget {
  /// Optional callback for when image is captured/selected
  final void Function(XFile)? onImageCaptured;
  
  /// Whether to show gallery option (default: true)
  final bool showGalleryOption;
  
  /// Initial camera facing (default: back)
  final CameraLensDirection initialCameraFacing;

  const CameraScreen({
    super.key,
    this.onImageCaptured,
    this.showGalleryOption = true,
    this.initialCameraFacing = CameraLensDirection.back,
  });

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  
  late AnimationController _fadeAnimationController;
  late AnimationController _scaleAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize animations
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(
      parent: _scaleAnimationController,
      curve: Curves.elasticOut,
    ));
    
    // Start animations
    _fadeAnimationController.forward();
    _scaleAnimationController.forward();
    
    // Initialize camera
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cameraControllerProvider.notifier)
          .initializeCamera(widget.initialCameraFacing);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _fadeAnimationController.dispose();
    _scaleAnimationController.dispose();
    ref.read(cameraControllerProvider.notifier).dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cameraController = ref.read(cameraControllerProvider.notifier);
    
    if (state == AppLifecycleState.inactive) {
      cameraController.pauseCamera();
    } else if (state == AppLifecycleState.resumed) {
      cameraController.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraControllerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context, colorScheme),
      body: cameraState.when(
        loading: () => _buildLoadingView(),
        error: (error, stack) => _buildErrorView(context, error.toString()),
        data: (state) => _buildCameraView(context, state),
      ),
    );
  }

  /// Builds the app bar with camera controls
  PreferredSizeWidget _buildAppBar(BuildContext context, ColorScheme colorScheme) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.close,
            color: Colors.white,
            size: 20,
          ),
        ),
        tooltip: 'Close Camera',
      ),
      actions: [
        if (widget.showGalleryOption)
          IconButton(
            onPressed: _selectFromGallery,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.photo_library,
                color: Colors.white,
                size: 20,
              ),
            ),
            tooltip: 'Select from Gallery',
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// Builds loading view
  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingWidget(),
          SizedBox(height: 16),
          Text(
            'Initializing Camera...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds error view
  Widget _buildErrorView(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: Colors.white54,
            ),
            const SizedBox(height: 24),
            const Text(
              'Camera Not Available',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to access camera. Please check permissions.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(cameraControllerProvider.notifier)
                        .initializeCamera(widget.initialCameraFacing);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                ),
                if (widget.showGalleryOption)
                  ElevatedButton.icon(
                    onPressed: _selectFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds main camera view
  Widget _buildCameraView(BuildContext context, CameraState state) {
    if (state.cameraController == null || !state.cameraController!.value.isInitialized) {
      return _buildLoadingView();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Stack(
          children: [
            // Camera Preview
            _buildCameraPreview(state),
            
            // Camera Controls Overlay
            CameraControlsOverlay(
              isRecording: state.isRecording,
              flashMode: state.flashMode,
              zoomLevel: state.zoomLevel,
              onFlashToggle: () => ref.read(cameraControllerProvider.notifier).toggleFlash(),
              onCameraSwitch: () => ref.read(cameraControllerProvider.notifier).switchCamera(),
              onZoomChanged: (zoom) => ref.read(cameraControllerProvider.notifier).setZoom(zoom),
            ),
            
            // Bottom Controls
            _buildBottomControls(context, state),
            
            // Grid Lines (if enabled)
            if (state.showGrid) _buildGridLines(),
            
            // Focus Point Indicator
            if (state.focusPoint != null) _buildFocusIndicator(state.focusPoint!),
          ],
        ),
      ),
    );
  }

  /// Builds camera preview with gesture detection
  Widget _buildCameraPreview(CameraState state) {
    return Positioned.fill(
      child: GestureDetector(
        onTapUp: (details) {
          final controller = ref.read(cameraControllerProvider.notifier);
          controller.focusOnPoint(details.localPosition);
        },
        onScaleUpdate: (details) {
          final controller = ref.read(cameraControllerProvider.notifier);
          controller.handleZoomGesture(details.scale);
        },
        child: CameraPreview(state.cameraController!),
      ),
    );
  }

  /// Builds bottom controls
  Widget _buildBottomControls(BuildContext context, CameraState state) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.8),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Recent Photos Thumbnail
              _buildRecentPhotoThumbnail(),
              
              // Capture Button
              CameraCaptureButton(
                onTap: _capturePhoto,
                isCapturing: state.isCapturing,
              ),
              
              // Camera Switch Button
              CameraSwitchButton(
                onTap: () => ref.read(cameraControllerProvider.notifier).switchCamera(),
                isEnabled: state.availableCameras.length > 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds recent photo thumbnail
  Widget _buildRecentPhotoThumbnail() {
    return GestureDetector(
      onTap: widget.showGalleryOption ? _selectFromGallery : null,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: const Icon(
          Icons.photo_library_outlined,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  /// Builds grid lines overlay
  Widget _buildGridLines() {
    return Positioned.fill(
      child: CustomPaint(
        painter: GridPainter(),
      ),
    );
  }

  /// Builds focus point indicator
  Widget _buildFocusIndicator(Offset point) {
    return Positioned(
      left: point.dx - 40,
      top: point.dy - 40,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(40),
        ),
        child: const Icon(
          Icons.center_focus_strong,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  /// Captures photo
  Future<void> _capturePhoto() async {
    try {
      final image = await ref.read(cameraControllerProvider.notifier).capturePhoto();
      if (image != null) {
        if (widget.onImageCaptured != null) {
          widget.onImageCaptured!(image);
        } else {
          // Navigate to add clothing item screen with captured image
          if (mounted) {
            context.push('/wardrobe/add-item', extra: {'image': image});
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Selects image from gallery
  Future<void> _selectFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        if (widget.onImageCaptured != null) {
          widget.onImageCaptured!(image);
        } else {
          // Navigate to add clothing item screen with selected image
          if (mounted) {
            context.push('/wardrobe/add-item', extra: {'image': image});
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Custom painter for grid lines
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1.0;

    // Draw vertical lines
    final double verticalSpacing = size.width / 3;
    for (int i = 1; i < 3; i++) {
      final double x = i * verticalSpacing;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    final double horizontalSpacing = size.height / 3;
    for (int i = 1; i < 3; i++) {
      final double y = i * horizontalSpacing;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
