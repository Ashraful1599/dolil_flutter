import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/dio_provider.dart';
import '../../../shared/providers/auth_state_provider.dart';
import '../../../shared/models/user_model.dart';
import '../repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

// Auth notifier handles login, logout, token management
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository _repo;
  final Ref _ref;

  AuthNotifier(this._repo, this._ref) : super(const AsyncValue.data(null));

  Future<void> login(String identifier, String password) async {
    state = const AsyncValue.loading();
    try {
      final data = await _repo.login(identifier, password);
      final token = data['token'] as String?;
      final userData = data['data'] ?? data['user'];
      if (token != null) {
        await _ref.read(secureStorageProvider).write(key: 'dolil_token', value: token);
        _ref.read(authTokenProvider.notifier).state = token;
      }
      if (userData != null) {
        final user = UserModel.fromJson(userData);
        _ref.read(currentUserProvider.notifier).state = user;
        state = AsyncValue.data(user);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> loadUser() async {
    try {
      final token = await _ref.read(secureStorageProvider).read(key: 'dolil_token');
      if (token == null) {
        state = const AsyncValue.data(null);
        return;
      }
      _ref.read(authTokenProvider.notifier).state = token;
      final user = await _repo.getUser();
      _ref.read(currentUserProvider.notifier).state = user;
      state = AsyncValue.data(user);
    } catch (_) {
      await _ref.read(secureStorageProvider).delete(key: 'dolil_token');
      _ref.read(authTokenProvider.notifier).state = null;
      state = const AsyncValue.data(null);
    }
  }

  Future<void> logout() async {
    try {
      await _repo.logout();
    } catch (_) {}
    await _ref.read(secureStorageProvider).delete(key: 'dolil_token');
    _ref.read(authTokenProvider.notifier).state = null;
    _ref.read(currentUserProvider.notifier).state = null;
    state = const AsyncValue.data(null);
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider), ref);
});
