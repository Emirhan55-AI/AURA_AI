import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';

import 'package:flutter_app/features/wardrobe/presentation/controllers/wardrobe_controller.dart';
import 'package:flutter_app/features/wardrobe/domain/repositories/wardrobe_repository.dart';
import 'package:flutter_app/features/wardrobe/domain/entities/clothing_item.dart';
import 'package:flutter_app/features/wardrobe/domain/entities/category.dart';
import 'package:flutter_app/core/error/failure.dart';

// Manual mock implementation for testing
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
    final newItem = item.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString());
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
      _items[index] = item;
      return Right(item);
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

  @override
  Future<Either<Failure, ClothingItem>> toggleFavorite(String itemId) async {
    if (shouldFail) {
      return const Left(ValidationFailure());
    }
    final index = _items.indexWhere((element) => element.id == itemId);
    if (index != -1) {
      final item = _items[index];
      final updatedItem = item.copyWith(isFavorite: !item.isFavorite);
      _items[index] = updatedItem;
      return Right(updatedItem);
    }
    return const Left(ValidationFailure(message: 'Item not found'));
  }

  @override
  Future<Either<Failure, List<ClothingItem>>> searchItems(String query) async {
    if (shouldFail) {
      return const Left(NetworkFailure());
    }
    final filteredItems = _items.where((item) =>
        item.name.toLowerCase().contains(query.toLowerCase()) ||
        item.brand?.toLowerCase().contains(query.toLowerCase()) == true ||
        item.description?.toLowerCase().contains(query.toLowerCase()) == true
    ).toList();
    return Right(filteredItems);
  }

  @override
  Future<Either<Failure, List<ClothingItem>>> getItemsByCategory(Category category) async {
    if (shouldFail) {
      return const Left(NetworkFailure());
    }
    final filteredItems = _items.where((item) => item.category == category).toList();
    return Right(filteredItems);
  }
}

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
          name: 'Test Shirt',
          category: Category.tops,
          color: 'Blue',
          imageUrl: 'test.jpg',
        );
        mockRepository.addMockItem(testItem);

        // Act
        final result = await container.read(wardrobeControllerProvider.future);

        // Assert
        expect(result, hasLength(1));
        expect(result.first.name, equals('Test Shirt'));
      });
    });

    group('addItem', () {
      test('should add item successfully', () async {
        // Arrange
        final controller = container.read(wardrobeControllerProvider.notifier);
        final newItem = ClothingItem(
          id: '',
          name: 'New Shirt',
          category: Category.tops,
          color: 'Red',
          imageUrl: 'new.jpg',
        );

        // Act
        final result = await controller.addItem(newItem);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success, got failure'),
          (item) => expect(item.name, equals('New Shirt')),
        );

        // Verify state is updated
        final state = await container.read(wardrobeControllerProvider.future);
        expect(state, hasLength(1));
        expect(state.first.name, equals('New Shirt'));
      });

      test('should return failure when repository fails', () async {
        // Arrange
        mockRepository.setShouldFail(true);
        final controller = container.read(wardrobeControllerProvider.notifier);
        final newItem = ClothingItem(
          id: '',
          name: 'New Shirt',
          category: Category.tops,
          color: 'Red',
          imageUrl: 'new.jpg',
        );

        // Act
        final result = await controller.addItem(newItem);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (item) => fail('Expected failure, got success'),
        );
      });
    });

    group('updateItem', () {
      test('should update item successfully', () async {
        // Arrange
        final originalItem = ClothingItem(
          id: '1',
          name: 'Original Shirt',
          category: Category.tops,
          color: 'Blue',
          imageUrl: 'original.jpg',
        );
        mockRepository.addMockItem(originalItem);

        final controller = container.read(wardrobeControllerProvider.notifier);
        final updatedItem = originalItem.copyWith(name: 'Updated Shirt');

        // Act
        final result = await controller.updateItem(updatedItem);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success, got failure'),
          (item) => expect(item.name, equals('Updated Shirt')),
        );

        // Verify state is updated
        final state = await container.read(wardrobeControllerProvider.future);
        expect(state.first.name, equals('Updated Shirt'));
      });

      test('should return failure when item not found', () async {
        // Arrange
        final controller = container.read(wardrobeControllerProvider.notifier);
        final nonExistentItem = ClothingItem(
          id: 'non-existent',
          name: 'Non-existent',
          category: Category.tops,
          color: 'Blue',
          imageUrl: 'test.jpg',
        );

        // Act
        final result = await controller.updateItem(nonExistentItem);

        // Assert
        expect(result.isLeft(), isTrue);
      });
    });

    group('deleteItem', () {
      test('should delete item successfully', () async {
        // Arrange
        final testItem = ClothingItem(
          id: '1',
          name: 'Test Shirt',
          category: Category.tops,
          color: 'Blue',
          imageUrl: 'test.jpg',
        );
        mockRepository.addMockItem(testItem);

        final controller = container.read(wardrobeControllerProvider.notifier);

        // Act
        final result = await controller.deleteItem('1');

        // Assert
        expect(result.isRight(), isTrue);

        // Verify state is updated
        final state = await container.read(wardrobeControllerProvider.future);
        expect(state, isEmpty);
      });

      test('should return failure when repository fails', () async {
        // Arrange
        mockRepository.setShouldFail(true);
        final controller = container.read(wardrobeControllerProvider.notifier);

        // Act
        final result = await controller.deleteItem('1');

        // Assert
        expect(result.isLeft(), isTrue);
      });
    });

    group('toggleFavorite', () {
      test('should toggle favorite status successfully', () async {
        // Arrange
        final testItem = ClothingItem(
          id: '1',
          name: 'Test Shirt',
          category: Category.tops,
          color: 'Blue',
          imageUrl: 'test.jpg',
          isFavorite: false,
        );
        mockRepository.addMockItem(testItem);

        final controller = container.read(wardrobeControllerProvider.notifier);

        // Act
        final result = await controller.toggleFavorite('1');

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success, got failure'),
          (item) => expect(item.isFavorite, isTrue),
        );

        // Verify state is updated
        final state = await container.read(wardrobeControllerProvider.future);
        expect(state.first.isFavorite, isTrue);
      });
    });

    group('searchItems', () {
      test('should search items successfully', () async {
        // Arrange
        final items = [
          ClothingItem(
            id: '1',
            name: 'Blue Shirt',
            category: Category.tops,
            color: 'Blue',
            imageUrl: 'blue.jpg',
          ),
          ClothingItem(
            id: '2',
            name: 'Red Pants',
            category: Category.bottoms,
            color: 'Red',
            imageUrl: 'red.jpg',
          ),
        ];
        items.forEach(mockRepository.addMockItem);

        final controller = container.read(wardrobeControllerProvider.notifier);

        // Act
        final result = await controller.searchItems('Blue');

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success, got failure'),
          (items) {
            expect(items, hasLength(1));
            expect(items.first.name, equals('Blue Shirt'));
          },
        );
      });
    });

    group('filterByCategory', () {
      test('should filter items by category successfully', () async {
        // Arrange
        final items = [
          ClothingItem(
            id: '1',
            name: 'Shirt',
            category: Category.tops,
            color: 'Blue',
            imageUrl: 'shirt.jpg',
          ),
          ClothingItem(
            id: '2',
            name: 'Pants',
            category: Category.bottoms,
            color: 'Black',
            imageUrl: 'pants.jpg',
          ),
        ];
        items.forEach(mockRepository.addMockItem);

        final controller = container.read(wardrobeControllerProvider.notifier);

        // Act
        final result = await controller.filterByCategory(Category.tops);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success, got failure'),
          (items) {
            expect(items, hasLength(1));
            expect(items.first.category, equals(Category.tops));
          },
        );
      });
    });

    group('getStatistics', () {
      test('should calculate statistics correctly', () async {
        // Arrange
        final items = [
          ClothingItem(
            id: '1',
            name: 'Shirt',
            category: Category.tops,
            color: 'Blue',
            imageUrl: 'shirt.jpg',
            isFavorite: true,
          ),
          ClothingItem(
            id: '2',
            name: 'Pants',
            category: Category.bottoms,
            color: 'Black',
            imageUrl: 'pants.jpg',
            isFavorite: false,
          ),
          ClothingItem(
            id: '3',
            name: 'Jacket',
            category: Category.outerwear,
            color: 'Gray',
            imageUrl: 'jacket.jpg',
            isFavorite: true,
          ),
        ];
        items.forEach(mockRepository.addMockItem);

        // Trigger initial load
        await container.read(wardrobeControllerProvider.future);
        
        final controller = container.read(wardrobeControllerProvider.notifier);

        // Act
        final stats = controller.getStatistics();

        // Assert
        expect(stats.totalItems, equals(3));
        expect(stats.favoriteItems, equals(2));
        expect(stats.categoryCounts[Category.tops], equals(1));
        expect(stats.categoryCounts[Category.bottoms], equals(1));
        expect(stats.categoryCounts[Category.outerwear], equals(1));
      });
    });
  });
}
