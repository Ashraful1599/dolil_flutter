import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../models/activity_model.dart';

class ActivityTimelineWidget extends StatelessWidget {
  final List<ActivityModel> activities;

  const ActivityTimelineWidget({super.key, required this.activities});

  Color _dotColor(String action) {
    if (action.contains('created')) return AppColors.primary;
    if (action.contains('updated') || action.contains('changed')) return AppColors.warning;
    if (action.contains('deleted') || action.contains('cancelled')) return AppColors.danger;
    if (action.contains('completed')) return AppColors.success;
    return AppColors.gray400;
  }

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const Center(
        child: Padding(padding: EdgeInsets.all(32), child: Text('No activity recorded', style: TextStyle(color: AppColors.gray400))),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (_, i) {
        final a = activities[i];
        final isLast = i == activities.length - 1;
        return IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 24, child: Column(children: [
              Container(
                width: 12, height: 12,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(color: _dotColor(a.action), shape: BoxShape.circle),
              ),
              if (!isLast) Expanded(child: Container(width: 2, color: AppColors.gray200, margin: const EdgeInsets.only(top: 4))),
            ])),
            const SizedBox(width: 12),
            Expanded(child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(a.action.replaceAll('_', ' ').toUpperCase(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.gray400, letterSpacing: 0.5)),
                if (a.description != null)
                  Text(a.description!, style: const TextStyle(fontSize: 13, color: AppColors.gray700)),
                Text(
                  [if (a.userName != null) a.userName!, DateFormatter.timeAgo(a.createdAt)].join(' · '),
                  style: const TextStyle(fontSize: 11, color: AppColors.gray400),
                ),
              ]),
            )),
          ]),
        );
      },
    );
  }
}
