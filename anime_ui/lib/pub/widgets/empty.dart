import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// 空状态：图标 + 文案 + 可选操作按钮
///
/// 用于列表无数据、筛选无结果等场景
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.icon,
    this.iconColor,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  final String message;
  final IconData? icon;
  final Color? iconColor;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(
              icon,
              size: (Spacing.xl * 2).r,
              color: iconColor ?? AppColors.surfaceMuted,
            ),
          if (icon != null) SizedBox(height: Spacing.lg.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
          ),
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: Spacing.xl.h),
            FilledButton.icon(
              onPressed: onAction,
              icon: Icon(actionIcon ?? AppIcons.add, size: Spacing.lg.r),
              label: Text(actionLabel!),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ],
      ),
    );
  }
}
