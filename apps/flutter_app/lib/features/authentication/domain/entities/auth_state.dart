/// Authentication state enumeration for the Aura application
/// Represents all possible states during the authentication flow
enum AuthState {
  /// Initial state when the app starts
  initial,
  
  /// Loading state during authentication operations
  loading,
  
  /// User is successfully authenticated
  authenticated,
  
  /// User is not authenticated
  unauthenticated,
  
  /// An error occurred during authentication
  error,
  
  /// Authentication token has expired
  expired,
  
  /// Currently refreshing the authentication token
  refreshing,
}

/// Extension to provide convenient state checking methods
extension AuthStateX on AuthState {
  /// Returns true if the user is authenticated
  bool get isAuthenticated => this == AuthState.authenticated;
  
  /// Returns true if authentication is in progress
  bool get isLoading => this == AuthState.loading || this == AuthState.refreshing;
  
  /// Returns true if there's an authentication error
  bool get hasError => this == AuthState.error || this == AuthState.expired;
  
  /// Returns true if user needs to authenticate
  bool get requiresAuth => this == AuthState.unauthenticated || 
                          this == AuthState.expired ||
                          this == AuthState.error;
}
