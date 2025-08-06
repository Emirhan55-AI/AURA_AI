import 'dart:async';

/// Debouncer utility class for delaying function execution
/// 
/// Prevents excessive API calls by delaying execution until
/// a specified time has passed without new calls
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  /// Run the callback after debounce delay
  void run(VoidCallback callback) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), callback);
  }

  /// Cancel the pending timer
  void cancel() {
    _timer?.cancel();
  }

  /// Dispose the debouncer
  void dispose() {
    _timer?.cancel();
  }
}

/// Simple callback type
typedef VoidCallback = void Function();
