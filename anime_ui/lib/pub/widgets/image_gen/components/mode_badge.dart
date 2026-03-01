import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../image_gen_controller.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// 当前生成模式只读标签（底部状态栏）
class ModeBadge extends StatelessWidget {
  const ModeBadge({super.key, required this.mode, required this.accent});

  final ImageGenMode mode;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          AppIcons.autoAwesome,
          size: 12.r,
          color: accent.withValues(alpha: 0.7),
        ),
        SizedBox(width: Spacing.badgeGap.w),
        Text(
          '当前模式：',
          style: AppTextStyles.tiny.copyWith(color: AppColors.mutedDarker),
        ),
        Text(
          mode.label,
          style: AppTextStyles.tiny.copyWith(
            color: accent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
