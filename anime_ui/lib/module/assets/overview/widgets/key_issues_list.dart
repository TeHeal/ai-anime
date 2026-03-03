import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/module/assets/overview/providers/overview.dart';

/// 严重程度排序权重（error 优先）
int _severityOrder(KeyIssueSeverity s) => switch (s) {
  KeyIssueSeverity.error => 0,
  KeyIssueSeverity.warning => 1,
  KeyIssueSeverity.info => 2,
};

/// 关键问题列表
class KeyIssuesList extends StatefulWidget {
  const KeyIssuesList({
    super.key,
    required this.issues,
    this.isLoading = false,
  });

  final List<KeyIssue> issues;
  final bool isLoading;

  @override
  State<KeyIssuesList> createState() => _KeyIssuesListState();
}

class _KeyIssuesListState extends State<KeyIssuesList> {
  static const int _collapseThreshold = 5;
  bool _expanded = false;

  List<KeyIssue> get _sortedIssues {
    final list = [...widget.issues];
    list.sort((a, b) =>
        _severityOrder(a.severity).compareTo(_severityOrder(b.severity)));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final issues = _sortedIssues;
    final shouldCollapse = issues.length > _collapseThreshold && !_expanded;
    final visibleIssues = shouldCollapse
        ? issues.take(_collapseThreshold).toList()
        : issues;
    final hiddenCount = issues.length - visibleIssues.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(AppIcons.warning, size: 18.r, color: AppColors.warning),
            SizedBox(width: Spacing.sm.w),
            Text(
              '关键问题',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface.withValues(alpha: 0.75),
              ),
            ),
            SizedBox(width: Spacing.sm.w),
            if (issues.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Spacing.sm.w,
                  vertical: Spacing.xxs.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
                ),
                child: Text(
                  '${issues.length}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: Spacing.md.h),
        if (issues.isEmpty)
          widget.isLoading
              ? const _LoadingPlaceholder()
              : const _EmptyState(),
        if (issues.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...visibleIssues.map((issue) => _IssueRowItem(issue: issue)),
              if (issues.length > _collapseThreshold)
                _CollapseToggleButton(
                  expanded: _expanded,
                  hiddenCount: shouldCollapse ? hiddenCount : null,
                  onTap: () => setState(() => _expanded = !_expanded),
                ),
            ],
          ),
      ],
    );
  }
}

/// 加载中占位
class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: Spacing.xl.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20.r,
            height: 20.r,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: Spacing.md.w),
          Text(
            '加载中...',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

/// 无问题时的空状态
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: Spacing.xl.h),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(AppIcons.check, size: 28.r, color: AppColors.success),
          SizedBox(height: Spacing.sm.h),
          Text(
            '所有资产已就绪',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

/// 展开/收起切换按钮
class _CollapseToggleButton extends StatelessWidget {
  const _CollapseToggleButton({
    required this.expanded,
    this.hiddenCount,
    required this.onTap,
  });

  final bool expanded;
  final int? hiddenCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isExpand = !expanded;
    final label = isExpand
        ? '展开更多 (${hiddenCount ?? 0})'
        : '收起';
    final icon = isExpand ? AppIcons.expandMore : AppIcons.expandLess;
    final color = isExpand
        ? AppColors.primary
        : AppColors.onSurface.withValues(alpha: 0.5);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: Spacing.sm.h),
          child: Row(
            children: [
              Icon(icon, size: 16.r, color: color),
              SizedBox(width: Spacing.xs.w),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 单条关键问题（整条可点击，悬停有视觉反馈）
class _IssueRowItem extends StatefulWidget {
  const _IssueRowItem({required this.issue});

  final KeyIssue issue;

  @override
  State<_IssueRowItem> createState() => _IssueRowItemState();
}

class _IssueRowItemState extends State<_IssueRowItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = switch (widget.issue.severity) {
      KeyIssueSeverity.error => AppColors.error,
      KeyIssueSeverity.warning => AppColors.warning,
      KeyIssueSeverity.info => AppColors.info,
    };

    final icon = switch (widget.issue.icon) {
      'person' => AppIcons.person,
      'landscape' => AppIcons.landscape,
      'mic' => AppIcons.mic,
      'style' => AppIcons.brush,
      _ => AppIcons.warning,
    };

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: Material(
        color: _hovered
            ? color.withValues(alpha: 0.06)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
        child: InkWell(
          onTap: () => context.go(widget.issue.route),
          borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            margin: EdgeInsets.only(bottom: Spacing.lg.h),
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.gridGap.w,
              vertical: Spacing.md.h,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
              border: Border.all(
                color: _hovered
                    ? color.withValues(alpha: 0.35)
                    : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: Spacing.sm.w,
                  height: Spacing.sm.h,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius:
                        BorderRadius.circular(RadiusTokens.xs.r),
                  ),
                ),
                SizedBox(width: Spacing.md.w),
                Icon(
                  icon,
                  size: 14.r,
                  color: AppColors.onSurface.withValues(alpha: 0.55),
                ),
                SizedBox(width: Spacing.sm.w),
                Expanded(
                  child: Text(
                    widget.issue.text,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                SizedBox(width: Spacing.sm.w),
                Icon(
                  AppIcons.chevronRight,
                  size: 14.r,
                  color: _hovered
                      ? color
                      : AppColors.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
