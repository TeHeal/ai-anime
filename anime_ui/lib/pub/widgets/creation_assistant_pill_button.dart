import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// 创作助理药丸按钮：紫色渐变样式，点击展开下拉菜单。
///
/// 用于剧本块、表单等场景，需由调用方提供 [itemBuilder] 和 [onSelected]。
/// 菜单内容（润色/扩写/续写等）由业务方决定。
class CreationAssistantPillButton<T> extends StatelessWidget {
  const CreationAssistantPillButton({
    super.key,
    required this.itemBuilder,
    required this.onSelected,
    this.tooltip = '创作助理',
    this.offset,
    this.menuColor = AppColors.surface,
  });

  /// 构建弹出菜单项
  final List<PopupMenuEntry<T>> Function(BuildContext) itemBuilder;

  /// 选中某项时的回调
  final ValueChanged<T> onSelected;

  /// 悬停提示
  final String tooltip;

  /// 弹出菜单位置偏移，默认 (0, 36.h)
  final Offset? offset;

  /// 菜单背景色
  final Color menuColor;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      onSelected: onSelected,
      tooltip: tooltip,
      offset: offset ?? Offset(0, 36.h),
      color: menuColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
      ),
      itemBuilder: itemBuilder,
      child: _PillChild(),
    );
  }
}

/// 药丸外观（渐变 + 图标 + 文案）
class _PillChild extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26.h,
      padding: EdgeInsets.symmetric(horizontal: Spacing.lg.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.info],
        ),
        borderRadius: BorderRadius.circular(RadiusTokens.xxl.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.autoAwesome, size: 12.r, color: AppColors.onPrimary),
          SizedBox(width: Spacing.xs.w),
          Text(
            '创作助理',
            style: AppTextStyles.tiny.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
