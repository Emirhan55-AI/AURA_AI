import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../../../wardrobe/presentation/screens/wardrobe_home_screen.dart';
import '../../../style_assistant/presentation/screens/style_assistant_screen.dart';
import '../../../social/presentation/screens/social_feed_screen.dart';
import '../../../user_profile/presentation/screens/user_profile_screen.dart';

/// Main screen that provides the core navigation structure for the Aura app
/// Features a bottom navigation bar with 5 main sections and consistent app bar
/// Manages local state for tab switching and displays appropriate content
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> 
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Main content animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    // Button press animation controller
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    // Fade animation for content transitions
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    // Slide animation for content transitions
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));
    
    // Scale animation for button press feedback
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    // Start initial animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }  /// Screen widgets for each main section
  static const List<Widget> _screenOptions = <Widget>[
    // Home Screen
    HomeScreen(),
    
    // Wardrobe Screen - Fully functional digital closet management
    WardrobeHomeScreen(),
    
    // Style Assistant Screen - AI-powered styling chat interface
    StyleAssistantScreen(),
    
    // Social Feed Screen - Community feed and interactions (using Social as Inspire Me)
    SocialFeedScreen(),
    
    // Profile Screen - User profile and settings
    UserProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      // Trigger button press animation
      _scaleController.forward().then((_) {
        _scaleController.reverse();
      });
      
      setState(() {
        _selectedIndex = index;
      });
      
      // Reset and start content transition animation
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
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _screenOptions[_selectedIndex],
            ),
          );
        },
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
      leading: Semantics(
        label: 'Aura app logo',
        child: Padding(
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
        Semantics(
          label: 'Search for items and styles',
          button: true,
          child: IconButton(
            onPressed: () {
              // TODO: Implement search functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Search feature coming soon'),
                  backgroundColor: colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: Icon(
              Icons.search_outlined,
              color: colorScheme.onSurfaceVariant,
            ),
            tooltip: 'Search',
          ),
        ),
        
        // Notifications button
        Semantics(
          label: 'View notifications',
          button: true,
          child: Stack(
            children: [
              IconButton(
                onPressed: () {
                  // TODO: Implement notifications
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Notifications feature coming soon'),
                      backgroundColor: colorScheme.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
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
                child: Semantics(
                  label: 'You have new notifications',
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 8),
      ],
    );
  }

  /// Builds the bottom navigation bar with 5 main sections and animation feedback
  Widget _buildBottomNavigationBar(ThemeData theme, ColorScheme colorScheme) {
    return AnimatedBuilder(
      animation: _scaleController,
      builder: (context, child) {
        return Transform.scale(
          scale: _selectedIndex == _selectedIndex ? _scaleAnimation.value : 1.0,
          child: Container(
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
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Semantics(
                      label: 'Navigate to Home tab',
                      child: Icon(Icons.home_outlined),
                    ),
                  ),
                  activeIcon: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Semantics(
                      label: 'Home tab selected',
                      child: Icon(Icons.home),
                    ),
                  ),
                  label: 'Home',
                  tooltip: 'Home Screen',
                ),
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Semantics(
                      label: 'Navigate to Wardrobe tab',
                      child: Icon(Icons.checkroom_outlined),
                    ),
                  ),
                  activeIcon: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Semantics(
                      label: 'Wardrobe tab selected',
                      child: Icon(Icons.checkroom),
                    ),
                  ),
                  label: 'Wardrobe',
                  tooltip: 'Wardrobe Management',
                ),
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Semantics(
                      label: 'Navigate to Style Assistant tab',
                      child: Icon(Icons.auto_awesome_outlined),
                    ),
                  ),
                  activeIcon: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Semantics(
                      label: 'Style Assistant tab selected',
                      child: Icon(Icons.auto_awesome),
                    ),
                  ),
                  label: 'Style',
                  tooltip: 'Style Assistant',
                ),
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Semantics(
                      label: 'Navigate to Inspiration tab',
                      child: Icon(Icons.lightbulb_outlined),
                    ),
                  ),
                  activeIcon: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Semantics(
                      label: 'Inspiration tab selected',
                      child: Icon(Icons.lightbulb),
                    ),
                  ),
                  label: 'Inspire',
                  tooltip: 'Inspiration & Discovery',
                ),
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Semantics(
                      label: 'Navigate to Profile tab',
                      child: Icon(Icons.person_outline),
                    ),
                  ),
                  activeIcon: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Semantics(
                      label: 'Profile tab selected',
                      child: Icon(Icons.person),
                    ),
                  ),
                  label: 'Profile',
                  tooltip: 'User Profile',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
