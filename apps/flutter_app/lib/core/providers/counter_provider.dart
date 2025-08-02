import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'counter_provider.g.dart';

/// Example AsyncNotifier provider demonstrating Riverpod v2 code generation
/// This provider manages a simple integer counter with async state updates
@riverpod
class Counter extends _$Counter {
  @override
  Future<int> build() async {
    // Simulate async data loading (e.g., from database or API)
    await Future<void>.delayed(const Duration(seconds: 1));
    return 0; // Initial state
  }

  /// Increment the counter value asynchronously
  Future<void> increment() async {
    // Set loading state while processing
    state = const AsyncValue.loading();
    
    try {
      // Get current value and increment
      final currentValue = await future;
      state = AsyncValue.data(currentValue + 1);
    } catch (error, stackTrace) {
      // Handle any errors that might occur
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Decrement the counter value asynchronously
  Future<void> decrement() async {
    state = const AsyncValue.loading();
    
    try {
      final currentValue = await future;
      state = AsyncValue.data(currentValue - 1);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Reset the counter to zero
  Future<void> reset() async {
    state = const AsyncValue.loading();
    
    try {
      // Simulate async reset operation
      await Future<void>.delayed(const Duration(milliseconds: 500));
      state = const AsyncValue.data(0);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
