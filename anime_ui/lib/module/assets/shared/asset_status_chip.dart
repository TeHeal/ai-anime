import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';

/// 资产状态芯片
class AssetStatusChip extends StatelessWidget {
  const AssetStatusChip({
    super.key,
    required this.label,
    required this.color,
    this.fontSize = 10,
  });

  final String label;
  final Color color;
  final double fontSize;

  /// 与 locations/props 的 _statusChip 映射一致
  factory AssetStatusChip.fromStatus(String status) {
    switch (status) {
      case 'confirmed':
        return const AssetStatusChip(label: '已确认', color: AppColors.success);
      case 'skeleton':
        return const AssetStatusChip(label: '骨架', color: AppColors.onSurface);
      case 'draft':
        return const AssetStatusChip(label: '待确认', color: AppColors.newTag);
      default:
        return AssetStatusChip(
          label: status.isEmpty ? '待确认' : status,
          color: status.isEmpty ? AppColors.newTag : AppColors.onSurface,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.sm.w,
        vertical: Spacing.xxs.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.tiny.copyWith(
          fontSize: fontSize.sp,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
