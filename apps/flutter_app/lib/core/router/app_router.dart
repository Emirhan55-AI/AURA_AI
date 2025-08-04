import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Import screens
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/onboarding/onboarding_screen.dart';
import '../../features/home/presentation/pages/main_screen.dart';
import '../../features/home/presentation/pages/splash_screen.dart';
import '../../features/home/presentation/screens/app_tab_controller.dart';
import '../../features/authentication/presentation/controllers/auth_controller.dart';
import '../../features/wardrobe/presentation/screens/add_clothing_item_screen.dart';
import '../../features/wardrobe/presentation/screens/outfit_creation_screen.dart';
import '../../features/style_assistant/presentation/screens/style_challenges_screen.dart';
import '../../features/style_assistant/presentation/screens/challenge_detail_screen.dart';
import '../../features/style_assistant/presentation/widgets/challenges/challenge_card.dart';

/// Router provider for the Aura application with authentication-aware routing
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/main', // Directly start at main screen
    // TEMPORARY: Remove redirect for testing
    // redirect: (BuildContext context, GoRouterState state) {
    //   return _handleRedirect(ref, context, state);
    // },
    routes: _buildRoutes(),
    errorBuilder: _buildErrorScreen,
  );
});

/// Handle redirect logic based on authentication and onboarding state
String? _handleRedirect(Ref ref, BuildContext context, GoRouterState state) {
  final currentPath = state.fullPath ?? '/';
  
  // Allow splash screen to always load first
  if (currentPath == '/splash') {
    return null;
  }
  
  // TEMPORARY: Skip authentication for testing - redirect to main
  if (currentPath.startsWith('/auth/') || currentPath == '/') {
    return '/main';
  }
  
  return null;
}

/// Build route configuration
List<RouteBase> _buildRoutes() {
  return [
    // Splash Screen Route
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      },
    ),
    
    // Authentication Routes
    GoRoute(
      path: '/auth',
      redirect: (context, state) {
        // Redirect /auth to /auth/login
        if (state.fullPath == '/auth') {
          return '/auth/login';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (BuildContext context, GoRouterState state) {
            return const LoginScreen();
          },
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (BuildContext context, GoRouterState state) {
            return const RegisterScreenPlaceholder();
          },
        ),
        GoRoute(
          path: '/forgot-password',
          name: 'forgotPassword',
          builder: (BuildContext context, GoRouterState state) {
            return const ForgotPasswordScreenPlaceholder();
          },
        ),
      ],
    ),
    
    // Onboarding Route
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (BuildContext context, GoRouterState state) {
        return const OnboardingScreen();
      },
    ),
    
    // Main App Route (bypass authentication)
    GoRoute(
      path: '/main',
      name: 'main',
      builder: (BuildContext context, GoRouterState state) {
        return const AppTabController(); // Directly show the app tabs
      },
      routes: [
        // Profile sub-route
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (BuildContext context, GoRouterState state) {
            return const ProfileScreenPlaceholder();
          },
        ),
        // Settings sub-route
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (BuildContext context, GoRouterState state) {
            return const SettingsScreenPlaceholder();
          },
        ),
      ],
    ),
    
    // Wardrobe Routes (outside main to be accessible independently)
    GoRoute(
      path: '/wardrobe',
      redirect: (context, state) {
        // Redirect /wardrobe to main wardrobe tab
        if (state.fullPath == '/wardrobe') {
          return '/main';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/add',
          name: 'addClothingItem',
          builder: (BuildContext context, GoRouterState state) {
            return const AddClothingItemScreen();
          },
        ),
        GoRoute(
          path: '/create-outfit',
          name: 'createOutfit',
          builder: (BuildContext context, GoRouterState state) {
            return const OutfitCreationScreen();
          },
        ),
        GoRoute(
          path: '/item/:itemId',
          name: 'clothingItemDetail',
          builder: (BuildContext context, GoRouterState state) {
            final itemId = state.pathParameters['itemId']!;
            return ClothingItemDetailScreenPlaceholder(itemId: itemId);
          },
        ),
      ],
    ),
    
    // Style Assistant Routes
    GoRoute(
      path: '/style-challenges',
      name: 'styleChallenges',
      builder: (BuildContext context, GoRouterState state) {
        return const StyleChallengesScreen();
      },
      routes: [
        GoRoute(
          path: ':id',
          name: 'challengeDetail',
          builder: (BuildContext context, GoRouterState state) {
            final challenge = state.extra as StyleChallenge;
            return ChallengeDetailScreen(challenge: challenge);
          },
        ),
      ],
    ),
    
    // Legacy routes for backward compatibility
    GoRoute(
      path: '/home',
      redirect: (context, state) => '/main',
    ),
  ];
}

/// Build error screen for unknown routes
Widget _buildErrorScreen(BuildContext context, GoRouterState state) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Page Not Found'),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Page Not Found',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'The page "${state.uri}" could not be found.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/main'),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  );
}

// Placeholder screens for routes not yet implemented
class RegisterScreenPlaceholder extends StatelessWidget {
  const RegisterScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: const Center(
        child: Text('Register Screen - Coming Soon'),
      ),
    );
  }
}

class ForgotPasswordScreenPlaceholder extends StatelessWidget {
  const ForgotPasswordScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: const Center(
        child: Text('Forgot Password Screen - Coming Soon'),
      ),
    );
  }
}

class ProfileScreenPlaceholder extends StatelessWidget {
  const ProfileScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(
        child: Text('Profile Screen - Coming Soon'),
      ),
    );
  }
}

class SettingsScreenPlaceholder extends StatelessWidget {
  const SettingsScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(
        child: Text('Settings Screen - Coming Soon'),
      ),
    );
  }
}

class ClothingItemDetailScreenPlaceholder extends StatelessWidget {
  final String itemId;
  
  const ClothingItemDetailScreenPlaceholder({
    super.key,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Item Details')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Clothing Item Detail Screen - Coming Soon'),
            const SizedBox(height: 16),
            Text('Item ID: $itemId'),
          ],
        ),
      ),
    );
  }
}
