import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import '../text_gen_config.dart';

/// 文本生成弹窗头部
class TextGenHeader extends StatelessWidget {
  const TextGenHeader({
    super.key,
    required this.config,
    required this.accent,
    this.onClose,
  });

  final TextGenConfig config;
  final Color accent;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        Spacing.xl.w,
        Spacing.mid.h,
        Spacing.lg.w,
        Spacing.gridGap.h,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.surfaceMutedDarker)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(Spacing.sm.r),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
            ),
            child: Icon(AppIcons.magicStick, size: 18.r, color: accent),
          ),
          SizedBox(width: Spacing.md.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.title,
                  style: AppTextStyles.h4.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                SizedBox(height: Spacing.xxs.h),
                Text(
                  config.mode.label,
                  style: AppTextStyles.tiny.copyWith(color: accent),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(AppIcons.close, size: 18.r, color: AppColors.mutedDark),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}
