import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ui/system_state_widget.dart';
import '../widgets/profile_header.dart';
import '../widgets/aura_score_display.dart';
import '../widgets/profile_stats_row.dart';
import '../widgets/profile_tab_bar.dart';
import '../widgets/profile_tab_bar_view.dart';
import '../widgets/analytics_dashboard_widget.dart';
import '../controllers/user_profile_controller.dart';

/// User Profile Screen - Central control panel for user profile management
/// 
/// This screen provides:
/// - User profile information (avatar, name, bio)
/// - Aura Score display with progress
/// - Profile statistics (combinations, favorites, followers)
/// - Tabbed content for different profile sections
/// - Settings access via app bar
class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize tab controller - we'll get tab labels from the controller state
    _tabController = TabController(
      length: 6, // Will be updated once we get the state
      vsync: this,
    );
    
    // Listen to tab changes and update controller
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        final state = ref.read(userProfileControllerProvider);
        if (_tabController.index < state.availableTabs.length) {
          final tabName = state.availableTabs[_tabController.index];
          ref.read(userProfileControllerProvider.notifier).selectTab(tabName);
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(userProfileControllerProvider);

    // Update tab controller length if needed
    if (_tabController.length != state.availableTabs.length) {
      _tabController.dispose();
      _tabController = TabController(
        length: state.availableTabs.length,
        vsync: this,
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(theme, colorScheme),
      body: _buildBody(theme, colorScheme, state),
    );
  }

  /// Builds the app bar with title and settings action
  PreferredSizeWidget _buildAppBar(ThemeData theme, ColorScheme colorScheme) {
    return AppBar(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      elevation: 0,
      scrolledUnderElevation: 1,
      title: Text(
        'Profile',
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
          fontFamily: 'Urbanist', // Using Urbanist for headings as per style guide
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          onPressed: () {
            // Navigate to settings
            context.push('/profile/settings');
          },
          icon: Icon(
            Icons.settings_outlined,
            color: colorScheme.onSurface,
          ),
          tooltip: 'Settings',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// Builds the main body content with state handling
  Widget _buildBody(ThemeData theme, ColorScheme colorScheme, UserProfileState state) {
    // Handle loading state for profile
    if (state.userProfile.isLoading) {
      return const SystemStateWidget(
        message: 'Loading your profile...',
        icon: Icons.person_outline,
      );
    }

    // Handle error state for profile
    if (state.userProfile.hasError) {
      return SystemStateWidget(
        title: 'Something went wrong',
        message: 'We couldn\'t load your profile. Please try again.',
        icon: Icons.error_outline,
        iconColor: colorScheme.error,
        onRetry: () {
          ref.read(userProfileControllerProvider.notifier).retry();
        },
        retryText: 'Try Again',
      );
    }

    // Profile data is available, build content
    final userProfile = state.userProfile.value;
    if (userProfile == null) {
      return const SystemStateWidget(
        message: 'No profile data available',
        icon: Icons.person_off_outlined,
      );
    }

    return _buildProfileContent(theme, colorScheme, state, userProfile);
  }

  /// Builds the main profile content
  Widget _buildProfileContent(
    ThemeData theme, 
    ColorScheme colorScheme, 
    UserProfileState state, 
    UserProfileData userProfile,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(userProfileControllerProvider.notifier).refreshProfile();
      },
      child: CustomScrollView(
        slivers: [
          // Profile Header Section
          SliverToBoxAdapter(
            child: ProfileHeader(
              user: userProfile,
              onEditProfile: () {
                // TODO: Navigate to edit profile (will be implemented in controller connection)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Edit profile coming soon'),
                    backgroundColor: colorScheme.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),

          // Aura Score Display Section
          SliverToBoxAdapter(
            child: AuraScoreDisplay(
              score: userProfile.auraScore,
              level: userProfile.auraLevel,
              progress: userProfile.auraProgress,
            ),
          ),

          // Profile Stats Section
          SliverToBoxAdapter(
            child: _buildStatsSection(colorScheme, state),
          ),

          // Tab Bar Section
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              ProfileTabBar(
                tabController: _tabController,
                tabs: state.availableTabs,
              ),
            ),
          ),

          // Tab Bar View Content
          SliverFillRemaining(
            child: ProfileTabBarView(
              tabController: _tabController,
              tabs: state.availableTabs,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the stats section with error handling
  Widget _buildStatsSection(ColorScheme colorScheme, UserProfileState state) {
    return state.userStats.when(
      data: (stats) => ProfileStatsRow(
        stats: stats,
        onStatsPressed: (statType) {
          ref.read(userProfileControllerProvider.notifier).navigateToStatDetail(statType);
        },
      ),
      loading: () => Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: colorScheme.error,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to load stats',
              style: TextStyle(
                color: colorScheme.error,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                ref.read(userProfileControllerProvider.notifier).retryStats();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom sliver delegate for pinned tab bar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverAppBarDelegate(this.child);

  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}
