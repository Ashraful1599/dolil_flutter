import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AvatarWidget extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double radius;

  const AvatarWidget({super.key, required this.name, this.imageUrl, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl!,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => _initials(),
          ),
        ),
      );
    }
    return _initials();
  }

  Widget _initials() => CircleAvatar(
    radius: radius,
    backgroundColor: AppColors.primary,
    child: Text(
      name.isNotEmpty ? name[0].toUpperCase() : '?',
      style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: radius * 0.7),
    ),
  );
}
