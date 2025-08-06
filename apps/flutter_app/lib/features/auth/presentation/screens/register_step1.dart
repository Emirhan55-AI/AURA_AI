import 'package:flutter/material.dart';

class RegisterStep1 extends StatelessWidget {
  final String email;
  final String password;
  final String fullName;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onFullNameChanged;
  final VoidCallback onNextPressed;

  const RegisterStep1({
    super.key,
    required this.email,
    required this.password,
    required this.fullName,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onFullNameChanged,
    required this.onNextPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Hesabını Oluştur',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            initialValue: email,
            onChanged: onEmailChanged,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'E-posta',
              hintText: 'ornek@email.com',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: password,
            onChanged: onPasswordChanged,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Şifre',
              hintText: '********',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: fullName,
            onChanged: onFullNameChanged,
            decoration: const InputDecoration(
              labelText: 'Ad Soyad',
              hintText: 'Adınız ve soyadınız',
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onNextPressed,
            child: const Text('Devam Et'),
          ),
        ],
      ),
    );
  }
}
