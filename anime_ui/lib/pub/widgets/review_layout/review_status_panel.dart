import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// Status option for the review panel radio selector.
class ReviewOption {
  final String value;
  final String label;
  final Color color;

  const ReviewOption({
    required this.value,
    required this.label,
    required this.color,
  });
}

/// Default review options shared across modules.
const kDefaultReviewOptions = [
  ReviewOption(value: 'pending', label: '待审核', color: AppColors.muted),
  ReviewOption(value: 'approved', label: '确认通过', color: AppColors.success),
  ReviewOption(value: 'needsRevision', label: '需修改', color: AppColors.warning),
];

/// Right-panel section showing review status radios + approve/reject buttons.
class ReviewStatusPanel extends StatelessWidget {
  final String currentStatus;
  final List<ReviewOption> options;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final String approveLabel;
  final String rejectLabel;

  const ReviewStatusPanel({
    super.key,
    required this.currentStatus,
    this.options = kDefaultReviewOptions,
    this.onApprove,
    this.onReject,
    this.approveLabel = '确认通过',
    this.rejectLabel = '标记需修改',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '审核状态',
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        SizedBox(height: Spacing.md.h),
        for (final opt in options) _radio(opt),
        SizedBox(height: Spacing.md.h),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: currentStatus == 'approved' ? null : onApprove,
            icon: Icon(AppIcons.check, size: 16.r),
            label: Text(approveLabel),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: EdgeInsets.symmetric(vertical: Spacing.lg.h),
              textStyle: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: Spacing.sm.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: currentStatus == 'needsRevision' ? null : onReject,
            icon: Icon(AppIcons.warning, size: 16.r, color: AppColors.warning),
            label: Text(
              rejectLabel,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.warning),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.warning),
              padding: EdgeInsets.symmetric(vertical: Spacing.lg.h),
              textStyle: AppTextStyles.bodySmall,
            ),
          ),
        ),
      ],
    );
  }

  Widget _radio(ReviewOption opt) {
    final isActive = currentStatus == opt.value;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Spacing.xxs.h),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? opt.color : Colors.transparent,
              border: Border.all(
                color: isActive ? opt.color : AppColors.mutedDarker,
                width: 2.r,
              ),
            ),
          ),
          SizedBox(width: Spacing.sm.w),
          Text(
            opt.label,
            style: AppTextStyles.caption.copyWith(
              color: isActive ? opt.color : AppColors.mutedDark,
            ),
          ),
        ],
      ),
    );
  }
}
