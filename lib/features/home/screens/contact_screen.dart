import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../../../core/theme/app_colors.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() { _nameCtrl.dispose(); _emailCtrl.dispose(); _msgCtrl.dispose(); super.dispose(); }

  Future<void> _send() async {
    if (_nameCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty || _msgCtrl.text.trim().isEmpty) {
      toastification.show(context: context, type: ToastificationType.warning, title: const Text('Please fill all fields'), autoCloseDuration: const Duration(seconds: 2));
      return;
    }
    setState(() => _sending = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _sending = false);
      _nameCtrl.clear(); _emailCtrl.clear(); _msgCtrl.clear();
      toastification.show(context: context, type: ToastificationType.success, title: const Text('Message sent!'), description: const Text('We will get back to you within 24 hours.'), autoCloseDuration: const Duration(seconds: 4));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Get in Touch', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Have a question? We\'d love to hear from you.', style: TextStyle(color: AppColors.gray500)),
          const SizedBox(height: 24),

          // Contact info
          _infoCard(Icons.email_outlined, 'Email', 'dolilbd247@gmail.com'),
          _infoCard(Icons.phone_outlined, 'Phone', '+880 1234-567890'),
          _infoCard(Icons.location_on_outlined, 'Address', 'Dhaka, Bangladesh'),

          const SizedBox(height: 32),
          const Text('Send a Message', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Your Name')),
          const SizedBox(height: 12),
          TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email Address'), keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 12),
          TextFormField(controller: _msgCtrl, decoration: const InputDecoration(labelText: 'Message'), maxLines: 5),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _sending ? null : _send,
            icon: _sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.send),
            label: Text(_sending ? 'Sending...' : 'Send Message'),
          ),
        ]),
      ),
    );
  }

  Widget _infoCard(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppColors.primary, size: 20)),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.gray400, fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.gray800)),
      ]),
    ]),
  );
}
