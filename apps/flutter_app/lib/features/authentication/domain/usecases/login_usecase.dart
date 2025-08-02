import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for user login/authentication
/// Encapsulates the business logic for user authentication
/// following the Clean Architecture principles
class LoginUseCase {
  final AuthRepository _authRepository;

  const LoginUseCase(this._authRepository);

  /// Executes the login operation with email and password
  /// 
  /// [email] - User's email address
  /// [password] - User's password
  /// 
  /// Returns [Right(User)] on successful authentication
  /// Returns [Left(Failure)] on authentication failure
  Future<Either<Failure, User>> execute(String email, String password) async {
    // Input validation
    if (email.isEmpty) {
      return Left(ValidationFailure(message: 'Email cannot be empty'));
    }
    
    if (password.isEmpty) {
      return Left(ValidationFailure(message: 'Password cannot be empty'));
    }
    
    if (!_isValidEmail(email)) {
      return Left(ValidationFailure(message: 'Invalid email format'));
    }
    
    if (password.length < 6) {
      return Left(ValidationFailure(message: 'Password must be at least 6 characters'));
    }

    // Delegate to repository for actual authentication
    return await _authRepository.login(email, password);
  }

  /// Alternative method name for consistency with common use case patterns
  Future<Either<Failure, User>> call(String email, String password) =>
      execute(email, password);

  /// Validates email format using a simple regex
  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }
}
