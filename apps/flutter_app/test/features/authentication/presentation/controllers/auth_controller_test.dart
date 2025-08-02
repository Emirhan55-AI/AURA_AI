import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:flutter_app/features/authentication/presentation/controllers/auth_controller.dart';
import 'package:flutter_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:flutter_app/features/authentication/domain/entities/user.dart';
import 'package:flutter_app/core/error/failure.dart';
import 'package:flutter_app/core/services/secure_storage_service.dart';

import 'auth_controller_test.mocks.dart';

// Generate mocks for dependencies
@GenerateMocks([AuthRepository, SecureStorageService])
void main() {
  late MockAuthRepository mockAuthRepository;
  late MockSecureStorageService mockStorageService;
  late ProviderContainer container;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockStorageService = MockSecureStorageService();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
        secureStorageServiceProvider.overrideWithValue(mockStorageService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthController', () {
    group('build', () {
      test('should return null when no user is authenticated', () async {
        // Arrange
        when(mockStorageService.getToken()).thenAnswer((_) async => null);

        // Act
        final result = await container.read(authControllerProvider.future);

        // Assert
        expect(result, isNull);
        verify(mockStorageService.getToken()).called(1);
      });

      test('should return user when valid token exists', () async {
        // Arrange
        const user = User(
          id: '123',
          email: 'test@example.com',
          name: 'Test User',
        );
        const token = 'valid_token';

        when(mockStorageService.getToken()).thenAnswer((_) async => token);
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => const Right(user));

        // Act
        final result = await container.read(authControllerProvider.future);

        // Assert
        expect(result, equals(user));
        verify(mockStorageService.getToken()).called(1);
        verify(mockAuthRepository.getCurrentUser()).called(1);
      });

      test('should return null when token is invalid', () async {
        // Arrange
        const token = 'invalid_token';
        const failure = AuthFailure.invalidToken();

        when(mockStorageService.getToken()).thenAnswer((_) async => token);
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await container.read(authControllerProvider.future);

        // Assert
        expect(result, isNull);
        verify(mockStorageService.getToken()).called(1);
        verify(mockAuthRepository.getCurrentUser()).called(1);
      });
    });

    group('login', () {
      test('should login successfully with valid credentials', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const token = 'auth_token';
        const user = User(
          id: '123',
          email: email,
          name: 'Test User',
        );

        when(mockAuthRepository.login(email, password))
            .thenAnswer((_) async => const Right((user, token)));
        when(mockStorageService.storeToken(token))
            .thenAnswer((_) async => {});

        // Act
        final controller = container.read(authControllerProvider.notifier);
        final result = await controller.login(email, password);

        // Assert
        expect(result.isRight(), isTrue);
        expect(result.fold((l) => null, (r) => r), equals(user));
        
        // Verify state is updated
        final state = await container.read(authControllerProvider.future);
        expect(state, equals(user));

        verify(mockAuthRepository.login(email, password)).called(1);
        verify(mockStorageService.storeToken(token)).called(1);
      });

      test('should return failure with invalid credentials', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'wrong_password';
        const failure = AuthFailure.invalidCredentials();

        when(mockAuthRepository.login(email, password))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final controller = container.read(authControllerProvider.notifier);
        final result = await controller.login(email, password);

        // Assert
        expect(result.isLeft(), isTrue);
        expect(result.fold((l) => l, (r) => null), equals(failure));

        // Verify state remains null
        final state = await container.read(authControllerProvider.future);
        expect(state, isNull);

        verify(mockAuthRepository.login(email, password)).called(1);
        verifyNever(mockStorageService.storeToken(any));
      });

      test('should handle network failures during login', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const failure = NetworkFailure.noConnection();

        when(mockAuthRepository.login(email, password))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final controller = container.read(authControllerProvider.notifier);
        final result = await controller.login(email, password);

        // Assert
        expect(result.isLeft(), isTrue);
        expect(result.fold((l) => l, (r) => null), equals(failure));
        verify(mockAuthRepository.login(email, password)).called(1);
      });
    });

    group('register', () {
      test('should register successfully with valid data', () async {
        // Arrange
        const email = 'newuser@example.com';
        const password = 'password123';
        const name = 'New User';
        const token = 'auth_token';
        const user = User(
          id: '124',
          email: email,
          name: name,
        );

        when(mockAuthRepository.register(email, password, name))
            .thenAnswer((_) async => const Right((user, token)));
        when(mockStorageService.storeToken(token))
            .thenAnswer((_) async => {});

        // Act
        final controller = container.read(authControllerProvider.notifier);
        final result = await controller.register(email, password, name);

        // Assert
        expect(result.isRight(), isTrue);
        expect(result.fold((l) => null, (r) => r), equals(user));

        final state = await container.read(authControllerProvider.future);
        expect(state, equals(user));

        verify(mockAuthRepository.register(email, password, name)).called(1);
        verify(mockStorageService.storeToken(token)).called(1);
      });

      test('should return failure when email already exists', () async {
        // Arrange
        const email = 'existing@example.com';
        const password = 'password123';
        const name = 'User';
        const failure = AuthFailure.emailAlreadyExists();

        when(mockAuthRepository.register(email, password, name))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final controller = container.read(authControllerProvider.notifier);
        final result = await controller.register(email, password, name);

        // Assert
        expect(result.isLeft(), isTrue);
        expect(result.fold((l) => l, (r) => null), equals(failure));
        verify(mockAuthRepository.register(email, password, name)).called(1);
      });
    });

    group('logout', () {
      test('should logout successfully and clear storage', () async {
        // Arrange
        const user = User(
          id: '123',
          email: 'test@example.com',
          name: 'Test User',
        );

        // Setup initial authenticated state
        when(mockStorageService.getToken()).thenAnswer((_) async => 'token');
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => const Right(user));

        // Setup logout behavior
        when(mockAuthRepository.logout())
            .thenAnswer((_) async => const Right(unit));
        when(mockStorageService.deleteToken())
            .thenAnswer((_) async => {});

        // Get initial state
        await container.read(authControllerProvider.future);

        // Act
        final controller = container.read(authControllerProvider.notifier);
        await controller.logout();

        // Assert
        final state = await container.read(authControllerProvider.future);
        expect(state, isNull);

        verify(mockAuthRepository.logout()).called(1);
        verify(mockStorageService.deleteToken()).called(1);
      });
    });

    group('validateToken', () {
      test('should validate token and update state', () async {
        // Arrange
        const user = User(
          id: '123',
          email: 'test@example.com',
          name: 'Test User',
        );

        when(mockStorageService.getToken()).thenAnswer((_) async => 'token');
        when(mockAuthRepository.validateToken())
            .thenAnswer((_) async => const Right(user));

        // Act
        final controller = container.read(authControllerProvider.notifier);
        final isValid = await controller.validateToken();

        // Assert
        expect(isValid, isTrue);
        final state = await container.read(authControllerProvider.future);
        expect(state, equals(user));

        verify(mockStorageService.getToken()).called(1);
        verify(mockAuthRepository.validateToken()).called(1);
      });

      test('should return false for invalid token', () async {
        // Arrange
        const failure = AuthFailure.invalidToken();

        when(mockStorageService.getToken()).thenAnswer((_) async => 'invalid');
        when(mockAuthRepository.validateToken())
            .thenAnswer((_) async => const Left(failure));
        when(mockStorageService.deleteToken())
            .thenAnswer((_) async => {});

        // Act
        final controller = container.read(authControllerProvider.notifier);
        final isValid = await controller.validateToken();

        // Assert
        expect(isValid, isFalse);
        final state = await container.read(authControllerProvider.future);
        expect(state, isNull);

        verify(mockAuthRepository.validateToken()).called(1);
        verify(mockStorageService.deleteToken()).called(1);
      });
    });

    group('resetPassword', () {
      test('should send reset password email successfully', () async {
        // Arrange
        const email = 'test@example.com';

        when(mockAuthRepository.resetPassword(email))
            .thenAnswer((_) async => const Right(unit));

        // Act
        final controller = container.read(authControllerProvider.notifier);
        final result = await controller.resetPassword(email);

        // Assert
        expect(result.isRight(), isTrue);
        verify(mockAuthRepository.resetPassword(email)).called(1);
      });

      test('should return failure for non-existent email', () async {
        // Arrange
        const email = 'nonexistent@example.com';
        const failure = AuthFailure.userNotFound();

        when(mockAuthRepository.resetPassword(email))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final controller = container.read(authControllerProvider.notifier);
        final result = await controller.resetPassword(email);

        // Assert
        expect(result.isLeft(), isTrue);
        expect(result.fold((l) => l, (r) => null), equals(failure));
        verify(mockAuthRepository.resetPassword(email)).called(1);
      });
    });
  });

  group('AuthState Helper Providers', () {
    test('isAuthenticatedProvider should return true when user exists', () async {
      // Arrange
      const user = User(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
      );

      when(mockStorageService.getToken()).thenAnswer((_) async => 'token');
      when(mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(user));

      // Act
      final isAuthenticated = await container.read(isAuthenticatedProvider.future);

      // Assert
      expect(isAuthenticated, isTrue);
    });

    test('isAuthenticatedProvider should return false when no user', () async {
      // Arrange
      when(mockStorageService.getToken()).thenAnswer((_) async => null);

      // Act
      final isAuthenticated = await container.read(isAuthenticatedProvider.future);

      // Assert
      expect(isAuthenticated, isFalse);
    });
  });
}
