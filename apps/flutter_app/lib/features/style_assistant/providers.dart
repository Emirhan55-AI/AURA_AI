import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/repositories/style_assistant_repository_impl.dart';
import 'data/services/style_assistant_ai_service.dart';
import 'domain/repositories/style_assistant_repository.dart';
import 'domain/usecases/get_ai_response_stream_usecase.dart';
import 'domain/usecases/upload_image_usecase.dart';

// Configuration constants - In production, these should be environment variables
const String _fastApiBaseUrl = 'http://localhost:8000'; // TODO: Replace with actual FastAPI URL

/// Provider for getting authentication token
/// Uses the existing Supabase client to get the current user's JWT token
final authTokenProvider = Provider<Future<String?> Function()>((ref) {
  final supabaseClient = Supabase.instance.client;
  
  return () async {
    final session = supabaseClient.auth.currentSession;
    return session?.accessToken;
  };
});

/// Provider for StyleAssistantAiService
/// Provides the AI service with FastAPI backend URL and auth token getter
final styleAssistantAiServiceProvider = Provider<StyleAssistantAiService>((ref) {
  final getAuthToken = ref.read(authTokenProvider);
  
  return StyleAssistantAiService(
    baseUrl: _fastApiBaseUrl,
    getAuthToken: getAuthToken,
  );
});

/// Provider for StyleAssistantRepository implementation
/// Provides the repository with AI service dependency
final styleAssistantRepositoryProvider = Provider<StyleAssistantRepository>((ref) {
  final aiService = ref.read(styleAssistantAiServiceProvider);
  
  return StyleAssistantRepositoryImpl(aiService: aiService);
});

/// Provider for GetAiResponseStreamUseCase
/// Provides the use case with repository dependency
final getAiResponseStreamUseCaseProvider = Provider<GetAiResponseStreamUseCase>((ref) {
  final repository = ref.read(styleAssistantRepositoryProvider);
  
  return GetAiResponseStreamUseCase(repository);
});

/// Provider for UploadImageUseCase
/// Provides the use case with repository dependency
final uploadImageUseCaseProvider = Provider<UploadImageUseCase>((ref) {
  final repository = ref.read(styleAssistantRepositoryProvider);
  
  return UploadImageUseCase(repository);
});

/// Provider to dispose of AI service when no longer needed  
final styleAssistantDisposalProvider = Provider<void>((ref) {
  final aiService = ref.read(styleAssistantAiServiceProvider);
  
  ref.onDispose(() {
    aiService.dispose();
  });
});
