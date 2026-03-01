import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/module/assets/overview/providers/overview.dart';

/// 关键问题列表
class KeyIssuesList extends StatelessWidget {
  const KeyIssuesList({super.key, required this.issues});

  final List<KeyIssue> issues;

  @override
  Widget build(BuildContext context) {
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
          Container(
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
          )
        else
          ...issues.map((issue) => _buildIssueRow(context, issue)),
      ],
    );
  }

  Widget _buildIssueRow(BuildContext context, KeyIssue issue) {
    final color = switch (issue.severity) {
      KeyIssueSeverity.error => AppColors.error,
      KeyIssueSeverity.warning => AppColors.warning,
      KeyIssueSeverity.info => AppColors.info,
    };

    final icon = switch (issue.icon) {
      'person' => AppIcons.person,
      'landscape' => AppIcons.landscape,
      'mic' => AppIcons.mic,
      'style' => AppIcons.brush,
      _ => AppIcons.warning,
    };

    return Container(
      margin: EdgeInsets.only(bottom: Spacing.sm.h),
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.gridGap.w,
        vertical: Spacing.md.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: Spacing.sm.w,
            height: Spacing.sm.h,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
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
              issue.text,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurface,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => context.go(issue.route),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.md.w,
                vertical: Spacing.xs.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(RadiusTokens.md.r),
              ),
              child: Text(
                '前往',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
