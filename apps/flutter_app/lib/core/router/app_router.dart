import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Import screens - Authentication
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/register_screen.dart';
import '../../features/authentication/presentation/screens/forgot_password_screen.dart';
import '../../features/authentication/presentation/screens/onboarding/onboarding_screen.dart';
import '../../features/authentication/presentation/screens/onboarding/style_discovery_screen.dart';

// Import screens - Home & Main Navigation
import '../../features/home/presentation/pages/splash_screen.dart';
import '../../features/home/presentation/screens/app_tab_controller.dart';

// Import screens - Camera
import '../../features/camera/presentation/screens/camera_screen.dart';

// Import screens - Wardrobe
import '../../features/wardrobe/presentation/screens/wardrobe_home_screen.dart';
import '../../features/wardrobe/presentation/screens/add_clothing_item_screen.dart';
import '../../features/wardrobe/presentation/screens/clothing_item_detail_screen.dart';
import '../../features/wardrobe/presentation/screens/outfit_creation_screen.dart';
import '../../features/wardrobe/presentation/screens/simple_outfit_planner_screen.dart';
import '../../features/wardrobe/presentation/screens/ai_styling_suggestions_screen.dart';
import '../../features/wardrobe/presentation/screens/wardrobe_analytics_screen.dart';
import '../../features/wardrobe/presentation/screens/wardrobe_planner_screen.dart';

// Import screens - Outfits
import '../../features/outfits/presentation/screens/outfit_detail_screen.dart';

// Import screens - Style Assistant
import '../../features/style_assistant/presentation/screens/style_assistant_screen.dart';
import '../../features/style_assistant/presentation/screens/style_challenges_screen.dart';

// Import screens - Search
import '../../features/search/presentation/screens/search_screen.dart';

// Import screens - Social
// Temporarily commented out due to compilation errors
// import '../../features/social/presentation/screens/social_feed_screen.dart';
// import '../../features/social/presentation/screens/social_post_detail_screen.dart';
// import '../../features/social/presentation/screens/social_user_profile_screen.dart';
// import '../../features/social/presentation/screens/create_post_screen.dart';

// Import screens - User Profile 
import '../../features/user_profile/presentation/screens/profile_screen_wrapper.dart';
import '../../features/user_profile/presentation/screens/favorites_screen.dart';
import '../../features/user_profile/presentation/screens/settings_screen.dart';
import '../../features/user_profile/presentation/screens/privacy_policy_screen.dart';
import '../../features/user_profile/presentation/screens/terms_of_service_screen.dart';

// Import screens - Swap Market
import '../../features/swap_market/presentation/screens/swap_market_screen.dart';
import '../../features/swap_market/presentation/screens/swap_listing_detail_screen.dart';
import '../../features/swap_market/presentation/screens/create_swap_listing_screen.dart';
import '../../features/swap_market/presentation/screens/pre_swap_chat_screen.dart';

// Import screens - Privacy
import '../../features/privacy/presentation/screens/privacy_consent_screen.dart';
import '../../features/privacy/presentation/screens/privacy_data_management_screen.dart';

// Import screens - Messaging
import '../../features/messaging/presentation/screens/messaging_screen.dart';
import '../../features/messaging/presentation/screens/chat_screen.dart';

// Import screens - Notifications
import '../../features/notifications/presentation/screens/notifications_screen.dart';

// Import core screens
import '../../features/core/presentation/screens/supabase_test_screen.dart';

/// Router provider for the Aura application with authentication-aware routing
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/splash', // Always start with splash screen
    routes: _buildRoutes(),
    errorBuilder: _buildErrorScreen,
  );
});

