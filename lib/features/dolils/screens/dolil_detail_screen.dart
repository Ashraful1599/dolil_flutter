import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:toastification/toastification.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/file_utils.dart';
import '../../../shared/models/dolil_model.dart';
import '../../../shared/models/comment_model.dart';
import '../../../shared/models/document_model.dart';
import '../../../shared/models/payment_model.dart';
import '../../../shared/models/review_model.dart';
import '../../../shared/models/activity_model.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/widgets/status_badge_widget.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/star_rating_widget.dart';
import '../../../shared/widgets/activity_timeline_widget.dart';
import '../../../shared/widgets/confirm_dialog_widget.dart';
import '../repositories/dolil_repository.dart';
import '../repositories/comment_repository.dart';
import '../repositories/document_repository.dart';
import '../repositories/payment_repository.dart';
import '../repositories/review_repository.dart';
import '../../../shared/providers/dio_provider.dart';
import '../../../shared/providers/auth_state_provider.dart';

class DolilDetailScreen extends ConsumerStatefulWidget {
  final int dolilId;

  const DolilDetailScreen({super.key, required this.dolilId});

  @override
  ConsumerState<DolilDetailScreen> createState() => _DolilDetailScreenState();
}

class _DolilDetailScreenState extends ConsumerState<DolilDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  DolilModel? _dolil;
  bool _loading = true;
  UserModel? _me;

  final _tabs = ['Details', 'Notes', 'Payments', 'Documents', 'Reviews', 'Comments', 'Activity'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _me = ref.read(currentUserProvider);
    _fetchDolil();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchDolil() async {
    try {
      final repo = DolilRepository(ref.read(dioProvider));
      final dolil = await repo.getDolil(widget.dolilId);
      if (mounted) setState(() { _dolil = dolil; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool get _canEdit {
    if (_me == null || _dolil == null) return false;
    return _me!.isAdmin || _me!.isDolilWriter || _dolil!.createdById == _me!.id || _dolil!.assignedToId == _me!.id;
  }

  bool get _canPayment {
    if (_me == null || _dolil == null) return false;
    return _me!.isAdmin || _dolil!.assignedToId == _me!.id || (_dolil!.createdById == _me!.id && _me!.isDolilWriter);
  }

  bool get _canReview {
    if (_me == null || _dolil == null) return false;
    if (!_dolil!.isCompletedOrArchived()) return false;
    if (_me!.isDolilWriter || _dolil!.assignedToId == _me!.id) return false;
    return _me!.isAdmin || _me!.isUser;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_dolil == null) return const Scaffold(body: Center(child: Text('Dolil not found')));

    return Scaffold(
      appBar: AppBar(
        title: Text(_dolil!.title, overflow: TextOverflow.ellipsis),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
          isScrollable: true,
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _DetailsTab(dolil: _dolil!, canEdit: _canEdit, onUpdated: (d) => setState(() => _dolil = d), dioProvider: dioProvider),
          _NotesTab(dolil: _dolil!, canEdit: _canEdit, onUpdated: (d) => setState(() => _dolil = d), dioProvider: dioProvider),
          _PaymentsTab(dolilId: widget.dolilId, canAdd: _canPayment, isAdmin: _me?.isAdmin ?? false, dioProvider: dioProvider),
          _DocumentsTab(dolilId: widget.dolilId, canEdit: _canEdit, dioProvider: dioProvider),
          _ReviewsTab(dolilId: widget.dolilId, canReview: _canReview, currentUserId: _me?.id, dioProvider: dioProvider),
          _CommentsTab(dolilId: widget.dolilId, currentUserId: _me?.id, isAdmin: _me?.isAdmin ?? false, dioProvider: dioProvider),
          _ActivityTab(dolilId: widget.dolilId, dioProvider: dioProvider),
        ],
      ),
    );
  }
}

// ──────────── Details Tab ────────────
class _DetailsTab extends ConsumerWidget {
  final DolilModel dolil;
  final bool canEdit;
  final void Function(DolilModel) onUpdated;
  final dynamic dioProvider;

  const _DetailsTab({required this.dolil, required this.canEdit, required this.onUpdated, required this.dioProvider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(dolil.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            StatusBadgeWidget(status: dolil.status),
          ]),
          const Divider(height: 24),
          if (dolil.description != null) _row('Description', dolil.description!),
          if (dolil.partyA != null) _row('Party A', dolil.partyA!),
          if (dolil.partyB != null) _row('Party B', dolil.partyB!),
          if (dolil.partyAContact != null) _row('Party A Contact', dolil.partyAContact!),
          if (dolil.partyBContact != null) _row('Party B Contact', dolil.partyBContact!),
          const Divider(height: 24),
          if (dolil.mouza != null) _row('Mouza', dolil.mouza!),
          if (dolil.khatian != null) _row('Khatian', dolil.khatian!),
          if (dolil.plot != null) _row('Plot', dolil.plot!),
          if (dolil.area != null) _row('Area', dolil.area!),
          if (dolil.landDescription != null) _row('Land Description', dolil.landDescription!),
          if (dolil.registrationOffice != null) _row('Registration Office', dolil.registrationOffice!),
          const Divider(height: 24),
          if (dolil.createdByName != null) _row('Created By', dolil.createdByName!),
          if (dolil.assignedToName != null) _row('Assigned To', dolil.assignedToName!),
          _row('Created', DateFormatter.format(dolil.createdAt)),
          _row('Updated', DateFormatter.format(dolil.updatedAt)),
        ]))),

        if (canEdit) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _showEditStatusDialog(context, ref),
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text('Update Status'),
          ),
        ],
      ]),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 140, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.gray500, fontWeight: FontWeight.w500))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13, color: AppColors.gray800))),
    ]),
  );

  void _showEditStatusDialog(BuildContext context, WidgetRef ref) {
    String selected = dolil.status;
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Update Status'),
      content: StatefulBuilder(builder: (ctx, setState) => Column(
        mainAxisSize: MainAxisSize.min,
        children: ['pending', 'in_progress', 'completed', 'archived'].map((s) => RadioListTile<String>(
          title: Text(s.replaceAll('_', ' ').toUpperCase()),
          value: s,
          groupValue: selected,
          onChanged: (v) => setState(() => selected = v!),
        )).toList(),
      )),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () async {
          Navigator.pop(ctx);
          try {
            final repo = DolilRepository(ref.read(dioProvider));
            final updated = await repo.updateDolil(dolil.id, {'status': selected});
            onUpdated(updated);
          } catch (_) {}
        }, child: const Text('Update')),
      ],
    ));
  }
}

