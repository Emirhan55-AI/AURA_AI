import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Provider for ImagePicker
final imagePickerProvider = Provider<ImagePicker>((ref) {
  return ImagePicker();
});