/// Build route configuration
List<RouteBase> _buildRoutes() {
  return [
    // Debug/Test Routes
    GoRoute(
      path: '/supabase-test',
      name: 'supabase-test',
      builder: (BuildContext context, GoRouterState state) {
        return const SupabaseTestScreen();
      },
    ),
    
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
        // Wardrobe analytics route disabled
        // GoRoute(
        //   path: '/analytics',
        //   name: 'wardrobeAnalytics',
        //   builder: (BuildContext context, GoRouterState state) {
        //     return const WardrobeAnalyticsScreen();
        //   },
        // },
        GoRoute(
          path: '/forgot-password',
          name: 'forgotPassword',
          builder: (BuildContext context, GoRouterState state) {
            return const ForgotPasswordScreen();
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
    
    // Style Discovery Route
    GoRoute(
      path: '/style-discovery',
      name: 'styleDiscovery',
      builder: (BuildContext context, GoRouterState state) {
        return const StyleDiscoveryScreen();
      },
    ),
    
    // Main App Route (tab controller with nested routes)
    GoRoute(
      path: '/main',
      name: 'main',
      builder: (BuildContext context, GoRouterState state) {
        return const AppTabController();
      },
    ),

    // Search Route
    GoRoute(
      path: '/search',
      name: 'search',
      builder: (BuildContext context, GoRouterState state) {
        final query = state.uri.queryParameters['q'];
        return SearchScreen(initialQuery: query);
      },
    ),

    // Wardrobe Routes
    GoRoute(
      path: '/wardrobe',
      name: 'wardrobeHome',
      builder: (BuildContext context, GoRouterState state) {
        return const WardrobeHomeScreen();
      },
      routes: [
        GoRoute(
          path: '/camera',
          name: 'camera',
          builder: (BuildContext context, GoRouterState state) {
            return const CameraScreen();
          },
        ),
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
          path: '/outfits/:outfitId/detail',
          name: 'outfitDetail',
          builder: (BuildContext context, GoRouterState state) {
            final outfitId = state.pathParameters['outfitId']!;
            return OutfitDetailScreen(outfitId: outfitId);
          },
        ),
        GoRoute(
          path: '/item/:itemId',
          name: 'clothingItemDetail',
          builder: (BuildContext context, GoRouterState state) {
            final itemId = state.pathParameters['itemId']!;
            return ClothingItemDetailScreen(itemId: itemId);
          },
        ),
        GoRoute(
          path: '/item/:itemId/edit',
          name: 'editClothingItem',
          builder: (BuildContext context, GoRouterState state) {
            final itemId = state.pathParameters['itemId']!;
            // TODO: Load actual clothing item from itemId
            return EditClothingItemScreenPlaceholder(itemId: itemId);
          },
        ),
        GoRoute(
          path: '/analytics',
          name: 'wardrobeAnalytics',
          builder: (BuildContext context, GoRouterState state) {
            return const WardrobeAnalyticsScreen();
          },
        ),
        GoRoute(
          path: '/planner',
          name: 'wardrobePlanner',
          builder: (BuildContext context, GoRouterState state) {
            return const WardrobePlannerScreen();
          },
        ),
        GoRoute(
          path: '/outfit-planner',
          name: 'wardrobeOutfitPlanner',
          builder: (BuildContext context, GoRouterState state) {
            return const SimpleOutfitPlannerScreen();
          },
        ),
        GoRoute(
          path: '/ai-suggestions',
          name: 'aiStylingSuggestions',
          builder: (BuildContext context, GoRouterState state) {
            return const AiStylingSuggestionsScreen();
          },
        ),
      ],
    ),

    // Style Assistant Routes
    GoRoute(
      path: '/style-assistant',
      name: 'styleAssistant',
      builder: (BuildContext context, GoRouterState state) {
        return const StyleAssistantScreen();
      },
      routes: [
        GoRoute(
          path: '/challenges',
          name: 'styleChallenges',
          builder: (BuildContext context, GoRouterState state) {
            return const StyleChallengesScreen();
          },
          routes: [
            GoRoute(
              path: '/:challengeId',
              name: 'challengeDetail',
              builder: (BuildContext context, GoRouterState state) {
                return const Scaffold(
                  body: Center(
                    child: Text('Challenge Detail Screen - Coming Soon'),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    ),

    // Social Routes - Temporarily commented out due to compilation errors
    /*
    GoRoute(
      path: '/social',
      name: 'socialFeed',
      builder: (BuildContext context, GoRouterState state) {
        return const SocialFeedScreen();
      },
      routes: [
        GoRoute(
          path: '/create',
          name: 'createPost',
          builder: (BuildContext context, GoRouterState state) {
            return const CreatePostScreen();
          },
        ),
        GoRoute(
          path: '/post/:postId',
          name: 'socialPostDetail',
          builder: (BuildContext context, GoRouterState state) {
            final postId = state.pathParameters['postId']!;
            return SocialPostDetailScreen(postId: postId);
          },
        ),
        GoRoute(
          path: '/user/:userId',
          name: 'socialUserProfile',
          builder: (BuildContext context, GoRouterState state) {
            final userId = state.pathParameters['userId']!;
            final username = state.uri.queryParameters['username'];
            return SocialUserProfileScreen(
              userId: userId,
              username: username,
            );
          },
        ),
      ],
    ),
    */

    // User Profile Routes
    GoRoute(
      path: '/profile',
      name: 'userProfile',
      builder: (BuildContext context, GoRouterState state) {
        return const ProfileScreenWrapper(useHeroAnimation: true);
      },
      routes: [
        GoRoute(
          path: '/favorites',
          name: 'favorites',
          builder: (BuildContext context, GoRouterState state) {
            return const FavoritesScreen();
          },
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (BuildContext context, GoRouterState state) {
            return const SettingsScreen();
          },
        ),
        GoRoute(
          path: '/privacy-policy',
          name: 'privacyPolicy',
          builder: (BuildContext context, GoRouterState state) {
            return const PrivacyPolicyScreen();
          },
        ),
        GoRoute(
          path: '/terms-of-service',
          name: 'termsOfService',
          builder: (BuildContext context, GoRouterState state) {
            return const TermsOfServiceScreen();
          },
        ),
      ],
    ),

    // Swap Market Routes
    GoRoute(
      path: '/swap-market',
      name: 'swapMarket',
      builder: (BuildContext context, GoRouterState state) {
        return const SwapMarketScreen();
      },
      routes: [
        GoRoute(
          path: '/create',
          name: 'createSwapListing',
          builder: (BuildContext context, GoRouterState state) {
            final clothingItemId = state.uri.queryParameters['itemId'] ?? '';
            return CreateSwapListingScreen(clothingItemId: clothingItemId);
          },
        ),
        GoRoute(
          path: '/listing/:listingId',
          name: 'swapListingDetail',
          builder: (BuildContext context, GoRouterState state) {
            final listingId = state.pathParameters['listingId']!;
            return SwapListingDetailScreen(listingId: listingId);
          },
        ),
        GoRoute(
          path: '/chat/:otherUserId',
          name: 'preSwapChat',
          builder: (BuildContext context, GoRouterState state) {
            final otherUserId = state.pathParameters['otherUserId']!;
            final swapListingId = state.uri.queryParameters['listingId'];
            final otherUserName = state.uri.queryParameters['userName'];
            final otherUserAvatar = state.uri.queryParameters['userAvatar'];
            return PreSwapChatScreen(
              otherUserId: otherUserId,
              swapListingId: swapListingId,
              otherUserName: otherUserName,
              otherUserAvatar: otherUserAvatar,
            );
          },
        ),
      ],
    ),

    // Messaging Routes
    GoRoute(
      path: '/messaging',
      name: 'messaging',
      builder: (BuildContext context, GoRouterState state) {
        return const MessagingScreen();
      },
      routes: [
        GoRoute(
          path: '/chat/:conversationId',
          name: 'chat',
          builder: (BuildContext context, GoRouterState state) {
            final conversationId = state.pathParameters['conversationId']!;
            return ChatScreen(conversationId: conversationId);
          },
        ),
      ],
    ),

    // Notifications Route - V3.0 Release Critical Feature
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (BuildContext context, GoRouterState state) {
        return const NotificationsScreen();
      },
    ),

    // Privacy Routes
    GoRoute(
      path: '/privacy',
      name: 'privacyHome',
      redirect: (context, state) => '/profile/privacy-policy',
      routes: [
        GoRoute(
          path: '/consent',
          name: 'privacyConsent',
          builder: (BuildContext context, GoRouterState state) {
            return const PrivacyConsentScreen();
          },
        ),
        GoRoute(
          path: '/data-management',
          name: 'privacyDataManagement',
          builder: (BuildContext context, GoRouterState state) {
            return const PrivacyDataManagementScreen();
          },
        ),
      ],
    ),

    // Legacy routes for backward compatibility
    GoRoute(
      path: '/home',
      redirect: (context, state) => '/main',
    ),
    
    // Root route redirect
    GoRoute(
      path: '/',
      redirect: (context, state) => '/main',
    ),

    // Legacy style challenges route (keep for backward compatibility)
    GoRoute(
      path: '/style-challenges',
      redirect: (context, state) => '/style-assistant/challenges',
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
            const Text('Clothing Item Detail Screen - Coming Soon'),
            const SizedBox(height: 16),
            Text('Item ID: $itemId'),
          ],
        ),
      ),
    );
  }
}

class EditClothingItemScreenPlaceholder extends StatelessWidget {
  final String itemId;
  
  const EditClothingItemScreenPlaceholder({
    super.key,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Item')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Edit Clothing Item Screen - Coming Soon'),
            const SizedBox(height: 16),
            Text('Item ID: $itemId'),
          ],
        ),
      ),
    );
  }
}
