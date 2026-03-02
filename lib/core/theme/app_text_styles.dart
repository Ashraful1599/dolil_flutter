import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle h1 = TextStyle(
    fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.gray900,
  );
  static const TextStyle h2 = TextStyle(
    fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.gray900,
  );
  static const TextStyle h3 = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.gray900,
  );
  static const TextStyle body = TextStyle(
    fontSize: 14, color: AppColors.gray700,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12, color: AppColors.gray500,
  );
  static const TextStyle label = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.gray700,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 11, color: AppColors.gray400,
  );
}
