import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../../../../core/error/failure.dart';
import '../../domain/entities/user.dart';
import '../models/user_model.dart';

/// Service class for handling authentication operations with Supabase
/// This service encapsulates all Supabase Auth interactions and maps them
/// to domain types with proper error handling
class AuthService {
  final SupabaseClient _supabaseClient;

  const AuthService(this._supabaseClient);

  /// Signs in a user with email and password
  /// 
  /// Returns [Right(User)] on successful authentication
  /// Returns [Left(Failure)] on authentication failure
  Future<Either<Failure, User>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return Left(AuthFailure(message: 'Authentication failed: No user returned'));
      }

      final userModel = UserModel.fromSupabaseUser(response.user!);
      return Right(userModel.toDomainEntity());
    } on AuthException catch (e) {
      return Left(_mapAuthException(e));
    } catch (e) {
      return Left(UnknownFailure(message: 'Unexpected error during sign in: ${e.toString()}'));
    }
  }

  /// Signs out the current user
  /// 
  /// Returns [Right(void)] on successful sign out
  /// Returns [Left(Failure)] on sign out failure
  Future<Either<Failure, void>> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(_mapAuthException(e));
    } catch (e) {
      return Left(UnknownFailure(message: 'Unexpected error during sign out: ${e.toString()}'));
    }
  }

  /// Gets the current authenticated user
  /// 
  /// Returns [Right(User)] if user is authenticated
  /// Returns [Right(null)] if no user is authenticated
  /// Returns [Left(Failure)] on error retrieving user
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final currentUser = _supabaseClient.auth.currentUser;
      
      if (currentUser == null) {
        return const Right(null);
      }

      final userModel = UserModel.fromSupabaseUser(currentUser);
      return Right(userModel.toDomainEntity());
    } catch (e) {
      return Left(UnknownFailure(message: 'Error retrieving current user: ${e.toString()}'));
    }
  }

  /// Registers a new user with email and password
  /// 
  /// Returns [Right(User)] on successful registration
  /// Returns [Left(Failure)] on registration failure
  Future<Either<Failure, User>> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return Left(AuthFailure(message: 'Registration failed: No user returned'));
      }

      final userModel = UserModel.fromSupabaseUser(response.user!);
      return Right(userModel.toDomainEntity());
    } on AuthException catch (e) {
      return Left(_mapAuthException(e));
    } catch (e) {
      return Left(UnknownFailure(message: 'Unexpected error during sign up: ${e.toString()}'));
    }
  }

  /// Sends a password reset email
  /// 
  /// Returns [Right(void)] on successful password reset email sent
  /// Returns [Left(Failure)] on failure to send password reset email
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await _supabaseClient.auth.resetPasswordForEmail(email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(_mapAuthException(e));
    } catch (e) {
      return Left(UnknownFailure(message: 'Unexpected error during password reset: ${e.toString()}'));
    }
  }

  /// Stream of authentication state changes
  /// Maps Supabase auth state changes to domain User objects
  Stream<User?> get authStateChanges {
    return _supabaseClient.auth.onAuthStateChange.map((authState) {
      final user = authState.session?.user;
      if (user == null) return null;
      
      final userModel = UserModel.fromSupabaseUser(user);
      return userModel.toDomainEntity();
    });
  }

  /// Maps Supabase AuthException to domain Failure types
  Failure _mapAuthException(AuthException authException) {
    switch (authException.message.toLowerCase()) {
      case 'invalid login credentials':
      case 'invalid email or password':
        return AuthFailure(message: 'Invalid email or password');
      case 'email not confirmed':
        return AuthFailure(message: 'Please verify your email address');
      case 'user not found':
        return AuthFailure(message: 'No account found with this email');
      case 'too many requests':
        return AuthFailure(message: 'Too many login attempts. Please try again later');
      case 'weak password':
        return ValidationFailure(message: 'Password is too weak');
      case 'email already in use':
      case 'user already registered':
        return AuthFailure(message: 'An account with this email already exists');
      default:
        return AuthFailure(message: authException.message);
    }
  }
}
