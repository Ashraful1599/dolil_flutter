import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../repository/admin_repository.dart';
import '../../../shared/providers/dio_provider.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final _searchCtrl = TextEditingController();
  List<UserModel> _users = [];
  bool _loading = true;
  int _page = 1, _total = 0, _totalPages = 1;
  String? _roleFilter;

  @override
  void initState() { super.initState(); _fetch(); }
  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _fetch({int page = 1}) async {
    setState(() { _loading = true; _page = page; });
    try {
      final repo = AdminRepository(ref.read(dioProvider));
      final result = await repo.getUsers(search: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(), role: _roleFilter, page: page);
      if (mounted) setState(() {
        _users = result['users'] as List<UserModel>;
        _total = result['total'] as int;
        _totalPages = result['last_page'] as int;
        _loading = false;
      });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _editUser(UserModel user) async {
    String selectedRole = user.role;
    bool isActive = user.isActive;
    final saved = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: Text('Edit ${user.name}'),
      content: StatefulBuilder(builder: (ctx, setState) => Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Role', style: TextStyle(fontWeight: FontWeight.w500)),
        ...['user', 'dolil_writer', 'admin'].map((r) => RadioListTile<String>(
          title: Text(r.replaceAll('_', ' ')),
          value: r, groupValue: selectedRole,
          onChanged: (v) => setState(() => selectedRole = v!),
        )),
        SwitchListTile(title: const Text('Active'), value: isActive, onChanged: (v) => setState(() => isActive = v)),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
      ],
    ));

    if (saved == true) {
      try {
        final repo = AdminRepository(ref.read(dioProvider));
        final updated = await repo.updateUser(user.id, {'role': selectedRole, 'is_active': isActive});
        setState(() => _users = _users.map((u) => u.id == user.id ? updated : u).toList());
        toastification.show(context: context, type: ToastificationType.success, title: const Text('User updated'), autoCloseDuration: const Duration(seconds: 2));
      } catch (e) {
        toastification.show(context: context, type: ToastificationType.error, title: const Text('Update failed'), autoCloseDuration: const Duration(seconds: 3));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Users ($_total)')),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: Column(children: [
          Row(children: [
            Expanded(child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(hintText: 'Search users...', prefixIcon: Icon(Icons.search), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
              onSubmitted: (_) => _fetch(),
            )),
          ]),
          const SizedBox(height: 8),
          SizedBox(height: 36, child: ListView(scrollDirection: Axis.horizontal, children: [
            ChoiceChip(label: const Text('All'), selected: _roleFilter == null, onSelected: (_) { setState(() => _roleFilter = null); _fetch(); }),
            const SizedBox(width: 8),
            ...['user', 'dolil_writer', 'admin'].map((r) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(label: Text(r.replaceAll('_', ' ')), selected: _roleFilter == r, onSelected: (_) { setState(() => _roleFilter = r); _fetch(); }),
            )),
          ])),
        ])),

        Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _fetch(page: 1),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _users.length + (_totalPages > 1 ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == _users.length) return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      IconButton(onPressed: _page > 1 ? () => _fetch(page: _page - 1) : null, icon: const Icon(Icons.chevron_left)),
                      Text('$_page / $_totalPages'),
                      IconButton(onPressed: _page < _totalPages ? () => _fetch(page: _page + 1) : null, icon: const Icon(Icons.chevron_right)),
                    ]),
                  );
                  final u = _users[i];
                  return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
                    leading: AvatarWidget(name: u.name, imageUrl: u.avatar, radius: 20),
                    title: Row(children: [
                      Expanded(child: Text(u.name, style: const TextStyle(fontWeight: FontWeight.w500))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: u.isAdmin ? const Color(0xFFFEE2E2) : u.isDolilWriter ? const Color(0xFFF3E8FF) : AppColors.gray100, borderRadius: BorderRadius.circular(12)),
                        child: Text(u.role.replaceAll('_', ' '), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: u.isAdmin ? AppColors.danger : u.isDolilWriter ? AppColors.secondary : AppColors.gray600)),
                      ),
                    ]),
                    subtitle: Text(u.email, style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      if (!u.isActive) const Icon(Icons.block, size: 14, color: AppColors.danger),
                      IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () => _editUser(u)),
                    ]),
                  ));
                },
              ),
            )),
      ]),
    );
  }
}
