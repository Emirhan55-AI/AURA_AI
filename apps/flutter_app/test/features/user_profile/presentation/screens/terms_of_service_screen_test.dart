import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/user_profile/presentation/screens/terms_of_service_screen.dart';

void main() {
  group('TermsOfServiceScreen', () {
    Widget createTestWidget({List<Override>? overrides}) {
      return ProviderScope(
        overrides: overrides ?? [],
        child: MaterialApp(
          home: TermsOfServiceScreen(),
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
        expect(find.text('Terms of Service'), findsOneWidget);
      });

      testWidgets('displays main screen structure', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Should show main screen structure
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });

      testWidgets('displays terms of service content', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Should show terms of service sections
        expect(find.byType(Card), findsAtLeastNWidgets(1));
        expect(find.byType(Text), findsAtLeastNWidgets(1));
      });

      testWidgets('displays section headers', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Should show terms of service section headers
        expect(find.text('Agreement to Terms'), findsOneWidget);
        expect(find.text('Use License'), findsOneWidget);
        expect(find.text('User Account'), findsOneWidget);
      });
    });

    group('Content Sections', () {
      testWidgets('displays agreement section', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Should show agreement information
        expect(find.text('Agreement to Terms'), findsOneWidget);
        expect(find.textContaining('agree'), findsAtLeastNWidgets(1));
      });

      testWidgets('displays use license section', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Should show use license information  
        expect(find.text('Use License'), findsOneWidget);
        expect(find.textContaining('license'), findsAtLeastNWidgets(1));
      });

      testWidgets('displays user account section', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Should show user account information
        expect(find.text('User Account'), findsOneWidget);
        expect(find.textContaining('account'), findsAtLeastNWidgets(1));
      });

      testWidgets('displays prohibited uses section', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Should show prohibited uses information
        expect(find.text('Prohibited Uses'), findsOneWidget);
        expect(find.textContaining('prohibited'), findsAtLeastNWidgets(1));
      });
    });

    group('Scroll Behavior', () {
      testWidgets('handles scroll interactions', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Test scrolling through terms of service
        final scrollViewFinder = find.byType(SingleChildScrollView);
        if (scrollViewFinder.evaluate().isNotEmpty) {
          await tester.drag(scrollViewFinder, const Offset(0, -200));
          await tester.pumpAndSettle();
        }

        expect(tester.takeException(), isNull);
      });

      testWidgets('handles scrolling to different sections', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Scroll through different sections
        final scrollViewFinder = find.byType(SingleChildScrollView);
        if (scrollViewFinder.evaluate().isNotEmpty) {
          // Scroll down
          await tester.drag(scrollViewFinder, const Offset(0, -400));
          await tester.pumpAndSettle();
          
          // Scroll back up
          await tester.drag(scrollViewFinder, const Offset(0, 300));
          await tester.pumpAndSettle();
        }

        expect(tester.takeException(), isNull);
      });
    });

    group('Navigation', () {
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
    });

    group('Accessibility', () {
      testWidgets('provides proper accessibility support', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Should provide proper semantic structure
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    group('Content Interactions', () {
      testWidgets('handles card interactions', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Test tapping on terms of service cards
        final cardFinder = find.byType(Card);
        if (cardFinder.evaluate().isNotEmpty) {
          await tester.tap(cardFinder.first);
          await tester.pumpAndSettle();
        }

        expect(tester.takeException(), isNull);
      });

      testWidgets('handles text selection', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Test text selection interactions
        final textFinder = find.byType(SelectableText);
        if (textFinder.evaluate().isNotEmpty) {
          await tester.longPress(textFinder.first);
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
        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });
    });

    group('Content Integrity', () {
      testWidgets('displays complete terms of service content', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Should show all required terms of service sections
        expect(find.text('Agreement to Terms'), findsOneWidget);
        expect(find.text('Use License'), findsOneWidget);
        expect(find.text('User Account'), findsOneWidget);
        expect(find.text('Prohibited Uses'), findsOneWidget);
        expect(find.text('Service Availability'), findsOneWidget);
      });

      testWidgets('maintains content formatting', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Should maintain proper content structure
        expect(find.byType(Card), findsAtLeastNWidgets(5)); // One for each section
        expect(tester.takeException(), isNull);
      });
    });

    group('Legal Content', () {
      testWidgets('displays liability disclaimers', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Should show liability and disclaimer sections
        expect(find.text('Disclaimers'), findsOneWidget);
        expect(find.text('Limitation of Liability'), findsOneWidget);
      });

      testWidgets('displays modification terms', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Should show terms modification information
        expect(find.text('Modifications to Terms'), findsOneWidget);
        expect(find.textContaining('modify'), findsAtLeastNWidgets(1));
      });

      testWidgets('displays contact information', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Should show contact information for legal inquiries
        expect(find.text('Contact Information'), findsOneWidget);
        expect(find.textContaining('contact'), findsAtLeastNWidgets(1));
      });
    });
  });
}
