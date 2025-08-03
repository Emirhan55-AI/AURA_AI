import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/user_wardrobe_repository.dart';
import '../services/wardrobe_service.dart';
import '../../domain/repositories/i_user_wardrobe_repository.dart';
import '../../presentation/controllers/add_clothing_item_controller.dart';

/// Provider for the Wardrobe Service
/// Provides the service layer that handles direct Supabase communication
final wardrobeServiceProvider = Provider<WardrobeService>((ref) {
  return WardrobeService();
});

/// Provider for the User Wardrobe Repository
/// Provides the repository implementation that converts between domain and data layers
final userWardrobeRepositoryProvider = Provider<IUserWardrobeRepository>((ref) {
  final wardrobeService = ref.watch(wardrobeServiceProvider);
  return UserWardrobeRepository(wardrobeService: wardrobeService);
});

/// Provider for the Add Clothing Item Controller
/// Manages the state for adding new clothing items to the wardrobe
final addClothingItemControllerProvider = StateNotifierProvider<AddClothingItemController, AddClothingItemState>((ref) {
  return AddClothingItemController(ref);
});
