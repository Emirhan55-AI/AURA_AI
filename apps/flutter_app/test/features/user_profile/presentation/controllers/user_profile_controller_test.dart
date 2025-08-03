import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/user_profile/presentation/controllers/user_profile_controller.dart';

void main() {
  group('UserProfileController', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with loading state', () {
      final controller = container.read(userProfileControllerProvider);
      
      expect(controller.userProfile.isLoading, true);
      expect(controller.userStats.isLoading, true);
      expect(controller.selectedTab, 'My Combinations');
      expect(controller.availableTabs.length, 6);
    });

    test('should load profile data', () async {
      // Wait for initial load
      await Future<void>.delayed(const Duration(milliseconds: 1000));
      
      final state = container.read(userProfileControllerProvider);
      
      expect(state.userProfile.hasValue, true);
      expect(state.userStats.hasValue, true);
      
      final profile = state.userProfile.value!;
      expect(profile.displayName, 'Emma Wilson');
      expect(profile.username, '@emma_style');
      expect(profile.auraScore, 2847);
      
      final stats = state.userStats.value!;
      expect(stats.combinations, 127);
      expect(stats.favorites, 89);
      expect(stats.followers, 1204);
      expect(stats.following, 456);
    });

    test('should change selected tab', () {
      final controller = container.read(userProfileControllerProvider.notifier);
      
      controller.selectTab('My Favorites');
      
      final state = container.read(userProfileControllerProvider);
      expect(state.selectedTab, 'My Favorites');
    });

    test('should refresh profile data', () async {
      final controller = container.read(userProfileControllerProvider.notifier);
      
      // Wait for initial load
      await Future<void>.delayed(const Duration(milliseconds: 1000));
      
      // Refresh
      await controller.refreshProfile();
      
      final state = container.read(userProfileControllerProvider);
      expect(state.userProfile.hasValue, true);
      expect(state.userStats.hasValue, true);
    });
  });
}
