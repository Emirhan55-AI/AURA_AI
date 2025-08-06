import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/app_version_service.dart';
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
      await Future<void>.delayed(const Duration(milliseconds: 2000));

      // Initialize and validate authentication token
      await ref.read(authControllerProvider.notifier).validateToken();
      
      // Get authentication state
      final authState = ref.read(authControllerProvider);

      if (!mounted) return;

      // Temporary: Skip onboarding and go directly to login screen
      authState.when(
        data: (user) {
          if (user != null) {
            // User is authenticated - go to main app
            context.go('/main');
          } else {
            // User is not authenticated - go directly to login
            context.go('/auth/login');
          }
        },
        loading: () {
          // Still loading - stay on splash screen
          debugPrint('Authentication state still loading...');
        },
        error: (error, stack) {
          debugPrint('Authentication error: $error');
          // Error - treat as unauthenticated and go to login
          context.go('/auth/login');
        },
      );
      
    } catch (error) {
      debugPrint('Splash screen initialization error: $error');
      if (mounted) {
        // Any error - go directly to login screen
        context.go('/auth/login');
      }
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
    
    // Temporary: Skip onboarding status check
    const hasSeenOnboarding = true; // Force skip onboarding
    
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
