import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/auth_service.dart';

/// Concrete implementation of AuthRepository
/// This class implements the repository interface and delegates
/// operations to the AuthService while maintaining the repository pattern
class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  const AuthRepositoryImpl(this._authService);

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    return await _authService.signInWithEmailAndPassword(email, password);
  }

  @override
  Future<Either<Failure, void>> logout() async {
    return await _authService.signOut();
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    return await _authService.getCurrentUser();
  }

  @override
  Future<Either<Failure, User>> register(String email, String password) async {
    return await _authService.signUpWithEmailAndPassword(email, password);
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    return await _authService.resetPassword(email);
  }

  @override
  Stream<User?> get authStateChanges => _authService.authStateChanges;
}
