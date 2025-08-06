import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/repositories/auth_repository.dart';
import '../repositories/mock_auth_repository.dart';

part 'auth_repository_provider.g.dart';

@riverpod
IAuthRepository authRepository(AuthRepositoryRef ref) {
  return MockAuthRepository();
}
