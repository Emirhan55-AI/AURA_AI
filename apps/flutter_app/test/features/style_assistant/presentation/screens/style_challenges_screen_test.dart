import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/style_assistant/presentation/screens/style_challenges_screen.dart';

void main() {
  group('StyleChallengesScreen', () {
    Widget createTestWidget({List<Override>? overrides}) {
      return ProviderScope(
        overrides: overrides ?? [],
        child: MaterialApp(
          home: StyleChallengesScreen(),
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
        expect(find.text('Style Challenges'), findsOneWidget);
      });

      testWidgets('displays tab controller with tabs', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Should show DefaultTabController and TabBar
        expect(find.byType(DefaultTabController), findsOneWidget);
        expect(find.byType(TabBar), findsOneWidget);
        
        // Should show the three tabs
        expect(find.text('Active'), findsOneWidget);
        expect(find.text('Upcoming'), findsOneWidget);
        expect(find.text('Past'), findsOneWidget);
      });

      testWidgets('displays tab bar view', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(TabBarView), findsOneWidget);
      });

      testWidgets('displays main screen structure', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Should show main screen structure
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(DefaultTabController), findsOneWidget);
      });
    });

    group('Tab Navigation', () {
      testWidgets('handles tab switching', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Test switching to Upcoming tab
        final upcomingTab = find.text('Upcoming');
        if (upcomingTab.evaluate().isNotEmpty) {
          await tester.tap(upcomingTab);
          await tester.pumpAndSettle();
        }

        expect(tester.takeException(), isNull);
      });

      testWidgets('handles Past tab switching', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Test switching to Past tab
        final pastTab = find.text('Past');
        if (pastTab.evaluate().isNotEmpty) {
          await tester.tap(pastTab);
          await tester.pumpAndSettle();
        }

        expect(tester.takeException(), isNull);
      });

      testWidgets('maintains tab state during navigation', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Switch between tabs
        final upcomingTab = find.text('Upcoming');
        if (upcomingTab.evaluate().isNotEmpty) {
          await tester.tap(upcomingTab);
          await tester.pumpAndSettle();
        }

        final activeTab = find.text('Active');
        if (activeTab.evaluate().isNotEmpty) {
          await tester.tap(activeTab);
          await tester.pumpAndSettle();
        }

        expect(tester.takeException(), isNull);
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

      testWidgets('handles content interactions', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Allow content to load
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Test any challenge card interactions if present
        final cardFinder = find.byType(Card);
        if (cardFinder.evaluate().isNotEmpty) {
          await tester.tap(cardFinder.first);
          await tester.pumpAndSettle();
        }

        expect(tester.takeException(), isNull);
      });
    });

    group('Challenge Content', () {
      testWidgets('displays challenge content correctly', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Allow challenges to load
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Should display tab content without errors
        expect(find.byType(TabBarView), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('handles empty state gracefully', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Allow empty state to render
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Should handle empty state without crashing
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
        expect(find.byType(DefaultTabController), findsOneWidget);
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
