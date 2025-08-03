import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../social/presentation/screens/social_post_detail_screen_simple.dart';

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

  /// Placeholder widgets for each main section
  /// These will be replaced with actual screen implementations
  static const List<Widget> _screenOptions = <Widget>[
    // Home Screen Placeholder
    _PlaceholderScreen(
      title: 'Home',
      subtitle: 'Your style journey starts here',
      icon: Icons.home_outlined,
      color: Color(0xFF6B46C1),
    ),
    
    // Wardrobe Screen Placeholder (temporarily disabled due to build issues)
    _PlaceholderScreen(
      title: 'Wardrobe',
      subtitle: 'Digital closet management',
      icon: Icons.checkroom_outlined,
      color: Color(0xFF059669),
    ),
    
    // Style Assistant Screen Placeholder
    _PlaceholderScreen(
      title: 'Style Assistant',
      subtitle: 'AI-powered styling recommendations',
      icon: Icons.auto_awesome_outlined,
      color: Color(0xFFDC2626),
    ),
    
    // Social Screen - ACTUAL Social Post Detail Implementation
    SocialPostDetailScreen(),
    
    // Profile Screen Placeholder (temporarily disabled)
    _PlaceholderScreen(
      title: 'Profile',
      subtitle: 'Personal settings & style preferences',
      icon: Icons.person_outline,
      color: Color(0xFF7C3AED),
    ),
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
        
        // Notifications button
        Stack(
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
              label: 'Navigate to Social tab',
              child: Icon(Icons.people_outline),
            ),
            activeIcon: Semantics(
              label: 'Social tab selected',
              child: Icon(Icons.people),
            ),
            label: 'Social',
            tooltip: 'Social & Community',
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

/// Placeholder screen widget for main sections
/// Provides a consistent design while actual screens are implemented
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _PlaceholderScreen({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Main icon with gradient background
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.8),
                    color,
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 60,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Title
            Text(
              title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Subtitle
            Text(
              subtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 48),
            
            // Coming soon badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.construction_outlined,
                    size: 16,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Coming Soon',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Additional info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What\'s Next:',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getFeatureDescription(title),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFeatureDescription(String title) {
    switch (title) {
      case 'Home':
        return 'Dashboard with style insights, recent outfits, and personalized recommendations.';
      case 'Wardrobe':
        return 'Digital closet organization, outfit planning, and clothing item management.';
      case 'Style':
        return 'AI-powered styling assistant with outfit suggestions and fashion advice.';
      case 'Inspire Me':
        return 'Style inspiration, trend discovery, and personalized fashion recommendations.';
      case 'Social':
        return 'Fashion community features, outfit sharing, and style inspiration.';
      case 'Profile':
        return 'Personal style preferences, account settings, and style history.';
      default:
        return 'This feature is currently under development.';
    }
  }
}
