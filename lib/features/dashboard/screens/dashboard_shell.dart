import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/auth_state_provider.dart';
import '../../../shared/models/user_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_providers.dart';
import '../../notifications/providers/notification_providers.dart';


class DashboardShell extends ConsumerStatefulWidget {
  final Widget child;
  final String location;

  const DashboardShell({super.key, required this.child, required this.location});

  @override
  ConsumerState<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends ConsumerState<DashboardShell> {
  @override
  void initState() {
    super.initState();
    // Initialize SSE when shell mounts
    ref.read(sseNotifierProvider);
    // Load initial unread count
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final repo = ref.read(notificationRepositoryProvider);
      final count = await repo.getUnreadCount();
      ref.read(unreadCountProvider.notifier).state = count;
    } catch (_) {}
  }

  List<_NavItem> _navItems(UserModel? user) {
    if (user?.isAdmin == true) {
      return [
        _NavItem('/admin', Icons.shield_outlined, Icons.shield, 'Admin'),
        _NavItem('/admin/users', Icons.people_outline, Icons.people, 'Users'),
        _NavItem('/admin/dolils', Icons.description_outlined, Icons.description, 'Dolils'),
        _NavItem('/dashboard/appointments', Icons.calendar_today_outlined, Icons.calendar_today, 'Appointments'),
        _NavItem('/admin/notifications', Icons.notifications_outlined, Icons.notifications, 'Notifications', badge: true),
      ];
    }
    return [
      _NavItem('/dashboard', Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
      _NavItem('/dashboard/dolils', Icons.description_outlined, Icons.description, 'Dolils'),
      _NavItem('/dashboard/appointments', Icons.calendar_today_outlined, Icons.calendar_today, 'Appointments'),
      _NavItem('/dashboard/notifications', Icons.notifications_outlined, Icons.notifications, 'Notifications', badge: true),
      _NavItem('/dashboard/profile', Icons.person_outline, Icons.person, 'Profile'),
    ];
  }

  int _currentIndex(List<_NavItem> items) {
    final loc = widget.location;
    for (int i = 0; i < items.length; i++) {
      if (loc == items[i].route || (items[i].route != '/dashboard' && items[i].route != '/admin' && loc.startsWith(items[i].route))) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final unreadCount = ref.watch(unreadCountProvider);
    final navItems = _navItems(user);
    final currentIndex = _currentIndex(navItems);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(children: [
          Container(width: 26, height: 26, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.description, size: 14, color: Colors.white)),
          const SizedBox(width: 8),
          const Text.rich(TextSpan(children: [
            TextSpan(text: 'Dolil', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.gray900)),
            TextSpan(text: 'BD', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          ])),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.gray600),
            tooltip: 'Logout',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Logout', style: TextStyle(color: AppColors.danger))),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                await ref.read(authNotifierProvider.notifier).logout();
                if (context.mounted) context.go('/home');
              }
            },
          ),
        ],
      ),
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => context.go(navItems[i].route),
        destinations: navItems.map((item) {
          final isNotif = item.badge;
          return NavigationDestination(
            icon: isNotif && unreadCount > 0
              ? Badge(label: Text('${unreadCount > 99 ? '99+' : unreadCount}'), child: Icon(item.icon))
              : Icon(item.icon),
            selectedIcon: isNotif && unreadCount > 0
              ? Badge(label: Text('${unreadCount > 99 ? '99+' : unreadCount}'), child: Icon(item.activeIcon))
              : Icon(item.activeIcon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}

class _NavItem {
  final String route;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool badge;

  const _NavItem(this.route, this.icon, this.activeIcon, this.label, {this.badge = false});
}
