import 'package:flutter/material.dart';

/// Style Assistant Home Screen - Main interface for AI-powered style assistance
/// 
/// This screen provides the primary interface for users to interact with Aura's
/// AI-powered style assistant, featuring:
/// - Style inspiration carousel
/// - Personalized recommendations
/// - Quick action buttons
/// - Recent activity feed
/// - AI chat interface
class StyleAssistantScreen extends StatelessWidget {
  const StyleAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: _buildAppBar(context, theme, colorScheme),
      body: const StyleAssistantContent(),
      floatingActionButton: _buildFloatingActionButton(context, colorScheme),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return AppBar(
      title: Text(
        'Style Assistant',
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onPrimary,
        ),
      ),
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 0,
      scrolledUnderElevation: 2,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // TODO: Implement notifications
          },
          tooltip: 'Notifications',
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            // TODO: Implement settings
          },
          tooltip: 'Settings',
        ),
      ],
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context, ColorScheme colorScheme) {
    return FloatingActionButton.extended(
      onPressed: () {
        // TODO: Open full AI chat interface
      },
      backgroundColor: colorScheme.secondary,
      foregroundColor: colorScheme.onSecondary,
      icon: const Icon(Icons.auto_awesome),
      label: const Text('Ask Aura'),
      tooltip: 'Start AI conversation',
    );
  }
}

/// Main content widget for the Style Assistant screen
class StyleAssistantContent extends StatelessWidget {
  const StyleAssistantContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message
          _WelcomeSection(),
          SizedBox(height: 24),
          
          // Style inspiration carousel
          _StyleInspirationSection(),
          SizedBox(height: 32),
          
          // Personalized recommendations
          _PersonalizedRecommendationsSection(),
          SizedBox(height: 32),
          
          // Quick actions grid
          _QuickActionsSection(),
          SizedBox(height: 32),
          
          // Recent activity feed
          _RecentActivitySection(),
          SizedBox(height: 32),
          
          // AI chat widget
          _AiChatWidget(),
          SizedBox(height: 100), // Extra space for FAB
        ],
      ),
    );
  }
}

/// Welcome section with personalized greeting
class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.wb_sunny_outlined,
                color: colorScheme.onPrimaryContainer,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Good morning!',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ready to discover your perfect style today? I have some fresh ideas for you!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Style inspiration carousel section
class _StyleInspirationSection extends StatelessWidget {
  const _StyleInspirationSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              color: colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Style Inspiration',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to full inspiration gallery
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return _InspirationCard(
                index: index,
                colorScheme: colorScheme,
                theme: theme,
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Individual inspiration card
class _InspirationCard extends StatelessWidget {
  final int index;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _InspirationCard({
    required this.index,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final inspirationTypes = [
      'Casual Chic',
      'Office Style',
      'Date Night',
      'Weekend Vibes',
      'Elegant Evening'
    ];

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () {
            // TODO: Navigate to inspiration details
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Placeholder image area
              Container(
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primaryContainer,
                      colorScheme.secondaryContainer,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.style_outlined,
                    size: 48,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inspirationTypes[index],
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '3 outfits',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Personalized recommendations section
class _PersonalizedRecommendationsSection extends StatelessWidget {
  const _PersonalizedRecommendationsSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.favorite_outlined,
              color: colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Personalized for You',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to full recommendations
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              return _RecommendationCard(
                index: index,
                colorScheme: colorScheme,
                theme: theme,
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Individual recommendation card
class _RecommendationCard extends StatelessWidget {
  final int index;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _RecommendationCard({
    required this.index,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final recommendations = [
      'Perfect for Today\'s Weather',
      'Based on Your Favorites',
      'Trending in Your Style',
      'Complete Your Look'
    ];

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to recommendation details
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.secondaryContainer.withOpacity(0.3),
                colorScheme.tertiaryContainer.withOpacity(0.3),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.recommend_outlined,
                  size: 32,
                  color: colorScheme.onSecondaryContainer,
                ),
                const SizedBox(height: 12),
                Text(
                  recommendations[index],
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSecondaryContainer,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '${index + 2} items',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSecondaryContainer.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Quick actions grid section
class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.flash_on_outlined,
              color: colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Quick Actions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: const [
            _QuickActionCard(
              icon: Icons.auto_awesome,
              title: 'Generate Outfit',
              subtitle: 'AI-powered styling',
              index: 0,
            ),
            _QuickActionCard(
              icon: Icons.quiz_outlined,
              title: 'Style Quiz',
              subtitle: 'Discover your style',
              index: 1,
            ),
            _QuickActionCard(
              icon: Icons.wb_sunny_outlined,
              title: 'Weather Outfits',
              subtitle: 'Perfect for today',
              index: 2,
            ),
            _QuickActionCard(
              icon: Icons.history,
              title: 'Outfit History',
              subtitle: 'Your past looks',
              index: 3,
            ),
          ],
        ),
      ],
    );
  }
}

/// Individual quick action card
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int index;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Implement quick action navigation
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Recent activity section
class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.history_outlined,
              color: colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Recent Activity',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to full activity history
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            return _ActivityItem(
              index: index,
              colorScheme: colorScheme,
              theme: theme,
            );
          },
        ),
      ],
    );
  }
}

/// Individual activity item
class _ActivityItem extends StatelessWidget {
  final int index;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _ActivityItem({
    required this.index,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final activities = [
      {
        'icon': Icons.auto_awesome,
        'title': 'Generated outfit "Casual Friday"',
        'time': '2 hours ago',
        'color': colorScheme.primaryContainer,
      },
      {
        'icon': Icons.favorite,
        'title': 'Saved "Summer Dress Collection"',
        'time': '1 day ago',
        'color': colorScheme.secondaryContainer,
      },
      {
        'icon': Icons.quiz,
        'title': 'Completed Style Quiz',
        'time': '3 days ago',
        'color': colorScheme.tertiaryContainer,
      },
    ];

    final activity = activities[index];

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: activity['color'] as Color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            activity['icon'] as IconData,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(
          activity['title'] as String,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          activity['time'] as String,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
        onTap: () {
          // TODO: Navigate to activity details
        },
      ),
    );
  }
}

/// AI chat widget - persistent assistant presence
class _AiChatWidget extends StatelessWidget {
  const _AiChatWidget();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.secondary.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.auto_awesome,
                color: colorScheme.onPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi, I\'m Aura! 👋',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ask me anything about style, fashion, or your wardrobe!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton.tonal(
              onPressed: () {
                // TODO: Open full AI chat interface
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: const Text('Chat'),
            ),
          ],
        ),
      ),
    );
  }
}
