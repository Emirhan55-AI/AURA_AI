import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

import '../error/failure_types.dart';

/// Central service for Supabase interactions
/// 
/// This service provides common functionality for working with Supabase across the app
/// It handles authentication, database access, and storage
class SupabaseService {
  final SupabaseClient _client;

  /// Creates a SupabaseService with the provided client or uses the default instance
  SupabaseService({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;

  /// Access the Supabase client directly
  SupabaseClient get client => _client;

  /// Get current authenticated user ID or throw error if not authenticated
  String get currentUserId {
    final id = _client.auth.currentUser?.id;
    if (id == null) {
      throw const AuthFailure(
        message: 'User not authenticated',
        code: 'AUTH_REQUIRED',
      );
    }
    return id;
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _client.auth.currentUser != null;

  /// Upload a file to Supabase Storage
  /// 
  /// Returns the public URL of the uploaded file
  Future<String> uploadFile({
    required String filePath,
    required String bucket,
    String? customFilename,
  }) async {
    try {
      final file = File(filePath);
      final fileExtension = path.extension(filePath);
      final filename = customFilename ?? '${currentUserId}_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      
      // Upload the file to Supabase Storage
      await _client.storage.from(bucket).upload(
        filename,
        file,
        fileOptions: const FileOptions(cacheControl: '3600'),
      );
      
      // Get the public URL
      final publicUrl = _client.storage.from(bucket).getPublicUrl(filename);
      
      return publicUrl;
    } catch (e) {
      throw ServerFailure(
        message: 'Failed to upload file: ${e.toString()}',
        code: 'STORAGE_UPLOAD_ERROR',
      );
    }
  }
}
