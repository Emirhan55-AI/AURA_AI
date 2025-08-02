import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/presentation/widgets/loading_screen.dart';
import '../../../authentication/domain/entities/auth_state.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../controllers/navigation_controller.dart';
import '../screens/app_tab_controller.dart';

/// Provider that converts User? state to AuthState
final authStateProvider = Provider<AuthState>((ref) {
  final userState = ref.watch(authControllerProvider);
  
  return userState.when(
    data: (user) => user != null ? AuthState.authenticated : AuthState.unauthenticated,
    loading: () => AuthState.loading,
    error: (_, __) => AuthState.error,
  );
});

/// MainScreen serves as the authentication router
/// Determines which screen to show based on authentication state
class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return _buildScreenForState(context, ref, authState);
  }

  Widget _buildScreenForState(BuildContext context, WidgetRef ref, AuthState state) {
    switch (state) {
      case AuthState.initial:
      case AuthState.loading:
      case AuthState.refreshing:
        return const LoadingScreen();
        
      case AuthState.authenticated:
        return const AppTabController();
        
      case AuthState.unauthenticated:
      case AuthState.expired:
        return _buildUnauthenticatedFlow(context, ref);
        
      case AuthState.error:
        return _buildAuthErrorScreen(context, ref);
    }
  }

  Widget _buildUnauthenticatedFlow(BuildContext context, WidgetRef ref) {
    // Check if user has completed onboarding
    // For now, navigate to auth screens (will be implemented later)
    return _buildAuthNavigationScreen(context);
  }

  Widget _buildAuthNavigationScreen(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Aura',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/auth/login'),
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => context.go('/auth/register'),
              child: const Text('Create Account'),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => context.go('/onboarding'),
              child: const Text('Learn More'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthErrorScreen(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Authentication Error',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'There was a problem with authentication.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(authControllerProvider.notifier).logout();
                context.go('/');
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Navigation wrapper that handles bottom tab navigation
/// Separated from authentication routing for clean separation of concerns
class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(navigationStateProvider);
    
    return Scaffold(
      body: _buildCurrentTabScreen(currentTab),
      bottomNavigationBar: _buildBottomNavigationBar(context, ref, currentTab),
    );
  }

  Widget _buildCurrentTabScreen(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return const HomeTabScreen();
      case 1:
        return const WardrobeTabScreen();
      case 2:
        return const StyleAssistantTabScreen();
      case 3:
        return const InspireMeTabScreen();
      case 4:
        return const ProfileTabScreen();
      default:
        return const HomeTabScreen();
    }
  }

  Widget _buildBottomNavigationBar(BuildContext context, WidgetRef ref, int currentIndex) {
    final navigationController = ref.read(navigationControllerProvider);
    
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) {
        navigationController.selectTab(index);
        // Track navigation history
        ref.read(navigationHistoryProvider.notifier).push(index);
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.checkroom_outlined),
          activeIcon: Icon(Icons.checkroom),
          label: 'Wardrobe',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.auto_awesome_outlined),
          activeIcon: Icon(Icons.auto_awesome),
          label: 'Style AI',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.lightbulb_outlined),
          activeIcon: Icon(Icons.lightbulb),
          label: 'Inspire',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}

// Placeholder tab screens - will be implemented later
class HomeTabScreen extends StatelessWidget {
  const HomeTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Home Tab'),
    );
  }
}

class WardrobeTabScreen extends StatelessWidget {
  const WardrobeTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Wardrobe Tab'),
    );
  }
}

class StyleAssistantTabScreen extends StatelessWidget {
  const StyleAssistantTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Style Assistant Tab'),
    );
  }
}

class InspireMeTabScreen extends StatelessWidget {
  const InspireMeTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Inspire Me Tab'),
    );
  }
}

class ProfileTabScreen extends StatelessWidget {
  const ProfileTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Profile Tab'),
    );
  }
}
