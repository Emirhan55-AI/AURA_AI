import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/app_version_service.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';

/// Splash screen that handles app initialization
/// Performs authentication check, version validation, and determines initial route
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Start with minimum splash duration
      await Future.delayed(const Duration(milliseconds: 1500));

      // Validate stored authentication token
      await ref.read(authControllerProvider.notifier).validateToken();

      // Check app version and updates
      final versionInfo = await ref.read(currentAppVersionProvider.future);
      final needsUpdate = await ref.read(appNeedsUpdateProvider.future);

      // Log version information (for debugging)
      debugPrint('App Version: ${versionInfo.version} (${versionInfo.buildNumber})');
      debugPrint('Needs Update: $needsUpdate');

      // Initialize preferences service if needed
      final preferencesService = ref.read(preferencesServiceProvider);
      await preferencesService.getHasSeenOnboarding();

      // Navigation will be handled by the router based on auth state
      // Splash screen has completed its initialization tasks
      
    } catch (error) {
      debugPrint('Splash screen initialization error: $error');
      // Continue anyway - errors will be handled by the main router
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
            ),
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Logo
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          size: 60,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // App Name
                      Text(
                        'Aura',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // App Tagline
                      Text(
                        'Your Personal Style Assistant',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onPrimary.withOpacity(0.8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 48),
                      
                      // Loading Indicator
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Provider for splash screen initialization state
final splashInitializationProvider = FutureProvider<SplashInitResult>((ref) async {
  try {
    // Validate authentication token
    await ref.read(authControllerProvider.notifier).validateToken();
    
    // Get version information
    final versionInfo = await ref.read(currentAppVersionProvider.future);
    
    // Check for updates
    final needsUpdate = await ref.read(appNeedsUpdateProvider.future);
    
    // Check onboarding status
    final preferencesService = ref.read(preferencesServiceProvider);
    final hasSeenOnboarding = await preferencesService.getHasSeenOnboarding();
    
    return SplashInitResult(
      versionInfo: versionInfo,
      needsUpdate: needsUpdate,
      hasSeenOnboarding: hasSeenOnboarding,
      isAuthenticated: ref.read(authControllerProvider).value != null,
    );
  } catch (error) {
    throw SplashInitializationException('Failed to initialize app: $error');
  }
});

/// Result of splash screen initialization
class SplashInitResult {
  final AppVersionInfo versionInfo;
  final bool needsUpdate;
  final bool hasSeenOnboarding;
  final bool isAuthenticated;

  const SplashInitResult({
    required this.versionInfo,
    required this.needsUpdate,
    required this.hasSeenOnboarding,
    required this.isAuthenticated,
  });

  @override
  String toString() {
    return 'SplashInitResult(versionInfo: $versionInfo, needsUpdate: $needsUpdate, hasSeenOnboarding: $hasSeenOnboarding, isAuthenticated: $isAuthenticated)';
  }
}

/// Exception thrown during splash screen initialization
class SplashInitializationException implements Exception {
  final String message;
  
  const SplashInitializationException(this.message);
  
  @override
  String toString() => 'SplashInitializationException: $message';
}
