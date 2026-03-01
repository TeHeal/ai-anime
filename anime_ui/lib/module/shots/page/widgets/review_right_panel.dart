import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';
import 'package:anime_ui/pub/widgets/review_layout/review_status_panel.dart';

/// 审核编辑右侧面板：状态操作 + 分轨汇总 + AI 综合分 + 分轨重跑
class ReviewRightPanel extends StatelessWidget {
  final dynamic shot;

  const ReviewRightPanel({super.key, required this.shot});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.rightPanelBackground,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(Spacing.lg.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statusPanel(context),
            Divider(height: 24.h, color: AppColors.divider),
            _trackSummary(),
            Divider(height: 24.h, color: AppColors.divider),
            _aiScore(),
            Divider(height: 24.h, color: AppColors.divider),
            _trackRetryActions(context),
            Divider(height: 24.h, color: AppColors.divider),
            _batchApprove(context),
          ],
        ),
      ),
    );
  }

  Widget _statusPanel(BuildContext context) {
    return ReviewStatusPanel(
      currentStatus: shot?.reviewStatus ?? 'pending',
      options: const [
        ReviewOption(value: 'pending', label: '待审核', color: AppColors.muted),
        ReviewOption(
          value: 'approved',
          label: '确认通过',
          color: AppColors.success,
        ),
        ReviewOption(
          value: 'needsRevision',
          label: '需修改',
          color: AppColors.warning,
        ),
        ReviewOption(value: 'rejected', label: '退回重生成', color: AppColors.error),
      ],
      onApprove: () => showToast(context, '已确认通过'),
      onReject: () => showToast(context, '已标记需修改'),
    );
  }

  Widget _trackSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '分轨审核汇总',
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        SizedBox(height: Spacing.sm.h),
        _trackSummaryRow('🎬 视频', '✅', 92, AppColors.success),
        _trackSummaryRow('🎤 VO', '✅', 88, AppColors.success),
        _trackSummaryRow('🎵 BGM', '✅', 90, AppColors.success),
        _trackSummaryRow('🔊 音效', '⚠️', 72, AppColors.warning),
        _trackSummaryRow('👄 口型', '✅', 85, AppColors.success),
        _trackSummaryRow('🎯 整体', '✅', 87, AppColors.success),
      ],
    );
  }

  Widget _trackSummaryRow(
    String label,
    String statusEmoji,
    int score,
    Color color,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Spacing.tinyGap.h),
      child: Row(
        children: [
          SizedBox(
            width: 70.w,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(color: AppColors.muted),
            ),
          ),
          Text(statusEmoji, style: AppTextStyles.caption),
          const Spacer(),
          Text(
            '$score',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _aiScore() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI 综合分',
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        SizedBox(height: Spacing.xs.h),
        Text(
          '84/100',
          style: AppTextStyles.h2.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _trackRetryActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '分轨操作',
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        SizedBox(height: Spacing.sm.h),
        for (final track in ['视频', 'VO', 'BGM', '音效', '口型同步'])
          Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => showToast(context, '重跑 $track'),
                icon: Icon(AppIcons.refresh, size: 14.r),
                label: Text('重跑 $track'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: Spacing.iconGapSm.h),
                  textStyle: AppTextStyles.tiny,
                ),
              ),
            ),
          ),
        SizedBox(height: Spacing.xs.h),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => showToast(context, '仅重跑未通过项'),
            icon: Icon(AppIcons.refresh, size: 14.r),
            label: const Text('仅重跑未通过项'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(vertical: Spacing.sm.h),
              textStyle: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _batchApprove(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => showToast(context, '一键全部通过'),
        icon: Icon(AppIcons.check, size: 16.r),
        label: const Text('一键全部通过'),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.success,
          padding: EdgeInsets.symmetric(vertical: Spacing.buttonPaddingV.h),
          textStyle: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
