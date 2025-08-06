import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../../../wardrobe/presentation/screens/wardrobe_home_screen.dart';
import '../../../style_assistant/presentation/screens/style_assistant_screen.dart';
import '../../../messaging/presentation/screens/messaging_screen.dart';
// Temporarily disabled social import
// import '../../../social/presentation/screens/social_feed_screen.dart';
import '../../../user_profile/presentation/screens/user_profile_screen.dart';

/// App tab controller that provides the core navigation structure for the Aura app
/// Features a bottom navigation bar with 5 main sections and consistent app bar
/// Manages local state for tab switching and displays appropriate content
class AppTabController extends ConsumerStatefulWidget {
  const AppTabController({super.key});

  @override
  ConsumerState<AppTabController> createState() => _AppTabControllerState();
}

class _AppTabControllerState extends ConsumerState<AppTabController>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Screen widgets for each main section
  static const List<Widget> _screenOptions = <Widget>[
    // Home Screen
    HomeScreen(key: Key('home_screen')),
    
    // Wardrobe Screen - Fully functional digital closet management
    WardrobeHomeScreen(),
    
    // Style Assistant Screen - AI-powered styling chat interface
    StyleAssistantScreen(),
    
    // Messaging Screen - Real-time messaging system
    MessagingScreen(),
    
    // Profile Screen - User profile and settings
    UserProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(theme, colorScheme),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _screenOptions[_selectedIndex],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(theme, colorScheme),
    );
  }

  /// Builds the app bar with Aura branding and action buttons
  PreferredSizeWidget _buildAppBar(ThemeData theme, ColorScheme colorScheme) {
    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: colorScheme.surfaceTint,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.auto_awesome,
            color: colorScheme.onPrimary,
            size: 24,
          ),
        ),
      ),
      title: Text(
        'Aura',
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
      centerTitle: false,
      actions: [
        // Search button
        IconButton(
          onPressed: () {
            // Navigate to search screen
            context.push('/search');
          },
          icon: Icon(
            Icons.search_outlined,
            color: colorScheme.onSurfaceVariant,
          ),
          tooltip: 'Search',
        ),
        
        // Notifications button
        Stack(
          children: [
            IconButton(
              onPressed: () {
                // Navigate to NotificationsScreen
                context.push('/notifications');
              },
              icon: Icon(
                Icons.notifications_outlined,
                color: colorScheme.onSurfaceVariant,
              ),
              tooltip: 'Notifications',
            ),
            // Notification badge (placeholder)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colorScheme.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(width: 8),
      ],
    );
  }

  /// Builds the bottom navigation bar with 5 main sections
  Widget _buildBottomNavigationBar(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        selectedLabelStyle: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        iconSize: 24,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: Semantics(
              label: 'Navigate to Home tab',
              child: Icon(Icons.home_outlined),
            ),
            activeIcon: Semantics(
              label: 'Home tab selected',
              child: Icon(Icons.home),
            ),
            label: 'Home',
            tooltip: 'Home Screen',
          ),
          BottomNavigationBarItem(
            icon: Semantics(
              label: 'Navigate to Wardrobe tab',
              child: Icon(Icons.checkroom_outlined),
            ),
            activeIcon: Semantics(
              label: 'Wardrobe tab selected',
              child: Icon(Icons.checkroom),
            ),
            label: 'Wardrobe',
            tooltip: 'Wardrobe Management',
          ),
          BottomNavigationBarItem(
            icon: Semantics(
              label: 'Navigate to Style Assistant tab',
              child: Icon(Icons.auto_awesome_outlined),
            ),
            activeIcon: Semantics(
              label: 'Style Assistant tab selected',
              child: Icon(Icons.auto_awesome),
            ),
            label: 'Style',
            tooltip: 'Style Assistant',
          ),
          BottomNavigationBarItem(
            icon: Semantics(
              label: 'Navigate to Messaging tab',
              child: Icon(Icons.chat_bubble_outline),
            ),
            activeIcon: Semantics(
              label: 'Messaging tab selected',
              child: Icon(Icons.chat_bubble),
            ),
            label: 'Messages',
            tooltip: 'Messaging & Chat',
          ),
          BottomNavigationBarItem(
            icon: Semantics(
              label: 'Navigate to Profile tab',
              child: Icon(Icons.person_outline),
            ),
            activeIcon: Semantics(
              label: 'Profile tab selected',
              child: Icon(Icons.person),
            ),
            label: 'Profile',
            tooltip: 'User Profile',
          ),
        ],
      ),
    );
  }
}
