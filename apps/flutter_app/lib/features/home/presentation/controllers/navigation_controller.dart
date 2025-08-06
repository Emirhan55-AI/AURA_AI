import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for managing bottom navigation state
/// Simple StateProvider for tracking selected tab index
final navigationStateProvider = StateProvider<int>((ref) => 0);

/// Enhanced Navigation controller for handling tab operations
class NavigationController {
  final Ref ref;
  
  NavigationController(this.ref);

  /// Select specific tab by index
  void selectTab(int index) {
    if (index >= 0 && index < 5) { // 5 tabs total
      ref.read(navigationStateProvider.notifier).state = index;
    }
  }

  /// Reset to home tab (index 0)
  void resetToHome() {
    ref.read(navigationStateProvider.notifier).state = 0;
  }

  /// Navigate to Dashboard tab (alias for resetToHome)
  void goToDashboard() {
    resetToHome();
  }

  /// Navigate to wardrobe tab
  void goToWardrobe() {
    selectTab(1);
  }

  /// Navigate to style assistant tab
  void goToStyleAssistant() {
    selectTab(2);
  }

  /// Navigate to social tab (renamed from inspire me)
  void goToSocial() {
    selectTab(3);
  }

  /// Navigate to inspire me tab (legacy alias for social)
  void goToInspireMe() {
    selectTab(3);
  }

  /// Navigate to profile tab
  void goToProfile() {
    selectTab(4);
  }

  /// Get current tab index
  int currentTab() => ref.read(navigationStateProvider);

  /// Check if currently on home tab
  bool isOnHome() => ref.read(navigationStateProvider) == 0;

  /// Check if currently on wardrobe tab
  bool isOnWardrobe() => ref.read(navigationStateProvider) == 1;

  /// Check if currently on style assistant tab
  bool isOnStyleAssistant() => ref.read(navigationStateProvider) == 2;

  /// Check if currently on inspire me tab
  bool isOnInspireMe() => ref.read(navigationStateProvider) == 3;

  /// Check if currently on profile tab
  bool isOnProfile() => ref.read(navigationStateProvider) == 4;
}

/// Provider for navigation controller instance
final navigationControllerProvider = Provider<NavigationController>((ref) {
  return NavigationController(ref);
});

/// Navigation history state
class NavigationHistoryState {
  final List<int> history;
  
  const NavigationHistoryState({this.history = const [0]});
  
  NavigationHistoryState copyWith({List<int>? history}) {
    return NavigationHistoryState(
      history: history ?? this.history,
    );
  }
}

/// Navigation history provider for tracking user navigation
final navigationHistoryProvider = StateNotifierProvider<NavigationHistoryNotifier, NavigationHistoryState>((ref) {
  return NavigationHistoryNotifier();
});

class NavigationHistoryNotifier extends StateNotifier<NavigationHistoryState> {
  NavigationHistoryNotifier() : super(const NavigationHistoryState());

  /// Add new navigation entry
  void push(int tabIndex) {
    state = state.copyWith(history: [...state.history, tabIndex]);
  }

  /// Remove last navigation entry
  void pop() {
    if (state.history.length > 1) {
      state = state.copyWith(
        history: state.history.sublist(0, state.history.length - 1),
      );
    }
  }

  /// Clear navigation history
  void clear() {
    state = state.copyWith(history: [0]);
  }

  /// Get previous tab
  int? get previousTab {
    return state.history.length > 1 ? state.history[state.history.length - 2] : null;
  }

  /// Check if can go back
  bool get canGoBack => state.history.length > 1;
}
