import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dashboard_screen.dart';
import '../controllers/navigation_controller.dart';
import '../../../wardrobe/presentation/screens/wardrobe_home_screen.dart';
import '../../../style_assistant/presentation/screens/style_assistant_screen.dart';
import '../../../user_profile/presentation/screens/profile_screen_wrapper.dart';
import '../../../social/presentation/screens/social_feed_screen.dart';

/// Home Screen - Main navigation container with BottomNavigationBar
/// Manages tab switching and displays appropriate content for each section
/// Follows specification from docs/development/api/sayfalar_ve_detayları.md
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// Screen widgets for each main section
  static const List<Widget> _screenOptions = <Widget>[
    // Dashboard Screen - Home tab content
    DashboardScreen(),
    
    // Wardrobe Screen - Fully functional digital closet management
    WardrobeHomeScreen(),
    
    // Style Assistant Screen - AI-powered styling chat interface
    StyleAssistantScreen(),
    
    // Social Feed Screen - Community social feed and interactions  
    const SocialFeedScreen(),
    
    // Profile Screen - User profile and settings
    ProfileScreenWrapper(),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(navigationStateProvider);
    final navigationController = ref.read(navigationControllerProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _handleBackButton(navigationController);
        }
      },
      child: IndexedStack(
        index: selectedIndex,
        children: _screenOptions,
      ),
    );
  }

  /// Handle back button press
  void _handleBackButton(NavigationController navigationController) {
    final selectedIndex = ref.read(navigationStateProvider);
    
    if (selectedIndex != 0) {
      // If not on Dashboard, go to Dashboard
      navigationController.goToDashboard();
    } else {
      // If on Dashboard, show exit confirmation
      _showExitConfirmation();
    }
  }

  /// Show exit confirmation dialog
  void _showExitConfirmation() {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit Aura?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              SystemNavigator.pop();
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

}
