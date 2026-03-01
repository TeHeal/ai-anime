import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/shot.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// 镜图审核：提示词编辑工具栏
class ReviewEditToolbar extends StatelessWidget {
  const ReviewEditToolbar({
    super.key,
    required this.shot,
    required this.onToast,
  });

  final StoryboardShot shot;
  final void Function(String) onToast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Spacing.lg.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '提示词编辑',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: Spacing.md.h),
          TextFormField(
            initialValue: shot.prompt,
            maxLines: 3,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurface,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: '编辑提示词…',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mutedDarker,
              ),
              filled: true,
              fillColor: AppColors.surfaceContainer,
              contentPadding: EdgeInsets.all(Spacing.md.r),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: Spacing.md.h),
          Row(
            children: [
              FilledButton.icon(
                onPressed: () => onToast('重新生成功能开发中'),
                icon: Icon(AppIcons.magicStick, size: 14.r),
                label: Text('生成', style: AppTextStyles.caption),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.md.w,
                    vertical: Spacing.sm.h,
                  ),
                ),
              ),
              SizedBox(width: Spacing.sm.w),
              FilledButton.icon(
                onPressed: () => onToast('已恢复'),
                icon: Icon(AppIcons.refresh, size: 14.r),
                label: Text('恢复原始', style: AppTextStyles.caption),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.surfaceContainerHighest,
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.md.w,
                    vertical: Spacing.sm.h,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
