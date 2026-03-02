import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About DolilBD')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.description_rounded, size: 48, color: AppColors.primary),
          )),
          const SizedBox(height: 24),
          const Center(child: Text('DolilBD', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
          const Center(child: Text('Legal Document Management System', style: TextStyle(color: AppColors.gray500))),
          const SizedBox(height: 32),
          _section('Our Mission', 'DolilBD connects citizens of Bangladesh with certified deed writers, making legal document management accessible, transparent, and efficient for everyone.'),
          _section('What We Do', 'We provide a comprehensive platform for:\n\n• Finding certified deed writers near you\n• Managing legal documents digitally\n• Tracking document status in real-time\n• Secure communication between parties\n• Online appointment booking'),
          _section('For Deed Writers', 'Registered deed writers can manage their practice online, accept appointments, and collaborate with clients on legal documents through our secure platform.'),
          _section('Security & Privacy', 'All data is encrypted and stored securely. We comply with Bangladesh data protection regulations and never share your information without consent.'),
          const SizedBox(height: 16),
          const Center(child: Text('Version 1.0.0', style: TextStyle(color: AppColors.gray400, fontSize: 12))),
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
