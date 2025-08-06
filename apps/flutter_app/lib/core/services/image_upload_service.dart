import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;

class ImageUploadService {
  final SupabaseClient _supabase;
  
  ImageUploadService(this._supabase);

  /// Uploads an image to Supabase storage and returns the public URL
  Future<String> uploadClothingItemImage(File imageFile) async {
    try {
      // Optimize image before upload
      final optimizedImage = await _optimizeImage(imageFile);
      
      // Generate unique filename
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final filePath = 'clothing_items/$fileName';
      
      // Upload to Supabase storage
      await _supabase.storage
          .from('clothing-images')
          .uploadBinary(filePath, optimizedImage);
      
      // Get public URL
      final publicUrl = _supabase.storage
          .from('clothing-images')
          .getPublicUrl(filePath);
      
      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Uploads image from bytes to Supabase storage and returns the public URL
  Future<String> uploadClothingItemImageFromBytes(Uint8List imageBytes) async {
    try {
      // Optimize image before upload
      final optimizedImage = await _optimizeImageFromBytes(imageBytes);
      
      // Generate unique filename
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_clothing_item.jpg';
      final filePath = 'clothing_items/$fileName';
      
      // Upload to Supabase storage
      await _supabase.storage
          .from('clothing-images')
          .uploadBinary(filePath, optimizedImage);
      
      // Get public URL
      final publicUrl = _supabase.storage
          .from('clothing-images')
          .getPublicUrl(filePath);
      
      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Optimizes image for upload (resize and compress)
  Future<Uint8List> _optimizeImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return await _optimizeImageFromBytes(bytes);
  }

  /// Optimizes image from bytes for upload (resize and compress)
  Future<Uint8List> _optimizeImageFromBytes(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    
    if (image == null) {
      throw Exception('Invalid image format');
    }
    
    // Resize to max 800px width while maintaining aspect ratio
    final resized = img.copyResize(image, width: 800);
    
    // Compress as JPEG with 85% quality
    return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
  }
}
