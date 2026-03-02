import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/auth_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await ref.read(authNotifierProvider.notifier).loadUser();
    if (!mounted) return;
    final user = ref.read(authNotifierProvider).value;
    if (user == null) {
      context.go('/home');
    } else if (user.isAdmin) {
      context.go('/admin');
    } else {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.description_rounded, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          const Text('DolilBD', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.white)),
          const SizedBox(height: 8),
          const Text('Legal Document System', style: TextStyle(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 48),
          const CircularProgressIndicator(color: AppColors.white),
        ]),
      ),
    );
  }
}