// ──────────── Notes Tab ────────────
class _NotesTab extends ConsumerStatefulWidget {
  final DolilModel dolil;
  final bool canEdit;
  final void Function(DolilModel) onUpdated;
  final dynamic dioProvider;

  const _NotesTab({required this.dolil, required this.canEdit, required this.onUpdated, required this.dioProvider});

  @override
  ConsumerState<_NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends ConsumerState<_NotesTab> {
  late TextEditingController _ctrl;
  bool _editing = false, _saving = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.dolil.notes ?? '');
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final repo = DolilRepository(ref.read(widget.dioProvider));
      final updated = await repo.updateDolil(widget.dolil.id, {'notes': _ctrl.text});
      widget.onUpdated(updated);
      setState(() => _editing = false);
    } catch (_) {} finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('Notes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const Spacer(),
        if (widget.canEdit && !_editing) IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => setState(() => _editing = true)),
        if (_editing) ...[
          TextButton(onPressed: () { _ctrl.text = widget.dolil.notes ?? ''; setState(() => _editing = false); }, child: const Text('Cancel')),
          ElevatedButton(onPressed: _saving ? null : _save, child: _saving ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Save')),
        ],
      ]),
      const SizedBox(height: 12),
      _editing
        ? TextField(controller: _ctrl, maxLines: 10, decoration: const InputDecoration())
        : Container(
            width: double.infinity, padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(10)),
            child: Text(widget.dolil.notes?.isNotEmpty == true ? widget.dolil.notes! : 'No notes yet.', style: TextStyle(color: widget.dolil.notes?.isNotEmpty == true ? AppColors.gray700 : AppColors.gray400)),
          ),
    ]));
  }
}

// ──────────── Payments Tab ────────────
class _PaymentsTab extends ConsumerStatefulWidget {
  final int dolilId;
  final bool canAdd, isAdmin;
  final dynamic dioProvider;

