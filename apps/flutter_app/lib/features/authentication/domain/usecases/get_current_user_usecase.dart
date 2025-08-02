import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for getting the current authenticated user
/// Encapsulates the business logic for retrieving current user state
/// following the Clean Architecture principles
class GetCurrentUserUseCase {
  final AuthRepository _authRepository;

  const GetCurrentUserUseCase(this._authRepository);

  /// Executes the get current user operation
  /// 
  /// Returns [Right(User)] if user is authenticated
  /// Returns [Right(null)] if no user is authenticated
  /// Returns [Left(Failure)] on error retrieving user
  Future<Either<Failure, User?>> execute() async {
    // Delegate to repository for actual user retrieval
    return await _authRepository.getCurrentUser();
  }

  /// Alternative method name for consistency with common use case patterns
  Future<Either<Failure, User?>> call() => execute();
}
