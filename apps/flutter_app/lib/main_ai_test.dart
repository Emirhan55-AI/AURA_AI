import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/ai_integration/test/ai_integration_test_screen.dart';

void main() {
  runApp(const ProviderScope(child: AuraAiTestApp()));
}

class AuraAiTestApp extends StatelessWidget {
  const AuraAiTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aura AI Test',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        useMaterial3: true,
      ),
      home: const AiIntegrationTestScreen(),
    );
  }
}
