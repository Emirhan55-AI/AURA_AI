import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/app_version_service.dart';
import '../services/loading_state_service.dart';
import '../services/error_handling_service.dart';
import '../services/preferences_service.dart';
import '../../features/authentication/presentation/controllers/auth_controller.dart';
import '../../features/authentication/domain/entities/user.dart';

part 'app_state_controller.g.dart';

/// Global app state controller that manages application-wide state
/// Coordinates between authentication, loading, errors, and app lifecycle
@riverpod
class AppState extends _$AppState {
  @override
  AppStateData build() {
    // Watch dependencies for automatic updates
    ref.listen(authControllerProvider, (previous, next) {
      _handleAuthStateChange(previous, next);
    });
    
    ref.listen(loadingStateProvider, (previous, next) {
      _handleLoadingStateChange(previous, next);
    });
    
    ref.listen(errorStateProvider, (previous, next) {
      _handleErrorStateChange(previous, next);
    });
    
    return const AppStateData();
  }

  /// Handle authentication state changes
  void _handleAuthStateChange(
    AsyncValue<User?>? previous,
    AsyncValue<User?> next,
  ) {
    next.when(
      data: (user) {
        if (user != null) {
          // User authenticated - initialize user-specific state
          _initializeUserState(user);
        } else {
          // User logged out - clean up state
          _cleanupUserState();
        }
      },
      loading: () {
        // Auth is loading
        ref.read(loadingStateProvider.notifier).startLoading(
          LoadingContexts.authentication,
          message: 'Authenticating...',
        );
      },
      error: (error, _) {
        // Auth error
        ref.read(loadingStateProvider.notifier).stopLoading(
          LoadingContexts.authentication,
        );
        ref.read(errorStateProvider.notifier).handleError(
          error,
          context: ErrorContexts.authentication,
        );
      },
    );
  }

  /// Handle loading state changes
  void _handleLoadingStateChange(
    LoadingStateSummary? previous,
    LoadingStateSummary next,
  ) {
    // Update app state based on loading changes
    state = state.copyWith(
      isLoading: next.isAnyLoading,
      loadingMessage: next.messages.values.isNotEmpty 
          ? next.messages.values.first 
          : null,
    );
  }

  /// Handle error state changes
  void _handleErrorStateChange(
    Map<String, AppError>? previous,
    Map<String, AppError> next,
  ) {
    // Update app state based on error changes
    final hasErrors = next.isNotEmpty;
    final currentError = hasErrors ? next.values.first : null;
    
    state = state.copyWith(
      hasError: hasErrors,
      currentError: currentError,
    );
  }

  /// Initialize user-specific state after authentication
  void _initializeUserState(User user) {
    ref.read(loadingStateProvider.notifier).stopLoading(
      LoadingContexts.authentication,
    );
    
    state = state.copyWith(
      isAuthenticated: true,
      currentUser: user,
    );
  }

  /// Clean up state when user logs out
  void _cleanupUserState() {
    // Clear all loading states
    ref.read(loadingStateProvider.notifier).clearAll();
    
    // Clear all errors
    ref.read(errorStateProvider.notifier).clearAllErrors();
    
    // Reset app state
    state = state.copyWith(
      isAuthenticated: false,
      currentUser: null,
      hasError: false,
      currentError: null,
      isLoading: false,
      loadingMessage: null,
    );
  }

  /// Initialize the application
  Future<void> initializeApp() async {
    try {
      // Start app initialization loading
      ref.read(loadingStateProvider.notifier).startLoading(
        LoadingContexts.appInitialization,
        message: 'Initializing app...',
      );

      // Initialize preferences service (auto-initialized by provider)
      ref.read(preferencesServiceProvider);
      
      // Check app version
      final versionInfo = await ref.read(currentAppVersionProvider.future);
      final needsUpdate = await ref.read(appNeedsUpdateProvider.future);
      
      // Update state with initialization results
      state = state.copyWith(
        isInitialized: true,
        appVersion: versionInfo,
        needsUpdate: needsUpdate,
      );

      // Stop initialization loading
      ref.read(loadingStateProvider.notifier).stopLoading(
        LoadingContexts.appInitialization,
      );

    } catch (error) {
      // Handle initialization error
      ref.read(loadingStateProvider.notifier).stopLoading(
        LoadingContexts.appInitialization,
      );
      
      ref.read(errorStateProvider.notifier).handleError(
        error,
        context: ErrorContexts.appInitialization,
        severity: ErrorSeverity.critical,
      );
    }
  }

