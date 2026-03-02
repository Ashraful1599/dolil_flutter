import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms of Service')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Terms of Service', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Last updated: January 2026', style: TextStyle(color: AppColors.gray400, fontSize: 13)),
          const SizedBox(height: 24),
          _section('Acceptance of Terms', 'By accessing and using DolilBD, you accept and agree to be bound by the terms and provision of this agreement.'),
          _section('Use of Service', 'DolilBD provides a platform for connecting citizens with certified deed writers. You agree to use this service only for lawful purposes and in accordance with these Terms.'),
          _section('User Accounts', 'You are responsible for maintaining the confidentiality of your account and password and for restricting access to your computer. You agree to accept responsibility for all activities that occur under your account.'),
          _section('Intellectual Property', 'The service and its original content, features, and functionality are owned by DolilBD and are protected by international copyright, trademark, patent, trade secret, and other intellectual property laws.'),
          _section('Disclaimer', 'DolilBD is a platform connecting users with deed writers. We do not provide legal advice and are not responsible for the content of legal documents created through our platform.'),
          _section('Contact', 'Questions about the Terms of Service should be sent to legal@dolilbd.com'),
        ]),
      ),
    );
  }

  Widget _section(String title, String body) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.gray900)),
      const SizedBox(height: 8),
      Text(body, style: const TextStyle(color: AppColors.gray600, height: 1.6)),
    ]),
  );
}
