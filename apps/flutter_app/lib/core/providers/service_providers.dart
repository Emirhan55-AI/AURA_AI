import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/image_upload_service.dart';
import '../services/ai_tagging_service.dart';
import '../services/aura_ai_service.dart';

part 'service_providers.g.dart';

@riverpod
ImageUploadService imageUploadService(ImageUploadServiceRef ref) {
  final supabase = Supabase.instance.client;
  return ImageUploadService(supabase);
}

@riverpod
AiTaggingService aiTaggingService(AiTaggingServiceRef ref) {
  return AiTaggingService();
}

@riverpod
AuraAiService auraAiService(AuraAiServiceRef ref) {
  return AuraAiService();
}
