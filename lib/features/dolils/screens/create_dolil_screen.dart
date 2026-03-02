import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:toastification/toastification.dart';
import '../../../core/theme/app_colors.dart';
import '../repositories/dolil_repository.dart';
import '../repositories/document_repository.dart';
import '../../../shared/providers/dio_provider.dart';

class CreateDolilScreen extends ConsumerStatefulWidget {
  const CreateDolilScreen({super.key});

  @override
  ConsumerState<CreateDolilScreen> createState() => _CreateDolilScreenState();
}

class _CreateDolilScreenState extends ConsumerState<CreateDolilScreen> {
  int _step = 0;
  bool _loading = false;
  int? _createdDolilId;

  // Step 1 fields
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _partyACtrl = TextEditingController();
  final _partyBCtrl = TextEditingController();
  final _partyAContactCtrl = TextEditingController();
  final _partyBContactCtrl = TextEditingController();
  final _landDescCtrl = TextEditingController();
  final _mouzaCtrl = TextEditingController();
  final _khatianCtrl = TextEditingController();
  final _plotCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _regOfficeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // Step 2 – documents
  List<PlatformFile> _files = [];

  @override
  void dispose() {
    for (final c in [_titleCtrl, _descCtrl, _partyACtrl, _partyBCtrl, _partyAContactCtrl, _partyBContactCtrl, _landDescCtrl, _mouzaCtrl, _khatianCtrl, _plotCtrl, _areaCtrl, _regOfficeCtrl, _notesCtrl]) c.dispose();
    super.dispose();
  }

  Future<void> _submitStep1() async {
    if (_titleCtrl.text.trim().isEmpty) {
      toastification.show(context: context, type: ToastificationType.warning, title: const Text('Title is required'), autoCloseDuration: const Duration(seconds: 2));
      return;
    }
    setState(() => _loading = true);
    try {
      final repo = DolilRepository(ref.read(dioProvider));
      final dolil = await repo.createDolil({
        'title': _titleCtrl.text.trim(),
        if (_descCtrl.text.isNotEmpty) 'description': _descCtrl.text.trim(),
        if (_partyACtrl.text.isNotEmpty) 'party_a': _partyACtrl.text.trim(),
        if (_partyBCtrl.text.isNotEmpty) 'party_b': _partyBCtrl.text.trim(),
        if (_partyAContactCtrl.text.isNotEmpty) 'party_a_contact': _partyAContactCtrl.text.trim(),
        if (_partyBContactCtrl.text.isNotEmpty) 'party_b_contact': _partyBContactCtrl.text.trim(),
        if (_landDescCtrl.text.isNotEmpty) 'land_description': _landDescCtrl.text.trim(),
        if (_mouzaCtrl.text.isNotEmpty) 'mouza': _mouzaCtrl.text.trim(),
        if (_khatianCtrl.text.isNotEmpty) 'khatian': _khatianCtrl.text.trim(),
        if (_plotCtrl.text.isNotEmpty) 'plot': _plotCtrl.text.trim(),
        if (_areaCtrl.text.isNotEmpty) 'area': _areaCtrl.text.trim(),
        if (_regOfficeCtrl.text.isNotEmpty) 'registration_office': _regOfficeCtrl.text.trim(),
        if (_notesCtrl.text.isNotEmpty) 'notes': _notesCtrl.text.trim(),
      });
      _createdDolilId = dolil.id;
      setState(() => _step = 1);
    } catch (e) {
      toastification.show(context: context, type: ToastificationType.error, title: const Text('Failed to create dolil'), description: Text(e.toString().replaceFirst('Exception: ', '')), autoCloseDuration: const Duration(seconds: 4));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true, withData: false);
    if (result != null) setState(() => _files = [..._files, ...result.files]);
  }

