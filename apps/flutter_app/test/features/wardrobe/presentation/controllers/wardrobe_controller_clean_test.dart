import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';

import 'package:flutter_app/features/wardrobe/presentation/controllers/wardrobe_controller.dart';
import 'package:flutter_app/features/wardrobe/domain/repositories/wardrobe_repository.dart';
import 'package:flutter_app/features/wardrobe/domain/entities/clothing_item.dart';
import 'package:flutter_app/core/error/failure.dart';
import 'package:flutter_app/core/providers/data_layer_providers.dart';

// Mock data layer services
class MockWardrobeRepository implements WardrobeRepository {
  List<ClothingItem> _items = [];
  bool shouldFail = false;
  
  void setShouldFail(bool value) {
    shouldFail = value;
  }
  
  void addMockItem(ClothingItem item) {
    _items.add(item);
  }
  
  void clearItems() {
    _items.clear();
  }

  @override
  Future<Either<Failure, List<ClothingItem>>> getClothingItems() async {
    if (shouldFail) {
      return const Left(NetworkFailure());
    }
    return Right(_items);
  }

  @override
  Future<Either<Failure, ClothingItem>> addClothingItem(ClothingItem item) async {
    if (shouldFail) {
      return const Left(ValidationFailure());
    }
    final newItem = item.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _items.add(newItem);
    return Right(newItem);
  }

  @override
  Future<Either<Failure, ClothingItem>> updateClothingItem(ClothingItem item) async {
    if (shouldFail) {
      return const Left(ValidationFailure());
    }
    final index = _items.indexWhere((element) => element.id == item.id);
    if (index != -1) {
      final updatedItem = item.copyWith(updatedAt: DateTime.now());
      _items[index] = updatedItem;
      return Right(updatedItem);
    }
    return const Left(ValidationFailure(message: 'Item not found'));
  }

  @override
  Future<Either<Failure, Unit>> deleteClothingItem(String itemId) async {
    if (shouldFail) {
      return const Left(ValidationFailure());
    }
    _items.removeWhere((element) => element.id == itemId);
    return const Right(unit);
  }
}

// Mock data layer services
class MockDataLayerServices {
  final WardrobeRepository wardrobeRepository;
  
  MockDataLayerServices({required this.wardrobeRepository});
}

