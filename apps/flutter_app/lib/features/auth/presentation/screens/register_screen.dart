import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/register_controller.dart';
import 'register_step1.dart';
import 'register_step2.dart';
import 'register_step3.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registerControllerProvider);
    final controller = ref.read(registerControllerProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
        leading: state.currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: controller.previousStep,
              )
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.pop(),
              ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (state.currentStep + 1) / 3,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            Expanded(
              child: _buildCurrentStep(state, controller),
            ),
            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  state.errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep(RegisterState state, RegisterController controller) {
    switch (state.currentStep) {
      case 0:
        return RegisterStep1(
          email: state.email,
          password: state.password,
          fullName: state.fullName,
          onEmailChanged: controller.updateEmail,
          onPasswordChanged: controller.updatePassword,
          onFullNameChanged: controller.updateFullName,
          onNextPressed: controller.nextStep,
        );
      case 1:
        return RegisterStep2(
          preferences: state.preferences,
          onPreferencesChanged: controller.updateStylePreferences,
          onNextPressed: controller.nextStep,
        );
      case 2:
        return RegisterStep3(
          termsAccepted: state.termsAccepted,
          privacyAccepted: state.privacyAccepted,
          onTermsAcceptedChanged: controller.acceptTerms,
          onPrivacyAcceptedChanged: controller.acceptPrivacy,
          onRegisterPressed: controller.register,
          isLoading: state.isLoading ?? false,
          isVerificationEmailSent: state.isVerificationEmailSent ?? false,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
