import 'package:flutter/material.dart';
import '../../../../core/ui/system_state_widget.dart';
import '../widgets/legal/legal_widgets.dart';

/// PrivacyPolicyScreen - Screen for displaying the application's privacy policy
/// 
/// This screen provides users with comprehensive information about how their
/// personal data is collected, used, stored, and protected. It ensures compliance
/// with GDPR, KVKK, and other privacy regulations by presenting clear, accessible
/// legal information.
/// 
/// Features:
/// - Full privacy policy content display
/// - Optimized text rendering for long documents
/// - Material 3 design with proper theming
/// - Responsive layout for different screen sizes
/// - Error handling and loading states
/// - Accessibility-friendly text formatting
/// - Search-friendly content structure (future enhancement)
/// 
/// Compliance:
/// - GDPR (General Data Protection Regulation)
/// - KVKK (Turkish Personal Data Protection Law)
/// - Other applicable privacy regulations
class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    // Simulate loading content (in production, this might fetch from API or assets)
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Simulate network delay for demonstration
      await Future<void>.delayed(const Duration(milliseconds: 800));
      
      // In production, this would load content from:
      // - Local assets (markdown/HTML files)
      // - Remote API for dynamic updates
      // - Cached content with fallback
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        elevation: 0,
        title: Text(
          'Privacy Policy',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            fontFamily: 'Urbanist',
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Future enhancement: Search functionality
          IconButton(
            icon: Icon(
              Icons.search,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: () {
              // TODO: Implement search within document
              _showFeatureComingSoon('Search within document');
            },
          ),
          // Share functionality
          IconButton(
            icon: Icon(
              Icons.share,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: () {
              // TODO: Implement sharing functionality
              _showFeatureComingSoon('Share privacy policy');
            },
          ),
        ],
      ),
      body: _buildContent(context, theme, colorScheme),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading Privacy Policy...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontFamily: 'Urbanist',
              ),
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return SystemStateWidget(
        title: 'Failed to Load Privacy Policy',
        message: 'We couldn\'t load the privacy policy. Please check your connection and try again.',
        icon: Icons.policy_outlined,
        onRetry: _loadContent,
        retryText: 'Try Again',
      );
    }

    // Main content display
    return const PrivacyPolicyContent();
  }

  void _showFeatureComingSoon(String feature) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