void main() {
  late MockWardrobeRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockWardrobeRepository();
    container = ProviderContainer(
      overrides: [
        dataLayerServicesProvider.overrideWithValue(
          MockDataLayerServices(wardrobeRepository: mockRepository),
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    mockRepository.clearItems();
  });

  group('WardrobeController', () {
    group('build', () {
      test('should return empty list initially', () async {
        // Act
        final result = await container.read(wardrobeControllerProvider.future);

        // Assert
        expect(result, isA<List<ClothingItem>>());
        expect(result, isEmpty);
      });

      test('should return items from repository', () async {
        // Arrange
        final testItem = ClothingItem(
          id: '1',
          userId: 'user1',
          name: 'Test Shirt',
          category: 'tops',
          color: 'Blue',
          imageUrl: 'test.jpg',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        mockRepository.addMockItem(testItem);

        // Act
        final result = await container.read(wardrobeControllerProvider.future);

        // Assert
        expect(result, hasLength(1));
        expect(result.first.name, equals('Test Shirt'));
      });

      test('should throw exception when repository fails', () async {
        // Arrange
        mockRepository.setShouldFail(true);

        // Act & Assert
        expect(
          () => container.read(wardrobeControllerProvider.future),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('addClothingItem', () {
      test('should add item successfully and refresh state', () async {
        // Arrange
        final controller = container.read(wardrobeControllerProvider.notifier);
        final newItem = ClothingItem(
          id: '',
          userId: 'user1',
          name: 'New Shirt',
          category: 'tops',
          color: 'Red',
          imageUrl: 'new.jpg',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        await controller.addClothingItem(newItem);

        // Assert
        final state = await container.read(wardrobeControllerProvider.future);
        expect(state, hasLength(1));
        expect(state.first.name, equals('New Shirt'));
      });

      test('should set error state when repository fails', () async {
        // Arrange
        mockRepository.setShouldFail(true);
        final controller = container.read(wardrobeControllerProvider.notifier);
        final newItem = ClothingItem(
          id: '',
          userId: 'user1',
          name: 'New Shirt',
          category: 'tops',
          color: 'Red',
          imageUrl: 'new.jpg',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        await controller.addClothingItem(newItem);

        // Assert
        final state = container.read(wardrobeControllerProvider);
        expect(state.hasError, isTrue);
      });
    });

    group('updateClothingItem', () {
      test('should update item successfully', () async {
        // Arrange
        final originalItem = ClothingItem(
          id: '1',
          userId: 'user1',
          name: 'Original Shirt',
          category: 'tops',
          color: 'Blue',
          imageUrl: 'original.jpg',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        mockRepository.addMockItem(originalItem);

        // Load initial state
        await container.read(wardrobeControllerProvider.future);

        final controller = container.read(wardrobeControllerProvider.notifier);
        final updatedItem = originalItem.copyWith(name: 'Updated Shirt');

        // Act
        await controller.updateClothingItem(updatedItem);

        // Assert
        final state = await container.read(wardrobeControllerProvider.future);
        expect(state.first.name, equals('Updated Shirt'));
      });

      test('should set error state when repository fails', () async {
        // Arrange
        mockRepository.setShouldFail(true);
        final controller = container.read(wardrobeControllerProvider.notifier);
        final item = ClothingItem(
          id: '1',
          userId: 'user1',
          name: 'Test Shirt',
          category: 'tops',
          color: 'Blue',
          imageUrl: 'test.jpg',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        await controller.updateClothingItem(item);

        // Assert
        final state = container.read(wardrobeControllerProvider);
        expect(state.hasError, isTrue);
      });
    });

    group('deleteClothingItem', () {
      test('should delete item successfully', () async {
        // Arrange
        final testItem = ClothingItem(
          id: '1',
          userId: 'user1',
          name: 'Test Shirt',
          category: 'tops',
          color: 'Blue',
          imageUrl: 'test.jpg',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        mockRepository.addMockItem(testItem);

        // Load initial state
        await container.read(wardrobeControllerProvider.future);

        final controller = container.read(wardrobeControllerProvider.notifier);

        // Act
        await controller.deleteClothingItem('1');

        // Assert
        final state = await container.read(wardrobeControllerProvider.future);
        expect(state, isEmpty);
      });

      test('should set error state when repository fails', () async {
        // Arrange
        mockRepository.setShouldFail(true);
        final controller = container.read(wardrobeControllerProvider.notifier);

        // Act
        await controller.deleteClothingItem('1');

        // Assert
        final state = container.read(wardrobeControllerProvider);
        expect(state.hasError, isTrue);
      });
    });

    group('toggleFavorite', () {
      test('should toggle favorite status successfully', () async {
        // Arrange
        final testItem = ClothingItem(
          id: '1',
          userId: 'user1',
          name: 'Test Shirt',
          category: 'tops',
          color: 'Blue',
          imageUrl: 'test.jpg',
          isFavorite: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        mockRepository.addMockItem(testItem);

        // Load initial state
        await container.read(wardrobeControllerProvider.future);

        final controller = container.read(wardrobeControllerProvider.notifier);

        // Act
        await controller.toggleFavorite('1');

        // Assert
        final state = await container.read(wardrobeControllerProvider.future);
        expect(state.first.isFavorite, isTrue);
      });

      test('should return early when state is null', () async {
        // Arrange
        final controller = container.read(wardrobeControllerProvider.notifier);

        // Act & Assert - should not throw
        await controller.toggleFavorite('1');
      });
    });

    group('searchItems', () {
      test('should search items by name successfully', () async {
        // Arrange
        final items = [
          ClothingItem(
            id: '1',
            userId: 'user1',
            name: 'Blue Shirt',
            category: 'tops',
            color: 'Blue',
            imageUrl: 'blue.jpg',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          ClothingItem(
            id: '2',
            userId: 'user1',
            name: 'Red Pants',
            category: 'bottoms',
            color: 'Red',
            imageUrl: 'red.jpg',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        items.forEach(mockRepository.addMockItem);

        // Load initial state
        await container.read(wardrobeControllerProvider.future);
        final controller = container.read(wardrobeControllerProvider.notifier);

        // Act
        final result = await controller.searchItems('Blue');

        // Assert
        expect(result, hasLength(1));
        expect(result.first.name, equals('Blue Shirt'));
      });

      test('should return all items when query is empty', () async {
        // Arrange
        final items = [
          ClothingItem(
            id: '1',
            userId: 'user1',
            name: 'Shirt',
            category: 'tops',
            color: 'Blue',
            imageUrl: 'shirt.jpg',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          ClothingItem(
            id: '2',
            userId: 'user1',
            name: 'Pants',
            category: 'bottoms',
            color: 'Black',
            imageUrl: 'pants.jpg',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        items.forEach(mockRepository.addMockItem);

        // Load initial state
        await container.read(wardrobeControllerProvider.future);
        final controller = container.read(wardrobeControllerProvider.notifier);

        // Act
        final result = await controller.searchItems('');

        // Assert
        expect(result, hasLength(2));
      });

      test('should return empty list when state is null', () async {
        // Arrange
        final controller = container.read(wardrobeControllerProvider.notifier);

        // Act
        final result = await controller.searchItems('test');

        // Assert
        expect(result, isEmpty);
      });
    });
  });
}
