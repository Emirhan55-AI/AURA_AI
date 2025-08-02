import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/user.dart';

/// Abstract repository interface for authentication operations
/// This interface defines the contract for authentication-related data operations
/// following the Repository pattern and Dependency Inversion Principle
abstract class AuthRepository {
  /// Authenticates a user with email and password
  /// 
  /// Returns [Right(User)] on successful authentication
  /// Returns [Left(Failure)] on authentication failure
  Future<Either<Failure, User>> login(String email, String password);

  /// Signs out the current user
  /// 
  /// Returns [Right(void)] on successful sign out
  /// Returns [Left(Failure)] on sign out failure
  Future<Either<Failure, void>> logout();

  /// Gets the currently authenticated user if any
  /// 
  /// Returns [Right(User)] if user is authenticated
  /// Returns [Right(null)] if no user is authenticated
  /// Returns [Left(Failure)] on error retrieving user
  Future<Either<Failure, User?>> getCurrentUser();

  /// Registers a new user with email and password
  /// 
  /// Returns [Right(User)] on successful registration
  /// Returns [Left(Failure)] on registration failure
  Future<Either<Failure, User>> register(String email, String password);

  /// Sends a password reset email to the provided email address
  /// 
  /// Returns [Right(void)] on successful password reset email sent
  /// Returns [Left(Failure)] on failure to send password reset email
  Future<Either<Failure, void>> resetPassword(String email);

  /// Stream of authentication state changes
  /// Emits the current user when authentication state changes
  Stream<User?> get authStateChanges;
}
