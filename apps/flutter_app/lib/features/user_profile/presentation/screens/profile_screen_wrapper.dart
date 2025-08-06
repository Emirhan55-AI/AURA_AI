import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'user_profile_screen.dart';

/// Wrapper component for UserProfileScreen that handles routing and initialization
class ProfileScreenWrapper extends ConsumerWidget {
  final bool useHeroAnimation;
  
  const ProfileScreenWrapper({
    super.key, 
    this.useHeroAnimation = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Builder(
      builder: (context) {
        // Only use Hero animation when explicitly requested
        if (!useHeroAnimation) {
          return const UserProfileScreen();
        }

        // Use Hero animation with a unique tag
        return Hero(
          tag: 'profile-hero',
          child: const UserProfileScreen(),
        );
      },
    );
  }
}
