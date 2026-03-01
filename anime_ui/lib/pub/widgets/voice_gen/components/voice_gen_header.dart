import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import '../voice_gen_config.dart';
import '../voice_gen_controller.dart';

/// 音色生成弹窗头部：标题、模式标签、关闭按钮
class VoiceGenHeader extends StatelessWidget {
  const VoiceGenHeader({
    super.key,
    required this.config,
    required this.ctrl,
    required this.accent,
    this.onClose,
  });

  final VoiceGenConfig config;
  final VoiceGenController ctrl;
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
            child: Icon(AppIcons.mic, size: 18.r, color: accent),
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
                  ctrl.mode.label,
                  style: AppTextStyles.caption.copyWith(color: accent),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(AppIcons.close, size: 18.r, color: AppColors.mutedDark),
            onPressed: onClose ?? () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
