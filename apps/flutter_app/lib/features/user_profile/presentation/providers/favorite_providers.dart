import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/supabase_favorite_repository.dart';
import '../../domain/repositories/favorite_repository.dart';

part 'favorite_providers.g.dart';

/// Provider for FavoriteRepository
@riverpod
FavoriteRepository favoriteRepository(FavoriteRepositoryRef ref) {
  return SupabaseFavoriteRepository();
}
