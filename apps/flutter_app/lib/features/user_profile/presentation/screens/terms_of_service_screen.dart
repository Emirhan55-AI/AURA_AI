import 'package:flutter/material.dart';
import '../../../../core/ui/system_state_widget.dart';
import '../widgets/legal/legal_widgets.dart';

/// TermsOfServiceScreen - Screen for displaying the application's terms of service
/// 
/// This screen provides users with comprehensive information about the legal
/// agreement between users and the application. It outlines user rights,
/// responsibilities, service limitations, and legal obligations to ensure
/// proper usage of the application.
/// 
/// Features:
/// - Full terms of service content display
/// - Optimized text rendering for long legal documents
/// - Material 3 design with proper theming
/// - Responsive layout for different screen sizes
/// - Error handling and loading states
/// - Accessibility-friendly text formatting
/// - Numbered sections for easy reference
/// - Search-friendly content structure (future enhancement)
/// 
/// Legal Coverage:
/// - User obligations and acceptable use policies
/// - Intellectual property rights and licensing
/// - Service availability and modifications
/// - Payment terms and subscription policies
/// - Privacy and data protection references
/// - Limitation of liability and disclaimers
/// - Termination conditions and procedures
/// - Dispute resolution and governing law
class TermsOfServiceScreen extends StatefulWidget {
  const TermsOfServiceScreen({super.key});

  @override
  State<TermsOfServiceScreen> createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
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
      // - Version-controlled legal documents
      
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
          'Terms of Service',
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
              _showFeatureComingSoon('Share terms of service');
            },
          ),
          // More options menu
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: colorScheme.onSurfaceVariant,
            ),
            onSelected: (value) {
              switch (value) {
                case 'print':
                  _showFeatureComingSoon('Print document');
                  break;
                case 'save':
                  _showFeatureComingSoon('Save offline');
                  break;
                case 'translate':
                  _showFeatureComingSoon('Translate document');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'print',
                child: Row(
                  children: [
                    Icon(Icons.print),
                    SizedBox(width: 12),
                    Text('Print'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'save',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 12),
                    Text('Save Offline'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'translate',
                child: Row(
                  children: [
                    Icon(Icons.translate),
                    SizedBox(width: 12),
                    Text('Translate'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildContent(context, theme, colorScheme),
      // Floating action button for quick actions
      floatingActionButton: _hasError || _isLoading
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                _showAcceptanceDialog(context, theme, colorScheme);
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('I Accept'),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
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
              'Loading Terms of Service...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontFamily: 'Urbanist',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we fetch the latest version',
              style: theme.textTheme.bodySmall?.copyWith(
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
        title: 'Failed to Load Terms of Service',
        message: 'We couldn\'t load the terms of service. This might be due to a network issue or the document being temporarily unavailable.',
        icon: Icons.description_outlined,
        onRetry: _loadContent,
        retryText: 'Try Again',
      );
    }

    // Main content display
    return const TermsOfServiceContent();
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

  void _showAcceptanceDialog(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 12),
            const Text('Accept Terms'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'By accepting these Terms of Service, you confirm that:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'Urbanist',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '• You have read and understood all terms\n'
              '• You agree to be legally bound by these terms\n'
              '• You are of legal age to enter this agreement\n'
              '• You will use the app in accordance with these terms',
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'Urbanist',
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showFeatureComingSoon('Terms acceptance tracking');
            },
            child: const Text('I Accept'),
          ),
        ],
      ),
    );
  }
}
