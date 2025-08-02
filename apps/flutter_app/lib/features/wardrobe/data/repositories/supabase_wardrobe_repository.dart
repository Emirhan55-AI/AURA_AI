import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../domain/entities/clothing_item.dart';
import '../../domain/repositories/wardrobe_repository.dart';
import '../models/clothing_item_model.dart';

/// Supabase implementation of the wardrobe repository
/// Handles all wardrobe-related data operations with Supabase backend
class SupabaseWardrobeRepository implements WardrobeRepository {
  final SupabaseClient _supabase;
  final String? _currentUserId;

  const SupabaseWardrobeRepository({
    required SupabaseClient supabase,
    String? currentUserId,
  }) : _supabase = supabase,
       _currentUserId = currentUserId;

  String get currentUserId {
    final userId = _currentUserId ?? _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthFailure.notAuthenticated();
    }
    return userId;
  }

  @override
  Future<Either<Failure, List<ClothingItem>>> getClothingItems() async {
    try {
      final response = await _supabase
          .from('clothing_items')
          .select('*')
          .eq('user_id', currentUserId)
          .isFilter('deleted_at', null) // Only get non-deleted items
          .order('created_at', ascending: false);

      final items = (response as List<dynamic>)
          .map((json) => ClothingItemModel.fromJson(json).toEntity())
          .toList();

      return Right(items);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, ClothingItem>> getClothingItemById(String id) async {
    try {
      final response = await _supabase
          .from('clothing_items')
          .select('*')
          .eq('id', id)
          .eq('user_id', currentUserId) // RLS compliance
          .isFilter('deleted_at', null)
          .single();

      final item = ClothingItemModel.fromJson(response).toEntity();
      return Right(item);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, ClothingItem>> addClothingItem(ClothingItem item) async {
    try {
      final model = ClothingItemModel.fromEntity(item);
      final jsonData = model.toJson()
        ..['user_id'] = currentUserId
        ..['created_at'] = DateTime.now().toIso8601String()
        ..['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('clothing_items')
          .insert(jsonData)
          .select('*')
          .single();

      final createdItem = ClothingItemModel.fromJson(response).toEntity();
      return Right(createdItem);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, ClothingItem>> updateClothingItem(ClothingItem item) async {
    try {
      final model = ClothingItemModel.fromEntity(item);
      final jsonData = model.toJson()
        ..['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('clothing_items')
          .update(jsonData)
          .eq('id', item.id)
          .eq('user_id', currentUserId) // RLS compliance
          .select('*')
          .single();

      final updatedItem = ClothingItemModel.fromJson(response).toEntity();
      return Right(updatedItem);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteClothingItem(String id) async {
    try {
      // Soft delete - set deleted_at timestamp
      await _supabase
          .from('clothing_items')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', id)
          .eq('user_id', currentUserId); // RLS compliance

      return const Right(null);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<ClothingItem>>> getClothingItemsByCategory(String category) async {
    try {
      final response = await _supabase
          .from('clothing_items')
          .select('*')
          .eq('user_id', currentUserId)
          .eq('category', category)
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false);

      final items = (response as List<dynamic>)
          .map((json) => ClothingItemModel.fromJson(json).toEntity())
          .toList();

      return Right(items);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<ClothingItem>>> searchClothingItems(String query) async {
    try {
      final response = await _supabase
          .from('clothing_items')
          .select('*')
          .eq('user_id', currentUserId)
          .isFilter('deleted_at', null)
          .or('name.ilike.%$query%,brand.ilike.%$query%,category.ilike.%$query%')
          .order('created_at', ascending: false);

      final items = (response as List<dynamic>)
          .map((json) => ClothingItemModel.fromJson(json).toEntity())
          .toList();

      return Right(items);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<ClothingItem>>> getClothingItemsByColor(String color) async {
    try {
      final response = await _supabase
          .from('clothing_items')
          .select('*')
          .eq('user_id', currentUserId)
          .contains('colors', [color])
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false);

      final items = (response as List<dynamic>)
          .map((json) => ClothingItemModel.fromJson(json).toEntity())
          .toList();

      return Right(items);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<ClothingItem>>> getClothingItemsByBrand(String brand) async {
    try {
      final response = await _supabase
          .from('clothing_items')
          .select('*')
          .eq('user_id', currentUserId)
          .eq('brand', brand)
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false);

      final items = (response as List<dynamic>)
          .map((json) => ClothingItemModel.fromJson(json).toEntity())
          .toList();

      return Right(items);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getWardrobeStats() async {
    try {
      // Get total items count
      final totalResponse = await _supabase
          .from('clothing_items')
          .select('id')
          .eq('user_id', currentUserId)
          .isFilter('deleted_at', null);

      // Get items by category
      final categoryResponse = await _supabase
          .from('clothing_items')
          .select('category')
          .eq('user_id', currentUserId)
          .isFilter('deleted_at', null);

      final categories = <String, int>{};
      for (final item in categoryResponse as List<dynamic>) {
        final category = item['category'] as String? ?? 'Unknown';
        categories[category] = (categories[category] ?? 0) + 1;
      }

      return Right({
        'total_items': totalResponse.length,
        'categories': categories.length,
        ...categories.map((key, value) => MapEntry('category_$key', value)),
      });
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> batchDeleteClothingItems(List<String> ids) async {
    try {
      await _supabase
          .from('clothing_items')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .inFilter('id', ids)
          .eq('user_id', currentUserId);

      return const Right(null);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<ClothingItem>>> getRecentlyAddedItems({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('clothing_items')
          .select('*')
          .eq('user_id', currentUserId)
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false)
          .limit(limit);

      final items = (response as List<dynamic>)
          .map((json) => ClothingItemModel.fromJson(json).toEntity())
          .toList();

      return Right(items);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> isClothingItemOwner(String itemId) async {
    try {
      final response = await _supabase
          .from('clothing_items')
          .select('user_id')
          .eq('id', itemId)
          .isFilter('deleted_at', null)
          .maybeSingle();

      if (response == null) {
        return const Right(false);
      }

      final isOwner = response['user_id'] == currentUserId;
      return Right(isOwner);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }
}
