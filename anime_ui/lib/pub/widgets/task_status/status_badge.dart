import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// Unified generation status with color, icon, and label.
enum GenerationStatus {
  notStarted(
    label: '待生成',
    color: AppColors.muted,
    icon: AppIcons.circleOutline,
  ),
  generating(
    label: '生成中',
    color: AppColors.primary,
    icon: AppIcons.sync,
  ),
  completed(
    label: '已完成',
    color: AppColors.success,
    icon: AppIcons.check,
  ),
  failed(
    label: '失败',
    color: AppColors.error,
    icon: AppIcons.error,
  ),
  rejected(
    label: '退回',
    color: AppColors.warning,
    icon: AppIcons.refresh,
  ),
  waitingDependency(
    label: '等待依赖',
    color: AppColors.tagAmber,
    icon: AppIcons.hourglassEmpty,
  ),
  partialComplete(
    label: '部分完成',
    color: AppColors.info,
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
        Icon(status.icon, size: 13.r, color: status.color),
        SizedBox(width: Spacing.badgeGap.w),
        Text(
          status.label,
          style: AppTextStyles.tiny.copyWith(
            color: status.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (suffix != null) ...[
          SizedBox(width: Spacing.xs.w),
          Text(
            suffix!,
            style: AppTextStyles.tiny.copyWith(color: AppColors.mutedDark),
          ),
        ],
      ],
    );
  }
}