  const _PaymentsTab({required this.dolilId, required this.canAdd, required this.isAdmin, required this.dioProvider});

  @override
  ConsumerState<_PaymentsTab> createState() => _PaymentsTabState();
}

class _PaymentsTabState extends ConsumerState<_PaymentsTab> {
  List<PaymentModel> _payments = [];
  bool _loading = true;

  final _amountCtrl = TextEditingController();
  final _refCtrl = TextEditingController();
  String _method = 'cash';

  @override
  void initState() { super.initState(); _fetch(); }
  @override
  void dispose() { _amountCtrl.dispose(); _refCtrl.dispose(); super.dispose(); }

  Future<void> _fetch() async {
    try {
      final repo = PaymentRepository(ref.read(widget.dioProvider));
      final list = await repo.getPayments(widget.dolilId);
      if (mounted) setState(() { _payments = list; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _add() async {
    if (_amountCtrl.text.isEmpty) return;
    try {
      final repo = PaymentRepository(ref.read(widget.dioProvider));
      final p = await repo.addPayment(widget.dolilId, {
        'amount': double.tryParse(_amountCtrl.text) ?? 0,
        'method': _method,
        if (_refCtrl.text.isNotEmpty) 'reference': _refCtrl.text,
        'paid_at': DateTime.now().toIso8601String(),
      });
      setState(() { _payments.insert(0, p); _amountCtrl.clear(); _refCtrl.clear(); });
      Navigator.pop(context);
    } catch (_) {}
  }

  void _showAddDialog() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Add Payment'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _amountCtrl, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(value: _method, decoration: const InputDecoration(labelText: 'Method'),
          items: ['cash', 'bank_transfer', 'mobile_banking', 'cheque'].map((m) => DropdownMenuItem(value: m, child: Text(m.replaceAll('_', ' ')))).toList(),
          onChanged: (v) => _method = v!),
        const SizedBox(height: 12),
        TextField(controller: _refCtrl, decoration: const InputDecoration(labelText: 'Reference (optional)')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: _add, child: const Text('Add')),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final total = _payments.fold(0.0, (sum, p) => sum + (double.tryParse(p.amount) ?? 0));

    return Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: Row(children: [
        Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          const Text('Total Paid', style: TextStyle(color: AppColors.gray500, fontSize: 12)),
          Text('৳${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.success)),
        ])))),
        if (widget.canAdd) ...[const SizedBox(width: 8), ElevatedButton.icon(onPressed: _showAddDialog, icon: const Icon(Icons.add, size: 16), label: const Text('Add'))],
      ])),
      Expanded(child: _loading ? const Center(child: CircularProgressIndicator()) : _payments.isEmpty
        ? const Center(child: Text('No payments recorded', style: TextStyle(color: AppColors.gray400)))
        : ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: _payments.length, itemBuilder: (_, i) {
            final p = _payments[i];
            return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
              leading: const CircleAvatar(backgroundColor: AppColors.success, child: Icon(Icons.payments_outlined, color: Colors.white, size: 18)),
              title: Text('৳${double.tryParse(p.amount)?.toStringAsFixed(2) ?? p.amount}', style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${p.method.replaceAll('_', ' ')} · ${DateFormatter.format(p.paidAt)}', style: const TextStyle(fontSize: 12)),
              trailing: widget.isAdmin ? IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 18), onPressed: () async {
                final repo = PaymentRepository(ref.read(widget.dioProvider));
                await repo.deletePayment(p.id);
                setState(() => _payments.removeAt(i));
              }) : null,
            ));
          })),
    ]);
  }
}

// ──────────── Documents Tab ────────────
class _DocumentsTab extends ConsumerStatefulWidget {
  final int dolilId;
  final bool canEdit;
  final dynamic dioProvider;

  const _DocumentsTab({required this.dolilId, required this.canEdit, required this.dioProvider});

  @override
  ConsumerState<_DocumentsTab> createState() => _DocumentsTabState();
}

class _DocumentsTabState extends ConsumerState<_DocumentsTab> {
  List<DocumentModel> _docs = [];
  bool _loading = true, _uploading = false;

  @override
  void initState() { super.initState(); _fetch(); }

