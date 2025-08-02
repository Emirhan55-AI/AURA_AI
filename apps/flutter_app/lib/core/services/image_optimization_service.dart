import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_optimization_service.g.dart';

/// Image optimization service for compressing and resizing images
/// Provides efficient image processing for wardrobe photos
class ImageOptimizationService {
  /// Maximum image dimensions for different use cases
  static const int thumbnailSize = 150;
  static const int mediumSize = 500;
  static const int largeSize = 1200;
  
  /// Image quality settings (0-100)
  static const int highQuality = 85;
  static const int mediumQuality = 70;
  static const int lowQuality = 50;

  /// Optimize an image file for storage and display
  Future<OptimizedImage> optimizeImage(
    File imageFile, {
    ImageOptimizationOptions? options,
  }) async {
    final ImageOptimizationOptions opts = 
        options ?? const ImageOptimizationOptions();
    
    try {
      // Read the original image
      final Uint8List originalBytes = await imageFile.readAsBytes();
      final img.Image? image = img.decodeImage(originalBytes);
      
      if (image == null) {
        throw ImageOptimizationException('Unable to decode image');
      }
      
      // Create different sizes
      final Map<ImageSize, Uint8List> optimizedImages = {};
      
      if (opts.generateThumbnail) {
        optimizedImages[ImageSize.thumbnail] = await _resizeAndCompress(
          image,
          thumbnailSize,
          opts.quality,
        );
      }
      
      if (opts.generateMedium) {
        optimizedImages[ImageSize.medium] = await _resizeAndCompress(
          image,
          mediumSize,
          opts.quality,
        );
      }
      
      if (opts.generateLarge) {
        optimizedImages[ImageSize.large] = await _resizeAndCompress(
          image,
          largeSize,
          opts.quality,
        );
      }
      
      return OptimizedImage(
        originalSize: originalBytes.length,
        originalDimensions: ImageDimensions(
          width: image.width,
          height: image.height,
        ),
        optimizedImages: optimizedImages,
        format: _getImageFormat(imageFile.path),
      );
    } catch (e) {
      throw ImageOptimizationException('Failed to optimize image: $e');
    }
  }
  
  /// Resize and compress image to specified size
  Future<Uint8List> _resizeAndCompress(
    img.Image image,
    int maxSize,
    int quality,
  ) async {
    return compute(_resizeAndCompressIsolate, ResizeParams(
      imageBytes: img.encodePng(image),
      maxSize: maxSize,
      quality: quality,
    ));
  }
  
  /// Get image format from file extension
  ImageFormat _getImageFormat(String filePath) {
    final String extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return ImageFormat.jpeg;
      case '.png':
        return ImageFormat.png;
      case '.webp':
        return ImageFormat.webp;
      default:
        return ImageFormat.jpeg;
    }
  }
}

/// Isolate function for image processing
Uint8List _resizeAndCompressIsolate(ResizeParams params) {
  final img.Image? image = img.decodePng(params.imageBytes);
  if (image == null) {
    throw ImageOptimizationException('Unable to decode image in isolate');
  }
  
  // Calculate new dimensions maintaining aspect ratio
  final double aspectRatio = image.width / image.height;
  int newWidth, newHeight;
  
  if (image.width > image.height) {
    newWidth = params.maxSize;
    newHeight = (params.maxSize / aspectRatio).round();
  } else {
    newHeight = params.maxSize;
    newWidth = (params.maxSize * aspectRatio).round();
  }
  
  // Resize image
  final img.Image resized = img.copyResize(
    image,
    width: newWidth,
    height: newHeight,
    interpolation: img.Interpolation.cubic,
  );
  
  // Compress as JPEG
  return Uint8List.fromList(img.encodeJpg(resized, quality: params.quality));
}

/// Parameters for image resizing in isolate
class ResizeParams {
  const ResizeParams({
    required this.imageBytes,
    required this.maxSize,
    required this.quality,
  });

  final Uint8List imageBytes;
  final int maxSize;
  final int quality;
}

/// Image optimization options
class ImageOptimizationOptions {
  const ImageOptimizationOptions({
    this.generateThumbnail = true,
    this.generateMedium = true,
    this.generateLarge = false,
    this.quality = ImageOptimizationService.mediumQuality,
  });

  final bool generateThumbnail;
  final bool generateMedium;
  final bool generateLarge;
  final int quality;
}

/// Optimized image result
class OptimizedImage {
  const OptimizedImage({
    required this.originalSize,
    required this.originalDimensions,
    required this.optimizedImages,
    required this.format,
  });

  final int originalSize;
  final ImageDimensions originalDimensions;
  final Map<ImageSize, Uint8List> optimizedImages;
  final ImageFormat format;

  /// Get compression ratio for a specific size
  double getCompressionRatio(ImageSize size) {
    final Uint8List? optimized = optimizedImages[size];
    if (optimized == null) return 0.0;
    
    return 1.0 - (optimized.length / originalSize);
  }
  
  /// Get optimized image bytes for a specific size
  Uint8List? getOptimizedBytes(ImageSize size) {
    return optimizedImages[size];
  }
}

/// Image dimensions
class ImageDimensions {
  const ImageDimensions({
    required this.width,
    required this.height,
  });

  final int width;
  final int height;

  double get aspectRatio => width / height;
  
  @override
  String toString() => '${width}x$height';
}

/// Image size categories
enum ImageSize {
  thumbnail,
  medium,
  large,
}

/// Supported image formats
enum ImageFormat {
  jpeg,
  png,
  webp,
}

/// Image optimization exception
class ImageOptimizationException implements Exception {
  const ImageOptimizationException(this.message);
  
  final String message;
  
  @override
  String toString() => 'ImageOptimizationException: $message';
}

/// Image optimization service provider
@Riverpod(keepAlive: true)
ImageOptimizationService imageOptimizationService(
  ImageOptimizationServiceRef ref,
) {
  return ImageOptimizationService();
}

/// Image cache manager for optimized images
@riverpod
class ImageCacheManager extends _$ImageCacheManager {
  @override
  Map<String, OptimizedImage> build() {
    return {};
  }
  
  /// Cache an optimized image
  void cacheImage(String key, OptimizedImage image) {
    state = {...state, key: image};
  }
  
  /// Get cached image
  OptimizedImage? getCachedImage(String key) {
    return state[key];
  }
  
  /// Clear image cache
  void clearCache() {
    state = {};
  }
  
  /// Get cache size in bytes
  int getCacheSize() {
    int totalSize = 0;
    for (final OptimizedImage image in state.values) {
      totalSize += image.originalSize;
      for (final Uint8List bytes in image.optimizedImages.values) {
        totalSize += bytes.length;
      }
    }
    return totalSize;
  }
}

/// Image utility functions
class ImageUtils {
  /// Get image widget with optimization
  static Widget buildOptimizedImage(
    OptimizedImage optimizedImage,
    ImageSize preferredSize, {
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
  }) {
    final Uint8List? imageBytes = optimizedImage.getOptimizedBytes(preferredSize);
    
    if (imageBytes == null) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: const Icon(Icons.image_not_supported),
      );
    }
    
    return Image.memory(
      imageBytes,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        );
      },
    );
  }
  
  /// Format file size for display
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
  
  /// Get recommended image size based on context
  static ImageSize getRecommendedSize(BuildContext context) {
    final double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final Size screenSize = MediaQuery.of(context).size;
    
    if (devicePixelRatio > 2.0 && screenSize.width > 600) {
      return ImageSize.large;
    } else if (screenSize.width > 300) {
      return ImageSize.medium;
    } else {
      return ImageSize.thumbnail;
    }
  }
}
