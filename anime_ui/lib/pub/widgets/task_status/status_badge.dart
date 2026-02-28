import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';

/// Unified generation status with color, icon, and label.
enum GenerationStatus {
  notStarted(
    label: '待生成',
    color: Colors.grey,
    icon: AppIcons.circleOutline,
  ),
  generating(
    label: '生成中',
    color: AppColors.primary,
    icon: AppIcons.sync,
  ),
  completed(
    label: '已完成',
    color: Colors.green,
    icon: AppIcons.check,
  ),
  failed(
    label: '失败',
    color: Colors.red,
    icon: AppIcons.error,
  ),
  rejected(
    label: '退回',
    color: Colors.orange,
    icon: AppIcons.refresh,
  ),
  waitingDependency(
    label: '等待依赖',
    color: Colors.amber,
    icon: AppIcons.hourglassEmpty,
  ),
  partialComplete(
    label: '部分完成',
    color: Colors.blue,
    icon: AppIcons.inProgress,
  );

  final String label;
  final Color color;
  final IconData icon;

  const GenerationStatus({
    required this.label,
    required this.color,
    required this.icon,
  });
}

/// A compact status badge showing icon + label, colored by status.
class StatusBadge extends StatelessWidget {
  final GenerationStatus status;
  final String? suffix;

  const StatusBadge({super.key, required this.status, this.suffix});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(status.icon, size: 13, color: status.color),
        const SizedBox(width: 5),
        Text(
          status.label,
          style: TextStyle(
            fontSize: 11,
            color: status.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (suffix != null) ...[
          const SizedBox(width: 4),
          Text(suffix!,
              style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        ],
      ],
    );
  }
}
