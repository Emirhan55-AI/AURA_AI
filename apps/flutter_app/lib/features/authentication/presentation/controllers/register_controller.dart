import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../providers.dart';
import '../../../../core/error/failure.dart';

/// Registration state representing different stages of registration process
@immutable
class RegisterState {
  final bool isLoading;
  final String? error;
  final int currentStep;
  final Map<String, dynamic> formData;
  final bool isEmailSent;
  final bool isEmailVerified;
  final bool verificationCodeSent;
  final User? user;

  const RegisterState({
    this.isLoading = false,
    this.error,
    this.currentStep = 1,
    this.formData = const {},
    this.isEmailSent = false,
    this.isEmailVerified = false,
    this.verificationCodeSent = false,
    this.user,
  });

  RegisterState copyWith({
    bool? isLoading,
    String? error,
    int? currentStep,
    Map<String, dynamic>? formData,
    bool? isEmailSent,
    bool? isEmailVerified,
    bool? verificationCodeSent,
    User? user,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentStep: currentStep ?? this.currentStep,
      formData: formData ?? this.formData,
      isEmailSent: isEmailSent ?? this.isEmailSent,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      verificationCodeSent: verificationCodeSent ?? this.verificationCodeSent,
      user: user ?? this.user,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RegisterState &&
           other.isLoading == isLoading &&
           other.error == error &&
           other.currentStep == currentStep &&
           mapEquals(other.formData, formData) &&
           other.isEmailSent == isEmailSent &&
           other.isEmailVerified == isEmailVerified &&
           other.user == user;
  }

  @override
  int get hashCode {
    return isLoading.hashCode ^
           error.hashCode ^
           currentStep.hashCode ^
           formData.hashCode ^
           isEmailSent.hashCode ^
           isEmailVerified.hashCode ^
           user.hashCode;
  }
}

/// Registration Controller - Manages multi-step registration process
/// 
/// This controller handles the complete user registration flow including:
/// - Step 1: Basic information (email, password, full name)
/// - Step 2: Style preferences and interests
/// - Step 3: Email verification and profile completion
/// 
/// Features:
/// - Multi-step wizard navigation
/// - Form data persistence across steps
/// - Email verification flow
/// - Style preference collection
/// - Error handling with user-friendly messages
/// - Integration with Supabase Authentication
class RegisterController extends StateNotifier<RegisterState> {
  final AuthRepository _authRepository;

  RegisterController(this._authRepository) : super(const RegisterState());

  /// Navigate to next step in registration process
  void nextStep() {
    if (state.currentStep < 2) {
      state = state.copyWith(
        currentStep: state.currentStep + 1,
        error: null,
      );
    }
  }

