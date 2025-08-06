import '../models/register_state.dart';
import '../models/style_preferences.dart';

abstract class IAuthRepository {
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required StylePreferences preferences,
  });
  
  Future<void> sendVerificationEmail(String email);
  
  Future<bool> verifyEmail(String token);
  
  Future<void> acceptTerms(String userId);
  
  Future<void> saveStylePreferences(String userId, StylePreferences preferences);
}
