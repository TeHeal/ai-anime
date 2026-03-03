import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/utils/snackbar_helpers.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/widgets/review_layout/qa_checklist.dart';
import 'package:anime_ui/pub/widgets/task_status/mini_action_button.dart';

/// 分轨审核卡片：展示一条轨道的 QA 检查项和操作按钮
class ReviewTrackCard extends StatelessWidget {
  final String title;
  final int score;
  final List<QACheckItem> items;
  final String trackType;
  final ValueChanged<String>? onAction;

  const ReviewTrackCard({
    super.key,
    required this.title,
    required this.score,
    required this.items,
    required this.trackType,
    this.onAction,
  });

  void _notify(BuildContext context, String msg) {
    showToast(context, msg, isInfo: true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Divider(height: 1.h, color: AppColors.border),
          Padding(
            padding: EdgeInsets.all(Spacing.lg.r),
            child: Column(
              children: [
                for (final item in items) _qaItem(item),
                SizedBox(height: Spacing.sm.h),
                _buildActions(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final color = score >= 80
        ? AppColors.success
        : (score >= 60 ? AppColors.warning : AppColors.error);
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: Spacing.lg.w, vertical: Spacing.md.h),
      child: Row(
        children: [
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const Spacer(),
          Text(
            '$score',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _qaItem(QACheckItem item) {
    final color = item.score >= 80
        ? AppColors.success
        : (item.score >= 60 ? AppColors.warning : AppColors.error);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xxs),
      child: Row(
        children: [
          Icon(
            item.score >= 80
                ? AppIcons.check
                : (item.score >= 60 ? AppIcons.warning : AppIcons.error),
            size: 13.r,
            color: color,
          ),
          SizedBox(width: Spacing.sm.w),
          Expanded(
            child: Text(
              item.name,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.mutedLight,
              ),
            ),
          ),
          Text(
            '${item.score}',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          SizedBox(width: Spacing.sm.w),
          if (item.feedback.isNotEmpty)
            Expanded(
              child: Text(
                item.feedback,
                style: AppTextStyles.tiny.copyWith(
                color: AppColors.mutedDark,
              ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        MiniActionButton(
          label: '通过',
          icon: AppIcons.check,
          color: AppColors.success,
          onTap: () {
            onAction?.call('approve');
            _notify(context, '$title 已通过');
          },
        ),
        SizedBox(width: Spacing.sm.w),
        MiniActionButton(
          label: '需调整',
          icon: AppIcons.warning,
          color: AppColors.warning,
          onTap: () {
            onAction?.call('revise');
            _notify(context, '$title 标记需调整');
          },
        ),
        SizedBox(width: Spacing.sm.w),
        MiniActionButton(
          label: '重跑$trackType',
          icon: AppIcons.refresh,
          color: AppColors.primary,
          onTap: () {
            onAction?.call('retry');
            _notify(context, '重跑 $trackType');
          },
        ),
      ],
    );
  }
}
