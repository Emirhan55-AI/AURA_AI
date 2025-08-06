import '../../domain/models/style_preferences.dart';
import '../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements IAuthRepository {
  @override
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required StylePreferences preferences,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Simulate validation
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Geçersiz e-posta adresi');
    }
    
    if (password.length < 6) {
      throw Exception('Şifre en az 6 karakter olmalıdır');
    }
    
    if (fullName.isEmpty) {
      throw Exception('Ad soyad boş olamaz');
    }
    
    // Success case
    return;
  }

  @override
  Future<void> sendVerificationEmail(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Success case
    return;
  }

  @override
  Future<bool> verifyEmail(String token) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Success case
    return true;
  }

  @override
  Future<void> acceptTerms(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Success case
    return;
  }

  @override
  Future<void> saveStylePreferences(String userId, StylePreferences preferences) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Success case
    return;
  }
}
