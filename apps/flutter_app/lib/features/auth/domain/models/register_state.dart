import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_state.freezed.dart';

@freezed
class RegisterState with _$RegisterState {
  const factory RegisterState({
    required String email,
    required String password,
    required String fullName,
    required bool termsAccepted,
    required bool privacyAccepted,
    required int currentStep,
    required StylePreferences preferences,
    String? errorMessage,
    bool? isLoading,
    bool? isVerificationEmailSent,
  }) = _RegisterState;

  factory RegisterState.initial() => RegisterState(
    email: '',
    password: '',
    fullName: '',
    termsAccepted: false,
    privacyAccepted: false,
    currentStep: 0,
    preferences: StylePreferences.empty(),
    errorMessage: null,
    isLoading: false,
    isVerificationEmailSent: false,
  );
}
