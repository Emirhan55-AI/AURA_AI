import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../providers.dart';

part 'forgot_password_controller.g.dart';

/// States for the forgot password flow
enum ForgotPasswordState {
  initial,
  loading,
  emailSent,
  error,
}

/// Data class to hold forgot password state and error information
class ForgotPasswordStateData {
  final ForgotPasswordState state;
  final String? errorMessage;
  final String? email;

  const ForgotPasswordStateData({
    required this.state,
    this.errorMessage,
    this.email,
  });

  ForgotPasswordStateData copyWith({
    ForgotPasswordState? state,
    String? errorMessage,
    String? email,
  }) {
    return ForgotPasswordStateData(
      state: state ?? this.state,
      errorMessage: errorMessage,
      email: email ?? this.email,
    );
  }
}

/// Controller for forgot password functionality
/// Handles password reset flow with real Supabase integration
@riverpod
class ForgotPasswordController extends _$ForgotPasswordController {
  @override
  ForgotPasswordStateData build() {
    return const ForgotPasswordStateData(state: ForgotPasswordState.initial);
  }

  /// Sends password reset email to the provided email address
  Future<void> sendPasswordResetEmail(String email) async {
    // Validate email format
    if (!_isValidEmail(email)) {
      state = state.copyWith(
        state: ForgotPasswordState.error,
        errorMessage: 'Please enter a valid email address',
      );
      return;
    }

    // Set loading state
    state = state.copyWith(
      state: ForgotPasswordState.loading,
      email: email,
      errorMessage: null,
    );

    // Call repository to send reset email
    final authRepository = ref.read(authRepositoryProvider);
    final result = await authRepository.resetPassword(email);

    result.fold(
      (Failure failure) {
        // Handle error
        state = state.copyWith(
          state: ForgotPasswordState.error,
          errorMessage: _getErrorMessage(failure),
        );
      },
      (_) {
        // Success - email sent
        state = state.copyWith(
          state: ForgotPasswordState.emailSent,
          errorMessage: null,
        );
      },
    );
  }

  /// Resets the controller state to initial
  void resetState() {
    state = const ForgotPasswordStateData(state: ForgotPasswordState.initial);
  }

  /// Validates email format using regex
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email.trim());
  }

  /// Maps domain failures to user-friendly error messages
  String _getErrorMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ValidationFailure:
        return 'Invalid email address format';
      case AuthFailure:
        return 'No account found with this email address';
      case NetworkFailure:
        return 'Network error. Please check your connection';
      case ServiceFailure:
        return 'Server error. Please try again later';
      default:
        return failure.message;
    }
  }
}
