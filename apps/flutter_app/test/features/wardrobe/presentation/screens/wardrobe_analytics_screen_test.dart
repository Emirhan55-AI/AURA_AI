import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/wardrobe/presentation/screens/wardrobe_analytics_screen.dart';

void main() {
  group('WardrobeAnalyticsScreen UI Tests', () {
    testWidgets('should display loading state initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: WardrobeAnalyticsScreen(),
          ),
        ),
      );

      // Should show loading state initially
      expect(find.text('Analyzing your wardrobe...'), findsOneWidget);
      expect(find.byIcon(Icons.analytics_outlined), findsOneWidget);
      
      // Wait for timer to complete to avoid test issues
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets('should display tab bar and content after loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: WardrobeAnalyticsScreen(),
          ),
        ),
      );

      // Wait for loading to complete
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Should show app bar
      expect(find.text('Wardrobe Analytics'), findsOneWidget);
      
      // Should show tab bar
      expect(find.text('Statistics'), findsOneWidget);
      expect(find.text('Insights'), findsOneWidget);
      expect(find.text('Shopping Guide'), findsOneWidget);

      // Should show statistics tab content by default
      expect(find.text('Time Range'), findsOneWidget);
      expect(find.text('Total Items'), findsOneWidget);
    });

    testWidgets('should navigate between tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: WardrobeAnalyticsScreen(),
          ),
        ),
      );

      // Wait for loading to complete
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Tap on Insights tab
      await tester.tap(find.text('Insights'));
      await tester.pumpAndSettle();

      // Should show insights content
      expect(find.text('Insights Summary'), findsOneWidget);

      // Tap on Shopping Guide tab
      await tester.tap(find.text('Shopping Guide'));
      await tester.pumpAndSettle();

      // Should show shopping guide content - look for any shopping guide text
      expect(find.textContaining('Shopping'), findsAtLeastNWidgets(1));
    });

    testWidgets('should show refresh button in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: WardrobeAnalyticsScreen(),
          ),
        ),
      );

      // Wait for loading to complete
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Should show refresh button
      expect(find.byIcon(Icons.refresh_outlined), findsOneWidget);
    });
  });
}
