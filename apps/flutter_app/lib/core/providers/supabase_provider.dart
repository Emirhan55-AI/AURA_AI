import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/supabase_service.dart';

/// Provider for the SupabaseService
/// This provider creates and manages a singleton instance of the SupabaseService
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  final supabaseService = SupabaseService();
  
  ref.onDispose(() {
    // Clean up resources when the provider is disposed
  });
  
  return supabaseService;
});
