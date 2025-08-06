import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../../authentication/presentation/screens/login_screen.dart';
import '../../../authentication/presentation/screens/onboarding/onboarding_screen.dart';
import 'app_tab_controller.dart';
import '../pages/splash_screen.dart';

/// Main Screen - Authentication routing and app entry point
/// Determines which screen to show based on authentication and onboarding state
/// Follows Clean Architecture principles and acts as the main routing controller
class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch authentication state
    final authState = ref.watch(authControllerProvider);
    
    return authState.when(
      loading: () => const SplashScreen(),
      error: (error, stackTrace) {
        // On authentication error, check onboarding status
        return FutureBuilder<bool>(
          future: ref.read(preferencesServiceProvider).getHasSeenOnboarding(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }
            
            final hasSeenOnboarding = snapshot.data ?? false;
            return hasSeenOnboarding 
                ? const LoginScreen() 
                : const OnboardingScreen();
          },
        );
      },
      data: (user) {
        if (user != null) {
          // User is authenticated - show main app
          return const AppTabController();
        } else {
          // User is not authenticated - check onboarding status
          return FutureBuilder<bool>(
            future: ref.read(preferencesServiceProvider).getHasSeenOnboarding(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
              }
              
              final hasSeenOnboarding = snapshot.data ?? false;
              return hasSeenOnboarding 
                  ? const LoginScreen() 
                  : const OnboardingScreen();
            },
          );
        }
      },
    );
  }
}
