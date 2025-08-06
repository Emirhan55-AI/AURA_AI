import 'package:flutter/material.dart';

/// PrivacyPolicyContent - Widget for displaying the full privacy policy content
/// 
/// This widget is responsible for rendering the privacy policy text with proper
/// formatting and readability optimizations. It handles long-form text display
/// with appropriate styling, spacing, and responsive layout.
/// 
/// Features:
/// - Optimized text rendering for long documents
/// - Proper text styling following Material 3 guidelines
/// - Responsive layout with appropriate padding
/// - Prepared for future Markdown/HTML content integration
/// - Accessibility-friendly text formatting
class PrivacyPolicyContent extends StatelessWidget {
  const PrivacyPolicyContent({super.key});

  // Placeholder content for UI structure demonstration
  // In production, this would be replaced with actual privacy policy content
  // from a markdown file, API, or static asset
  static const String _placeholderContent = '''
# Privacy Policy

**Last Updated: January 2025**
**Version: 1.0**

## Introduction

Welcome to Aura, your personal style and wardrobe management application. We are committed to protecting your privacy and ensuring the security of your personal information. This Privacy Policy explains how we collect, use, store, and protect your data when you use our application.

## Information We Collect

### Personal Information
- Profile information (name, email, profile picture)
- Account credentials and authentication data
- Preferences and settings
- Communication preferences

### Wardrobe and Style Data
- Clothing items and wardrobe information
- Style preferences and recommendations
- Outfit combinations and history
- Shopping preferences and wishlists

### Usage Data
- App usage statistics and analytics
- Feature interaction data
- Performance and crash reports
- Device information and identifiers

### Location Data
- Approximate location for weather-based recommendations
- Location data for local shopping suggestions (with your consent)

## How We Use Your Information

We use your information to:

### Core Functionality
- Provide personalized style recommendations
- Manage your digital wardrobe
- Generate outfit suggestions based on weather and occasions
- Sync your data across devices

### Improvement and Analytics
- Analyze app usage to improve our services
- Develop new features and functionality
- Provide customer support and assistance
- Send important updates and notifications

### Personalization
- Customize your app experience
- Provide relevant content and recommendations
- Remember your preferences and settings

## Data Storage and Security

### Security Measures
- End-to-end encryption for sensitive data
- Secure cloud storage with industry-standard protocols
- Regular security audits and updates
- Multi-factor authentication support

### Data Retention
- Personal data is retained only as long as necessary
- You can request data deletion at any time
- Inactive accounts are automatically cleaned up
- Legal compliance data retention policies

## Your Rights and Choices

### Access and Control
- View and download your personal data
- Update or correct your information
- Delete your account and associated data
- Control data sharing preferences

### Privacy Settings
- Manage notification preferences
- Control data collection settings
- Opt-out of analytics and tracking
- Adjust location sharing permissions

### Legal Rights (GDPR/KVKK Compliance)
- Right to access your personal data
- Right to rectification of inaccurate data
- Right to erasure ("right to be forgotten")
- Right to restrict processing
- Right to data portability
- Right to object to processing

## Data Sharing and Third Parties

### Service Providers
We may share data with trusted service providers who assist us in:
- Cloud storage and infrastructure
- Analytics and performance monitoring
- Customer support services
- Payment processing (if applicable)

### Legal Requirements
We may disclose information when required by law or to:
- Comply with legal processes
- Protect our rights and property
- Ensure user safety and security
- Prevent fraud and abuse

### No Sale of Personal Data
We do not sell, rent, or trade your personal information to third parties for commercial purposes.

## International Data Transfers

- Data may be processed in different countries
- We ensure adequate protection through appropriate safeguards
- We comply with applicable data transfer regulations
- We maintain the same level of protection regardless of location

## Children's Privacy

- Our service is not intended for children under 13
- We do not knowingly collect data from children
- Parents can contact us to request deletion of child data
- We comply with applicable children's privacy laws

## Changes to This Policy

- We may update this policy from time to time
- Users will be notified of significant changes
- The latest version will always be available in the app
- Continued use constitutes acceptance of changes

## Contact Us

If you have questions about this Privacy Policy or your data rights:

**Email:** privacy@aura-app.com
**Address:** [Company Address]
**Data Protection Officer:** dpo@aura-app.com

For GDPR-related inquiries, you may also contact your local data protection authority.

## Cookie Policy

We use cookies and similar technologies to:
- Remember your preferences
- Analyze app usage
- Provide personalized content
- Improve app performance

You can manage cookie preferences in your device settings.

## Updates and Notifications

We will notify you of policy changes through:
- In-app notifications
- Email notifications
- App store update notes
- Website announcements

By using Aura, you acknowledge that you have read and understood this Privacy Policy and agree to the collection and use of your information as described herein.''';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Document header with version info
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.policy_outlined,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Privacy Policy',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Last Updated: January 2025 • Version 1.0',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontFamily: 'Urbanist',
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Main content area
          // TODO: Replace with Markdown renderer or HTML parser in future implementation
          // This structure is prepared for dynamic content integration
          Expanded(
            child: SingleChildScrollView(
              child: _buildFormattedContent(context, theme, colorScheme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormattedContent(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    // Split content into sections for better formatting
    final sections = _placeholderContent.split('\n\n');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.map((section) {
        if (section.trim().isEmpty) return const SizedBox.shrink();
        
        // Handle different content types
        if (section.startsWith('# ')) {
          // Main heading
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
            child: Text(
              section.substring(2),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                fontFamily: 'Urbanist',
                height: 1.3,
              ),
            ),
          );
        } else if (section.startsWith('## ')) {
          // Section heading
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0, top: 20.0),
            child: Text(
              section.substring(3),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
                fontFamily: 'Urbanist',
                height: 1.3,
              ),
            ),
          );
        } else if (section.startsWith('### ')) {
          // Subsection heading
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
            child: Text(
              section.substring(4),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
                fontFamily: 'Urbanist',
                height: 1.3,
              ),
            ),
          );
        } else if (section.startsWith('**') && section.endsWith('**')) {
          // Bold text
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              section.substring(2, section.length - 2),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
                fontFamily: 'Urbanist',
                height: 1.5,
              ),
            ),
          );
        } else if (section.startsWith('- ')) {
          // List item
          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0, left: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontFamily: 'Urbanist',
                    height: 1.5,
                  ),
                ),
                Expanded(
                  child: Text(
                    section.substring(2),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontFamily: 'Urbanist',
                      height: 1.5,
                    ),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          );
        } else {
          // Regular paragraph text
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              section,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontFamily: 'Urbanist',
                height: 1.6,
              ),
              textAlign: TextAlign.justify,
              softWrap: true,
            ),
          );
        }
      }).toList(),
    );
  }
}
