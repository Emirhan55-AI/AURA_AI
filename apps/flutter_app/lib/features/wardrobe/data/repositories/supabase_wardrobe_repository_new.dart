import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failure_mapper.dart';
import '../../domain/entities/clothing_item.dart';
import '../../domain/repositories/wardrobe_repository.dart';
import '../../domain/repositories/i_user_wardrobe_repository.dart';
import '../models/clothing_item_model.dart';

/// Supabase implementation of the wardrobe repository
/// Handles all wardrobe-related data operations with Supabase backend
class SupabaseWardrobeRepository implements WardrobeRepository, IUserWardrobeRepository {
  final SupabaseClient _supabase;
  final String? _currentUserId;

  const SupabaseWardrobeRepository({
    required SupabaseClient supabase,
    String? currentUserId,
  }) : _supabase = supabase,
       _currentUserId = currentUserId;

  String get _tableName => 'clothing_items';

  String? get _userId => _currentUserId ?? _supabase.auth.currentUser?.id;

  // IUserWardrobeRepository implementations
  @override
  Future<Either<Failure, List<ClothingItem>>> fetchItems({
    int page = 1,
    int limit = 20,
    String? searchTerm,
    List<String>? categoryIds,
    List<String>? seasons,
    bool showOnlyFavorites = false,
    String? sortBy,
  }) async {
    try {
      final userId = _userId;
      if (userId == null) {
        return Left(FailureMapper.fromException(Exception('User not authenticated')));
      }

      var query = _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId);

      if (searchTerm != null && searchTerm.isNotEmpty) {
        query = query.or('name.ilike.%$searchTerm%,brand.ilike.%$searchTerm%,notes.ilike.%$searchTerm%');
      }

      if (categoryIds != null && categoryIds.isNotEmpty) {
        // Use PostgreSQL 'IN' operator syntax
        final categoryFilter = categoryIds.map((id) => "'$id'").join(',');
        query = query.filter('category', 'in', '($categoryFilter)');
      }

      if (seasons != null && seasons.isNotEmpty) {
        // Assuming seasons is stored as an array in database
        for (final season in seasons) {
          query = query.contains('season', [season]);
        }
      }

      if (showOnlyFavorites) {
        query = query.eq('is_favorite', true);
      }

      // Apply sorting and pagination
      final response = await query
          .order(sortBy ?? 'created_at', ascending: false)
          .range((page - 1) * limit, page * limit - 1);

      final items = (response as List<dynamic>)
          .map((json) => ClothingItemModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();

      return Right(items);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, ClothingItem>> addItem(ClothingItem newItem) async {
    try {
      final userId = _userId;
      if (userId == null) {
        return Left(FailureMapper.fromException(Exception('User not authenticated')));
      }

      final model = ClothingItemModel.fromEntity(newItem);
      final now = DateTime.now();
      
      final dataToInsert = model.toJson()
        ..['user_id'] = userId
        ..['created_at'] = now.toIso8601String()
        ..['updated_at'] = now.toIso8601String();

      final response = await _supabase
          .from(_tableName)
          .insert(dataToInsert)
          .select()
          .single();

      final createdItem = ClothingItemModel.fromJson(response).toEntity();
      return Right(createdItem);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, ClothingItem>> getItemById(String itemId) async {
    try {
      final userId = _userId;
      if (userId == null) {
        return Left(FailureMapper.fromException(Exception('User not authenticated')));
      }

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', itemId)
          .eq('user_id', userId)
          .single();

      final item = ClothingItemModel.fromJson(response).toEntity();
      return Right(item);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, ClothingItem>> updateItem(ClothingItem item) async {
    try {
      final userId = _userId;
      if (userId == null) {
        return Left(FailureMapper.fromException(Exception('User not authenticated')));
      }

      final model = ClothingItemModel.fromEntity(item);
      final dataToUpdate = model.toJson()
        ..['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from(_tableName)
          .update(dataToUpdate)
          .eq('id', item.id)
          .eq('user_id', userId)
          .select()
          .single();

      final updatedItem = ClothingItemModel.fromJson(response).toEntity();
      return Right(updatedItem);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteItem(String itemId) async {
    try {
      final userId = _userId;
      if (userId == null) {
        return Left(FailureMapper.fromException(Exception('User not authenticated')));
      }

      // Hard delete for now (can be changed to soft delete later)
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', itemId)
          .eq('user_id', userId);

      return const Right(null);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, ClothingItem>> toggleFavorite(String itemId, bool isFavorite) async {
    try {
      final userId = _userId;
      if (userId == null) {
        return Left(FailureMapper.fromException(Exception('User not authenticated')));
      }

      final response = await _supabase
          .from(_tableName)
          .update({
            'is_favorite': isFavorite,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', itemId)
          .eq('user_id', userId)
          .select()
          .single();

      final updatedItem = ClothingItemModel.fromJson(response).toEntity();
      return Right(updatedItem);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  // WardrobeRepository implementations
  @override
  Future<Either<Failure, List<ClothingItem>>> getClothingItems() async {
    try {
      final userId = _userId;
      if (userId == null) {
        return Left(FailureMapper.fromException(Exception('User not authenticated')));
      }

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final items = (response as List<dynamic>)
          .map((json) => ClothingItemModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();

      return Right(items);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, ClothingItem>> getClothingItemById(String id) async {
    return getItemById(id);
  }

  @override
  Future<Either<Failure, ClothingItem>> addClothingItem(ClothingItem item) async {
    return addItem(item);
  }

  @override
  Future<Either<Failure, ClothingItem>> updateClothingItem(ClothingItem item) async {
    return updateItem(item);
  }

  @override
  Future<Either<Failure, void>> deleteClothingItem(String id) async {
    return deleteItem(id);
  }

  @override
  Future<Either<Failure, List<ClothingItem>>> getClothingItemsByCategory(String category) async {
    try {
      final userId = _userId;
      if (userId == null) {
        return Left(FailureMapper.fromException(Exception('User not authenticated')));
      }

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('category', category)
          .order('created_at', ascending: false);

      final items = (response as List<dynamic>)
          .map((json) => ClothingItemModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();

      return Right(items);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<ClothingItem>>> searchClothingItems(String query) async {
    try {
      final userId = _userId;
      if (userId == null) {
        return Left(FailureMapper.fromException(Exception('User not authenticated')));
      }

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .or('name.ilike.%$query%,brand.ilike.%$query%,category.ilike.%$query%,notes.ilike.%$query%')
          .order('created_at', ascending: false);

      final items = (response as List<dynamic>)
          .map((json) => ClothingItemModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();

      return Right(items);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<ClothingItem>>> getClothingItemsByColor(String color) async {
    try {
      final userId = _userId;
      if (userId == null) {
        return Left(FailureMapper.fromException(Exception('User not authenticated')));
      }

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('color', color)
          .order('created_at', ascending: false);

      final items = (response as List<dynamic>)
          .map((json) => ClothingItemModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();

      return Right(items);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<ClothingItem>>> getClothingItemsByBrand(String brand) async {
    try {
      final userId = _userId;
      if (userId == null) {
        return Left(FailureMapper.fromException(Exception('User not authenticated')));
      }

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('brand', brand)
          .order('created_at', ascending: false);

      final items = (response as List<dynamic>)
          .map((json) => ClothingItemModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();

      return Right(items);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getWardrobeStats() async {
    try {
      final userId = _userId;
      if (userId == null) {
        return Left(FailureMapper.fromException(Exception('User not authenticated')));
      }

      // Get all items for stats calculation
      final response = await _supabase
          .from(_tableName)
          .select('category, is_favorite')
          .eq('user_id', userId);

      final items = response as List<dynamic>;
      final stats = <String, int>{
        'total': items.length,
        'favorites': items.where((item) => item['is_favorite'] == true).length,
      };

      // Count by category
      final categoryCount = <String, int>{};
      for (final item in items) {
        final category = item['category'] as String? ?? 'other';
        categoryCount[category] = (categoryCount[category] ?? 0) + 1;
      }

      stats.addAll(categoryCount);
      return Right(stats);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> batchDeleteClothingItems(List<String> ids) async {
    try {
      final userId = _userId;
      if (userId == null) {
        return Left(FailureMapper.fromException(Exception('User not authenticated')));
      }

      // Delete multiple items using filter
      final idsFilter = ids.map((id) => "'$id'").join(',');
      await _supabase
          .from(_tableName)
          .delete()
          .eq('user_id', userId)
          .filter('id', 'in', '($idsFilter)');

      return const Right(null);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<ClothingItem>>> getRecentlyAddedItems({int limit = 10}) async {
    try {
      final userId = _userId;
      if (userId == null) {
        return Left(FailureMapper.fromException(Exception('User not authenticated')));
      }

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      final items = (response as List<dynamic>)
          .map((json) => ClothingItemModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();

      return Right(items);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> isClothingItemOwner(String itemId) async {
    try {
      final userId = _userId;
      if (userId == null) {
        return Left(FailureMapper.fromException(Exception('User not authenticated')));
      }

      final response = await _supabase
          .from(_tableName)
          .select('id')
          .eq('id', itemId)
          .eq('user_id', userId)
          .maybeSingle();

      return Right(response != null);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }
}
