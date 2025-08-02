import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:flutter_app/features/wardrobe/presentation/controllers/wardrobe_controller.dart';
import 'package:flutter_app/features/wardrobe/domain/repositories/wardrobe_repository.dart';
import 'package:flutter_app/features/wardrobe/domain/entities/clothing_item.dart';
import 'package:flutter_app/features/wardrobe/domain/entities/category.dart';
import 'package:flutter_app/core/error/failure.dart';

import 'wardrobe_controller_test.mocks.dart';

// Generate mocks for dependencies
@GenerateMocks([WardrobeRepository])
void main() {
  late MockWardrobeRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockWardrobeRepository();
    container = ProviderContainer(
      overrides: [
        wardrobeRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('WardrobeController', () {
    group('build', () {
      test('should return empty list when no items exist', () async {
        // Arrange
        when(mockRepository.getClothingItems())
            .thenAnswer((_) async => const Right([]));

        // Act
        final result = await container.read(wardrobeControllerProvider.future);

        // Assert
        expect(result, isEmpty);
        verify(mockRepository.getClothingItems()).called(1);
      });

      test('should return list of clothing items when items exist', () async {
        // Arrange
        final items = [
          const ClothingItem(
            id: '1',
            name: 'Test Shirt',
            category: Category(id: '1', name: 'Tops'),
            color: 'Blue',
          ),
          const ClothingItem(
            id: '2',
            name: 'Test Pants',
            category: Category(id: '2', name: 'Bottoms'),
            color: 'Black',
          ),
        ];
        when(mockRepository.getClothingItems())
            .thenAnswer((_) async => Right(items));

        // Act
        final result = await container.read(wardrobeControllerProvider.future);

        // Assert
        expect(result, equals(items));
        expect(result.length, equals(2));
        verify(mockRepository.getClothingItems()).called(1);
      });

      test('should throw failure when repository returns error', () async {
        // Arrange
        const failure = NetworkFailure.noConnection();
        when(mockRepository.getClothingItems())
            .thenAnswer((_) async => const Left(failure));

        // Act & Assert
        expect(
          () => container.read(wardrobeControllerProvider.future),
          throwsA(isA<NetworkFailure>()),
        );
        verify(mockRepository.getClothingItems()).called(1);
      });
    });

    group('addClothingItem', () {
      test('should add item successfully and refresh state', () async {
        // Arrange
        const newItem = ClothingItem(
          id: '3',
          name: 'New Jacket',
          category: Category(id: '3', name: 'Outerwear'),
          color: 'Green',
        );
        
        // Initial empty state
        when(mockRepository.getClothingItems())
            .thenAnswer((_) async => const Right([]));
        
        // After adding item
        when(mockRepository.addClothingItem(any))
            .thenAnswer((_) async => const Right(unit));
        when(mockRepository.getClothingItems())
            .thenAnswer((_) async => const Right([newItem]));

        // Act
        final controller = container.read(wardrobeControllerProvider.notifier);
        await controller.addClothingItem(newItem);

        // Assert
        final result = await container.read(wardrobeControllerProvider.future);
        expect(result, contains(newItem));
        verify(mockRepository.addClothingItem(newItem)).called(1);
        verify(mockRepository.getClothingItems()).called(2); // Initial + refresh
      });

      test('should handle add failure and maintain state', () async {
        // Arrange
        const newItem = ClothingItem(
          id: '3',
          name: 'New Jacket',
          category: Category(id: '3', name: 'Outerwear'),
          color: 'Green',
        );
        const failure = DataFailure.savingFailed();

        when(mockRepository.getClothingItems())
            .thenAnswer((_) async => const Right([]));
        when(mockRepository.addClothingItem(any))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final controller = container.read(wardrobeControllerProvider.notifier);
        final result = await controller.addClothingItem(newItem);

        // Assert
        expect(result.isLeft(), isTrue);
        expect(result.fold((l) => l, (r) => null), equals(failure));
        verify(mockRepository.addClothingItem(newItem)).called(1);
        verifyNever(mockRepository.getClothingItems());
      });
    });

    group('updateClothingItem', () {
      test('should update item successfully and refresh state', () async {
        // Arrange
        const originalItem = ClothingItem(
          id: '1',
          name: 'Old Name',
          category: Category(id: '1', name: 'Tops'),
          color: 'Blue',
        );
        const updatedItem = ClothingItem(
          id: '1',
          name: 'New Name',
          category: Category(id: '1', name: 'Tops'),
          color: 'Red',
        );

        when(mockRepository.getClothingItems())
            .thenAnswer((_) async => const Right([originalItem]));
        when(mockRepository.updateClothingItem(any))
            .thenAnswer((_) async => const Right(unit));

        // Act
        final controller = container.read(wardrobeControllerProvider.notifier);
        await controller.updateClothingItem(updatedItem);

        // Assert
        verify(mockRepository.updateClothingItem(updatedItem)).called(1);
        verify(mockRepository.getClothingItems()).called(2);
      });
    });

    group('deleteClothingItem', () {
      test('should delete item successfully and refresh state', () async {
        // Arrange
        const itemToDelete = ClothingItem(
          id: '1',
          name: 'To Delete',
          category: Category(id: '1', name: 'Tops'),
          color: 'Blue',
        );

        when(mockRepository.getClothingItems())
            .thenAnswer((_) async => const Right([itemToDelete]));
        when(mockRepository.deleteClothingItem(any))
            .thenAnswer((_) async => const Right(unit));

        // Act
        final controller = container.read(wardrobeControllerProvider.notifier);
        await controller.deleteClothingItem('1');

        // Assert
        verify(mockRepository.deleteClothingItem('1')).called(1);
        verify(mockRepository.getClothingItems()).called(2);
      });
    });

    group('toggleFavorite', () {
      test('should toggle favorite status and refresh state', () async {
        // Arrange
        const item = ClothingItem(
          id: '1',
          name: 'Test Item',
          category: Category(id: '1', name: 'Tops'),
          color: 'Blue',
          isFavorite: false,
        );

        when(mockRepository.getClothingItems())
            .thenAnswer((_) async => const Right([item]));
        when(mockRepository.toggleFavorite(any))
            .thenAnswer((_) async => const Right(unit));

        // Act
        final controller = container.read(wardrobeControllerProvider.notifier);
        await controller.toggleFavorite('1');

        // Assert
        verify(mockRepository.toggleFavorite('1')).called(1);
        verify(mockRepository.getClothingItems()).called(2);
      });
    });

    group('searchItems', () {
      test('should filter items by search query', () async {
        // Arrange
        final items = [
          const ClothingItem(
            id: '1',
            name: 'Blue Shirt',
            category: Category(id: '1', name: 'Tops'),
            color: 'Blue',
          ),
          const ClothingItem(
            id: '2',
            name: 'Red Pants',
            category: Category(id: '2', name: 'Bottoms'),
            color: 'Red',
          ),
          const ClothingItem(
            id: '3',
            name: 'Blue Jeans',
            category: Category(id: '2', name: 'Bottoms'),
            color: 'Blue',
          ),
        ];

        when(mockRepository.getClothingItems())
            .thenAnswer((_) async => Right(items));

        // Act
        final controller = container.read(wardrobeControllerProvider.notifier);
        await controller.searchItems('Blue');

        // Assert
        final searchResults = container.read(wardrobeSearchResultsProvider);
        expect(searchResults.length, equals(2));
        expect(searchResults.every((item) => 
            item.name.contains('Blue') || item.color.contains('Blue')), 
            isTrue);
      });
    });

    group('filterByCategory', () {
      test('should filter items by category', () async {
        // Arrange
        final items = [
          const ClothingItem(
            id: '1',
            name: 'Shirt',
            category: Category(id: '1', name: 'Tops'),
            color: 'Blue',
          ),
          const ClothingItem(
            id: '2',
            name: 'Pants',
            category: Category(id: '2', name: 'Bottoms'),
            color: 'Black',
          ),
          const ClothingItem(
            id: '3',
            name: 'T-Shirt',
            category: Category(id: '1', name: 'Tops'),
            color: 'White',
          ),
        ];

        when(mockRepository.getClothingItems())
            .thenAnswer((_) async => Right(items));

        // Act
        final controller = container.read(wardrobeControllerProvider.notifier);
        await controller.filterByCategory('1');

        // Assert
        final filteredResults = container.read(wardrobeFilteredItemsProvider);
        expect(filteredResults.length, equals(2));
        expect(filteredResults.every((item) => item.category.id == '1'), isTrue);
      });
    });
  });

  group('WardrobeStats', () {
    test('should calculate statistics correctly', () async {
      // Arrange
      final items = [
        const ClothingItem(
          id: '1',
          name: 'Shirt',
          category: Category(id: '1', name: 'Tops'),
          color: 'Blue',
          isFavorite: true,
        ),
        const ClothingItem(
          id: '2',
          name: 'Pants',
          category: Category(id: '2', name: 'Bottoms'),
          color: 'Black',
          isFavorite: false,
        ),
        const ClothingItem(
          id: '3',
          name: 'Jacket',
          category: Category(id: '3', name: 'Outerwear'),
          color: 'Green',
          isFavorite: true,
        ),
      ];

      when(mockRepository.getClothingItems())
          .thenAnswer((_) async => Right(items));

      // Act
      final stats = await container.read(wardrobeStatsProvider.future);

      // Assert
      expect(stats.totalItems, equals(3));
      expect(stats.favoriteCount, equals(2));
      expect(stats.categoriesCount, equals(3));
      expect(stats.topCategories.length, equals(3));
    });
  });
}
