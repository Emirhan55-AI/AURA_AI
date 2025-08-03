// Example navigation to Social Post Detail Screen
// This demonstrates how to navigate to the screen from other parts of the app

import 'package:flutter/material.dart';
import '../screens/social_post_detail_screen.dart';

/// Example usage of SocialPostDetailScreen navigation
class SocialPostDetailNavigation {
  /// Navigate to post detail from a social feed
  static void navigateToPostDetail(BuildContext context, String postId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SocialPostDetailScreen(postId: postId),
      ),
    );
  }

  /// Navigate to post detail with slide animation
  static void navigateToPostDetailWithAnimation(BuildContext context, String postId) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) => 
          SocialPostDetailScreen(postId: postId),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          final tween = Tween(begin: begin, end: end);
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: curve,
          );

          return SlideTransition(
            position: tween.animate(curvedAnimation),
            child: child,
          );
        },
      ),
    );
  }
}
