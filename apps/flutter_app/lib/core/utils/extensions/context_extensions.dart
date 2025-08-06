import 'package:flutter/material.dart';

/// Extension methods for BuildContext to provide easy access to theme data
extension ContextExtensions on BuildContext {
  /// Get the current theme data
  ThemeData get theme => Theme.of(this);
  
  /// Get the current color scheme
  ColorScheme get colorScheme => theme.colorScheme;
  
  /// Get the current text theme
  TextTheme get textTheme => theme.textTheme;
  
  /// Get media query data
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  
  /// Get screen size
  Size get screenSize => mediaQuery.size;
  
  /// Get screen width
  double get screenWidth => screenSize.width;
  
  /// Get screen height
  double get screenHeight => screenSize.height;
  
  /// Check if dark mode is active
  bool get isDarkMode => theme.brightness == Brightness.dark;
  
  /// Check if light mode is active
  bool get isLightMode => theme.brightness == Brightness.light;
  
  /// Get padding (safe area)
  EdgeInsets get padding => mediaQuery.padding;
  
  /// Get view insets (keyboard)
  EdgeInsets get viewInsets => mediaQuery.viewInsets;
  
  /// Get text scale factor
  double get textScaleFactor => mediaQuery.textScaleFactor;
  
  /// Get device pixel ratio
  double get devicePixelRatio => mediaQuery.devicePixelRatio;
  
  /// Show snackbar
  void showSnackBar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 2),
      ),
    );
  }
  
  /// Hide current snackbar
  void hideSnackBar() {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
  }
  
  /// Push a new route
  Future<T?> pushNamed<T extends Object?>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);
  }
  
  /// Pop current route
  void pop<T extends Object?>([T? result]) {
    Navigator.of(this).pop<T>(result);
  }
  
  /// Check if can pop
  bool get canPop => Navigator.of(this).canPop();
}
