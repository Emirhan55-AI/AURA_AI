import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/wardrobe/presentation/screens/clothing_item_edit_screen.dart';
import 'package:flutter_app/features/wardrobe/domain/entities/clothing_item.dart';
import 'package:flutter_app/core/ui/system_state_widget.dart';

void main() {
  group('ClothingItemEditScreen', () {
    late ClothingItem testItem;

    setUp(() {
      testItem = ClothingItem(
        id: 'test-item-123',
        userId: 'test-user-123',
        name: 'Test Item',
        category: 'tops',
        brand: 'Test Brand',
        color: 'Blue',
        size: 'M',
        imageUrl: 'https://example.com/image.jpg',
        tags: ['casual', 'cotton'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    Widget createTestWidget({
      ClothingItem? item,
      List<Override>? overrides,
    }) {
      return ProviderScope(
        overrides: overrides ?? [],
        child: MaterialApp(
          home: ClothingItemEditScreen(item: item ?? testItem),
        ),
      );
    }

    testWidgets('renders without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      expect(tester.takeException(), isNull);
    });

    group('Error Handling', () {
      testWidgets('displays error state for invalid item', (WidgetTester tester) async {
        final invalidItem = ClothingItem(
          id: '', // Empty ID should trigger error state
          userId: 'test-user-123',
          name: 'Test Item',
          category: 'tops',
          brand: 'Test Brand',
          color: 'Blue',
          size: 'M',
          imageUrl: 'https://example.com/image.jpg',
          tags: ['casual', 'cotton'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await tester.pumpWidget(createTestWidget(item: invalidItem));
        await tester.pump();

        // Should show error state with SystemStateWidget
        expect(find.byType(SystemStateWidget), findsOneWidget);
        expect(find.text('Item Not Found'), findsOneWidget);
        expect(find.text('The item you\'re trying to edit could not be found.'), findsOneWidget);
        expect(find.text('Go Back'), findsOneWidget);
      });

      testWidgets('handles go back action in error state', (WidgetTester tester) async {
        final invalidItem = ClothingItem(
          id: '',
          userId: 'test-user-123',
          name: 'Test Item',
          category: 'tops',
          brand: 'Test Brand',
          color: 'Blue',
          size: 'M',
          imageUrl: 'https://example.com/image.jpg',
          tags: ['casual', 'cotton'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await tester.pumpWidget(createTestWidget(item: invalidItem));
        await tester.pump();

        // Find and tap go back button
        final goBackButton = find.text('Go Back');
        expect(goBackButton, findsOneWidget);
        
        await tester.tap(goBackButton);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    });

    group('UI Elements', () {
      testWidgets('displays app bar with correct title', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('Edit Item'), findsOneWidget);
      });

      testWidgets('displays main edit form components', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Should show main form components
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(CustomScrollView), findsOneWidget);
      });
    });

    group('Interactions', () {
      testWidgets('handles back navigation', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Test back button functionality
        final backButtonFinder = find.byType(BackButton);
        if (backButtonFinder.evaluate().isNotEmpty) {
          await tester.tap(backButtonFinder);
          await tester.pumpAndSettle();
        }

        expect(tester.takeException(), isNull);
      });

      testWidgets('handles form interactions without errors', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Test scrolling interactions
        final scrollViewFinder = find.byType(CustomScrollView);
        if (scrollViewFinder.evaluate().isNotEmpty) {
          await tester.drag(scrollViewFinder, const Offset(0, -100));
          await tester.pumpAndSettle();
        }

        expect(tester.takeException(), isNull);
      });
    });

    group('Basic Functionality', () {
      testWidgets('builds without throwing exceptions', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Test multiple pump cycles
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 16));
        await tester.pump(const Duration(milliseconds: 32));
        
        expect(tester.takeException(), isNull);
      });

      testWidgets('maintains widget tree integrity', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Verify basic widget tree structure
        expect(find.byType(MaterialApp), findsOneWidget);
        expect(find.byType(ProviderScope), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);
      });
    });
  });
}
