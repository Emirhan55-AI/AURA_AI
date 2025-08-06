import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

/// Camera controller state
class CameraState {
  final List<CameraDescription> availableCameras;
  final CameraController? cameraController;
  final bool isInitialized;
  final bool isCapturing;
  final bool isRecording;
  final FlashMode flashMode;
  final double zoomLevel;
  final double maxZoom;
  final double minZoom;
  final bool showGrid;
  final Offset? focusPoint;
  final String? error;

  const CameraState({
    this.availableCameras = const [],
    this.cameraController,
    this.isInitialized = false,
    this.isCapturing = false,
    this.isRecording = false,
    this.flashMode = FlashMode.auto,
    this.zoomLevel = 1.0,
    this.maxZoom = 8.0,
    this.minZoom = 1.0,
    this.showGrid = false,
    this.focusPoint,
    this.error,
  });

  CameraState copyWith({
    List<CameraDescription>? availableCameras,
    CameraController? cameraController,
    bool? isInitialized,
    bool? isCapturing,
    bool? isRecording,
    FlashMode? flashMode,
    double? zoomLevel,
    double? maxZoom,
    double? minZoom,
    bool? showGrid,
    Offset? focusPoint,
    String? error,
  }) {
    return CameraState(
      availableCameras: availableCameras ?? this.availableCameras,
      cameraController: cameraController ?? this.cameraController,
      isInitialized: isInitialized ?? this.isInitialized,
      isCapturing: isCapturing ?? this.isCapturing,
      isRecording: isRecording ?? this.isRecording,
      flashMode: flashMode ?? this.flashMode,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      maxZoom: maxZoom ?? this.maxZoom,
      minZoom: minZoom ?? this.minZoom,
      showGrid: showGrid ?? this.showGrid,
      focusPoint: focusPoint,
      error: error,
    );
  }
}

/// Camera controller provider
final cameraControllerProvider = StateNotifierProvider<CameraControllerNotifier, AsyncValue<CameraState>>((ref) {
  return CameraControllerNotifier();
});

/// Camera controller notifier
class CameraControllerNotifier extends StateNotifier<AsyncValue<CameraState>> {
  CameraControllerNotifier() : super(const AsyncValue.loading());

  CameraState get _currentState => state.value ?? const CameraState();
  double _currentScale = 1.0;
  double _baseScale = 1.0;

  /// Initialize camera with specified lens direction
  Future<void> initializeCamera([CameraLensDirection lensDirection = CameraLensDirection.back]) async {
    try {
      state = const AsyncValue.loading();

      // Get available cameras
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No cameras available');
      }

      // Find camera with specified lens direction
      CameraDescription? selectedCamera;
      try {
        selectedCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == lensDirection,
        );
      } catch (e) {
        // If specified camera not found, use first available
        selectedCamera = cameras.first;
      }

      // Initialize camera controller
      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();

      // Get zoom capabilities
      final maxZoom = await controller.getMaxZoomLevel();
      final minZoom = await controller.getMinZoomLevel();

