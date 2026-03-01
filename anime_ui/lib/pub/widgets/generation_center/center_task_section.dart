import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/generation_center/filter_toolbar.dart';
import 'package:anime_ui/pub/widgets/generation_center/styled_card.dart';

/// 生成中心任务区域通用布局：标题行 + 筛选栏 + 内容区
///
/// 各模块（script、shot_images、shots）传入 filters、headerTrailing、child
class TaskSectionLayout extends StatelessWidget {
  const TaskSectionLayout({
    super.key,
    this.title = '生成任务',
    required this.count,
    required this.countLabel,
    required this.filters,
    required this.activeFilter,
    required this.onFilterChanged,
    this.groups = const [],
    this.activeGroup = '',
    this.onGroupChanged,
    this.headerTrailing,
    required this.child,
  });

  final String title;
  final int count;

  /// 如 "集"、"镜头"
  final String countLabel;
  final List<FilterChipData> filters;
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;
  final List<GroupChipData> groups;
  final String activeGroup;
  final ValueChanged<String>? onGroupChanged;

  /// 标题行右侧（如 BatchActionBar、视图模式切换）
  final Widget? headerTrailing;

  /// 任务网格或空状态
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return StyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(Spacing.sm.r),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.25),
                      AppColors.primary.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
                ),
                child: Icon(
                  AppIcons.magicStick,
                  size: 18.r,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: Spacing.md.w),
              Text(
                title,
                style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
              ),
              SizedBox(width: Spacing.md.w),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Spacing.sm.w,
                  vertical: Spacing.tinyGap.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
                ),
                child: Text(
                  '$count $countLabel',
                  style: AppTextStyles.tiny.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              if (headerTrailing case Widget w) w,
            ],
          ),
          SizedBox(height: Spacing.lg.h),
          FilterToolbar(
            filters: filters,
            activeFilter: activeFilter,
            onFilterChanged: onFilterChanged,
            groups: groups,
            activeGroup: activeGroup,
            onGroupChanged: onGroupChanged,
          ),
          SizedBox(height: Spacing.lg.h),
          child,
        ],
      ),
    );
  }
}