  Future<void> _fetch() async {
    try {
      final repo = DocumentRepository(ref.read(widget.dioProvider));
      final list = await repo.getDocuments(widget.dolilId);
      if (mounted) setState(() { _docs = list; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _upload() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true, withData: false);
    if (result == null) return;
    setState(() => _uploading = true);
    try {
      final repo = DocumentRepository(ref.read(widget.dioProvider));
      for (final f in result.files) {
        if (f.path != null) {
          final doc = await repo.uploadDocument(widget.dolilId, f.path!, f.name);
          setState(() => _docs.insert(0, doc));
        }
      }
    } catch (_) {} finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _open(DocumentModel doc) async {
    try {
      final repo = DocumentRepository(ref.read(widget.dioProvider));
      final bytes = await repo.downloadDocument(doc.id);
      final file = await FileUtils.saveToTemp(bytes, doc.name);
      await OpenFilex.open(file.path);
    } catch (_) {
      toastification.show(context: context, type: ToastificationType.error, title: const Text('Failed to open file'), autoCloseDuration: const Duration(seconds: 2));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      if (widget.canEdit)
        Padding(padding: const EdgeInsets.all(12), child: Row(children: [
          ElevatedButton.icon(onPressed: _uploading ? null : _upload, icon: const Icon(Icons.upload_file, size: 16), label: const Text('Upload')),
          if (_uploading) const Padding(padding: EdgeInsets.only(left: 12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
        ])),
      Expanded(child: _loading ? const Center(child: CircularProgressIndicator()) : _docs.isEmpty
        ? const Center(child: Text('No documents uploaded', style: TextStyle(color: AppColors.gray400)))
        : ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 12), itemCount: _docs.length, itemBuilder: (_, i) {
            final d = _docs[i];
            final isImg = FileUtils.isImage(d.name);
            return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
              leading: Icon(isImg ? Icons.image_outlined : Icons.description_outlined, color: AppColors.primary),
              title: Text(d.originalName ?? d.name, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
              subtitle: Text(DateFormatter.format(d.createdAt), style: const TextStyle(fontSize: 11)),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.open_in_new, size: 18, color: AppColors.primary), onPressed: () => _open(d)),
                if (widget.canEdit) IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger), onPressed: () async {
                  final repo = DocumentRepository(ref.read(widget.dioProvider));
                  await repo.deleteDocument(d.id);
                  setState(() => _docs.removeAt(i));
                }),
              ]),
            ));
          })),
    ]);
  }
}

// ──────────── Reviews Tab ────────────
class _ReviewsTab extends ConsumerStatefulWidget {
  final int dolilId;
  final bool canReview;
  final int? currentUserId;
  final dynamic dioProvider;

  const _ReviewsTab({required this.dolilId, required this.canReview, this.currentUserId, required this.dioProvider});

  @override
  ConsumerState<_ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends ConsumerState<_ReviewsTab> {
  List<ReviewModel> _reviews = [];
  bool _loading = true;
  int _myRating = 0;
  final _commentCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void initState() { super.initState(); _fetch(); }
  @override
  void dispose() { _commentCtrl.dispose(); super.dispose(); }

  Future<void> _fetch() async {
    try {
      final repo = ReviewRepository(ref.read(widget.dioProvider));
      final list = await repo.getReviews(widget.dolilId);
      if (mounted) setState(() { _reviews = list; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  bool get _alreadyReviewed => _reviews.any((r) => r.userId == widget.currentUserId);

  Future<void> _submit() async {
    if (_myRating == 0) return;
    setState(() => _submitting = true);
    try {
      final repo = ReviewRepository(ref.read(widget.dioProvider));
      final r = await repo.addReview(widget.dolilId, _myRating, _commentCtrl.text.isNotEmpty ? _commentCtrl.text : null);
      setState(() { _reviews.insert(0, r); _myRating = 0; _commentCtrl.clear(); });
    } catch (_) {} finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (widget.canReview && !_alreadyReviewed) ...[
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Write a Review', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          StarRatingPickerWidget(rating: _myRating, onRatingChanged: (r) => setState(() => _myRating = r)),
          const SizedBox(height: 12),
          TextField(controller: _commentCtrl, decoration: const InputDecoration(hintText: 'Write your review...'), maxLines: 3),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _submitting || _myRating == 0 ? null : _submit, child: const Text('Submit Review')),
        ]))),
        const SizedBox(height: 16),
      ],

      if (_loading) const Center(child: CircularProgressIndicator())
      else if (_reviews.isEmpty) const Center(child: Text('No reviews yet', style: TextStyle(color: AppColors.gray400)))
      else ..._reviews.map((r) => Card(margin: const EdgeInsets.only(bottom: 8), child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            AvatarWidget(name: r.userName ?? '?', imageUrl: r.userAvatar, radius: 16),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.userName ?? 'User', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Text(DateFormatter.timeAgo(r.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
            ])),
            StarRatingWidget(rating: r.rating.toDouble()),
          ]),
          if (r.comment != null) ...[const SizedBox(height: 8), Text(r.comment!, style: const TextStyle(color: AppColors.gray700))],
        ])))),
    ]));
  }
}

