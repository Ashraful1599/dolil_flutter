import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user_model.dart';

// Secure storage provider
final secureStorageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(),
);

// Auth token provider
final authTokenProvider = StateProvider<String?>((ref) => null);

// Current user provider
final currentUserProvider = StateProvider<UserModel?>((ref) => null);

// Auth check provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authTokenProvider) != null;
});
