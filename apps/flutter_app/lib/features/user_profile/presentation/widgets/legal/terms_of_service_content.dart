import 'package:flutter/material.dart';

/// TermsOfServiceContent - Widget for displaying the full terms of service content
/// 
/// This widget is responsible for rendering the terms of service text with proper
/// formatting and readability optimizations. It handles long-form legal text display
/// with appropriate styling, spacing, and responsive layout.
/// 
/// Features:
/// - Optimized text rendering for long legal documents
/// - Proper text styling following Material 3 guidelines
/// - Responsive layout with appropriate padding
/// - Prepared for future Markdown/HTML content integration
/// - Accessibility-friendly text formatting
/// - Legal document structure with numbered sections
class TermsOfServiceContent extends StatelessWidget {
  const TermsOfServiceContent({super.key});

  // Placeholder content for UI structure demonstration
  // In production, this would be replaced with actual terms of service content
  // from a markdown file, API, or static asset
  static const String _placeholderContent = '''
# Terms of Service

**Last Updated: January 2025**
**Version: 1.0**

## 1. Acceptance of Terms

By downloading, installing, or using the Aura application ("the App"), you agree to be bound by these Terms of Service ("Terms"). These Terms constitute a legally binding agreement between you ("User" or "you") and Aura ("we," "us," or "our").

If you do not agree to these Terms, please do not use the App.

## 2. Description of Service

Aura is a personal style and wardrobe management application that provides:

### Core Features
- Digital wardrobe management and organization
- Personal style recommendations and suggestions
- Outfit planning and coordination tools
- Weather-based clothing recommendations
- Social sharing and style inspiration features

### Additional Services
- Style analytics and insights
- Shopping recommendations and wishlists
- Calendar integration for outfit planning
- Social networking features with other users

## 3. User Obligations and Responsibilities

### Account Registration
- You must provide accurate and complete information
- You are responsible for maintaining account security
- You must notify us of any unauthorized account access
- One account per person is permitted

### Acceptable Use
You agree to use the App only for its intended purposes and will not:
- Violate any applicable laws or regulations
- Infringe on intellectual property rights
- Upload harmful, offensive, or inappropriate content
- Attempt to reverse engineer or hack the App
- Use the App for commercial purposes without permission
- Create fake accounts or impersonate others

### Content Guidelines
- All uploaded content must be your own or properly licensed
- Content must be appropriate and family-friendly
- We reserve the right to remove any inappropriate content
- You retain ownership of your uploaded content

## 4. Intellectual Property Rights

### Our Rights
- The App and its content are protected by copyright and trademark laws
- We own all rights to the App's design, features, and functionality
- Our trademarks and logos may not be used without permission
- The underlying technology and algorithms are proprietary

### Your Rights
- You retain ownership of content you upload
- You grant us a limited license to use your content for service provision
- You can delete your content at any time
- We respect your intellectual property rights

### Third-Party Content
- Some features may incorporate third-party content or services
- Third-party content is subject to separate terms and licenses
- We are not responsible for third-party content accuracy

## 5. Privacy and Data Protection

### Data Collection
- We collect data as described in our Privacy Policy
- Your privacy is important to us
- We comply with applicable data protection laws
- We use industry-standard security measures

### Data Usage
- Data is used to provide and improve our services
- We do not sell personal data to third parties
- You can control your privacy settings
- You can request data deletion at any time

## 6. Subscription and Payment Terms

### Free Services
- Basic App features are provided free of charge
- Free features may have usage limitations
- We reserve the right to modify free service offerings

### Premium Services
- Premium features may require subscription payment
- Subscription fees are charged in advance
- Subscriptions auto-renew unless cancelled
- Refunds are subject to our refund policy

### Payment Processing
- Payments are processed through secure third-party providers
- We do not store payment card information
- All transactions are encrypted and secure

## 7. Service Availability and Modifications

### Service Availability
- We strive to provide continuous service availability
- Scheduled maintenance may cause temporary interruptions
- We are not liable for service interruptions beyond our control

### Modifications
- We may modify the App and these Terms at any time
- Significant changes will be communicated to users
- Continued use constitutes acceptance of modifications
- We may discontinue features or the entire service

## 8. User-Generated Content and Social Features

### Content Responsibility
- You are solely responsible for content you share
- Content must comply with community guidelines
- We may monitor and moderate user content
- Violations may result in account suspension

### Social Interactions
- Respect other users and their opinions
- Do not engage in harassment or bullying
- Report inappropriate behavior to our moderation team
- We reserve the right to remove users who violate guidelines

## 9. Limitation of Liability

### Service Disclaimers
- The App is provided "as is" without warranties
- We do not guarantee uninterrupted or error-free service
- Style recommendations are suggestions, not professional advice
- Results may vary based on individual preferences

### Liability Limits
- Our liability is limited to the maximum extent permitted by law
- We are not liable for indirect, incidental, or consequential damages
- Total liability will not exceed the amount paid for premium services
- Some jurisdictions may not allow liability limitations

## 10. Termination

### User Termination
- You may terminate your account at any time
- Account deletion will remove your data from our systems
- Some data may be retained for legal compliance purposes

### Our Termination Rights
We may terminate or suspend accounts for:
- Violation of these Terms
- Illegal or harmful activity
- Extended periods of inactivity
- Technical or security reasons

### Effect of Termination
- Access to the App will be immediately revoked
- Premium subscriptions will be cancelled
- User data will be deleted according to our retention policy

## 11. Dispute Resolution

### Governing Law
- These Terms are governed by [Applicable Jurisdiction] law
- Disputes will be resolved in [Applicable Jurisdiction] courts
- We comply with local consumer protection laws

### Arbitration
- Disputes may be subject to binding arbitration
- Class action lawsuits are waived where permitted
- Small claims court remains available for appropriate disputes

## 12. Miscellaneous Provisions

### Entire Agreement
- These Terms constitute the complete agreement between parties
- They supersede all previous agreements and understandings
- Modifications must be in writing and agreed to by both parties

### Severability
- If any provision is found invalid, the remainder remains in effect
- Invalid provisions will be interpreted to be enforceable to the maximum extent

### Assignment
- We may assign these Terms to third parties
- You may not assign your rights without our consent
- Assignment does not relieve parties of existing obligations

### Force Majeure
- We are not liable for delays due to circumstances beyond our control
- This includes natural disasters, government actions, or technical failures

## 13. Contact Information

For questions about these Terms of Service:

**Email:** legal@aura-app.com
**Address:** [Company Address]
**Support:** support@aura-app.com

For urgent legal matters, please contact our legal department directly.

## 14. Updates and Effective Date

These Terms are effective as of the date posted. We will notify users of material changes through:
- In-app notifications
- Email notifications
- Website announcements
- App store update notes

By continuing to use Aura after changes are posted, you accept the updated Terms.

**Thank you for using Aura!**''';

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
                      Icons.description_outlined,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Terms of Service',
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
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Text(
                    'Legally Binding Agreement',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Urbanist',
                    ),
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
          // Section heading with numbering
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0, top: 24.0),
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: Text(
                section.substring(3),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  fontFamily: 'Urbanist',
                  height: 1.3,
                ),
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
                color: colorScheme.primary,
                fontFamily: 'Urbanist',
                height: 1.3,
              ),
            ),
          );
        } else if (section.startsWith('**') && section.endsWith('**')) {
          // Bold text (version info, important notices)
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
