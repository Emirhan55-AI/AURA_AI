import 'package:flutter/material.dart';

/// Mock user data for demonstration purposes
class MockUserData {
  static const displayName = 'Alex Mitchell';
  static const username = '@alexmitchell';
  static const bio = 'Fashion enthusiast | Sustainable style advocate 🌿\nExploring the future of fashion through AI';
  static const avatarUrl = 'https://picsum.photos/200/200?random=1';
  static const location = 'New York, USA';
  
  // Profile stats
  static const auraScore = 2847;
  static const auraLevel = 12;
  static const auraProgress = 0.75;
  
  // Social stats
  static const wardrobeItemCount = 156;
  static const combinationsCount = 47;
  static const favoritesCount = 89;
  static const followersCount = 1204;
  static const followingCount = 456;
  
  // Style preferences
  static const List<String> stylePreferences = [
    'Minimalist',
    'Casual Chic',
    'Sustainable',
    'Modern Classic'
  ];
  
  // Favorite colors
  static const List<Color> favoriteColors = [
    Color(0xFF2C3E50), // Navy
    Color(0xFFECF0F1), // White
    Color(0xFF7F8C8D), // Gray
    Color(0xFFE74C3C), // Red
  ];
  
  // Achievements
  static const achievements = [
    {
      'name': 'Style Pioneer',
      'description': 'Early adopter of AI styling',
      'icon': '🌟',
      'progress': 1.0,
    },
    {
      'name': 'Eco Warrior',
      'description': '100 sustainable items added',
      'icon': '🌿',
      'progress': 0.85,
    },
    {
      'name': 'Trendsetter',
      'description': '1000+ followers gained',
      'icon': '👑',
      'progress': 1.0,
    },
  ];
}