// ──────────── Comments Tab ────────────
class _CommentsTab extends ConsumerStatefulWidget {
  final int dolilId;
  final int? currentUserId;
  final bool isAdmin;
  final dynamic dioProvider;

  const _CommentsTab({required this.dolilId, this.currentUserId, required this.isAdmin, required this.dioProvider});

  @override
  ConsumerState<_CommentsTab> createState() => _CommentsTabState();
}

class _CommentsTabState extends ConsumerState<_CommentsTab> {
  List<CommentModel> _comments = [];
  bool _loading = true, _submitting = false;
  final _ctrl = TextEditingController();

  @override
  void initState() { super.initState(); _fetch(); }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _fetch() async {
    try {
      final repo = CommentRepository(ref.read(widget.dioProvider));
      final list = await repo.getComments(widget.dolilId);
      if (mounted) setState(() { _comments = list; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _submit() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    try {
      final repo = CommentRepository(ref.read(widget.dioProvider));
      final c = await repo.addComment(widget.dolilId, _ctrl.text.trim());
      setState(() { _comments.insert(0, c); _ctrl.clear(); });
    } catch (_) {} finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _delete(int id, int index) async {
    final ok = await showConfirmDialog(context, title: 'Delete Comment', message: 'Delete this comment?', danger: true);
    if (!ok) return;
    try {
      final repo = CommentRepository(ref.read(widget.dioProvider));
      await repo.deleteComment(id);
      setState(() => _comments.removeAt(index));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(child: _loading ? const Center(child: CircularProgressIndicator()) : _comments.isEmpty
        ? const Center(child: Text('No comments yet', style: TextStyle(color: AppColors.gray400)))
        : ListView.builder(padding: const EdgeInsets.all(12), itemCount: _comments.length, itemBuilder: (_, i) {
            final c = _comments[i];
            final isOwn = c.userId == widget.currentUserId;
            return Card(margin: const EdgeInsets.only(bottom: 8), child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                AvatarWidget(name: c.userName ?? '?', imageUrl: c.userAvatar, radius: 14),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.userName ?? 'User', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text(DateFormatter.timeAgo(c.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
                ])),
                if (isOwn || widget.isAdmin) IconButton(icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.danger), onPressed: () => _delete(c.id, i)),
              ]),
              const SizedBox(height: 6),
              Text(c.body, style: const TextStyle(color: AppColors.gray700)),
            ])));
          })),
      // Input
      Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(color: AppColors.white, border: Border(top: BorderSide(color: AppColors.gray200))),
        child: Row(children: [
          Expanded(child: TextField(controller: _ctrl, decoration: const InputDecoration(hintText: 'Write a comment...', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)), maxLines: null)),
          const SizedBox(width: 8),
          IconButton(onPressed: _submitting ? null : _submit, icon: _submitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send, color: AppColors.primary)),
        ]),
      ),
    ]);
  }
}

// ──────────── Activity Tab ────────────
class _ActivityTab extends ConsumerStatefulWidget {
  final int dolilId;
  final dynamic dioProvider;

  const _ActivityTab({required this.dolilId, required this.dioProvider});

  @override
  ConsumerState<_ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends ConsumerState<_ActivityTab> {
  List<ActivityModel> _activities = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _fetch(); }

  Future<void> _fetch() async {
    try {
      final repo = DolilRepository(ref.read(widget.dioProvider));
      final list = await repo.getActivities(widget.dolilId);
      if (mounted) setState(() { _activities = list; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ActivityTimelineWidget(activities: _activities),
    );
  }
}
