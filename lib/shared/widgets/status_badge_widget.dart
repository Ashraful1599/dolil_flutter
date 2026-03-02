import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class StatusBadgeWidget extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadgeWidget({super.key, required this.status, this.fontSize = 12});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.statusBackground(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600, color: AppColors.statusText(status)),
      ),
    );
  }
}