  Future<void> _uploadDocuments() async {
    if (_files.isEmpty) {
      context.go('/dashboard/dolils/$_createdDolilId');
      return;
    }
    setState(() => _loading = true);
    try {
      final repo = DocumentRepository(ref.read(dioProvider));
      for (final file in _files) {
        if (file.path != null) {
          await repo.uploadDocument(_createdDolilId!, file.path!, file.name);
        }
      }
      toastification.show(context: context, type: ToastificationType.success, title: const Text('Dolil created successfully!'), autoCloseDuration: const Duration(seconds: 2));
      if (mounted) context.go('/dashboard/dolils/$_createdDolilId');
    } catch (e) {
      toastification.show(context: context, type: ToastificationType.error, title: const Text('Some documents failed to upload'), autoCloseDuration: const Duration(seconds: 3));
      if (mounted) context.go('/dashboard/dolils/$_createdDolilId');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Dolil'),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop()),
      ),
      body: Column(children: [
        Row(children: List.generate(2, (i) => Expanded(child: Container(
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(color: i <= _step ? AppColors.primary : AppColors.gray200, borderRadius: BorderRadius.circular(2)),
        )))),
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: _step == 0 ? _buildStep1() : _buildStep2())),
      ]),
    );
  }

  Widget _buildStep1() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Dolil Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 16),
    _field(_titleCtrl, 'Title *'),
    _field(_descCtrl, 'Description', maxLines: 3),
    const SizedBox(height: 8),
    const Text('Parties', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.gray700)),
    const SizedBox(height: 8),
    Row(children: [Expanded(child: _field(_partyACtrl, 'Party A')), const SizedBox(width: 12), Expanded(child: _field(_partyBCtrl, 'Party B'))]),
    Row(children: [Expanded(child: _field(_partyAContactCtrl, 'Party A Contact')), const SizedBox(width: 12), Expanded(child: _field(_partyBContactCtrl, 'Party B Contact'))]),
    const SizedBox(height: 8),
    const Text('Land Details', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.gray700)),
    const SizedBox(height: 8),
    _field(_landDescCtrl, 'Land Description', maxLines: 3),
    Row(children: [Expanded(child: _field(_mouzaCtrl, 'Mouza')), const SizedBox(width: 12), Expanded(child: _field(_khatianCtrl, 'Khatian'))]),
    Row(children: [Expanded(child: _field(_plotCtrl, 'Plot')), const SizedBox(width: 12), Expanded(child: _field(_areaCtrl, 'Area'))]),
    _field(_regOfficeCtrl, 'Registration Office'),
    _field(_notesCtrl, 'Notes', maxLines: 3),
    const SizedBox(height: 24),
    ElevatedButton(
      onPressed: _loading ? null : _submitStep1,
      child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Next: Upload Documents'),
    ),
  ]);

  Widget _buildStep2() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Upload Documents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    const Text('Attach supporting documents (PDF, DOC, DOCX, JPG, PNG)', style: TextStyle(color: AppColors.gray500, fontSize: 13)),
    const SizedBox(height: 16),
    OutlinedButton.icon(onPressed: _pickFiles, icon: const Icon(Icons.attach_file), label: const Text('Select Files')),
    const SizedBox(height: 16),
    ..._files.asMap().entries.map((entry) => Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.description_outlined, color: AppColors.primary),
        title: Text(entry.value.name, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
        subtitle: Text(entry.value.size > 0 ? '${(entry.value.size / 1024).toStringAsFixed(1)} KB' : '', style: const TextStyle(fontSize: 12)),
        trailing: IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () { setState(() => _files.removeAt(entry.key)); }),
      ),
    )),
    const SizedBox(height: 24),
    ElevatedButton(
      onPressed: _loading ? null : _uploadDocuments,
      child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(_files.isEmpty ? 'Skip & Finish' : 'Upload & Finish'),
    ),
  ]);

  Widget _field(TextEditingController ctrl, String label, {int maxLines = 1}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(controller: ctrl, decoration: InputDecoration(labelText: label), maxLines: maxLines),
  );
}