  /// Navigate to previous step in registration process
  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(
        currentStep: state.currentStep - 1,
        error: null,
      );
    }
  }

  /// Update form data for current step
  Future<bool> updateFormData(Map<String, dynamic> data) async {
    final updatedFormData = Map<String, dynamic>.from(state.formData);
    updatedFormData.addAll(data);

    state = state.copyWith(
      formData: updatedFormData,
      error: null,
    );

    return true; // Simulating success
  }

  /// Validate current step data
  bool validateCurrentStep() {
    switch (state.currentStep) {
      case 0:
        return _validateBasicInfo();
      case 1:
        return _validateStylePreferences();
      case 2:
        return _validateEmailVerification();
      default:
        return false;
    }
  }

  /// Validate basic information (Step 1)
  bool _validateBasicInfo() {
    final email = state.formData['email'] as String?;
    final password = state.formData['password'] as String?;
    final fullName = state.formData['fullName'] as String?;
    
    if (email == null || email.isEmpty || !_isValidEmail(email)) {
      _setError('Please enter a valid email address');
      return false;
    }
    
    if (password == null || password.isEmpty || password.length < 6) {
      _setError('Password must be at least 6 characters long');
      return false;
    }
    
    if (fullName == null || fullName.isEmpty) {
      _setError('Please enter your full name');
      return false;
    }
    
    return true;
  }

  /// Validate style preferences (Step 2)
  bool _validateStylePreferences() {
    final stylePreferences = state.formData['stylePreferences'] as List<String>?;
    
    if (stylePreferences == null || stylePreferences.isEmpty) {
      _setError('Please select at least one style preference');
      return false;
    }
    
    return true;
  }

  /// Validate email verification (Step 3)
  bool _validateEmailVerification() {
    return state.isEmailVerified;
  }

  /// Send email verification (real implementation)
  Future<void> sendEmailVerification() async {
    if (!_validateBasicInfo()) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final email = state.formData['email'] as String;
      final result = await _authRepository.sendEmailVerification(email);
      
      result.fold(
        (failure) => _handleFailure(failure),
        (_) => state = state.copyWith(
          isLoading: false,
          isEmailSent: true,
          error: null,
        ),
      );
    } catch (e) {
      _setError('Failed to send verification email. Please try again.');
    }
  }

  /// Verify email with code (real implementation)
  Future<void> verifyEmail(String verificationCode) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final email = state.formData['email'] as String;
      final result = await _authRepository.verifyEmailCode(email, verificationCode);
      
      result.fold(
        (failure) => _handleFailure(failure),
        (_) => state = state.copyWith(
          isLoading: false,
          isEmailVerified: true,
          error: null,
        ),
      );
    } catch (e) {
      _setError('Invalid verification code. Please try again.');
    }
  }

  /// Complete registration process (real implementation)
  Future<void> completeRegistration() async {
    if (!validateCurrentStep()) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final email = state.formData['email'] as String;
      final password = state.formData['password'] as String;
      final fullName = state.formData['fullName'] as String;
      final stylePreferences = (state.formData['stylePreferences'] as List<dynamic>?)
          ?.cast<String>();
      
      final result = await _authRepository.register(
        email: email,
        password: password,
        fullName: fullName,
        stylePreferences: stylePreferences,
      );
      
      result.fold(
        (failure) => _handleFailure(failure),
        (user) {
          state = state.copyWith(
            isLoading: false,
            user: user,
            error: null,
          );
        },
      );
    } catch (e) {
      _setError('Registration failed. Please try again.');
    }
  }

  /// Send verification code to user's email
  Future<void> sendVerificationCode() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final email = state.formData['email'] as String;
      
      final result = await _authRepository.sendEmailVerification(email);
      
      result.fold(
        (failure) => _handleFailure(failure),
        (_) {
          state = state.copyWith(
            isLoading: false,
            verificationCodeSent: true,
          );
        },
      );
    } catch (e) {
      _setError('Network error. Please try again.');
    }
  }

  /// Verify email with code
  Future<bool> verifyEmailCode() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final email = state.formData['email'] as String;
      final verificationCode = state.formData['verificationCode'] as String;

      final result = await _authRepository.verifyEmailCode(email, verificationCode);
      
      return result.fold(
        (failure) {
          _handleFailure(failure);
          return false;
        },
        (_) {
          state = state.copyWith(isLoading: false);
          return true;
        },
      );
    } catch (e) {
      _setError('Network error. Please try again.');
      return false;
    }
  }

  /// Clear any errors
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reset registration state
  void reset() {
    state = const RegisterState();
  }

  // Helper methods
  void _setError(String error) {
    state = state.copyWith(
      isLoading: false,
      error: error,
    );
  }

  void _handleFailure(Failure failure) {
    String errorMessage = 'An unexpected error occurred. Please try again.';
    
    // Handle specific failure types based on your Failure implementation
    if (failure.message.isNotEmpty) {
      errorMessage = failure.message;
    }
    
    _setError(errorMessage);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

/// Provider for RegisterController
final registerControllerProvider = StateNotifierProvider<RegisterController, RegisterState>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return RegisterController(authRepository);
});
