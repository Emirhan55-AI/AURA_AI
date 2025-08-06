import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/repositories/search_repository.dart';
import '../repositories/search_repository_impl.dart';

part 'search_providers.g.dart';

/// Search Repository Provider
@riverpod
SearchRepository searchRepository(SearchRepositoryRef ref) {
  return SearchRepositoryImpl();
}
