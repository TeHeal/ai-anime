import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/generation_center/filter_toolbar.dart';

/// 生成中心任务区域通用布局：Header + Filter + Content 三层带状结构
///
/// 各模块（script、shot_images、shots）传入 filters、headerTrailing、child。
/// 三层各自带有独立的 padding 和底部边框，增强视觉层级。
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
    this.progressBar,
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

  /// 可选的进度条，显示在 header 和筛选栏之间
  final Widget? progressBar;

  /// 任务网格或空状态
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(RadiusTokens.card.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOverlay.withValues(alpha: 0.2),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(RadiusTokens.card.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            if (progressBar case Widget bar) bar,
            _buildFilter(),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  /// 顶部标题栏：图标 + 标题 + 数量徽章 + 右侧操作
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.cardPadding.w,
        vertical: Spacing.lg.h,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.06),
            Colors.transparent,
          ],
        ),
        border: const Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
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
    );
  }

  /// 筛选栏：状态筛选 + 分组，背景稍深于 header
  Widget _buildFilter() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.cardPadding.w,
        vertical: Spacing.sm.h,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainer,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: FilterToolbar(
        bare: true,
        filters: filters,
        activeFilter: activeFilter,
        onFilterChanged: onFilterChanged,
        groups: groups,
        activeGroup: activeGroup,
        onGroupChanged: onGroupChanged,
      ),
    );
  }

  /// 内容区域：任务卡片网格
  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.cardPadding.w,
        vertical: Spacing.lg.h,
      ),
      child: child,
    );
  }
}
