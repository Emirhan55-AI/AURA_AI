import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/supabase_provider.dart';
import '../../social/domain/repositories/social_repository.dart';
import '../../social/data/repositories/social_repository_impl.dart';

/// Provider for the SocialRepository implementation
/// Makes the repository available to controllers and other providers
final socialRepositoryProvider = Provider<SocialRepository>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  
  return SocialRepositoryImpl(
    supabaseService: supabaseService,
  );
});
