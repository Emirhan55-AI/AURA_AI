import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/user_profile/domain/repositories/profile_repository.dart';
import '../../features/outfits/domain/repositories/outfit_repository.dart';
import '../../features/style_profile/domain/repositories/style_profile_repository.dart';
import '../../features/wardrobe/domain/repositories/wardrobe_repository.dart';
import '../../features/wardrobe/providers/repository_providers.dart' as wardrobe_providers;

part 'data_layer_providers.g.dart';

/// Provider for ProfileRepository
@riverpod
ProfileRepository profileRepository(ProfileRepositoryRef ref) {
  // Will be implemented with concrete Supabase implementation
  throw UnimplementedError('ProfileRepository implementation pending');
}

/// Provider for OutfitRepository
@riverpod
OutfitRepository outfitRepository(OutfitRepositoryRef ref) {
  // Will be implemented with concrete Supabase implementation
  throw UnimplementedError('OutfitRepository implementation pending');
}

/// Provider for StyleProfileRepository
@riverpod
StyleProfileRepository styleProfileRepository(StyleProfileRepositoryRef ref) {
  // Will be implemented with concrete Supabase implementation
  throw UnimplementedError('StyleProfileRepository implementation pending');
}

/// Provider for WardrobeRepository (references existing provider)
@riverpod
WardrobeRepository wardrobeRepositoryWrapper(WardrobeRepositoryWrapperRef ref) {
  // Reference the existing provider from wardrobe feature
  return ref.watch(wardrobe_providers.wardrobeRepositoryProvider);
}

/// Combined data layer services provider
@riverpod
DataLayerServices dataLayerServices(DataLayerServicesRef ref) {
  return DataLayerServices(
    profileRepository: ref.watch(profileRepositoryProvider),
    outfitRepository: ref.watch(outfitRepositoryProvider),
    styleProfileRepository: ref.watch(styleProfileRepositoryProvider),
    wardrobeRepository: ref.watch(wardrobeRepositoryWrapperProvider),
  );
}

/// Data layer services container
class DataLayerServices {
  final ProfileRepository profileRepository;
  final OutfitRepository outfitRepository;
  final StyleProfileRepository styleProfileRepository;
  final WardrobeRepository wardrobeRepository;

  const DataLayerServices({
    required this.profileRepository,
    required this.outfitRepository,
    required this.styleProfileRepository,
    required this.wardrobeRepository,
  });
}
