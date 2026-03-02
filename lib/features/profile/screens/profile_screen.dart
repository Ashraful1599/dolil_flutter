import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toastification/toastification.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/otp_input_widget.dart';
import '../repository/profile_repository.dart';
import '../../auth/repositories/auth_repository.dart';
import '../../../shared/providers/dio_provider.dart';
import '../../../shared/providers/auth_state_provider.dart';
import '../../auth/providers/auth_providers.dart';


class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  UserModel? _user;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _regNoCtrl = TextEditingController();
  final _officeCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _oldPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  final _newPwConfCtrl = TextEditingController();
  bool _saving = false, _uploadingAvatar = false;
  bool _phoneOtpSent = false;
  final _otpKey = GlobalKey<OtpInputWidgetState>();

  @override
  void initState() {
    super.initState();
    _user = ref.read(currentUserProvider);
    _populate();
  }

  void _populate() {
    if (_user == null) return;
    _nameCtrl.text = _user!.name;
    _emailCtrl.text = _user!.email;
    _phoneCtrl.text = _user!.phone ?? '';
    _regNoCtrl.text = _user!.registrationNumber ?? '';
    _officeCtrl.text = _user!.officeName ?? '';
    _bioCtrl.text = _user!.bio ?? '';
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _emailCtrl, _phoneCtrl, _regNoCtrl, _officeCtrl, _bioCtrl, _oldPwCtrl, _newPwCtrl, _newPwConfCtrl]) c.dispose();
    super.dispose();
  }

  Future<void> _savePersonalInfo() async {
    setState(() => _saving = true);
    try {
      final repo = ProfileRepository(ref.read(dioProvider));
      final updated = await repo.updateProfile({
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
      });
      ref.read(currentUserProvider.notifier).state = updated;
      setState(() => _user = updated);
      _showSuccess('Personal info updated');
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveWriterInfo() async {
    setState(() => _saving = true);
    try {
      final repo = ProfileRepository(ref.read(dioProvider));
      final updated = await repo.updateProfile({
        'registration_number': _regNoCtrl.text.trim(),
        'office_name': _officeCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
      });
      ref.read(currentUserProvider.notifier).state = updated;
      setState(() => _user = updated);
      _showSuccess('Professional info updated');
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _changePassword() async {
    if (_newPwCtrl.text != _newPwConfCtrl.text) { _showError('Passwords do not match'); return; }
    setState(() => _saving = true);
    try {
      final repo = ProfileRepository(ref.read(dioProvider));
      await repo.updateProfile({
        'current_password': _oldPwCtrl.text,
        'password': _newPwCtrl.text,
        'password_confirmation': _newPwConfCtrl.text,
      });
      _oldPwCtrl.clear(); _newPwCtrl.clear(); _newPwConfCtrl.clear();
      _showSuccess('Password changed successfully');
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickAvatar() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (img == null) return;
    setState(() => _uploadingAvatar = true);
    try {
      final repo = ProfileRepository(ref.read(dioProvider));
      final updated = await repo.uploadAvatar(img.path, img.name);
      ref.read(currentUserProvider.notifier).state = updated;
      setState(() => _user = updated);
      _showSuccess('Avatar updated');
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _sendPhoneOtp() async {
    try {
      final repo = AuthRepository(ref.read(dioProvider));
      await repo.sendPhoneOtp();
      setState(() => _phoneOtpSent = true);
      _showSuccess('OTP sent to your phone');
    } catch (e) { _showError(e.toString()); }
  }

  Future<void> _verifyPhoneOtp(String otp) async {
    try {
      final repo = AuthRepository(ref.read(dioProvider));
      await repo.verifyPhone(otp);
      // Reload user
      final updated = await repo.getUser();
      ref.read(currentUserProvider.notifier).state = updated;
      setState(() { _user = updated; _phoneOtpSent = false; });
      _showSuccess('Phone verified successfully');
    } catch (e) {
      _showError('Invalid OTP');
      _otpKey.currentState?.clear();
    }
  }

  void _showSuccess(String msg) => toastification.show(context: context, type: ToastificationType.success, title: Text(msg), autoCloseDuration: const Duration(seconds: 3));
  void _showError(String msg) => toastification.show(context: context, type: ToastificationType.error, title: Text(msg.replaceFirst('Exception: ', '')), autoCloseDuration: const Duration(seconds: 4));

  @override
  Widget build(BuildContext context) {
    _user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Avatar section
          _section('Avatar', [
            Center(child: Stack(children: [
              _uploadingAvatar
                ? const CircleAvatar(radius: 50, child: CircularProgressIndicator())
                : AvatarWidget(name: _user?.name ?? '?', imageUrl: _user?.avatar, radius: 50),
              Positioned(bottom: 0, right: 0, child: GestureDetector(
                onTap: _pickAvatar,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                ),
              )),
            ])),
          ]),

          // Personal info
          _section('Personal Information', [
            TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
            const SizedBox(height: 12),
            TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            TextFormField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone'), keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _saving ? null : _savePersonalInfo, child: const Text('Save Personal Info')),
          ]),

          // Phone verification
          _section('Phone Verification', [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_user?.phoneVerified == true ? 'Phone verified ✓' : 'Phone not verified', style: TextStyle(color: _user?.phoneVerified == true ? AppColors.success : AppColors.warning, fontWeight: FontWeight.w500)),
                if (_user?.phone != null) Text(_user!.phone!, style: const TextStyle(color: AppColors.gray500, fontSize: 13)),
              ])),
              if (_user?.phoneVerified != true)
                ElevatedButton(onPressed: _sendPhoneOtp, style: ElevatedButton.styleFrom(minimumSize: const Size(0, 36)), child: const Text('Verify')),
            ]),
            if (_phoneOtpSent) ...[
              const SizedBox(height: 16),
              const Text('Enter the 4-digit OTP:', style: TextStyle(color: AppColors.gray600)),
              const SizedBox(height: 12),
              OtpInputWidget(key: _otpKey, onCompleted: _verifyPhoneOtp),
            ],
          ]),

          // Writer info
          if (_user?.isDolilWriter == true)
            _section('Professional Information', [
              TextFormField(controller: _regNoCtrl, decoration: const InputDecoration(labelText: 'Registration Number')),
              const SizedBox(height: 12),
              TextFormField(controller: _officeCtrl, decoration: const InputDecoration(labelText: 'Office Name')),
              const SizedBox(height: 12),
              TextFormField(controller: _bioCtrl, decoration: const InputDecoration(labelText: 'Bio'), maxLines: 4),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _saving ? null : _saveWriterInfo, child: const Text('Save Professional Info')),
            ]),

          // Referral
          if (_user?.referralCode != null)
            _section('Referral Program', [
              Row(children: [
                Expanded(child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(8)),
                  child: Text(_user!.referralCode!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
                )),
                const SizedBox(width: 8),
                IconButton(icon: const Icon(Icons.copy_outlined), onPressed: () { _showSuccess('Referral code copied'); }),
              ]),
              const SizedBox(height: 8),
              const Text('Share your code to invite friends', style: TextStyle(color: AppColors.gray500, fontSize: 13)),
            ]),

          // Change password
          _section('Change Password', [
            TextFormField(controller: _oldPwCtrl, decoration: const InputDecoration(labelText: 'Current Password'), obscureText: true),
            const SizedBox(height: 12),
            TextFormField(controller: _newPwCtrl, decoration: const InputDecoration(labelText: 'New Password'), obscureText: true),
            const SizedBox(height: 12),
            TextFormField(controller: _newPwConfCtrl, decoration: const InputDecoration(labelText: 'Confirm New Password'), obscureText: true),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _saving ? null : _changePassword, child: const Text('Change Password')),
          ]),

          // Logout
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: AppColors.danger),
              label: const Text('Logout', style: TextStyle(color: AppColors.danger)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.danger),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(authNotifierProvider.notifier).logout();
      if (mounted) context.go('/home');
    }
  }

  Widget _section(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.gray900)),
          const SizedBox(height: 16),
          ...children,
        ]),
      ),
    );
  }
}
