import 'package:flutter/material.dart';

/// Loading view for the Style Assistant screen
/// Shows shimmer placeholders while content is being loaded
class StyleAssistantLoadingView extends StatelessWidget {
  const StyleAssistantLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section loading
          _buildLoadingCard(colorScheme, height: 120),
          const SizedBox(height: 24),
          
          // Style inspiration loading
          _buildSectionTitle(theme, colorScheme, 'Style Inspiration'),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 16),
                  child: _buildLoadingCard(colorScheme, height: 220),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          
          // Recommendations loading
          _buildSectionTitle(theme, colorScheme, 'Personalized for You'),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(child: _buildLoadingCard(colorScheme, height: 200)),
                const SizedBox(width: 16),
                Expanded(child: _buildLoadingCard(colorScheme, height: 200)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Quick actions loading
          _buildSectionTitle(theme, colorScheme, 'Quick Actions'),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
            children: List.generate(4, (index) => _buildLoadingCard(colorScheme)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, ColorScheme colorScheme, String title) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCard(ColorScheme colorScheme, {double? height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: colorScheme.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

/// Error view for the Style Assistant screen
/// Shows when there's an error loading content
class StyleAssistantErrorView extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback? onRetry;

  const StyleAssistantErrorView({
    super.key,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage ?? 'We\'re having trouble loading your style recommendations. Please try again.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty view for the Style Assistant screen
/// Shows when there's no content available
class StyleAssistantEmptyView extends StatelessWidget {
  final VoidCallback? onGetStarted;

  const StyleAssistantEmptyView({
    super.key,
    this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primaryContainer,
                    colorScheme.secondaryContainer,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.auto_awesome_outlined,
                size: 64,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to your Style Assistant! 👋',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'I\'m here to help you discover your perfect style. Let\'s start by building your wardrobe and getting to know your preferences!',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onGetStarted,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Get Started'),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                // TODO: Navigate to style quiz
              },
              icon: const Icon(Icons.quiz_outlined),
              label: const Text('Take Style Quiz'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.primary,
                side: BorderSide(color: colorScheme.primary),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
