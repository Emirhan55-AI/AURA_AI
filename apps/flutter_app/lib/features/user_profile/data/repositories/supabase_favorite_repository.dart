import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/favorite.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../models/favorite_model.dart';

/// Supabase implementation of FavoriteRepository
/// 
/// This repository handles all favorite-related operations with Supabase backend:
/// - CRUD operations for favorites
/// - User-specific favorite management
/// - Real-time data synchronization
class SupabaseFavoriteRepository implements FavoriteRepository {
  final SupabaseClient _supabase;

  SupabaseFavoriteRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<Either<Failure, List<Favorite>>> getFavorites() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return Left(AuthFailure.notAuthenticated());
      }

      final response = await _supabase
          .from('favorites')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final favorites = response
          .map<Favorite>((json) => FavoriteModel.fromJson(json).toEntity())
          .toList();

      return Right(favorites);
    } on PostgrestException catch (e) {
      return Left(NetworkFailure.serverError(
        code: e.code,
        details: 'Failed to get favorites: ${e.message}',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Unexpected error occurred',
        details: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, List<Favorite>>> getFavoritesByType(FavoriteType type) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return Left(AuthFailure.notAuthenticated());
      }

      final response = await _supabase
          .from('favorites')
          .select()
          .eq('user_id', user.id)
          .eq('type', type.value)
          .order('created_at', ascending: false);

      final favorites = response
          .map<Favorite>((json) => FavoriteModel.fromJson(json).toEntity())
          .toList();

      return Right(favorites);
    } on PostgrestException catch (e) {
      return Left(NetworkFailure.serverError(
        code: e.code,
        details: 'Failed to get favorites by type: ${e.message}',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Unexpected error occurred',
        details: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, Favorite>> addFavorite(
    String itemId,
    FavoriteType type, {
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return Left(AuthFailure.notAuthenticated());
      }

      // Check if already favorited
      final existingCheck = await _supabase
          .from('favorites')
          .select('id')
          .eq('user_id', user.id)
          .eq('item_id', itemId)
          .eq('type', type.value)
          .maybeSingle();

      if (existingCheck != null) {
        return Left(ValidationFailure(
          message: 'Item is already favorited',
        ));
      }

      final favoriteData = {
        'user_id': user.id,
        'item_id': itemId,
        'type': type.value,
        'metadata': metadata ?? {},
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('favorites')
          .insert(favoriteData)
          .select()
          .single();

      final favorite = FavoriteModel.fromJson(response).toEntity();
      return Right(favorite);
    } on PostgrestException catch (e) {
      return Left(NetworkFailure.serverError(
        code: e.code,
        details: 'Failed to add favorite: ${e.message}',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Unexpected error occurred',
        details: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, void>> removeFavorite(String favoriteId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return Left(AuthFailure.notAuthenticated());
      }

      await _supabase
          .from('favorites')
          .delete()
          .eq('id', favoriteId)
          .eq('user_id', user.id); // Ensure user can only delete their own favorites

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(NetworkFailure.serverError(
        code: e.code,
        details: 'Failed to remove favorite: ${e.message}',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Unexpected error occurred',
        details: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, void>> removeFavoriteByItem(String itemId, FavoriteType type) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return Left(AuthFailure.notAuthenticated());
      }

      await _supabase
          .from('favorites')
          .delete()
          .eq('user_id', user.id)
          .eq('item_id', itemId)
          .eq('type', type.value);

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(NetworkFailure.serverError(
        code: e.code,
        details: 'Failed to remove favorite by item: ${e.message}',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Unexpected error occurred',
        details: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorited(String itemId, FavoriteType type) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return Left(AuthFailure.notAuthenticated());
      }

      final response = await _supabase
          .from('favorites')
          .select('id')
          .eq('user_id', user.id)
          .eq('item_id', itemId)
          .eq('type', type.value)
          .maybeSingle();

      return Right(response != null);
    } on PostgrestException catch (e) {
      return Left(NetworkFailure.serverError(
        code: e.code,
        details: 'Failed to check favorite status: ${e.message}',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Unexpected error occurred',
        details: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, void>> removeFavorites(List<String> favoriteIds) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return Left(AuthFailure.notAuthenticated());
      }

      await _supabase
          .from('favorites')
          .delete()
          .inFilter('id', favoriteIds)
          .eq('user_id', user.id); // Ensure user can only delete their own favorites

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(NetworkFailure.serverError(
        code: e.code,
        details: 'Failed to remove favorites: ${e.message}',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Unexpected error occurred',
        details: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, Map<FavoriteType, int>>> getFavoriteCounts() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return Left(AuthFailure.notAuthenticated());
      }

      final response = await _supabase
          .from('favorites')
          .select('type')
          .eq('user_id', user.id);

      final counts = <FavoriteType, int>{};
      
      // Initialize all types with 0
      for (final type in FavoriteType.values) {
        counts[type] = 0;
      }

      // Count actual favorites
      for (final item in response) {
        final typeString = item['type'] as String;
        try {
          final type = FavoriteType.fromString(typeString);
          counts[type] = (counts[type] ?? 0) + 1;
        } catch (e) {
          // Skip invalid types
          continue;
        }
      }

      return Right(counts);
    } on PostgrestException catch (e) {
      return Left(NetworkFailure.serverError(
        code: e.code,
        details: 'Failed to get favorite counts: ${e.message}',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Unexpected error occurred',
        details: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, List<Favorite>>> searchFavorites(String query, {FavoriteType? type}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return Left(AuthFailure.notAuthenticated());
      }

      // Note: This is a basic implementation. In a real app, you might want to
      // join with the actual item tables to search in item names/descriptions
      var queryBuilder = _supabase
          .from('favorites')
          .select()
          .eq('user_id', user.id);

      if (type != null) {
        queryBuilder = queryBuilder.eq('type', type.value);
      }

      // For now, we'll search in metadata if it contains searchable fields
      // In a production app, you'd likely join with the actual item tables
      final response = await queryBuilder.order('created_at', ascending: false);

      final favorites = response
          .map<Favorite>((json) => FavoriteModel.fromJson(json).toEntity())
          .toList();

      // Simple client-side filtering by item_id containing the query
      // In production, this should be server-side with proper full-text search
      final filteredFavorites = favorites.where((favorite) {
        return favorite.itemId.toLowerCase().contains(query.toLowerCase()) ||
               favorite.metadata.values.any((value) => 
                 value.toString().toLowerCase().contains(query.toLowerCase()));
      }).toList();

      return Right(filteredFavorites);
    } on PostgrestException catch (e) {
      return Left(NetworkFailure.serverError(
        code: e.code,
        details: 'Failed to search favorites: ${e.message}',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Unexpected error occurred',
        details: e.toString(),
      ));
    }
  }
}
