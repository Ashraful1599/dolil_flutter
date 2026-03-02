import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Privacy Policy', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Last updated: January 2026', style: TextStyle(color: AppColors.gray400, fontSize: 13)),
          const SizedBox(height: 24),
          _section('Information We Collect', 'We collect information you provide directly to us, such as when you create an account, use our services, or contact us for support. This includes:\n\n• Name, email address, and phone number\n• Profile information and preferences\n• Usage data and activity logs'),
          _section('How We Use Your Information', 'We use the information we collect to:\n\n• Provide, maintain, and improve our services\n• Process transactions and send related information\n• Send administrative messages and notifications\n• Respond to comments and questions'),
          _section('Information Sharing', 'We do not sell, trade, or otherwise transfer your personally identifiable information to outside parties except as described in this policy.'),
          _section('Data Security', 'We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.'),
          _section('Contact Us', 'If you have questions about this Privacy Policy, please contact us at privacy@dolilbd.com'),
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
