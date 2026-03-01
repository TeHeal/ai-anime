import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';
import 'package:anime_ui/pub/widgets/review_layout/qa_checklist.dart';
import 'package:anime_ui/pub/widgets/review_layout/review_status_panel.dart';

/// 镜图审核右侧面板
class ReviewRightPanel extends ConsumerWidget {
  final dynamic shot;

  const ReviewRightPanel({super.key, required this.shot});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppColors.rightPanelBackground,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(Spacing.lg.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReviewStatusPanel(
              currentStatus: shot?.reviewStatus ?? 'pending',
              options: const [
                ReviewOption(
                  value: 'pending',
                  label: '待审核',
                  color: AppColors.muted,
                ),
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
                ReviewOption(
                  value: 'rejected',
                  label: '退回重生成',
                  color: AppColors.error,
                ),
              ],
              onApprove: () => showToast(context, '已确认通过'),
              onReject: () => showToast(context, '已标记需修改'),
            ),
            Divider(height: 24.h, color: AppColors.divider),
            QAChecklist(
              items: const [
                QACheckItem(name: '风格一致性', score: 85, feedback: '风格基本统一'),
                QACheckItem(name: '角色一致性', score: 88, feedback: '角色外观与设定一致'),
                QACheckItem(name: '构图', score: 78, feedback: '主体偏左'),
                QACheckItem(name: '画面质量', score: 92, feedback: '清晰无瑕疵'),
                QACheckItem(name: '语义符合度', score: 80, feedback: '基本符合描述'),
              ],
              onRerunQA: () => showToast(context, 'AI 审核功能开发中'),
            ),
            Divider(height: 24.h, color: AppColors.divider),
            Text(
              '对比',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            SizedBox(height: Spacing.sm.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => showToast(context, '对比功能开发中'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: Spacing.sm.h),
                  textStyle: AppTextStyles.caption,
                ),
                child: const Text('与前镜对比'),
              ),
            ),
            SizedBox(height: Spacing.sm.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => showToast(context, '对比功能开发中'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: Spacing.sm.h),
                  textStyle: AppTextStyles.caption,
                ),
                child: const Text('与资产参考图对比'),
              ),
            ),
            Divider(height: 24.h, color: AppColors.divider),
            Text(
              '批量操作',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            SizedBox(height: Spacing.md.h),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => showToast(context, '一键全部通过'),
                icon: Icon(AppIcons.check, size: 16.r),
                label: const Text('一键全部通过'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(
                    vertical: Spacing.buttonPaddingV.h,
                  ),
                  textStyle: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Divider(height: 24.h, color: AppColors.divider),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => showToast(context, '重新生成'),
                icon: Icon(AppIcons.refresh, size: 14.r),
                label: const Text('重新生成'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: Spacing.sm.h),
                  textStyle: AppTextStyles.caption,
                ),
              ),
            ),
            SizedBox(height: Spacing.sm.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => showToast(context, '上传替换'),
                icon: Icon(AppIcons.upload, size: 14.r),
                label: const Text('上传替换'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: Spacing.sm.h),
                  textStyle: AppTextStyles.caption,
                ),
              ),
            ),
            SizedBox(height: Spacing.sm.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: shot == null
                    ? null
                    : () => showToast(context, '删除功能'),
                icon: Icon(AppIcons.delete, size: 14.r, color: AppColors.error),
                label: Text(
                  '删除镜头',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  padding: EdgeInsets.symmetric(vertical: Spacing.sm.h),
                  textStyle: AppTextStyles.caption,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
