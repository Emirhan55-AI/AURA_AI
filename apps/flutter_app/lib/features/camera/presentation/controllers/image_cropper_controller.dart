import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

/// Provider for the image cropper controller
final imageCropperControllerProvider = AutoDisposeNotifierProvider<ImageCropperController, ImageCropperState>((ref) {
  return ImageCropperController();
});

/// State for the image cropper
class ImageCropperState {
  final String? imagePath;
  final bool isLoading;
  final String? error;

  const ImageCropperState({
    this.imagePath,
    this.isLoading = false,
    this.error,
  });

  ImageCropperState copyWith({
    String? imagePath,
    bool? isLoading,
    String? error,
  }) {
    return ImageCropperState(
      imagePath: imagePath ?? this.imagePath,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Controller for handling image cropping operations
class ImageCropperController extends AutoDisposeNotifier<ImageCropperState> {
  @override
  ImageCropperState build() {
    return const ImageCropperState();
  }

  /// Crops an image file
  Future<void> cropImage(String sourcePath) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: sourcePath,
        compressQuality: 85,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9,
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Edit Image',
            toolbarColor: const Color(0xFF6750A4),
            toolbarWidgetColor: const Color(0xFFFFFFFF),
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Edit Image',
            rotateButtonsHidden: false,
            rotateClockwiseButtonHidden: false,
            aspectRatioPickerButtonHidden: false,
            aspectRatioLockEnabled: false,
            resetAspectRatioEnabled: true,
          ),
          WebUiSettings(
            context: null,
            presentStyle: CropperPresentStyle.dialog,
            enableExif: true,
            enableZoom: true,
            showZoomer: true,
          ),
        ],
      );

      if (croppedFile != null) {
        state = state.copyWith(
          imagePath: croppedFile.path,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to crop image: $e',
      );
    }
  }

  /// Picks a new image from gallery
  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        await cropImage(pickedFile.path);
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to pick image: $e',
      );
    }
  }

  /// Resets the state
  void reset() {
    state = const ImageCropperState();
  }
}