      state = AsyncValue.data(CameraState(
        availableCameras: cameras,
        cameraController: controller,
        isInitialized: true,
        maxZoom: maxZoom,
        minZoom: minZoom,
        zoomLevel: minZoom,
      ));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Switch to next available camera
  Future<void> switchCamera() async {
    final currentState = _currentState;
    if (!currentState.isInitialized || currentState.availableCameras.length <= 1) {
      return;
    }

    try {
      final currentCamera = currentState.cameraController!.description;
      final currentIndex = currentState.availableCameras.indexOf(currentCamera);
      final nextIndex = (currentIndex + 1) % currentState.availableCameras.length;
      final nextCamera = currentState.availableCameras[nextIndex];

      await currentState.cameraController!.dispose();
      await initializeCamera(nextCamera.lensDirection);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Toggle flash mode
  Future<void> toggleFlash() async {
    final currentState = _currentState;
    if (!currentState.isInitialized) return;

    try {
      FlashMode newFlashMode;
      switch (currentState.flashMode) {
        case FlashMode.off:
          newFlashMode = FlashMode.auto;
          break;
        case FlashMode.auto:
          newFlashMode = FlashMode.always;
          break;
        case FlashMode.always:
          newFlashMode = FlashMode.torch;
          break;
        case FlashMode.torch:
          newFlashMode = FlashMode.off;
          break;
      }

      await currentState.cameraController!.setFlashMode(newFlashMode);
      
      state = AsyncValue.data(currentState.copyWith(flashMode: newFlashMode));
    } catch (e) {
      // Flash mode not supported, ignore error
    }
  }

  /// Set zoom level
  Future<void> setZoom(double zoom) async {
    final currentState = _currentState;
    if (!currentState.isInitialized) return;

    try {
      final clampedZoom = zoom.clamp(currentState.minZoom, currentState.maxZoom);
      await currentState.cameraController!.setZoomLevel(clampedZoom);
      
      state = AsyncValue.data(currentState.copyWith(zoomLevel: clampedZoom));
    } catch (e) {
      // Zoom not supported, ignore error
    }
  }

  /// Handle zoom gesture
  void handleZoomGesture(double scale) {
    final currentState = _currentState;
    if (!currentState.isInitialized) return;

    if (scale == 1.0) {
      _baseScale = currentState.zoomLevel;
      _currentScale = 1.0;
      return;
    }

    _currentScale = scale;
    final newZoom = (_baseScale * _currentScale).clamp(
      currentState.minZoom,
      currentState.maxZoom,
    );

    setZoom(newZoom);
  }

  /// Focus on specific point
  Future<void> focusOnPoint(Offset point) async {
    final currentState = _currentState;
    if (!currentState.isInitialized) return;

    try {
      await currentState.cameraController!.setFocusPoint(point);
      await currentState.cameraController!.setExposurePoint(point);
      
      state = AsyncValue.data(currentState.copyWith(focusPoint: point));
      
      // Clear focus point after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          state = AsyncValue.data(_currentState.copyWith(focusPoint: null));
        }
      });
    } catch (e) {
      // Focus not supported, ignore error
    }
  }

  /// Toggle grid lines
  void toggleGrid() {
    final currentState = _currentState;
    state = AsyncValue.data(currentState.copyWith(showGrid: !currentState.showGrid));
  }

  /// Capture photo
  Future<XFile?> capturePhoto() async {
    final currentState = _currentState;
    if (!currentState.isInitialized || currentState.isCapturing) {
      return null;
    }

    try {
      state = AsyncValue.data(currentState.copyWith(isCapturing: true));
      
      final image = await currentState.cameraController!.takePicture();
      
      state = AsyncValue.data(currentState.copyWith(isCapturing: false));
      
      return image;
    } catch (e) {
      state = AsyncValue.data(currentState.copyWith(isCapturing: false));
      rethrow;
    }
  }

  /// Start video recording
  Future<void> startVideoRecording() async {
    final currentState = _currentState;
    if (!currentState.isInitialized || currentState.isRecording) {
      return;
    }

    try {
      await currentState.cameraController!.startVideoRecording();
      state = AsyncValue.data(currentState.copyWith(isRecording: true));
    } catch (e) {
      rethrow;
    }
  }

  /// Stop video recording
  Future<XFile?> stopVideoRecording() async {
    final currentState = _currentState;
    if (!currentState.isInitialized || !currentState.isRecording) {
      return null;
    }

    try {
      final video = await currentState.cameraController!.stopVideoRecording();
      state = AsyncValue.data(currentState.copyWith(isRecording: false));
      return video;
    } catch (e) {
      state = AsyncValue.data(currentState.copyWith(isRecording: false));
      rethrow;
    }
  }

  /// Pause camera
  Future<void> pauseCamera() async {
    final currentState = _currentState;
    if (currentState.isInitialized) {
      try {
        await currentState.cameraController!.pausePreview();
      } catch (e) {
        // Ignore pause errors
      }
    }
  }

  /// Resume camera
  Future<void> resumeCamera() async {
    final currentState = _currentState;
    if (currentState.isInitialized) {
      try {
        await currentState.cameraController!.resumePreview();
      } catch (e) {
        // Ignore resume errors
      }
    }
  }

  @override
  Future<void> dispose() async {
    final currentState = _currentState;
    if (currentState.cameraController != null) {
      await currentState.cameraController!.dispose();
    }
    super.dispose();
  }
}
