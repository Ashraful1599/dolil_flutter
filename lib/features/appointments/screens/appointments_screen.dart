import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/models/appointment_model.dart';
import '../../../shared/widgets/status_badge_widget.dart';
import '../../../shared/widgets/loading_skeleton_widget.dart';
import '../../../shared/widgets/confirm_dialog_widget.dart';
import '../repository/appointment_repository.dart';
import '../../../shared/providers/dio_provider.dart';
import '../../../shared/providers/auth_state_provider.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  bool _loading = true;
  List<AppointmentModel> _all = [];

  final _tabs = ['All', 'Pending', 'Confirmed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _fetch();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final repo = AppointmentRepository(ref.read(dioProvider));
      final list = await repo.getAppointments();
      if (mounted) setState(() { _all = list; });
    } catch (_) {} finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<AppointmentModel> _filtered(String tab) {
    if (tab == 'All') return _all;
    return _all.where((a) => a.status.toLowerCase() == tab.toLowerCase()).toList();
  }

  Future<void> _update(int id, String status) async {
    final confirmed = await showConfirmDialog(context,
      title: status == 'confirmed' ? 'Confirm Appointment' : 'Cancel Appointment',
      message: 'Are you sure?',
      confirmLabel: status == 'confirmed' ? 'Confirm' : 'Cancel',
      danger: status == 'cancelled',
    );
    if (!confirmed) return;
    try {
      final repo = AppointmentRepository(ref.read(dioProvider));
      final updated = await repo.updateAppointment(id, status);
      setState(() => _all = _all.map((a) => a.id == id ? updated : a).toList());
      toastification.show(context: context, type: ToastificationType.success, title: Text('Appointment $status'), autoCloseDuration: const Duration(seconds: 2));
    } catch (e) {
      toastification.show(context: context, type: ToastificationType.error, title: const Text('Action failed'), autoCloseDuration: const Duration(seconds: 3));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isDolilWriter = user?.isDolilWriter == true || user?.isAdmin == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
          isScrollable: true,
        ),
      ),
      body: _loading
        ? ListView.builder(itemCount: 5, itemBuilder: (_, __) => Padding(padding: const EdgeInsets.all(8), child: const CardSkeletonWidget()))
        : TabBarView(
            controller: _tabCtrl,
            children: _tabs.map((tab) {
              final list = _filtered(tab);
              if (list.isEmpty) return const Center(child: Text('No appointments', style: TextStyle(color: AppColors.gray400)));
              return RefreshIndicator(
                onRefresh: _fetch,
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final a = list[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(child: Text(a.clientName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
                          StatusBadgeWidget(status: a.status),
                        ]),
                        const SizedBox(height: 6),
                        _infoRow(Icons.phone_outlined, a.clientPhone),
                        if (a.clientEmail != null) _infoRow(Icons.email_outlined, a.clientEmail!),
                        _infoRow(Icons.calendar_today_outlined, DateFormatter.format(a.preferredDate)),
                        if (a.message != null) _infoRow(Icons.message_outlined, a.message!),
                        if (isDolilWriter && a.status == 'pending') ...[
                          const SizedBox(height: 12),
                          Row(children: [
                            Expanded(child: OutlinedButton.icon(onPressed: () => _update(a.id, 'cancelled'), icon: const Icon(Icons.close, size: 16), label: const Text('Cancel'), style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger), minimumSize: const Size(0, 36)))),
                            const SizedBox(width: 8),
                            Expanded(child: ElevatedButton.icon(onPressed: () => _update(a.id, 'confirmed'), icon: const Icon(Icons.check, size: 16), label: const Text('Confirm'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, minimumSize: const Size(0, 36)))),
                          ]),
                        ],
                      ])),
                    );
                  },
                ),
              );
            }).toList(),
          ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(children: [
      Icon(icon, size: 14, color: AppColors.gray400),
      const SizedBox(width: 6),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.gray600))),
    ]),
  );
}
