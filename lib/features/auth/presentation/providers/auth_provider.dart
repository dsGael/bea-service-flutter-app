// lib/features/auth/presentation/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../data/auth_repository.dart';

final apiClientProvider = Provider((ref) => ApiClient());

final authRepositoryProvider = Provider((ref) {
  return AuthRepository(ref.watch(apiClientProvider));
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<Map<String, dynamic>?>>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> login(String identificador, String password) async {
    state = const AsyncValue.loading();
    try {

      final usuario = await _repository.login(identificador.trim(), password);
      state = AsyncValue.data(usuario);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncValue.data(null);
  }
}