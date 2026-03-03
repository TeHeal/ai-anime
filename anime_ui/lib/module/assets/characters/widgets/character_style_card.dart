import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/character.dart';

/// 角色风格卡片（风格 API 未就绪时占位）
class CharacterStyleCard extends StatelessWidget {
  const CharacterStyleCard({super.key, required this.character});

  final Character character;

  Character get c => character;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Spacing.lg.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(RadiusTokens.card.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '风格设定',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          SizedBox(height: Spacing.md.h),
          Container(
            padding: EdgeInsets.all(Spacing.md.r),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(RadiusTokens.md.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(AppIcons.brush, size: 18.r, color: AppColors.muted),
                SizedBox(width: Spacing.sm.w),
                Expanded(
                  child: Text(
                    c.styleOverride
                        ? '个性化风格: ${c.style.isNotEmpty ? c.style : "未设定"}'
                        : '跟随统一风格',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: Spacing.sm.h),
          Text(
            '风格 API 就绪后可选择项目风格',
            style: AppTextStyles.caption.copyWith(color: AppColors.mutedDark),
          ),
        ],
      ),
    );
  }
}
