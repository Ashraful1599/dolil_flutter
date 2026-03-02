import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/notification_model.dart';
import '../../../shared/providers/dio_provider.dart';
import '../../../shared/providers/auth_state_provider.dart';
import '../repository/notification_repository.dart';
import '../services/sse_service.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(dioProvider));
});

// Unread count
final unreadCountProvider = StateProvider<int>((ref) => 0);

// Notifications list
final notificationsProvider = StateProvider<List<NotificationModel>>((ref) => []);

// SSE notifier
class SseNotifier extends StateNotifier<void> {
  final Ref _ref;
  SseService? _service;

  SseNotifier(this._ref) : super(null) {
    _connect();
  }

  void _connect() async {
    final token = await _ref.read(secureStorageProvider).read(key: 'dolil_token');
    if (token == null) return;

    _service = SseService();
    _service!.connect(token).listen((notification) {
      // Prepend to list
      _ref.read(notificationsProvider.notifier).update((list) => [notification, ...list].take(50).toList());
      // Increment unread count
      _ref.read(unreadCountProvider.notifier).update((count) => count + 1);
    });
  }

  @override
  void dispose() {
    _service?.dispose();
    super.dispose();
  }
}

final sseNotifierProvider = StateNotifierProvider<SseNotifier, void>((ref) {
  return SseNotifier(ref);
});
