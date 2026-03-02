import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/stat_card_widget.dart';
import '../../../shared/widgets/status_badge_widget.dart';
import '../../../shared/widgets/loading_skeleton_widget.dart';
import '../repository/dashboard_repository.dart';
import '../../../shared/providers/dio_provider.dart';
import '../../../shared/providers/auth_state_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _loading = true;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final repo = DashboardRepository(ref.read(dioProvider));
      final stats = await repo.getStats(
        from: _dateRange?.start.toIso8601String().split('T').first,
        to: _dateRange?.end.toIso8601String().split('T').first,
      );
      if (mounted) setState(() => _stats = stats);
    } catch (_) {} finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    if (range != null) {
      setState(() => _dateRange = range);
      _fetch();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${user?.name.split(' ').first ?? 'User'}'),
        actions: [
          IconButton(onPressed: _pickDateRange, icon: const Icon(Icons.date_range_outlined), tooltip: 'Filter by date'),
          if (_dateRange != null)
            IconButton(onPressed: () { setState(() => _dateRange = null); _fetch(); }, icon: const Icon(Icons.clear)),
        ],
      ),
      body: _loading
        ? Padding(padding: const EdgeInsets.all(16), child: Column(children: [
            GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.5, children: List.generate(4, (_) => const CardSkeletonWidget())),
          ]))
        : RefreshIndicator(
            onRefresh: _fetch,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (_dateRange != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Showing: ${DateFormat('MMM d').format(_dateRange!.start)} – ${DateFormat('MMM d, yyyy').format(_dateRange!.end)}',
                      style: const TextStyle(color: AppColors.gray500, fontSize: 13),
                    ),
                  ),

                // Stat cards grid
                if (_stats != null) ...[
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: _buildStatCards(),
                  ),
                  const SizedBox(height: 24),

                  // Recent dolils
                  if (_stats!['recent_dolils'] != null && (_stats!['recent_dolils'] as List).isNotEmpty) ...[
                    const Text('Recent Dolils', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.gray900)),
                    const SizedBox(height: 12),
                    ...(_stats!['recent_dolils'] as List).take(5).map((dolil) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(dolil['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(dolil['created_at']?.toString().substring(0, 10) ?? '', style: const TextStyle(fontSize: 12)),
                        trailing: StatusBadgeWidget(status: dolil['status'] ?? 'pending'),
                        onTap: () => context.push('/dashboard/dolils/${dolil['id']}'),
                      ),
                    )),
                  ],
                ],
              ]),
            ),
          ),
    );
  }

  List<Widget> _buildStatCards() {
    final s = _stats!;
    return [
      StatCardWidget(label: 'Total Dolils', value: '${s['total_dolils'] ?? 0}', icon: Icons.description_outlined, color: AppColors.primary),
      StatCardWidget(label: 'Pending', value: '${s['pending'] ?? 0}', icon: Icons.hourglass_empty, color: AppColors.warning),
      StatCardWidget(label: 'In Progress', value: '${s['in_progress'] ?? 0}', icon: Icons.sync, color: AppColors.info),
      StatCardWidget(label: 'Completed', value: '${s['completed'] ?? 0}', icon: Icons.check_circle_outline, color: AppColors.success),
    ];
  }
}
