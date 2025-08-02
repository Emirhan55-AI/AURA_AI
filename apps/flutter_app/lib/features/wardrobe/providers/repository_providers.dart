import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/repositories/supabase_wardrobe_repository.dart';
import '../domain/repositories/wardrobe_repository.dart';

/// Provider for Supabase client
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider for wardrobe repository
final wardrobeRepositoryProvider = Provider<WardrobeRepository>((ref) {
  final supabaseClient = ref.read(supabaseClientProvider);
  return SupabaseWardrobeRepository(supabase: supabaseClient);
});

/// Provider for current user ID
final currentUserIdProvider = Provider<String>((ref) {
  final client = ref.read(supabaseClientProvider);
  final userId = client.auth.currentUser?.id;
  
  if (userId == null) {
    throw Exception('User not authenticated');
  }
  
  return userId;
});
