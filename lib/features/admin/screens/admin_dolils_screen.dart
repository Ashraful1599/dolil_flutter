import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/models/dolil_model.dart';
import '../../../shared/widgets/status_badge_widget.dart';
import '../repository/admin_repository.dart';
import '../../../shared/providers/dio_provider.dart';

class AdminDolilsScreen extends ConsumerStatefulWidget {
  const AdminDolilsScreen({super.key});

  @override
  ConsumerState<AdminDolilsScreen> createState() => _AdminDolilsScreenState();
}

class _AdminDolilsScreenState extends ConsumerState<AdminDolilsScreen> {
  final _searchCtrl = TextEditingController();
  List<DolilModel> _dolils = [];
  bool _loading = true;
  int _page = 1, _total = 0, _totalPages = 1;
  String? _statusFilter;

  @override
  void initState() { super.initState(); _fetch(); }
  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _fetch({int page = 1}) async {
    setState(() { _loading = true; _page = page; });
    try {
      final repo = AdminRepository(ref.read(dioProvider));
      final result = await repo.getDolils(
        search: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
        status: _statusFilter,
        page: page,
      );
      if (mounted) setState(() {
        _dolils = result['dolils'] as List<DolilModel>;
        _total = result['total'] as int;
        _totalPages = result['last_page'] as int;
        _loading = false;
      });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('All Dolils ($_total)')),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: Column(children: [
          TextField(
            controller: _searchCtrl,
            decoration: const InputDecoration(hintText: 'Search dolils...', prefixIcon: Icon(Icons.search), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
            onSubmitted: (_) => _fetch(),
          ),
          const SizedBox(height: 8),
          SizedBox(height: 36, child: ListView(scrollDirection: Axis.horizontal, children: [
            ChoiceChip(label: const Text('All'), selected: _statusFilter == null, onSelected: (_) { setState(() => _statusFilter = null); _fetch(); }),
            const SizedBox(width: 8),
            ...['pending', 'in_progress', 'completed', 'archived'].map((s) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(label: Text(s.replaceAll('_', ' ')), selected: _statusFilter == s, onSelected: (_) { setState(() => _statusFilter = s); _fetch(); }),
            )),
          ])),
        ])),

        Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _fetch(page: 1),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _dolils.length + (_totalPages > 1 ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == _dolils.length) return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      IconButton(onPressed: _page > 1 ? () => _fetch(page: _page - 1) : null, icon: const Icon(Icons.chevron_left)),
                      Text('$_page / $_totalPages'),
                      IconButton(onPressed: _page < _totalPages ? () => _fetch(page: _page + 1) : null, icon: const Icon(Icons.chevron_right)),
                    ]),
                  );
                  final d = _dolils[i];
                  return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
                    title: Row(children: [
                      Expanded(child: Text(d.title, style: const TextStyle(fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      StatusBadgeWidget(status: d.status),
                    ]),
                    subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      if (d.createdByName != null) Text('By: ${d.createdByName}', style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
                      Text(DateFormatter.format(d.createdAt), style: const TextStyle(fontSize: 12, color: AppColors.gray400)),
                    ]),
                    onTap: () => context.push('/dashboard/dolils/${d.id}'),
                  ));
                },
              ),
            )),
      ]),
    );
  }
}
