import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/models/dolil_model.dart';
import '../../../shared/widgets/status_badge_widget.dart';
import '../../../shared/widgets/loading_skeleton_widget.dart';
import '../../../shared/widgets/confirm_dialog_widget.dart';
import '../repositories/dolil_repository.dart';
import '../../../shared/providers/dio_provider.dart';

class DolilsListScreen extends ConsumerStatefulWidget {
  const DolilsListScreen({super.key});

  @override
  ConsumerState<DolilsListScreen> createState() => _DolilsListScreenState();
}

class _DolilsListScreenState extends ConsumerState<DolilsListScreen> {
  final _searchCtrl = TextEditingController();
  List<DolilModel> _dolils = [];
  bool _loading = true;
  int _page = 1, _totalPages = 1, _total = 0;
  String? _statusFilter;
  DateTimeRange? _dateRange;
  String _sort = 'created_at', _dir = 'desc';

  final _statuses = ['All', 'pending', 'in_progress', 'completed', 'archived'];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetch({int page = 1}) async {
    setState(() { _loading = true; _page = page; });
    try {
      final repo = DolilRepository(ref.read(dioProvider));
      final result = await repo.getDolils(
        search: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
        status: _statusFilter == 'All' || _statusFilter == null ? null : _statusFilter,
        from: _dateRange?.start.toIso8601String().split('T').first,
        to: _dateRange?.end.toIso8601String().split('T').first,
        sort: _sort,
        dir: _dir,
        page: page,
      );
      if (mounted) setState(() {
        _dolils = result['dolils'] as List<DolilModel>;
        _total = result['total'] as int;
        _totalPages = result['last_page'] as int;
      });
    } catch (_) {} finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(int id) async {
    final confirmed = await showConfirmDialog(context, title: 'Delete Dolil', message: 'Are you sure you want to delete this dolil? This cannot be undone.', confirmLabel: 'Delete', danger: true);
    if (!confirmed) return;
    try {
      final repo = DolilRepository(ref.read(dioProvider));
      await repo.deleteDolil(id);
      setState(() => _dolils.removeWhere((d) => d.id == id));
      toastification.show(context: context, type: ToastificationType.success, title: const Text('Dolil deleted'), autoCloseDuration: const Duration(seconds: 2));
    } catch (e) {
      toastification.show(context: context, type: ToastificationType.error, title: const Text('Delete failed'), autoCloseDuration: const Duration(seconds: 3));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dolils ($_total)'),
        actions: [
          IconButton(
            onPressed: () => context.push('/dashboard/dolils/create').then((_) => _fetch()),
            icon: const Icon(Icons.add),
            tooltip: 'Create Dolil',
          ),
        ],
      ),
      body: Column(children: [
        // Filters
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            Row(children: [
              Expanded(child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Search dolils...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchCtrl.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchCtrl.clear(); _fetch(); }) : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onSubmitted: (_) => _fetch(),
              )),
              const SizedBox(width: 8),
              IconButton(onPressed: () async {
                final range = await showDateRangePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime.now());
                if (range != null) { setState(() => _dateRange = range); _fetch(); }
              }, icon: const Icon(Icons.date_range_outlined), tooltip: 'Date filter'),
            ]),
            const SizedBox(height: 8),
            SizedBox(height: 36, child: ListView(scrollDirection: Axis.horizontal, children: _statuses.map((s) {
              final selected = _statusFilter == s || (_statusFilter == null && s == 'All');
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(label: Text(s), selected: selected, onSelected: (_) { setState(() => _statusFilter = s == 'All' ? null : s); _fetch(); }),
              );
            }).toList())),
          ]),
        ),

        // List
        Expanded(child: _loading
          ? ListView.builder(itemCount: 6, itemBuilder: (_, __) => Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: const CardSkeletonWidget()))
          : _dolils.isEmpty
            ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.description_outlined, size: 64, color: AppColors.gray300),
                SizedBox(height: 12),
                Text('No dolils found', style: TextStyle(color: AppColors.gray400)),
              ]))
            : RefreshIndicator(
                onRefresh: () => _fetch(page: 1),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _dolils.length + (_totalPages > 1 ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == _dolils.length) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          IconButton(onPressed: _page > 1 ? () => _fetch(page: _page - 1) : null, icon: const Icon(Icons.chevron_left)),
                          Text('$_page / $_totalPages'),
                          IconButton(onPressed: _page < _totalPages ? () => _fetch(page: _page + 1) : null, icon: const Icon(Icons.chevron_right)),
                        ]),
                      );
                    }
                    final d = _dolils[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        title: Row(children: [
                          Expanded(child: Text(d.title, style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          StatusBadgeWidget(status: d.status),
                        ]),
                        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const SizedBox(height: 4),
                          if (d.partyA != null) Text('Party A: ${d.partyA}', style: const TextStyle(fontSize: 12, color: AppColors.gray500), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(DateFormatter.format(d.createdAt), style: const TextStyle(fontSize: 12, color: AppColors.gray400)),
                        ]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                          onPressed: () => _delete(d.id),
                        ),
                        onTap: () => context.push('/dashboard/dolils/${d.id}'),
                      ),
                    );
                  },
                ),
              ),
        ),
      ]),
    );
  }
}
