import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'loading_state_service.g.dart';

/// Service for managing global loading states across the application
/// Provides centralized loading state management with multiple loading contexts
class LoadingStateService {
  final Map<String, bool> _loadingStates = {};
  final Map<String, String> _loadingMessages = {};

  /// Check if any loading operation is active
  bool get isAnyLoading => _loadingStates.values.any((isLoading) => isLoading);

  /// Check if specific context is loading
  bool isLoading(String context) => _loadingStates[context] ?? false;

  /// Get loading message for specific context
  String? getLoadingMessage(String context) => _loadingMessages[context];

  /// Get all active loading contexts
  List<String> get activeLoadingContexts {
    return _loadingStates.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  /// Start loading for specific context
  void startLoading(String context, {String? message}) {
    _loadingStates[context] = true;
    if (message != null) {
      _loadingMessages[context] = message;
    }
    _notifyListeners();
    debugPrint('Loading started: $context ${message != null ? '- $message' : ''}');
  }

  /// Stop loading for specific context
  void stopLoading(String context) {
    _loadingStates[context] = false;
    _loadingMessages.remove(context);
    _notifyListeners();
    debugPrint('Loading stopped: $context');
  }

  /// Clear all loading states
  void clearAll() {
    _loadingStates.clear();
    _loadingMessages.clear();
    _notifyListeners();
    debugPrint('All loading states cleared');
  }

  /// Update loading message for active context
  void updateLoadingMessage(String context, String message) {
    if (isLoading(context)) {
      _loadingMessages[context] = message;
      _notifyListeners();
    }
  }

  /// Get current loading state summary
  LoadingStateSummary get summary {
    return LoadingStateSummary(
      isAnyLoading: isAnyLoading,
      activeContexts: activeLoadingContexts,
      messages: Map.from(_loadingMessages),
    );
  }

  // Placeholder for listener notification - will be implemented with proper state management
  void _notifyListeners() {
    // This will be connected to Riverpod state updates
  }
}

/// Summary of current loading states
class LoadingStateSummary {
  final bool isAnyLoading;
  final List<String> activeContexts;
  final Map<String, String> messages;

  const LoadingStateSummary({
    required this.isAnyLoading,
    required this.activeContexts,
    required this.messages,
  });

  @override
  String toString() {
    return 'LoadingStateSummary(isAnyLoading: $isAnyLoading, activeContexts: $activeContexts, messages: $messages)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is LoadingStateSummary &&
      other.isAnyLoading == isAnyLoading &&
      listEquals(other.activeContexts, activeContexts) &&
      mapEquals(other.messages, messages);
  }

  @override
  int get hashCode {
    return isAnyLoading.hashCode ^
      activeContexts.hashCode ^
    messages.hashCode;
  }
}

/// Predefined loading contexts for common operations
class LoadingContexts {
  static const String authentication = 'authentication';
  static const String userProfile = 'user_profile';
  static const String wardrobe = 'wardrobe';
  static const String styleAnalysis = 'style_analysis';
  static const String socialFeed = 'social_feed';
  static const String fileUpload = 'file_upload';
  static const String dataSync = 'data_sync';
  static const String onboarding = 'onboarding';
  static const String settings = 'settings';
  static const String appInitialization = 'app_initialization';
  
  /// Get all predefined contexts
  static List<String> get all => [
    authentication,
    userProfile,
    wardrobe,
    styleAnalysis,
    socialFeed,
    fileUpload,
    dataSync,
    onboarding,
    settings,
    appInitialization,
  ];
}

/// Provider for LoadingStateService instance
@riverpod
LoadingStateService loadingStateService(LoadingStateServiceRef ref) {
  return LoadingStateService();
}

/// Provider for global loading state
@riverpod
class LoadingState extends _$LoadingState {
  @override
  LoadingStateSummary build() {
    final service = ref.read(loadingStateServiceProvider);
    return service.summary;
  }

  /// Start loading for specific context
  void startLoading(String context, {String? message}) {
    final service = ref.read(loadingStateServiceProvider);
    service.startLoading(context, message: message);
    ref.invalidateSelf();
  }

  /// Stop loading for specific context
  void stopLoading(String context) {
    final service = ref.read(loadingStateServiceProvider);
    service.stopLoading(context);
    ref.invalidateSelf();
  }

  /// Clear all loading states
  void clearAll() {
    final service = ref.read(loadingStateServiceProvider);
    service.clearAll();
    ref.invalidateSelf();
  }

  /// Update loading message
  void updateMessage(String context, String message) {
    final service = ref.read(loadingStateServiceProvider);
    service.updateLoadingMessage(context, message);
    ref.invalidateSelf();
  }
}

/// Provider for checking if any loading is active
@riverpod
bool isAnyLoading(IsAnyLoadingRef ref) {
  final loadingState = ref.watch(loadingStateProvider);
  return loadingState.isAnyLoading;
}

/// Provider for checking if specific context is loading
@riverpod
bool isContextLoading(IsContextLoadingRef ref, String context) {
  final service = ref.watch(loadingStateServiceProvider);
  return service.isLoading(context);
}
