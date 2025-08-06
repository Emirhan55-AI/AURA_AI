import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/models/register_state.dart';
import '../domain/models/style_preferences.dart';
import '../domain/repositories/auth_repository.dart';

part 'register_controller.g.dart';

@riverpod
class RegisterController extends _$RegisterController {
  @override
  RegisterState build() => RegisterState.initial();

  Future<void> updateEmail(String email) async {
    state = state.copyWith(email: email, errorMessage: null);
  }

  Future<void> updatePassword(String password) async {
    state = state.copyWith(password: password, errorMessage: null);
  }

  Future<void> updateFullName(String fullName) async {
    state = state.copyWith(fullName: fullName, errorMessage: null);
  }

  Future<void> updateStylePreferences(StylePreferences preferences) async {
    state = state.copyWith(preferences: preferences, errorMessage: null);
  }

  Future<void> acceptTerms(bool accepted) async {
    state = state.copyWith(termsAccepted: accepted, errorMessage: null);
  }

  Future<void> acceptPrivacy(bool accepted) async {
    state = state.copyWith(privacyAccepted: accepted, errorMessage: null);
  }

  Future<void> nextStep() async {
    if (!_validateCurrentStep()) {
      return;
    }
    state = state.copyWith(
      currentStep: state.currentStep + 1,
      errorMessage: null,
    );
  }

  Future<void> previousStep() async {
    if (state.currentStep > 0) {
      state = state.copyWith(
        currentStep: state.currentStep - 1,
        errorMessage: null,
      );
    }
  }

  Future<void> register() async {
    if (!_validateAllSteps()) {
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final authRepository = ref.read(authRepositoryProvider);
      
      await authRepository.register(
        email: state.email,
        password: state.password,
        fullName: state.fullName,
        preferences: state.preferences,
      );

      await authRepository.sendVerificationEmail(state.email);
      
      state = state.copyWith(
        isLoading: false,
        isVerificationEmailSent: true,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  bool _validateCurrentStep() {
    switch (state.currentStep) {
      case 0: // Basic Info
        if (state.email.isEmpty || state.password.isEmpty || state.fullName.isEmpty) {
          state = state.copyWith(errorMessage: 'Lütfen tüm alanları doldurun');
          return false;
        }
        return true;
        
      case 1: // Style Preferences
        if (state.preferences.favoriteStyles.isEmpty) {
          state = state.copyWith(errorMessage: 'Lütfen en az bir stil seçin');
          return false;
        }
        return true;
        
      case 2: // Terms & Privacy
        if (!state.termsAccepted || !state.privacyAccepted) {
          state = state.copyWith(errorMessage: 'Lütfen kullanım koşullarını ve gizlilik sözleşmesini kabul edin');
          return false;
        }
        return true;
        
      default:
        return true;
    }
  }

  bool _validateAllSteps() {
    return _validateCurrentStep() &&
           state.email.isNotEmpty &&
           state.password.isNotEmpty &&
           state.fullName.isNotEmpty &&
           state.preferences.favoriteStyles.isNotEmpty &&
           state.termsAccepted &&
           state.privacyAccepted;
  }
}