  /// Show a global message (success, info, etc.)
  void showMessage(String message, {MessageType type = MessageType.info}) {
    state = state.copyWith(
      message: AppMessage(
        text: message,
        type: type,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Clear the current message
  void clearMessage() {
    state = state.copyWith(message: null);
  }

  /// Handle app lifecycle changes
  void handleAppLifecycleChange(AppLifecycleState lifecycleState) {
    state = state.copyWith(appLifecycleState: lifecycleState);
    
    switch (lifecycleState) {
      case AppLifecycleState.resumed:
        // App resumed - check for updates, sync data, etc.
        _handleAppResumed();
        break;
      case AppLifecycleState.paused:
        // App paused - save state, pause operations
        _handleAppPaused();
        break;
      case AppLifecycleState.detached:
        // App closing - cleanup
        _handleAppDetached();
        break;
      case AppLifecycleState.inactive:
        // App inactive - reduce operations
        break;
      case AppLifecycleState.hidden:
        // App hidden
        break;
    }
  }

  /// Handle app resuming from background
  void _handleAppResumed() {
    // Validate authentication token
    ref.read(authControllerProvider.notifier).validateToken();
    
    // Check for app updates
    ref.invalidate(appNeedsUpdateProvider);
  }

  /// Handle app going to background
  void _handleAppPaused() {
    // Save any pending state
    // This is a good place to persist important data
  }

  /// Handle app being closed/detached
  void _handleAppDetached() {
    // Final cleanup before app closes
    ref.read(loadingStateProvider.notifier).clearAll();
    ref.read(errorStateProvider.notifier).clearAllErrors();
  }
}

/// App state data model
class AppStateData {
  final bool isInitialized;
  final bool isAuthenticated;
  final User? currentUser;
  final bool isLoading;
  final String? loadingMessage;
  final bool hasError;
  final AppError? currentError;
  final AppMessage? message;
  final AppVersionInfo? appVersion;
  final bool needsUpdate;
  final AppLifecycleState? appLifecycleState;

  const AppStateData({
    this.isInitialized = false,
    this.isAuthenticated = false,
    this.currentUser,
    this.isLoading = false,
    this.loadingMessage,
    this.hasError = false,
    this.currentError,
    this.message,
    this.appVersion,
    this.needsUpdate = false,
    this.appLifecycleState,
  });

  AppStateData copyWith({
    bool? isInitialized,
    bool? isAuthenticated,
    User? currentUser,
    bool? isLoading,
    String? loadingMessage,
    bool? hasError,
    AppError? currentError,
    AppMessage? message,
    AppVersionInfo? appVersion,
    bool? needsUpdate,
    AppLifecycleState? appLifecycleState,
  }) {
    return AppStateData(
      isInitialized: isInitialized ?? this.isInitialized,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      currentUser: currentUser ?? this.currentUser,
      isLoading: isLoading ?? this.isLoading,
      loadingMessage: loadingMessage ?? this.loadingMessage,
      hasError: hasError ?? this.hasError,
      currentError: currentError ?? this.currentError,
      message: message ?? this.message,
      appVersion: appVersion ?? this.appVersion,
      needsUpdate: needsUpdate ?? this.needsUpdate,
      appLifecycleState: appLifecycleState ?? this.appLifecycleState,
    );
  }

  @override
  String toString() {
    return 'AppStateData(isInitialized: $isInitialized, isAuthenticated: $isAuthenticated, isLoading: $isLoading, hasError: $hasError)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is AppStateData &&
      other.isInitialized == isInitialized &&
      other.isAuthenticated == isAuthenticated &&
      other.currentUser == currentUser &&
      other.isLoading == isLoading &&
      other.hasError == hasError;
  }

  @override
  int get hashCode {
    return isInitialized.hashCode ^
      isAuthenticated.hashCode ^
      currentUser.hashCode ^
      isLoading.hashCode ^
      hasError.hashCode;
  }
}

/// App message model for global notifications
class AppMessage {
  final String text;
  final MessageType type;
  final DateTime timestamp;

  const AppMessage({
    required this.text,
    required this.type,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'AppMessage(text: $text, type: $type, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is AppMessage &&
      other.text == text &&
      other.type == type &&
      other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return text.hashCode ^ type.hashCode ^ timestamp.hashCode;
  }
}

/// Message types for app notifications
enum MessageType {
  info,
  success,
  warning,
  error
}

/// Provider for checking if app is initialized
@riverpod
bool isAppInitialized(IsAppInitializedRef ref) {
  final appState = ref.watch(appStateProvider);
  return appState.isInitialized;
}

/// Provider for checking if user is authenticated
@riverpod
bool isUserAuthenticated(IsUserAuthenticatedRef ref) {
  final appState = ref.watch(appStateProvider);
  return appState.isAuthenticated;
}

/// Provider for checking if app has any loading states
@riverpod
bool isAppLoading(IsAppLoadingRef ref) {
  final appState = ref.watch(appStateProvider);
  return appState.isLoading;
}

/// Provider for checking if app has any errors
@riverpod
bool hasAppError(HasAppErrorRef ref) {
  final appState = ref.watch(appStateProvider);
  return appState.hasError;
}

/// Provider for current app message
@riverpod
AppMessage? currentAppMessage(CurrentAppMessageRef ref) {
  final appState = ref.watch(appStateProvider);
  return appState.message;
}
