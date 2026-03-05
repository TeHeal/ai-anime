import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'asset_section_label.dart';

/// 资产表单统一输入框，自带 [AssetSectionLabel] + 深色主题 TextField。
///
/// 支持两种 accent 风格：
/// - 有 accent 时，聚焦边框跟随 accent 色（素材弹窗场景）
/// - 无 accent 时，使用 primary（通用场景）
class AssetInputField extends StatelessWidget {
  const AssetInputField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.accent,
    this.required = false,
    this.maxLines = 1,
    this.showBar = true,
    this.onChanged,
    this.labelHint,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final Color? accent;
  final bool required;
  final int maxLines;

  /// 是否在 SectionLabel 上显示竖条
  final bool showBar;
  final ValueChanged<String>? onChanged;

  /// SectionLabel 右侧的辅助文字
  final String? labelHint;

  @override
  Widget build(BuildContext context) {
    final focusColor = accent ?? AppColors.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AssetSectionLabel(
          label,
          accent: accent,
          required: required,
          showBar: showBar,
          hint: labelHint,
        ),
        SizedBox(height: Spacing.xs.h),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
          onChanged: onChanged,
          decoration: assetInputDecoration(hint ?? '', focusColor: focusColor),
        ),
      ],
    );
  }
}

/// 统一深色输入框装饰，供不搭配 [AssetInputField] 的场景直接使用。
InputDecoration assetInputDecoration(
  String hint, {
  Color focusColor = AppColors.primary,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.mutedDark),
    filled: true,
    fillColor: AppColors.inputBackground.withValues(alpha: 0.6),
    contentPadding: EdgeInsets.symmetric(
      horizontal: Spacing.sm.w,
      vertical: Spacing.sm.h,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
      borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
      borderSide: BorderSide(color: focusColor.withValues(alpha: 0.6)),
    ),
  );
}
