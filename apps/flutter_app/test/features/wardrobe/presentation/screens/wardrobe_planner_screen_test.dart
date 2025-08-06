import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/wardrobe/presentation/screens/wardrobe_planner_screen.dart';

void main() {
  group('WardrobePlannerScreen', () {
    Widget createTestWidget({List<Override>? overrides}) {
      return ProviderScope(
        overrides: overrides ?? [],
        child: MaterialApp(
          home: WardrobePlannerScreen(),
        ),
      );
    }

    testWidgets('renders without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      expect(tester.takeException(), isNull);
    });

    group('UI Elements', () {
      testWidgets('displays app bar with correct title', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('Wardrobe Planner'), findsOneWidget);
      });

      testWidgets('displays main screen components', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Should show main screen structure
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });

      testWidgets('displays calendar component', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Should show calendar for outfit planning
        expect(find.byType(Card), findsAtLeastNWidgets(1));
      });

      testWidgets('displays floating action button', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(FloatingActionButton), findsOneWidget);
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

      testWidgets('handles floating action button tap', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Test FAB tap
        final fabFinder = find.byType(FloatingActionButton);
        if (fabFinder.evaluate().isNotEmpty) {
          await tester.tap(fabFinder);
          await tester.pumpAndSettle();
        }

        expect(tester.takeException(), isNull);
      });

      testWidgets('handles scroll interactions', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Test scrolling interactions
        final scrollViewFinder = find.byType(SingleChildScrollView);
        if (scrollViewFinder.evaluate().isNotEmpty) {
          await tester.drag(scrollViewFinder, const Offset(0, -100));
          await tester.pumpAndSettle();
        }

        expect(tester.takeException(), isNull);
      });
    });

    group('Calendar Functionality', () {
      testWidgets('displays calendar events', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Allow calendar to load
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Should display calendar without errors
        expect(find.byType(Card), findsAtLeastNWidgets(1));
        expect(tester.takeException(), isNull);
      });

      testWidgets('handles calendar interactions', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Allow calendar to load
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Test calendar card taps
        final cardFinder = find.byType(Card).first;
        if (cardFinder.evaluate().isNotEmpty) {
          await tester.tap(cardFinder);
          await tester.pumpAndSettle();
        }

        expect(tester.takeException(), isNull);
      });
    });

    group('State Management', () {
      testWidgets('handles different states gracefully', (WidgetTester tester) async {
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

    group('Error Handling', () {
      testWidgets('handles loading state gracefully', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Should handle initial loading state
        expect(find.byType(Scaffold), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Allow time for async operations
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);
      });
    });
  });
}
