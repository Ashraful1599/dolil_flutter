import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFFEFF6FF);
  static const Color secondary = Color(0xFF7C3AED);
  static const Color success = Color(0xFF059669);
  static const Color warning = Color(0xFFD97706);
  static const Color danger = Color(0xFFDC2626);
  static const Color info = Color(0xFF0891B2);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF9FAFB);

  // Status colors
  static Color statusBackground(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return const Color(0xFFFEF9C3);
      case 'in_progress': return const Color(0xFFDBEAFE);
      case 'completed': return const Color(0xFFDCFCE7);
      case 'archived': return const Color(0xFFF3F4F6);
      case 'confirmed': return const Color(0xFFDCFCE7);
      case 'cancelled': return const Color(0xFFFEE2E2);
      default: return const Color(0xFFF3F4F6);
    }
  }

  static Color statusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return const Color(0xFF92400E);
      case 'in_progress': return const Color(0xFF1E40AF);
      case 'completed': return const Color(0xFF065F46);
      case 'archived': return const Color(0xFF374151);
      case 'confirmed': return const Color(0xFF065F46);
      case 'cancelled': return const Color(0xFF991B1B);
      default: return const Color(0xFF374151);
    }
  }
}
