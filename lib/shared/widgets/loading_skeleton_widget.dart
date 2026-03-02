import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';

class LoadingSkeletonWidget extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const LoadingSkeletonWidget({super.key, this.width, this.height = 16, this.borderRadius = 8});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.gray200,
      highlightColor: AppColors.gray100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(color: AppColors.gray200, borderRadius: BorderRadius.circular(borderRadius)),
      ),
    );
  }
}

class CardSkeletonWidget extends StatelessWidget {
  const CardSkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.gray200,
      highlightColor: AppColors.gray100,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.gray200, shape: BoxShape.circle)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(height: 14, color: AppColors.gray200),
                  const SizedBox(height: 8),
                  Container(height: 12, width: 100, color: AppColors.gray200),
                ])),
              ]),
              const SizedBox(height: 12),
              Container(height: 12, color: AppColors.gray200),
              const SizedBox(height: 6),
              Container(height: 12, width: 200, color: AppColors.gray200),
            ],
          ),
        ),
      ),
    );
  }
}
