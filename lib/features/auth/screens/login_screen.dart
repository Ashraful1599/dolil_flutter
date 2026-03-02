import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';
import '../../../core/theme/app_colors.dart';

import '../providers/auth_providers.dart';
import '../repositories/auth_repository.dart';
import '../../../shared/providers/dio_provider.dart';
import '../../../shared/providers/auth_state_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  bool _unverified = false;
  String? _unverifiedEmail;

  @override
  void dispose() {
    _idCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authNotifierProvider.notifier).login(_idCtrl.text.trim(), _pwCtrl.text);
      if (!mounted) return;
      final user = ref.read(currentUserProvider);
      if (user?.isAdmin == true) {
        context.go('/admin');
      } else {
        context.go('/dashboard');
      }
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      if (msg.contains('verified') || msg.contains('email')) {
        setState(() { _unverified = true; _unverifiedEmail = _idCtrl.text.trim(); });
      }
      toastification.show(
        context: context,
        type: ToastificationType.error,
        title: const Text('Login failed'),
        description: Text(msg),
        autoCloseDuration: const Duration(seconds: 4),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resendVerification() async {
    try {
      final repo = AuthRepository(ref.read(dioProvider));
      if (_unverifiedEmail != null) await repo.resendByEmail(_unverifiedEmail!);
      toastification.show(
        context: context,
        type: ToastificationType.success,
        title: const Text('Email sent'),
        description: const Text('Please check your inbox for the verification link.'),
        autoCloseDuration: const Duration(seconds: 4),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const SizedBox(height: 40),
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.description_rounded, size: 32, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            const Text('DolilBD', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.gray900)),
            const SizedBox(height: 8),
            const Text('Sign in to your account', style: TextStyle(color: AppColors.gray500)),
            const SizedBox(height: 32),

            if (_unverified) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFFEF9C3), borderRadius: BorderRadius.circular(12)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Email not verified', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF92400E))),
                  const SizedBox(height: 4),
                  const Text('Please verify your email address to continue.', style: TextStyle(fontSize: 13, color: Color(0xFF92400E))),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _resendVerification,
                    child: const Text('Resend verification email'),
                  ),
                ]),
              ),
              const SizedBox(height: 16),
            ],

            Form(
              key: _formKey,
              child: Column(children: [
                TextFormField(
                  controller: _idCtrl,
                  decoration: const InputDecoration(labelText: 'Email or Phone', prefixIcon: Icon(Icons.person_outline)),
                  validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pwCtrl,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  obscureText: _obscure,
                  validator: (v) => v?.isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: const Text('Forgot password?'),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Sign In'),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => context.push('/register'),
                  child: const Text('Create an account'),
                ),
                const SizedBox(height: 24),
                // Demo credentials
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(10)),
                  child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Demo Credentials', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.gray600)),
                    SizedBox(height: 4),
                    Text('Admin: admin@deed.com / 12345678', style: TextStyle(fontSize: 11, color: AppColors.gray500)),
                    Text('User: user@deed.com / 12345678', style: TextStyle(fontSize: 11, color: AppColors.gray500)),
                    Text('Writer: writer@deed.com / 12345678', style: TextStyle(fontSize: 11, color: AppColors.gray500)),
                  ]),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
