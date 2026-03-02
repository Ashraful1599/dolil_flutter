import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/models/notification_model.dart';
import '../../../shared/widgets/loading_skeleton_widget.dart';
import '../repository/notification_repository.dart';
import '../providers/notification_providers.dart';
import '../../../shared/providers/dio_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final repo = NotificationRepository(ref.read(dioProvider));
      final list = await repo.getNotifications(perPage: 50);
      ref.read(notificationsProvider.notifier).state = list;
      final unread = list.where((n) => !n.read).length;
      ref.read(unreadCountProvider.notifier).state = unread;
    } catch (_) {} finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markAllRead() async {
    try {
      final repo = NotificationRepository(ref.read(dioProvider));
      await repo.markAllRead();
      ref.read(notificationsProvider.notifier).update((list) => list.map((n) => NotificationModel(id: n.id, type: n.type, data: n.data, read: true, createdAt: n.createdAt)).toList());
      ref.read(unreadCountProvider.notifier).state = 0;
      toastification.show(context: context, type: ToastificationType.success, title: const Text('All marked as read'), autoCloseDuration: const Duration(seconds: 2));
    } catch (_) {}
  }

  Future<void> _markRead(int id) async {
    try {
      final repo = NotificationRepository(ref.read(dioProvider));
      await repo.markRead(id);
      ref.read(notificationsProvider.notifier).update((list) => list.map((n) => n.id == id ? NotificationModel(id: n.id, type: n.type, data: n.data, read: true, createdAt: n.createdAt) : n).toList());
      ref.read(unreadCountProvider.notifier).update((c) => (c - 1).clamp(0, 999));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsProvider);
    final unread = ref.watch(unreadCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications${unread > 0 ? ' ($unread)' : ''}'),
        actions: [
          if (unread > 0)
            TextButton(onPressed: _markAllRead, child: const Text('Mark all read')),
        ],
      ),
      body: _loading
        ? ListView.builder(itemCount: 6, itemBuilder: (_, __) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), child: const CardSkeletonWidget()))
        : notifications.isEmpty
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.notifications_none_outlined, size: 64, color: AppColors.gray300),
              SizedBox(height: 12),
              Text('No notifications yet', style: TextStyle(color: AppColors.gray400)),
            ]))
          : RefreshIndicator(
              onRefresh: _fetch,
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (_, i) {
                  final n = notifications[i];
                  return Container(
                    color: n.read ? null : AppColors.primaryLight.withOpacity(0.3),
                    child: ListTile(
                      leading: Container(
                        width: 10, height: 10,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: n.read ? AppColors.gray200 : AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Text(NotificationModel.labelForType(n.type), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.gray500, letterSpacing: 0.5)),
                      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(n.message, style: const TextStyle(color: AppColors.gray800)),
                        if (n.dolilId != null)
                          GestureDetector(
                            onTap: () { _markRead(n.id); context.push('/dashboard/dolils/${n.dolilId}'); },
                            child: Text(n.dolilTitle ?? 'Dolil #${n.dolilId}', style: const TextStyle(fontSize: 12, color: AppColors.primary)),
                          ),
                        Text(DateFormatter.timeAgo(n.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
                      ]),
                      trailing: !n.read ? IconButton(icon: const Icon(Icons.check, size: 18, color: AppColors.gray300), onPressed: () => _markRead(n.id)) : null,
                    ),
                  );
                },
              ),
            ),
    );
  }
}
