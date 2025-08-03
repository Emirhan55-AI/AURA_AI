import 'package:flutter/material.dart';
import '../controllers/user_profile_controller.dart';

/// Profile Header Widget - Displays user's avatar, name, username, and bio
/// 
/// Shows the main user information at the top of the profile screen including:
/// - Circular avatar (with placeholder if no image provided)
/// - Display name and username
/// - Bio/description text
/// - Edit profile button
class ProfileHeader extends StatelessWidget {
  final UserProfileData user;
  final VoidCallback onEditProfile;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Avatar section
          _buildAvatar(colorScheme),
          const SizedBox(height: 20),

          // Name and username section
          _buildNameSection(theme, colorScheme),
          const SizedBox(height: 16),

          // Bio section
          if (user.bio.isNotEmpty) ...[
            _buildBioSection(theme, colorScheme),
            const SizedBox(height: 20),
          ],

          // Edit profile button
          _buildEditButton(theme, colorScheme),
        ],
      ),
    );
  }

  /// Builds the user avatar with gradient border
  Widget _buildAvatar(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.surface,
        ),
        child: ClipOval(
          child: user.avatarUrl != null
              ? Image.network(
                  user.avatarUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildAvatarPlaceholder(colorScheme),
                )
              : _buildAvatarPlaceholder(colorScheme),
        ),
      ),
    );
  }

  /// Builds avatar placeholder when no image is available
  Widget _buildAvatarPlaceholder(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.person,
        size: 48,
        color: colorScheme.onPrimaryContainer,
      ),
    );
  }

  /// Builds the name and username section
  Widget _buildNameSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        // Display name
        Text(
          user.displayName,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
            fontFamily: 'Urbanist',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),

        // Username
        Text(
          user.username,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Builds the bio section
  Widget _buildBioSection(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        user.bio,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Builds the edit profile button
  Widget _buildEditButton(ThemeData theme, ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onEditProfile,
        icon: Icon(
          Icons.edit_outlined,
          size: 18,
          color: colorScheme.onSurface,
        ),
        label: Text(
          'Edit Profile',
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: colorScheme.outline,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
