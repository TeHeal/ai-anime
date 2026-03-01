import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// 错误状态：图标 + 文案 + 重试按钮
///
/// 用于加载失败、请求异常等场景
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    this.detail,
    this.onRetry,
  });

  final String message;
  final String? detail;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppIcons.error,
            size: (Spacing.xl * 2).r,
            color: AppColors.error,
          ),
          SizedBox(height: Spacing.lg.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.8),
            ),
          ),
          if (detail != null && detail!.isNotEmpty) ...[
            SizedBox(height: Spacing.sm.h),
            Text(
              detail!,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
          if (onRetry != null) ...[
            SizedBox(height: Spacing.lg.h),
            FilledButton.icon(
              onPressed: onRetry,
              icon: Icon(AppIcons.refresh, size: Spacing.lg.r),
              label: const Text('重试'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ],
      ),
    );
  }
}
