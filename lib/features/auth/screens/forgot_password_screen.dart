import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';
import '../../../core/theme/app_colors.dart';
import '../repositories/auth_repository.dart';
import '../../../shared/providers/dio_provider.dart';
import '../../../shared/widgets/otp_input_widget.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  int _step = 0;
  bool _loading = false;

  final _identifierCtrl = TextEditingController();
  String _method = 'email';
  String? _identifier;
  String? _resetToken;
  final _pwCtrl = TextEditingController();
  final _pwConfCtrl = TextEditingController();
  bool _obscure = true;
  final _otpKey = GlobalKey<OtpInputWidgetState>();

  @override
  void dispose() {
    _identifierCtrl.dispose(); _pwCtrl.dispose(); _pwConfCtrl.dispose();
    super.dispose();
  }

  Future<void> _lookup() async {
    if (_identifierCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final repo = AuthRepository(ref.read(dioProvider));
      await repo.lookupAccount(_identifierCtrl.text.trim());
      _identifier = _identifierCtrl.text.trim();
      setState(() => _step = 1);
    } catch (e) {
      toastification.show(context: context, type: ToastificationType.error, title: const Text('Account not found'), description: Text(e.toString().replaceFirst('Exception: ', '')), autoCloseDuration: const Duration(seconds: 3));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendOtp() async {
    setState(() => _loading = true);
    try {
      final repo = AuthRepository(ref.read(dioProvider));
      await repo.sendResetOtp(_identifier!, _method);
      setState(() => _step = 2);
      toastification.show(context: context, type: ToastificationType.success, title: Text('OTP sent via $_method'), autoCloseDuration: const Duration(seconds: 3));
    } catch (e) {
      toastification.show(context: context, type: ToastificationType.error, title: const Text('Failed to send OTP'), description: Text(e.toString().replaceFirst('Exception: ', '')), autoCloseDuration: const Duration(seconds: 3));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyOtp(String otp) async {
    setState(() => _loading = true);
    try {
      final repo = AuthRepository(ref.read(dioProvider));
      final result = await repo.verifyResetOtp(_identifier!, otp);
      _resetToken = result['reset_token'] ?? result['token'];
      setState(() => _step = 3);
    } catch (e) {
      toastification.show(context: context, type: ToastificationType.error, title: const Text('Invalid OTP'), autoCloseDuration: const Duration(seconds: 3));
      _otpKey.currentState?.clear();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_pwCtrl.text != _pwConfCtrl.text) {
      toastification.show(context: context, type: ToastificationType.error, title: const Text('Passwords do not match'), autoCloseDuration: const Duration(seconds: 3));
      return;
    }
    setState(() => _loading = true);
    try {
      final repo = AuthRepository(ref.read(dioProvider));
      await repo.resetPassword(_resetToken!, _pwCtrl.text, _pwConfCtrl.text);
      toastification.show(context: context, type: ToastificationType.success, title: const Text('Password reset successfully'), autoCloseDuration: const Duration(seconds: 3));
      if (mounted) context.go('/login');
    } catch (e) {
      toastification.show(context: context, type: ToastificationType.error, title: const Text('Reset failed'), description: Text(e.toString().replaceFirst('Exception: ', '')), autoCloseDuration: const Duration(seconds: 3));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () {
          if (_step > 0) setState(() => _step--);
          else context.pop();
        }),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            Row(children: List.generate(4, (i) => Expanded(child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(color: i <= _step ? AppColors.primary : AppColors.gray200, borderRadius: BorderRadius.circular(2)),
            )))),
            const SizedBox(height: 32),
            Expanded(child: SingleChildScrollView(child: _buildStep())),
          ]),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0: return _buildLookup();
      case 1: return _buildChooseMethod();
      case 2: return _buildOtp();
      case 3: return _buildNewPassword();
      default: return const SizedBox();
    }
  }

  Widget _buildLookup() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Find your account', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    const Text('Enter your email or phone number', style: TextStyle(color: AppColors.gray500)),
    const SizedBox(height: 24),
    TextField(controller: _identifierCtrl, decoration: const InputDecoration(labelText: 'Email or Phone', prefixIcon: Icon(Icons.search))),
    const SizedBox(height: 24),
    ElevatedButton(onPressed: _loading ? null : _lookup, child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Find Account')),
  ]);

  Widget _buildChooseMethod() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Choose reset method', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    const SizedBox(height: 24),
    _methodOption('email', 'Email', Icons.email_outlined),
    const SizedBox(height: 12),
    _methodOption('sms', 'SMS', Icons.sms_outlined),
    const SizedBox(height: 24),
    ElevatedButton(onPressed: _loading ? null : _sendOtp, child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Send OTP')),
  ]);

  Widget _methodOption(String val, String label, IconData icon) {
    final sel = _method == val;
    return GestureDetector(
      onTap: () => setState(() => _method = val),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: sel ? AppColors.primary : AppColors.gray200, width: sel ? 2 : 1),
          borderRadius: BorderRadius.circular(10),
          color: sel ? AppColors.primaryLight : AppColors.white,
        ),
        child: Row(children: [
          Icon(icon, color: sel ? AppColors.primary : AppColors.gray400),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: sel ? AppColors.primary : AppColors.gray700)),
          const Spacer(),
          if (sel) const Icon(Icons.check_circle, color: AppColors.primary),
        ]),
      ),
    );
  }

  Widget _buildOtp() => Column(children: [
    const SizedBox(height: 32),
    const Icon(Icons.lock_reset, size: 64, color: AppColors.primary),
    const SizedBox(height: 16),
    const Text('Enter OTP', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    const Text('Enter the 4-digit code sent to you', style: TextStyle(color: AppColors.gray500), textAlign: TextAlign.center),
    const SizedBox(height: 32),
    OtpInputWidget(key: _otpKey, onCompleted: _verifyOtp),
    if (_loading) ...[const SizedBox(height: 24), const CircularProgressIndicator()],
  ]);

  Widget _buildNewPassword() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('New Password', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    const SizedBox(height: 24),
    TextFormField(
      controller: _pwCtrl,
      decoration: InputDecoration(labelText: 'New Password', suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => _obscure = !_obscure))),
      obscureText: _obscure,
    ),
    const SizedBox(height: 12),
    TextFormField(controller: _pwConfCtrl, decoration: const InputDecoration(labelText: 'Confirm New Password'), obscureText: true),
    const SizedBox(height: 24),
    ElevatedButton(onPressed: _loading ? null : _resetPassword, child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Reset Password')),
  ]);
}
