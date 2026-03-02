import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/stat_card_widget.dart';

import '../../../shared/widgets/avatar_widget.dart';
import '../repository/admin_repository.dart';
import '../../../shared/providers/dio_provider.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() { super.initState(); _fetch(); }

  Future<void> _fetch() async {
    try {
      final repo = AdminRepository(ref.read(dioProvider));
      final stats = await repo.getStats();
      if (mounted) setState(() { _stats = stats; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _fetch,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (_stats != null) ...[
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.4,
                    children: [
                      StatCardWidget(label: 'Total Users', value: '${_stats!['total_users'] ?? 0}', icon: Icons.people_outline),
                      StatCardWidget(label: 'Deed Writers', value: '${_stats!['total_writers'] ?? 0}', icon: Icons.edit_document, color: AppColors.secondary),
                      StatCardWidget(label: 'Total Dolils', value: '${_stats!['total_dolils'] ?? 0}', icon: Icons.description_outlined, color: AppColors.info),
                      StatCardWidget(label: 'Completed', value: '${_stats!['completed_dolils'] ?? 0}', icon: Icons.check_circle_outline, color: AppColors.success),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Quick nav
                  Row(children: [
                    Expanded(child: Card(child: InkWell(
                      onTap: () => context.push('/admin/users'),
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(padding: EdgeInsets.all(16), child: Column(children: [
                        Icon(Icons.manage_accounts_outlined, size: 32, color: AppColors.primary),
                        SizedBox(height: 8),
                        Text('Manage Users', style: TextStyle(fontWeight: FontWeight.w600)),
                      ])),
                    ))),
                    const SizedBox(width: 12),
                    Expanded(child: Card(child: InkWell(
                      onTap: () => context.push('/admin/dolils'),
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(padding: EdgeInsets.all(16), child: Column(children: [
                        Icon(Icons.description_outlined, size: 32, color: AppColors.info),
                        SizedBox(height: 8),
                        Text('Manage Dolils', style: TextStyle(fontWeight: FontWeight.w600)),
                      ])),
                    ))),
                  ]),
                  const SizedBox(height: 24),

                  // Recent users
                  if (_stats!['recent_users'] != null) ...[
                    const Text('Recent Users', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...(_stats!['recent_users'] as List).take(5).map((u) => ListTile(
                      leading: AvatarWidget(name: u['name'] ?? '?', imageUrl: u['avatar']),
                      title: Text(u['name'] ?? ''),
                      subtitle: Text(u['email'] ?? '', style: const TextStyle(fontSize: 12)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(12)),
                        child: Text(u['role'] ?? '', style: const TextStyle(fontSize: 11, color: AppColors.gray600)),
                      ),
                    )),
                  ],
                ],
              ]),
            ),
          ),
    );
  }
}
