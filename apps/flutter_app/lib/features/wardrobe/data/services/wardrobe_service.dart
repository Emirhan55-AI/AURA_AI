import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failure.dart';

/// Service layer for wardrobe data operations with Supabase
/// Handles direct communication with the Supabase database
/// Maps raw database responses and exceptions to application-specific types
class WardrobeService {
  final SupabaseClient _supabaseClient;

  /// Constructor that initializes the service with a Supabase client
  WardrobeService({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  /// Gets the current user ID from the authenticated session
  String? get _currentUserId => _supabaseClient.auth.currentUser?.id;

  /// Fetches raw clothing items data from Supabase with filtering and pagination
  /// 
  /// Returns raw JSON data as List<Map<String, dynamic>> for further processing
  Future<Either<Failure, List<Map<String, dynamic>>>> fetchItemsRaw({
    int page = 1,
    int limit = 20,
    String? searchTerm,
    List<String>? categoryIds,
    List<String>? seasons,
    bool showOnlyFavorites = false,
    String? sortBy,
  }) async {
    try {
      // Ensure user is authenticated
      if (_currentUserId == null) {
        return const Left(AuthFailure(
          message: 'User not authenticated',
          code: 'AUTH_REQUIRED',
        ));
      }

      // Build the base query
      var queryBuilder = _supabaseClient
          .from('clothing_items')
          .select('*')
          .eq('user_id', _currentUserId!)
          .isFilter('deleted_at', null); // Only get non-deleted items

      // Apply search filter
      if (searchTerm != null && searchTerm.trim().isNotEmpty) {
        queryBuilder = queryBuilder.or('name.ilike.%$searchTerm%,brand.ilike.%$searchTerm%,notes.ilike.%$searchTerm%');
      }

      // Apply category filter
      if (categoryIds != null && categoryIds.isNotEmpty) {
        queryBuilder = queryBuilder.inFilter('category', categoryIds);
      }

      // Apply favorites filter
      if (showOnlyFavorites) {
        queryBuilder = queryBuilder.eq('is_favorite', true);
      }

      // Apply sorting
      final sortField = _getSortField(sortBy);
      final ascending = _getSortDirection(sortBy);
      
      // Apply pagination and execute
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit - 1;
      
      final response = await queryBuilder
          .order(sortField, ascending: ascending)
          .range(startIndex, endIndex);

      // Return the raw data
      return Right(List<Map<String, dynamic>>.from(response));
    } on PostgrestException catch (e) {
      return Left(ServiceFailure(
        message: 'Database error: ${e.message}',
        code: e.code,
        details: e.details,
      ));
    } on AuthException catch (e) {
      return Left(AuthFailure(
        message: 'Authentication error: ${e.message}',
        code: 'AUTH_ERROR',
        details: e,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Unexpected error while fetching items: ${e.toString()}',
        code: 'FETCH_ERROR',
        details: e,
      ));
    }
  }

  /// Adds a new clothing item to the database
  /// 
  /// Returns raw JSON data as Map<String, dynamic> for the created item
  Future<Either<Failure, Map<String, dynamic>>> addItemRaw(
    Map<String, dynamic> itemData,
  ) async {
    try {
      // Ensure user is authenticated
      if (_currentUserId == null) {
        return const Left(AuthFailure(
          message: 'User not authenticated',
          code: 'AUTH_REQUIRED',
        ));
      }

      // Ensure the item belongs to the current user
      final dataWithUserId = {
        ...itemData,
        'user_id': _currentUserId,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Insert the item and return the created record
      final response = await _supabaseClient
          .from('clothing_items')
          .insert(dataWithUserId)
          .select()
          .single();

      return Right(Map<String, dynamic>.from(response));
    } on PostgrestException catch (e) {
      return Left(ServiceFailure(
        message: 'Database error: ${e.message}',
        code: e.code,
        details: e.details,
      ));
    } on AuthException catch (e) {
      return Left(AuthFailure(
        message: 'Authentication error: ${e.message}',
        code: 'AUTH_ERROR',
        details: e,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Unexpected error while adding item: ${e.toString()}',
        code: 'ADD_ERROR',
        details: e,
      ));
    }
  }

  /// Gets a specific clothing item by ID
  Future<Either<Failure, Map<String, dynamic>>> getItemByIdRaw(String itemId) async {
    try {
      // Ensure user is authenticated
      if (_currentUserId == null) {
        return const Left(AuthFailure(
          message: 'User not authenticated',
          code: 'AUTH_REQUIRED',
        ));
      }

      final response = await _supabaseClient
          .from('clothing_items')
          .select('*')
          .eq('id', itemId)
          .eq('user_id', _currentUserId!)
          .isFilter('deleted_at', null)
          .single();

      return Right(Map<String, dynamic>.from(response));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return const Left(ValidationFailure(
          message: 'Clothing item not found',
          code: 'ITEM_NOT_FOUND',
        ));
      }
      return Left(ServiceFailure(
        message: 'Database error: ${e.message}',
        code: e.code,
        details: e.details,
      ));
    } on AuthException catch (e) {
      return Left(AuthFailure(
        message: 'Authentication error: ${e.message}',
        code: 'AUTH_ERROR',
        details: e,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Unexpected error while fetching item: ${e.toString()}',
        code: 'FETCH_ERROR',
        details: e,
      ));
    }
  }

  /// Updates an existing clothing item
  Future<Either<Failure, Map<String, dynamic>>> updateItemRaw(
    String itemId,
    Map<String, dynamic> itemData,
  ) async {
    try {
      // Ensure user is authenticated
      if (_currentUserId == null) {
        return const Left(AuthFailure(
          message: 'User not authenticated',
          code: 'AUTH_REQUIRED',
        ));
      }

      // Add updated timestamp
      final dataWithTimestamp = {
        ...itemData,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabaseClient
          .from('clothing_items')
          .update(dataWithTimestamp)
          .eq('id', itemId)
          .eq('user_id', _currentUserId!)
          .isFilter('deleted_at', null)
          .select()
          .single();

      return Right(Map<String, dynamic>.from(response));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return const Left(ValidationFailure(
          message: 'Clothing item not found',
          code: 'ITEM_NOT_FOUND',
        ));
      }
      return Left(ServiceFailure(
        message: 'Database error: ${e.message}',
        code: e.code,
        details: e.details,
      ));
    } on AuthException catch (e) {
      return Left(AuthFailure(
        message: 'Authentication error: ${e.message}',
        code: 'AUTH_ERROR',
        details: e,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Unexpected error while updating item: ${e.toString()}',
        code: 'UPDATE_ERROR',
        details: e,
      ));
    }
  }

  /// Soft deletes a clothing item by setting deleted_at timestamp
  Future<Either<Failure, void>> deleteItemRaw(String itemId) async {
    try {
      // Ensure user is authenticated
      if (_currentUserId == null) {
        return const Left(AuthFailure(
          message: 'User not authenticated',
          code: 'AUTH_REQUIRED',
        ));
      }

      await _supabaseClient
          .from('clothing_items')
          .update({
            'deleted_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', itemId)
          .eq('user_id', _currentUserId!)
          .isFilter('deleted_at', null);

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ServiceFailure(
        message: 'Database error: ${e.message}',
        code: e.code,
        details: e.details,
      ));
    } on AuthException catch (e) {
      return Left(AuthFailure(
        message: 'Authentication error: ${e.message}',
        code: 'AUTH_ERROR',
        details: e,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Unexpected error while deleting item: ${e.toString()}',
        code: 'DELETE_ERROR',
        details: e,
      ));
    }
  }

  /// Toggles the favorite status of a clothing item
  Future<Either<Failure, Map<String, dynamic>>> toggleFavoriteRaw(
    String itemId,
    bool isFavorite,
  ) async {
    try {
      // Ensure user is authenticated
      if (_currentUserId == null) {
        return const Left(AuthFailure(
          message: 'User not authenticated',
          code: 'AUTH_REQUIRED',
        ));
      }

      final response = await _supabaseClient
          .from('clothing_items')
          .update({
            'is_favorite': isFavorite,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', itemId)
          .eq('user_id', _currentUserId!)
          .isFilter('deleted_at', null)
          .select()
          .single();

      return Right(Map<String, dynamic>.from(response));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return const Left(ValidationFailure(
          message: 'Clothing item not found',
          code: 'ITEM_NOT_FOUND',
        ));
      }
      return Left(ServiceFailure(
        message: 'Database error: ${e.message}',
        code: e.code,
        details: e.details,
      ));
    } on AuthException catch (e) {
      return Left(AuthFailure(
        message: 'Authentication error: ${e.message}',
        code: 'AUTH_ERROR',
        details: e,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Unexpected error while toggling favorite: ${e.toString()}',
        code: 'FAVORITE_ERROR',
        details: e,
      ));
    }
  }

  /// Helper method to get the database field for sorting
  String _getSortField(String? sortBy) {
    switch (sortBy) {
      case 'name':
        return 'name';
      case 'created_at':
        return 'created_at';
      case 'updated_at':
        return 'updated_at';
      case 'last_worn_date':
        return 'last_worn_date';
      case 'brand':
        return 'brand';
      case 'price':
        return 'price';
      default:
        return 'created_at'; // Default sort by creation date
    }
  }

  /// Helper method to get the sort direction
  bool _getSortDirection(String? sortBy) {
    // Most recent first for dates, alphabetical for text fields
    switch (sortBy) {
      case 'created_at':
      case 'updated_at':
      case 'last_worn_date':
        return false; // Descending (newest first)
      case 'name':
      case 'brand':
        return true; // Ascending (A-Z)
      case 'price':
        return true; // Ascending (lowest first)
      default:
        return false; // Default to descending
    }
  }
}
