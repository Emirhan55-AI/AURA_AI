import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../repositories/auth_repository.dart';

/// Use case for user logout/sign out
/// Encapsulates the business logic for user logout
/// following the Clean Architecture principles
class LogoutUseCase {
  final AuthRepository _authRepository;

  const LogoutUseCase(this._authRepository);

  /// Executes the logout operation
  /// 
  /// Returns [Right(void)] on successful logout
  /// Returns [Left(Failure)] on logout failure
  Future<Either<Failure, void>> execute() async {
    // Delegate to repository for actual logout
    return await _authRepository.logout();
  }

  /// Alternative method name for consistency with common use case patterns
  Future<Either<Failure, void>> call() => execute();
}
