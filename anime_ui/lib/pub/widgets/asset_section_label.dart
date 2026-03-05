import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';

/// 资产表单统一 Section 标题，支持左侧竖条 + accent 色 + 必填星号。
///
/// 用法：
/// ```dart
/// AssetSectionLabel('名称', accent: AppColors.primary, required: true)
/// ```
class AssetSectionLabel extends StatelessWidget {
  const AssetSectionLabel(
    this.text, {
    super.key,
    this.accent,
    this.required = false,
    this.showBar = true,
    this.hint,
    this.trailing,
  });

  final String text;

  /// 竖条和星号颜色，默认 primary
  final Color? accent;
  final bool required;

  /// 是否显示左侧竖条，默认 true
  final bool showBar;

  /// 标签右侧的辅助文字
  final String? hint;

  /// 标签行尾部额外组件
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final barColor = accent ?? AppColors.primary;
    return Row(
      children: [
        if (showBar) ...[
          Container(
            width: 3.w,
            height: 13.h,
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: Spacing.sm.w),
        ],
        Text(
          text,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.mutedLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (required) ...[
          SizedBox(width: Spacing.xxs.w),
          Text(
            '*',
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.error),
          ),
        ],
        if (hint != null) ...[
          SizedBox(width: Spacing.sm.w),
          Text(
            hint!,
            style: AppTextStyles.tiny.copyWith(color: AppColors.mutedDarker),
          ),
        ],
        if (trailing != null) ...[
          const Spacer(),
          trailing!,
        ],
      ],
    );
  }
}
