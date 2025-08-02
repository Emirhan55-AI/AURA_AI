import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/error/failure.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../authentication/providers.dart';
import '../../domain/entities/user.dart';

part 'auth_controller.g.dart';

/// Authentication controller that manages the authentication state
/// Uses Riverpod for state management and follows Clean Architecture principles
/// 
/// This controller coordinates between the UI and the domain layer,
/// managing loading states, errors, and the current authenticated user
@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  Future<User?> build() async {
    // Get initial user state
    final getCurrentUserUseCase = ref.read(getCurrentUserUseCaseProvider);
    final result = await getCurrentUserUseCase.execute();
    
    return result.fold(
      (failure) => throw failure,
      (user) => user,
    );
  }

  /// Signs in a user with email and password
  /// 
  /// Updates the controller state with loading, success, or error states
  /// [email] - User's email address
  /// [password] - User's password
  Future<void> signIn(String email, String password) async {
    // Set loading state
    state = const AsyncLoading();
    
    try {
      final loginUseCase = ref.read(loginUseCaseProvider);
      final result = await loginUseCase.execute(email, password);
      
      result.fold(
        (failure) {
          // Set error state
          state = AsyncError(failure, StackTrace.current);
        },
        (user) {
          // Set success state with user data
          state = AsyncData(user);
        },
      );
    } catch (error, stackTrace) {
      // Handle unexpected errors
      state = AsyncError(
        UnknownFailure(message: 'Unexpected error during sign in: $error'),
        stackTrace,
      );
    }
  }

  /// Signs out the current user
  /// 
  /// Updates the controller state to reflect the logout operation
  Future<void> signOut() async {
    // Set loading state
    state = const AsyncLoading();
    
    try {
      final logoutUseCase = ref.read(logoutUseCaseProvider);
      final result = await logoutUseCase.execute();
      
      result.fold(
        (failure) {
          // Set error state
          state = AsyncError(failure, StackTrace.current);
        },
        (_) {
          // Set success state with no user (logged out)
          state = const AsyncData(null);
        },
      );
    } catch (error, stackTrace) {
      // Handle unexpected errors
      state = AsyncError(
        UnknownFailure(message: 'Unexpected error during sign out: $error'),
        stackTrace,
      );
    }
  }

  /// Refreshes the current user state
  /// Useful for manually refreshing the authentication state
  Future<void> refreshUser() async {
    state = const AsyncLoading();
    
    try {
      final getCurrentUserUseCase = ref.read(getCurrentUserUseCaseProvider);
      final result = await getCurrentUserUseCase.execute();
      
      result.fold(
        (failure) {
          state = AsyncError(failure, StackTrace.current);
        },
        (user) {
          state = AsyncData(user);
        },
      );
    } catch (error, stackTrace) {
      state = AsyncError(
        UnknownFailure(message: 'Unexpected error while refreshing user: $error'),
        stackTrace,
      );
    }
  }

  /// Validates stored authentication token
  /// Called during app initialization to restore authentication state
  Future<void> validateToken() async {
    try {
      final secureStorage = ref.read(secureStorageServiceProvider);
      final token = await secureStorage.getAccessToken();
      
      if (token == null) {
        state = const AsyncData(null);
        return;
      }

      // Validate token by attempting to get current user
      await refreshUser();
    } catch (error) {
      // Clear invalid token
      final secureStorage = ref.read(secureStorageServiceProvider);
      await secureStorage.clearUserData();
      state = const AsyncData(null);
    }
  }

  /// Checks if a user is currently authenticated
  bool get isAuthenticated {
    return state.asData?.value != null;
  }

  /// Gets the current authenticated user
  /// Returns null if no user is authenticated or if state is loading/error
  User? get currentUser {
    return state.asData?.value;
  }

  /// Logs out the current user by clearing authentication data
  Future<void> logout() async {
    try {
      final secureStorage = ref.read(secureStorageServiceProvider);
      await secureStorage.clearUserData();
      
      // Clear the Supabase session if exists
      final supabaseClient = supabase.Supabase.instance.client;
      await supabaseClient.auth.signOut();
      
      state = const AsyncData(null);
    } catch (error) {
      // Even if logout fails, clear local state
      state = const AsyncData(null);
    }
  }
}
