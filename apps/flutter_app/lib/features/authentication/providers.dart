import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/repositories/auth_repository_impl.dart';
import 'data/services/auth_service.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/get_current_user_usecase.dart';
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/logout_usecase.dart';

/// Provider for Supabase client instance
/// This provides a singleton instance of the Supabase client
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider for AuthService
/// Provides the authentication service with Supabase client dependency
final authServiceProvider = Provider<AuthService>((ref) {
  final supabaseClient = ref.read(supabaseClientProvider);
  return AuthService(supabaseClient);
});

/// Provider for AuthRepository implementation
/// Provides the repository with AuthService dependency
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authService = ref.read(authServiceProvider);
  return AuthRepositoryImpl(authService);
});

/// Provider for LoginUseCase
/// Provides the login use case with repository dependency
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return LoginUseCase(authRepository);
});

/// Provider for LogoutUseCase
/// Provides the logout use case with repository dependency
final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return LogoutUseCase(authRepository);
});

/// Provider for GetCurrentUserUseCase
/// Provides the get current user use case with repository dependency
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return GetCurrentUserUseCase(authRepository);
});
