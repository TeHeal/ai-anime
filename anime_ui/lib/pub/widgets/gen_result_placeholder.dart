import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// AI 生成结果区统一空态/生成中/错误占位。
///
/// 三种工厂构造：
/// - [GenResultPlaceholder.idle] — 空态引导
/// - [GenResultPlaceholder.generating] — 生成中动画
/// - [GenResultPlaceholder.error] — 错误 + 重试
class GenResultPlaceholder extends StatelessWidget {
  const GenResultPlaceholder._({
    super.key,
    required this.icon,
    required this.message,
    this.submessage,
    this.accent,
    this.showSpinner = false,
    this.progress,
    this.onRetry,
    this.isError = false,
  });

  /// 空态引导：图标 + 提示文案
  factory GenResultPlaceholder.idle({
    Key? key,
    IconData icon = AppIcons.magicStick,
    String message = '填写参数后点击生成',
    String? submessage,
    Color? accent,
  }) => GenResultPlaceholder._(
    key: key,
    icon: icon,
    message: message,
    submessage: submessage,
    accent: accent,
  );

  /// 生成中：旋转动画 + 进度
  factory GenResultPlaceholder.generating({
    Key? key,
    int progress = 0,
    String? message,
    Color? accent,
  }) => GenResultPlaceholder._(
    key: key,
    icon: AppIcons.magicStick,
    message: message ?? (progress > 0 ? '生成中 $progress%…' : '生成中…'),
    accent: accent,
    showSpinner: true,
    progress: progress,
  );

  /// 错误：错误图标 + 消息 + 重试按钮
  factory GenResultPlaceholder.error({
    Key? key,
    required String message,
    VoidCallback? onRetry,
  }) => GenResultPlaceholder._(
    key: key,
    icon: AppIcons.warning,
    message: message,
    isError: true,
    onRetry: onRetry,
  );

  final IconData icon;
  final String message;
  final String? submessage;
  final Color? accent;
  final bool showSpinner;
  final int? progress;
  final VoidCallback? onRetry;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError
        ? AppColors.error
        : (accent ?? AppColors.primary);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(Spacing.xl.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showSpinner) ...[
              SizedBox(
                width: 32.r,
                height: 32.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5.r,
                  color: color,
                ),
              ),
            ] else ...[
              Icon(
                icon,
                size: 36.r,
                color: color.withValues(alpha: isError ? 0.7 : 0.3),
              ),
            ],
            SizedBox(height: Spacing.md.h),
            Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: isError ? AppColors.error : AppColors.mutedDark,
              ),
              textAlign: TextAlign.center,
            ),
            if (submessage != null) ...[
              SizedBox(height: Spacing.xs.h),
              Text(
                submessage!,
                style: AppTextStyles.tiny.copyWith(color: AppColors.mutedDarker),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              SizedBox(height: Spacing.md.h),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: Icon(AppIcons.refresh, size: 14.r),
                label: const Text('重试'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: color,
                  side: BorderSide(color: color.withValues(alpha: 0.4)),
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.lg.w,
                    vertical: Spacing.sm.h,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
