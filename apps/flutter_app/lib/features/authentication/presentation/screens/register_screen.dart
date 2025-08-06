import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/register_controller.dart';
import '../widgets/register/register_step_1.dart';
import '../widgets/register/register_step_2.dart';
import '../widgets/register/register_step_3.dart';

/// RegisterScreen - Multi-step user registration flow
/// 
/// This screen provides a complete registration experience with:
/// - Step 1: Basic information (email, password, full name)
/// - Step 2: Style preferences and interests
/// - Step 3: Email verification and completion
/// 
/// Features:
/// - Material 3 design
/// - Progressive disclosure
/// - Form validation
/// - Error handling
/// - Loading states
/// - Accessibility support
/// - Real backend integration with Supabase
class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registerState = ref.watch(registerControllerProvider);
    final registerController = ref.read(registerControllerProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: registerState.currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: registerController.previousStep,
              )
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.pop(),
              ),
        title: Text(
          'Create Account',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            _buildProgressIndicator(context, registerState.currentStep),
            
            // Content
            Expanded(
              child: _buildStepContent(context, registerState, registerController),
            ),
          ],
        ),
      ),
    );
  }

  /// Build step progress indicator
  Widget _buildProgressIndicator(BuildContext context, int currentStep) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= currentStep;
          
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(
                left: index == 0 ? 0 : 4,
                right: index == 2 ? 0 : 4,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceVariant,
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Build content for current step
  Widget _buildStepContent(BuildContext context, RegisterState state, RegisterController controller) {
    // Show loading if any
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processing your registration...'),
          ],
        ),
      );
    }

    // Show error if any
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                state.error!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.clearError,
              child: Text('Try Again'),
            ),
          ],
        ),
      );
    }

    // Show success if registration completed
    if (state.user != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 80, color: Colors.green),
            SizedBox(height: 24),
            Text(
              'Registration Successful!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Welcome ${state.user!.fullName}!',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: Text('Continue to App'),
            ),
          ],
        ),
      );
    }

    // Show appropriate step
    switch (state.currentStep) {
      case 1:
        return RegisterStep1(
          formData: state.formData,
          onDataChanged: (data) async {
            controller.updateFormData(data);
            return Future.value(true); // Simulating success
          },
          onNext: () {
            if (controller.validateCurrentStep()) {
              controller.nextStep();
            }
          },
        );
      case 2:
        return RegisterStep2(
          formData: state.formData,
          onDataChanged: controller.updateFormData,
          onNext: () {
            if (controller.validateCurrentStep()) {
              controller.nextStep();
              // Send verification code when moving to step 3
              controller.sendVerificationCode();
            }
          },
        );
      case 3:
        return RegisterStep3(
          formData: state.formData,
          onDataChanged: controller.updateFormData,
          onComplete: () async {
            // Verify the code and complete registration
            final success = await controller.verifyEmailCode();
            if (success) {
              await controller.completeRegistration();
            }
          },
        );
      default:
        return const Center(
          child: Text('Invalid step'),
        );
    }
  }
}
