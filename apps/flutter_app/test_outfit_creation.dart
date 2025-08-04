import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'lib/features/wardrobe/presentation/screens/outfit_creation_screen.dart';

// Simple test to verify OutfitCreationScreen works correctly
// Run with: flutter run -d chrome -t test_outfit_creation.dart --web-port=8081
void main() {
  runApp(const ProviderScope(child: TestApp()));
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Outfit Creation Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF6F61)),
        useMaterial3: true,
      ),
      home: const OutfitCreationScreen(),
    );
  }
}
