import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/widgets/asset_section_label.dart';

/// 生成类弹窗通用表单标签，委托给 [AssetSectionLabel]（无竖条模式）
Widget genFormLabel(String text, {bool required = false}) {
  return AssetSectionLabel(text, required: required, showBar: false);
}

/// 输入框装饰：深底凹陷（用于文本输入、数字输入等"可输入"控件）
InputDecoration genFormInputDeco(String hint, Color accent) {
  return InputDecoration(
    hintText: hint,
    hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.mutedDarker),
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
      borderSide: BorderSide(color: accent.withValues(alpha: 0.6)),
    ),
  );
}

/// 选择器容器装饰：浅底凸起（用于下拉框、ComboBox 等"可选择"控件）
BoxDecoration genSelectBoxDeco({bool isOpen = false, Color? accent}) {
  return BoxDecoration(
    color: AppColors.surfaceMutedDark,
    borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
    border: Border.all(
      color: isOpen && accent != null
          ? accent.withValues(alpha: 0.6)
          : AppColors.border.withValues(alpha: 0.3),
    ),
  );
}
