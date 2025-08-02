import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' show Random;

// Import core components
import '../../../../core/ui/error_view.dart';
import '../../../../core/error/app_exception.dart';

/// Splash screen for the Aura application
/// Handles initial app loading, token validation, and routing decisions
/// Provides visual feedback during the loading process
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  Exception? _currentError;
  late AnimationController _logoAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    
    // Start the authentication check after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTokenAndNavigate();
    });
  }

  void _setupAnimations() {
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    // Start the logo animation
    _logoAnimationController.forward();
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (!_isLoading && _currentError != null) {
      // Show error state
      return Scaffold(
        body: ErrorView(
          error: _currentError!,
          onRetry: _retryTokenCheck,
          isRetrying: _isLoading,
          retryText: 'Try Again',
        ),
      );
    }

    // Show loading state with animated logo
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Aura Logo
              AnimatedBuilder(
                animation: _logoAnimationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScaleAnimation.value,
                    child: Opacity(
                      opacity: _logoOpacityAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colorScheme.primary,
                              colorScheme.secondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          size: 60,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // App Name
              AnimatedBuilder(
                animation: _logoOpacityAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoOpacityAnimation.value,
                    child: Text(
                      'Aura',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),

              // Tagline
              AnimatedBuilder(
                animation: _logoOpacityAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoOpacityAnimation.value * 0.7,
                    child: Text(
                      'AI Code Generation Factory',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 48),

              // Loading Indicator
              if (_isLoading) ...[
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Setting up your experience...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Simulates token validation and determines the next navigation route
  /// Handles three scenarios: valid token (home), invalid token (login/onboarding), and errors
  Future<void> _checkTokenAndNavigate() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _currentError = null;
    });

    try {
      // Simulate network delay for realistic loading experience
      await Future.delayed(const Duration(seconds: 2));

      // Simulate potential network error (10% chance)
      if (_shouldSimulateError()) {
        throw NetworkException(
          message: 'Unable to connect to authentication servers. Please check your internet connection.',
          code: 'AUTH_NETWORK_ERROR',
        );
      }

      // Simulate token validation
      final bool isTokenValid = _simulateTokenValidation();
      
      if (!mounted) return;

      if (isTokenValid) {
        // Token is valid, user is authenticated - go to home
        _navigateToRoute('/home');
      } else {
        // Token is invalid or missing
        // Check if user has seen onboarding before
        final bool hasSeenOnboarding = _simulateOnboardingCheck();
        
        if (hasSeenOnboarding) {
          // User has seen onboarding before - go to login
          _navigateToRoute('/login');
        } else {
          // First time user - go to onboarding
          _navigateToRoute('/onboarding');
        }
      }
    } catch (error) {
      if (!mounted) return;
      
      // Handle errors by showing error state
      setState(() {
        _isLoading = false;
        _currentError = error is Exception ? error : Exception(error.toString());
      });
    }
  }

  /// Handles retry functionality when an error occurs
  void _retryTokenCheck() {
    _checkTokenAndNavigate();
  }

  /// Navigates to the specified route using GoRouter
  void _navigateToRoute(String route) {
    if (!mounted) return;
    
    setState(() {
      _isLoading = false;
    });

    // Use GoRouter for navigation
    context.go(route);
  }

  /// Simulates whether a network error should occur (10% chance)
  bool _shouldSimulateError() {
    return Random().nextInt(10) == 0; // 10% chance of error
  }

  /// Simulates token validation logic
  /// Returns true if token is valid (70% chance), false otherwise
  bool _simulateTokenValidation() {
    // Simulate 70% chance of valid token
    return Random().nextInt(10) < 7;
  }

  /// Simulates checking if user has completed onboarding
  /// Returns true if user has seen onboarding (80% chance), false otherwise
  bool _simulateOnboardingCheck() {
    // Simulate 80% chance that user has seen onboarding
    return Random().nextInt(10) < 8;
  }
}
