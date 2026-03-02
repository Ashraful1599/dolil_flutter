import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/star_rating_widget.dart';
import '../repositories/writer_repository.dart';
import '../../../shared/providers/dio_provider.dart';

class WriterProfileScreen extends ConsumerStatefulWidget {
  final int writerId;

  const WriterProfileScreen({super.key, required this.writerId});

  @override
  ConsumerState<WriterProfileScreen> createState() => _WriterProfileScreenState();
}

class _WriterProfileScreenState extends ConsumerState<WriterProfileScreen> {
  UserModel? _writer;
  bool _loading = true;
  bool _booking = false;

  // Booking form
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose(); _emailCtrl.dispose(); _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    try {
      final repo = WriterRepository(ref.read(dioProvider));
      final writer = await repo.getWriter(widget.writerId);
      if (mounted) setState(() { _writer = writer; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _book() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      toastification.show(context: context, type: ToastificationType.warning, title: const Text('Please fill all fields and select a date'), autoCloseDuration: const Duration(seconds: 3));
      return;
    }
    setState(() => _booking = true);
    try {
      final repo = WriterRepository(ref.read(dioProvider));
      await repo.bookAppointment(widget.writerId, {
        'client_name': _nameCtrl.text.trim(),
        'client_phone': _phoneCtrl.text.trim(),
        if (_emailCtrl.text.trim().isNotEmpty) 'client_email': _emailCtrl.text.trim(),
        'preferred_date': _selectedDate!.toIso8601String().split('T').first,
        if (_msgCtrl.text.trim().isNotEmpty) 'message': _msgCtrl.text.trim(),
      });
      toastification.show(context: context, type: ToastificationType.success, title: const Text('Appointment requested!'), autoCloseDuration: const Duration(seconds: 3));
      _nameCtrl.clear(); _phoneCtrl.clear(); _emailCtrl.clear(); _msgCtrl.clear();
      setState(() => _selectedDate = null);
    } catch (e) {
      toastification.show(context: context, type: ToastificationType.error, title: const Text('Booking failed'), description: Text(e.toString().replaceFirst('Exception: ', '')), autoCloseDuration: const Duration(seconds: 4));
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_writer == null) return const Scaffold(body: Center(child: Text('Writer not found')));

    final writer = _writer!;
    return Scaffold(
      appBar: AppBar(title: Text(writer.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Profile header
          Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
            AvatarWidget(name: writer.name, imageUrl: writer.avatar, radius: 40),
            const SizedBox(height: 12),
            Text(writer.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            if (writer.registrationNumber != null) ...[
              const SizedBox(height: 4),
              Text('Reg: ${writer.registrationNumber}', style: const TextStyle(color: AppColors.gray500)),
            ],
            if (writer.officeName != null) ...[
              const SizedBox(height: 2),
              Text(writer.officeName!, style: const TextStyle(color: AppColors.gray500)),
            ],
            if (writer.averageRating != null) ...[
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                StarRatingWidget(rating: writer.averageRating!),
                const SizedBox(width: 8),
                Text('${writer.averageRating!.toStringAsFixed(1)} (${writer.totalReviews ?? 0} reviews)', style: const TextStyle(color: AppColors.gray500)),
              ]),
            ],
            if (writer.districtName != null || writer.upazilaName != null) ...[
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.gray400),
                const SizedBox(width: 4),
                Text([writer.upazilaName, writer.districtName].where((s) => s != null).join(', '), style: const TextStyle(color: AppColors.gray500, fontSize: 13)),
              ]),
            ],
          ]))),

          if (writer.bio != null) ...[
            const SizedBox(height: 16),
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('About', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(writer.bio!, style: const TextStyle(color: AppColors.gray600, height: 1.5)),
            ]))),
          ],

          // Booking form
          const SizedBox(height: 16),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Book an Appointment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Form(key: _formKey, child: Column(children: [
              TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Your Name *'), validator: (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone *'), keyboardType: TextInputType.phone, validator: (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email (optional)'), keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 1)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 90)));
                  if (date != null) setState(() => _selectedDate = date);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(border: Border.all(color: AppColors.gray200), borderRadius: BorderRadius.circular(10), color: AppColors.white),
                  child: Row(children: [
                    const Icon(Icons.calendar_today_outlined, color: AppColors.gray400),
                    const SizedBox(width: 12),
                    Text(_selectedDate == null ? 'Select preferred date *' : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}', style: TextStyle(color: _selectedDate == null ? AppColors.gray400 : AppColors.gray900)),
                  ]),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(controller: _msgCtrl, decoration: const InputDecoration(labelText: 'Message (optional)'), maxLines: 3),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _booking ? null : _book,
                child: _booking ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Request Appointment'),
              ),
            ])),
          ]))),

          const SizedBox(height: 32),
        ]),
      ),
    );
  }
}
