import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';

/// 资产列表项：左侧缩略图、名称、副标题、状态芯片、尾部操作
///
/// 支持 [leading] 左侧选中条、[subtitleWidget] 复杂副行、[titleTrailing] 名称后标签
class AssetListItem extends StatelessWidget {
  const AssetListItem({
    super.key,
    required this.name,
    required this.isSelected,
    required this.onTap,
    this.leading,
    this.thumbnail,
    this.titleTrailing,
    this.statusChip,
    this.subtitle,
    this.subtitleWidget,
    this.trailing,
  });

  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  /// 左侧可选指示条（如 3px 选中条）
  final Widget? leading;
  final Widget? thumbnail;

  /// 名称后的可选标签（如 interiorExterior）
  final Widget? titleTrailing;
  final Widget? statusChip;
  final String? subtitle;

  /// 复杂副行，优先于 subtitle
  final Widget? subtitleWidget;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: EdgeInsets.only(bottom: Spacing.xs.h),
          child: IntrinsicHeight(
            child: Row(
              children: [
                ...[leading].whereType<Widget>(),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Spacing.md.w,
                      vertical: Spacing.sm.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
                    ),
                    child: Row(
                      children: [
                        if (thumbnail != null) ...[
                          thumbnail!,
                          SizedBox(width: Spacing.md.w),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      name,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.onSurface,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (titleTrailing != null) ...[
                                    SizedBox(width: Spacing.sm.w),
                                    titleTrailing!,
                                  ],
                                ],
                              ),
                              if (subtitleWidget != null) ...[
                                SizedBox(height: Spacing.xs.h),
                                subtitleWidget!,
                              ] else if (subtitle != null) ...[
                                SizedBox(height: Spacing.xs.h),
                                Text(
                                  subtitle!,
                                  style: AppTextStyles.tiny.copyWith(
                                    color: AppColors.onSurface.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (statusChip != null) ...[
                          SizedBox(width: Spacing.sm.w),
                          statusChip!,
                        ],
                        if (trailing != null) ...[
                          SizedBox(width: Spacing.sm.w),
                          trailing!,
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
