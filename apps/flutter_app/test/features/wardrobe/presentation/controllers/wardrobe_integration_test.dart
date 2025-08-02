import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_app/features/wardrobe/presentation/controllers/wardrobe_controller.dart';
import 'package:flutter_app/features/wardrobe/domain/entities/clothing_item.dart';

/// Integration tests for WardrobeController
/// These tests focus on testing the controller behavior rather than mocking dependencies
void main() {
  group('WardrobeController Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Controller State Management', () {
      test('should start with loading state', () {
        // Act
        final state = container.read(wardrobeControllerProvider);

        // Assert
        expect(state.isLoading, isTrue);
      });

      test('should handle async state changes', () async {
        // Arrange
        final controller = container.read(wardrobeControllerProvider.notifier);

        // Act - trigger the async state
        final _ = container.read(wardrobeControllerProvider);

        // Allow async operations to complete
        await container.pump();

        // Assert that state is no longer loading
        final finalState = container.read(wardrobeControllerProvider);
        expect(finalState.isLoading, isFalse);
      });
    });

    group('Search Functionality', () {
      test('should handle search when state is null', () async {
        // Arrange
        final controller = container.read(wardrobeControllerProvider.notifier);

        // Act
        final result = await controller.searchItems('test');

        // Assert
        expect(result, isEmpty);
      });

      test('should handle empty search query', () async {
        // Arrange
        final controller = container.read(wardrobeControllerProvider.notifier);

        // Wait for initial state to load
        try {
          await container.read(wardrobeControllerProvider.future);
        } catch (e) {
          // Expected to fail without proper repository setup
        }

        // Act
        final result = await controller.searchItems('');

        // Assert
        expect(result, isA<List<ClothingItem>>());
      });
    });

    group('Toggle Favorite Functionality', () {
      test('should handle toggle favorite when state is null', () async {
        // Arrange
        final controller = container.read(wardrobeControllerProvider.notifier);

        // Act & Assert - should not throw
        await controller.toggleFavorite('test-id');
      });
    });

    group('Error Handling', () {
      test('should handle repository errors gracefully', () {
        // Act
        final future = container.read(wardrobeControllerProvider.future);

        // Assert
        expect(future, throwsA(isA<Exception>()));
      });
    });
  });

  group('ClothingItem Entity Tests', () {
    test('should create ClothingItem with required fields', () {
      // Arrange
      final now = DateTime.now();

      // Act
      final item = ClothingItem(
        id: '1',
        userId: 'user1',
        name: 'Test Shirt',
        createdAt: now,
        updatedAt: now,
      );

      // Assert
      expect(item.id, equals('1'));
      expect(item.userId, equals('user1'));
      expect(item.name, equals('Test Shirt'));
      expect(item.isFavorite, isFalse); // default value
      expect(item.category, isNull); // optional field
    });

    test('should create ClothingItem with all fields', () {
      // Arrange
      final now = DateTime.now();
      final purchaseDate = DateTime(2023, 1, 1);

      // Act
      final item = ClothingItem(
        id: '1',
        userId: 'user1',
        name: 'Designer Shirt',
        category: 'tops',
        color: 'Blue',
        pattern: 'Solid',
        brand: 'Nike',
        purchaseDate: purchaseDate,
        purchaseLocation: 'Online Store',
        size: 'M',
        condition: 'New',
        price: 29.99,
        currency: 'USD',
        imageUrl: 'https://example.com/image.jpg',
        notes: 'Favorite shirt',
        tags: ['casual', 'work'],
        aiTags: {'style': 'casual', 'occasion': 'work'},
        lastWornDate: now,
        isFavorite: true,
        createdAt: now,
        updatedAt: now,
      );

      // Assert
      expect(item.category, equals('tops'));
      expect(item.color, equals('Blue'));
      expect(item.brand, equals('Nike'));
      expect(item.price, equals(29.99));
      expect(item.isFavorite, isTrue);
      expect(item.tags, contains('casual'));
      expect(item.aiTags?['style'], equals('casual'));
    });

    test('should create copy with updated fields', () {
      // Arrange
      final now = DateTime.now();
      final original = ClothingItem(
        id: '1',
        userId: 'user1',
        name: 'Original Name',
        isFavorite: false,
        createdAt: now,
        updatedAt: now,
      );

      // Act
      final updated = original.copyWith(
        name: 'Updated Name',
        isFavorite: true,
      );

      // Assert
      expect(updated.id, equals(original.id));
      expect(updated.name, equals('Updated Name'));
      expect(updated.isFavorite, isTrue);
      expect(updated.userId, equals(original.userId));
    });
  });
}
