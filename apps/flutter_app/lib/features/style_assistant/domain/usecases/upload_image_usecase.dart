import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../repositories/style_assistant_repository.dart';

/// UploadImageUseCase is responsible for uploading an image to the AI service
class UploadImageUseCase {
  final StyleAssistantRepository _repository;

  UploadImageUseCase(this._repository);

  /// Call method to upload an image and get back the URL
  ///
  /// Takes the file path to the image to upload.
  /// Returns a [Future] that resolves to [Either]:
  /// - [Left] containing a [Failure] if the operation failed
  /// - [Right] containing the uploaded image URL string if successful
  Future<Either<Failure, String>> call(String filePath) async {
    return await _repository.uploadImage(filePath);
  }
}
