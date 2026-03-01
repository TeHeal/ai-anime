import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';


/// 加载遮罩：居中显示进度条和文案
///
/// 用于异步数据加载时的占位
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key, this.message = '加载中...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const LoadingSpinner(),
          SizedBox(height: Spacing.lg.h),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// 紧凑加载指示器：仅进度条，用于小区域
class LoadingSpinner extends StatelessWidget {
  const LoadingSpinner({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36.r,
      height: 36.r,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        color: AppColors.primary.withValues(alpha: 0.8),
      ),
    );
  }
}
