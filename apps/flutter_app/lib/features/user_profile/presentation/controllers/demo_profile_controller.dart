import 'package:flutter/material.dart';

/// Mock profile data for demo
class DemoProfileController extends ChangeNotifier {
  final String displayName = 'Alex Mitchell';
  final String username = '@alexmitchell';
  final String bio = 'Fashion enthusiast | Sustainable style advocate 🌿';
  final String avatarUrl = 'https://i.imgur.com/q66goF6.jpeg';

  final Map<String, int> stats = {
    'combinations': 47,
    'favorites': 89,
    'followers': 1204,
    'following': 456,
  };

  final List<Map<String, dynamic>> achievements = [
    {
      'name': 'Style Pioneer',
      'icon': '🌟',
      'progress': 1.0,
    },
    {
      'name': 'Eco Warrior',
      'icon': '🌿',
      'progress': 0.85,
    },
    {
      'name': 'Trendsetter',
      'icon': '👑',
      'progress': 1.0,
    },
  ];
}
