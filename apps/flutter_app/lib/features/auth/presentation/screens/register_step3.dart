import 'package:flutter/material.dart';

class RegisterStep3 extends StatelessWidget {
  final bool termsAccepted;
  final bool privacyAccepted;
  final ValueChanged<bool> onTermsAcceptedChanged;
  final ValueChanged<bool> onPrivacyAcceptedChanged;
  final VoidCallback onRegisterPressed;
  final bool isLoading;
  final bool isVerificationEmailSent;

  const RegisterStep3({
    super.key,
    required this.termsAccepted,
    required this.privacyAccepted,
    required this.onTermsAcceptedChanged,
    required this.onPrivacyAcceptedChanged,
    required this.onRegisterPressed,
    required this.isLoading,
    required this.isVerificationEmailSent,
  });

  @override
  Widget build(BuildContext context) {
    if (isVerificationEmailSent) {
      return _buildVerificationSentView(context);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Son Adım',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildTermsCheckbox(context),
          const SizedBox(height: 16),
          _buildPrivacyCheckbox(context),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: isLoading ? null : onRegisterPressed,
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Kayıt Ol'),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationSentView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.mark_email_read,
            size: 64,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          Text(
            'E-posta Doğrulama',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'E-posta adresinize doğrulama bağlantısı gönderdik. Lütfen e-postanızı kontrol edin ve hesabınızı doğrulayın.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox(BuildContext context) {
    return CheckboxListTile(
      value: termsAccepted,
      onChanged: (value) => onTermsAcceptedChanged(value ?? false),
      title: const Text('Kullanım Koşullarını kabul ediyorum'),
      subtitle: TextButton(
        onPressed: () {
          // TODO: Show terms and conditions
        },
        child: const Text('Kullanım Koşullarını Oku'),
      ),
    );
  }

  Widget _buildPrivacyCheckbox(BuildContext context) {
    return CheckboxListTile(
      value: privacyAccepted,
      onChanged: (value) => onPrivacyAcceptedChanged(value ?? false),
      title: const Text('Gizlilik Politikasını kabul ediyorum'),
      subtitle: TextButton(
        onPressed: () {
          // TODO: Show privacy policy
        },
        child: const Text('Gizlilik Politikasını Oku'),
      ),
    );
  }
}
