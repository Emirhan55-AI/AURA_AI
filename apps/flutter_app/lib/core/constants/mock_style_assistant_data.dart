import 'package:flutter/material.dart';

/// Mock data for Style Assistant demo
class MockStyleAssistantData {
  static const userName = MockUserData.displayName.split(' ')[0]; // 'Alex'
  
  static const welcomeMessage = '''
Hi $userName! 👋 I'm your personal AI Style Assistant. I can help you:
- Create stunning outfits from your wardrobe
- Get personalized style advice
- Stay on top of fashion trends
- Make sustainable fashion choices

What would you like help with today?
''';

  static const List<String> recentQueries = [
    'What should I wear to a summer wedding?',
    'Create a business casual outfit',
    'Suggest sustainable clothing brands',
    'How to style black jeans?',
  ];
  
  static const List<Map<String, String>> suggestions = [
    {
      'title': 'Create New Outfit',
      'subtitle': 'Get AI-powered outfit suggestions',
      'icon': '👔',
    },
    {
      'title': 'Style Advice',
      'subtitle': 'Ask any fashion question',
      'icon': '💭',
    },
    {
      'title': 'Trend Analysis',
      'subtitle': 'Stay ahead of fashion trends',
      'icon': '📈',
    },
    {
      'title': 'Sustainable Fashion',
      'subtitle': 'Eco-friendly style tips',
      'icon': '🌿',
    },
  ];
}
