import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:toastification/toastification.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/phone_normalizer.dart';
import '../repositories/auth_repository.dart';
import '../../../shared/providers/dio_provider.dart';
import '../../../shared/models/location_model.dart';
import '../../../shared/widgets/otp_input_widget.dart';
import '../../../shared/widgets/cascading_location_widget.dart';
import '../../home/repositories/location_repository.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  int _step = 0;
  bool _loading = false;

  // Step 1 fields
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _pwConfCtrl = TextEditingController();
  String _role = 'user';
  bool _obscure = true, _obscureConf = true;
  File? _avatar;

  // Writer fields
  final _regNoCtrl = TextEditingController();
  final _officeCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  int? _divId, _distId, _upaId;

  // Referral
  final _referralCtrl = TextEditingController();

  // Step 2 – OTP
  final _otpKey = GlobalKey<OtpInputWidgetState>();

  // Locations
  List<DivisionModel> _divisions = [];
  late LocationRepository _locationRepo;

  @override
  void initState() {
    super.initState();
    _locationRepo = LocationRepository(ref.read(dioProvider));
    _locationRepo.getDivisions().then((list) {
      if (mounted) setState(() => _divisions = list);
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose();
    _pwCtrl.dispose(); _pwConfCtrl.dispose();
    _regNoCtrl.dispose(); _officeCtrl.dispose(); _bioCtrl.dispose(); _referralCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (img != null) setState(() => _avatar = File(img.path));
  }

  Future<void> _submitStep1() async {
    if (_nameCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty || _pwCtrl.text.isEmpty) {
      toastification.show(context: context, type: ToastificationType.warning, title: const Text('Please fill all required fields'), autoCloseDuration: const Duration(seconds: 3));
      return;
    }
    if (_pwCtrl.text != _pwConfCtrl.text) {
      toastification.show(context: context, type: ToastificationType.error, title: const Text('Passwords do not match'), autoCloseDuration: const Duration(seconds: 3));
      return;
    }

    setState(() => _loading = true);
    try {
      final repo = AuthRepository(ref.read(dioProvider));
      final data = {
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': PhoneNormalizer.normalize(_phoneCtrl.text.trim()),
        'password': _pwCtrl.text,
        'password_confirmation': _pwConfCtrl.text,
        'role': _role,
        if (_referralCtrl.text.isNotEmpty) 'referral_code': _referralCtrl.text.trim(),
        if (_role == 'dolil_writer') ...{
          if (_regNoCtrl.text.isNotEmpty) 'registration_number': _regNoCtrl.text.trim(),
          if (_officeCtrl.text.isNotEmpty) 'office_name': _officeCtrl.text.trim(),
          if (_bioCtrl.text.isNotEmpty) 'bio': _bioCtrl.text.trim(),
          if (_divId != null) 'division_id': _divId,
          if (_distId != null) 'district_id': _distId,
          if (_upaId != null) 'upazila_id': _upaId,
        },
      };
      await repo.register(data);
      setState(() { _step = 1; });
    } catch (e) {
      toastification.show(context: context, type: ToastificationType.error, title: const Text('Registration failed'), description: Text(e.toString().replaceFirst('Exception: ', '')), autoCloseDuration: const Duration(seconds: 4));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitOtp(String otp) async {
    setState(() => _loading = true);
    try {
      // Phone OTP verification after registration
      final repo = AuthRepository(ref.read(dioProvider));
      await repo.verifyPhone(otp);
      setState(() => _step = 2);
    } catch (e) {
      toastification.show(context: context, type: ToastificationType.error, title: const Text('Invalid OTP'), description: Text(e.toString().replaceFirst('Exception: ', '')), autoCloseDuration: const Duration(seconds: 3));
      _otpKey.currentState?.clear();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () {
          if (_step > 0) setState(() => _step--);
          else context.pop();
        }),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            // Step indicator
            Row(children: List.generate(3, (i) => Expanded(child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: i <= _step ? AppColors.primary : AppColors.gray200,
                borderRadius: BorderRadius.circular(2),
              ),
            )))),
            const SizedBox(height: 24),
            Expanded(child: SingleChildScrollView(child: _buildStep())),
          ]),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0: return _buildStep1();
      case 1: return _buildStep2();
      case 2: return _buildStep3();
      default: return const SizedBox();
    }
  }

  Widget _buildStep1() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Step 1: Personal Info', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 24),

      // Avatar
      Center(child: GestureDetector(
        onTap: _pickAvatar,
        child: CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.gray200,
          backgroundImage: _avatar != null ? FileImage(_avatar!) : null,
          child: _avatar == null ? const Icon(Icons.camera_alt_outlined, size: 28, color: AppColors.gray500) : null,
        ),
      )),
      const SizedBox(height: 20),

      TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Full Name *')),
      const SizedBox(height: 12),
      TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email *'), keyboardType: TextInputType.emailAddress),
      const SizedBox(height: 12),
      TextFormField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone *', hintText: '01XXXXXXXXX'), keyboardType: TextInputType.phone),
      const SizedBox(height: 12),
      TextFormField(
        controller: _pwCtrl,
        decoration: InputDecoration(labelText: 'Password *', suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => _obscure = !_obscure))),
        obscureText: _obscure,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _pwConfCtrl,
        decoration: InputDecoration(labelText: 'Confirm Password *', suffixIcon: IconButton(icon: Icon(_obscureConf ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => _obscureConf = !_obscureConf))),
        obscureText: _obscureConf,
      ),
      const SizedBox(height: 16),

      // Role
      const Text('Account Type', style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.gray700)),
      const SizedBox(height: 8),
      Row(children: [
        _roleOption('user', 'Regular User', Icons.person_outline),
        const SizedBox(width: 12),
        _roleOption('dolil_writer', 'Deed Writer', Icons.edit_document),
      ]),

      if (_role == 'dolil_writer') ...[
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        const Text('Professional Info', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.gray700)),
        const SizedBox(height: 12),
        TextFormField(controller: _regNoCtrl, decoration: const InputDecoration(labelText: 'Registration Number')),
        const SizedBox(height: 12),
        TextFormField(controller: _officeCtrl, decoration: const InputDecoration(labelText: 'Office Name')),
        const SizedBox(height: 12),
        TextFormField(controller: _bioCtrl, decoration: const InputDecoration(labelText: 'Bio'), maxLines: 3),
        const SizedBox(height: 16),
        CascadingLocationWidget(
          divisions: _divisions,
          loadDistricts: _locationRepo.getDistricts,
          loadUpazilas: _locationRepo.getUpazilas,
          onChanged: (div, dist, upa) { _divId = div; _distId = dist; _upaId = upa; },
        ),
      ],

      const SizedBox(height: 16),
      TextFormField(controller: _referralCtrl, decoration: const InputDecoration(labelText: 'Referral Code (optional)')),
      const SizedBox(height: 24),

      ElevatedButton(
        onPressed: _loading ? null : _submitStep1,
        child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Continue'),
      ),
      const SizedBox(height: 12),
      TextButton(onPressed: () => context.go('/login'), child: const Text('Already have an account? Sign in')),
    ]);
  }

  Widget _roleOption(String value, String label, IconData icon) {
    final selected = _role == value;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _role = value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: selected ? AppColors.primary : AppColors.gray200, width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(10),
          color: selected ? AppColors.primaryLight : AppColors.white,
        ),
        child: Column(children: [
          Icon(icon, color: selected ? AppColors.primary : AppColors.gray400),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: selected ? AppColors.primary : AppColors.gray600)),
        ]),
      ),
    ));
  }

  Widget _buildStep2() {
    return Column(children: [
      const SizedBox(height: 32),
      const Icon(Icons.phone_android, size: 64, color: AppColors.primary),
      const SizedBox(height: 16),
      const Text('Verify Phone Number', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text('Enter the 4-digit OTP sent to ${_phoneCtrl.text}', style: const TextStyle(color: AppColors.gray500), textAlign: TextAlign.center),
      const SizedBox(height: 32),
      OtpInputWidget(key: _otpKey, onCompleted: _submitOtp),
      const SizedBox(height: 24),
      if (_loading) const CircularProgressIndicator(),
      const SizedBox(height: 16),
      TextButton(onPressed: () {}, child: const Text('Resend OTP')),
    ]);
  }

  Widget _buildStep3() {
    return Column(children: [
      const SizedBox(height: 64),
      const Icon(Icons.mark_email_read, size: 80, color: AppColors.success),
      const SizedBox(height: 24),
      const Text('Check Your Email', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Text(
        'We sent a verification link to ${_emailCtrl.text}. Click the link to activate your account.',
        style: const TextStyle(color: AppColors.gray500, height: 1.5),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 32),
      ElevatedButton(onPressed: () => context.go('/login'), child: const Text('Go to Login')),
    ]);
  }
}
