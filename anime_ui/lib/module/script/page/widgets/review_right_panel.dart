import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';
import 'package:anime_ui/pub/models/storyboard_script.dart';
import 'package:anime_ui/module/script/providers/review_ui.dart';
import 'package:anime_ui/module/script/providers/script_center.dart';

// ---------------------------------------------------------------------------
// 右栏：操作面板 (260px)
// ---------------------------------------------------------------------------

class ReviewRightPanel extends ConsumerWidget {
  final ShotV4? shot;
  final List<ShotV4> allShots;

  const ReviewRightPanel({
    super.key,
    required this.shot,
    required this.allShots,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(reviewUiProvider);
    final uiNotifier = ref.read(reviewUiProvider.notifier);

    return Container(
      color: AppColors.rightPanelBackground,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(Spacing.lg.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 审核状态
            Text(
              '审核状态',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            SizedBox(height: Spacing.md.h),
            if (shot != null) ...[
              _reviewRadio(
                'pending',
                '待审核',
                AppColors.muted,
                shot!.reviewStatus,
              ),
              _reviewRadio(
                'approved',
                '确认通过',
                AppColors.success,
                shot!.reviewStatus,
              ),
              _reviewRadio(
                'needsRevision',
                '需修改',
                AppColors.warning,
                shot!.reviewStatus,
              ),
              SizedBox(height: Spacing.md.h),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: shot!.reviewStatus == 'approved'
                      ? null
                      : () =>
                            uiNotifier.setReview(shot!.shotNumber, 'approved'),
                  icon: Icon(AppIcons.check, size: 16.r),
                  label: const Text('确认通过'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: EdgeInsets.symmetric(vertical: Spacing.md.h),
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
                  onPressed: shot!.reviewStatus == 'needsRevision'
                      ? null
                      : () => uiNotifier.setReview(
                          shot!.shotNumber,
                          'needsRevision',
                        ),
                  icon: Icon(
                    AppIcons.warning,
                    size: 16.r,
                    color: AppColors.warning,
                  ),
                  label: Text(
                    '标记需修改',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.warning),
                    padding: EdgeInsets.symmetric(vertical: Spacing.md.h),
                    textStyle: AppTextStyles.bodySmall,
                  ),
                ),
              ),
            ],

            const Divider(height: 24, color: AppColors.divider),

            // 审核备注
            Text(
              '审核备注',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            TextField(
              maxLines: 3,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.onSurface,
              ),
              decoration: InputDecoration(
                hintText: '记录审核意见...',
                hintStyle: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.mutedDarker,
                ),
                isDense: true,
                contentPadding: EdgeInsets.all(Spacing.md.r),
                border: const OutlineInputBorder(),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.border),
                ),
              ),
            ),

            const Divider(height: 24, color: AppColors.divider),

            // 生成任务
            Text(
              '生成任务',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            if (shot != null)
              Wrap(
                spacing: 6.w,
                runSpacing: 6.h,
                children: ['图像', '视频', 'TTS', 'BGM', '音效', '转场']
                    .map(
                      (task) =>
                          _taskChip(task, shot!.generateTasks.contains(task)),
                    )
                    .toList(),
              ),

            const Divider(height: 24, color: AppColors.divider),

            // 依赖关系
            Text(
              '依赖关系',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            if (shot?.dependencies != null) ...[
              Text(
                '前置镜头: ${shot!.dependencies!.before.isEmpty ? "无" : shot!.dependencies!.before.map((n) => "#$n").join(", ")}',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                '后置镜头: ${shot!.dependencies!.after.isEmpty ? "无" : shot!.dependencies!.after.map((n) => "#$n").join(", ")}',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.muted,
                ),
              ),
            ] else
              Text(
                '无',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.mutedDarker,
                ),
              ),

            const Divider(height: 24, color: AppColors.divider),

            // 批量操作
            Text(
              '批量操作',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            SizedBox(height: Spacing.md.h),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: allShots.isEmpty || uiState.selectedEpisodeId == null
                    ? null
                    : () {
                        ref
                            .read(episodeShotsMapProvider.notifier)
                            .approveAll(uiState.selectedEpisodeId!);
                        showToast(context, '本集全部镜头已确认通过');
                      },
                icon: Icon(AppIcons.check, size: 16.r),
                label: const Text('一键全部通过'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                  textStyle: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: Spacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: allShots.isEmpty
                    ? null
                    : () {
                        final pending = allShots
                            .where((s) => s.reviewStatus == 'pending')
                            .map((s) => s.shotNumber)
                            .toList();
                        if (pending.isEmpty) {
                          showToast(context, '没有待审核的镜头');
                          return;
                        }
                        if (uiState.selectedEpisodeId != null) {
                          ref
                              .read(episodeShotsMapProvider.notifier)
                              .batchApprove(
                                uiState.selectedEpisodeId!,
                                pending,
                              );
                        }
                        showToast(context, '${pending.length} 个待审核镜头已确认通过');
                      },
                icon: Icon(AppIcons.check, size: 16.r),
                label: const Text('通过全部待审核'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                  textStyle: AppTextStyles.labelMedium,
                ),
              ),
            ),

            const Divider(height: 24, color: AppColors.divider),

            // 删除
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: shot == null || uiState.selectedEpisodeId == null
                    ? null
                    : () => _confirmDeleteShot(context, ref, shot!, uiState),
                icon: Icon(AppIcons.delete, size: 14.r, color: AppColors.error),
                label: Text(
                  '删除镜头',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  padding: EdgeInsets.symmetric(vertical: Spacing.sm.h),
                  textStyle: AppTextStyles.labelMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 私有辅助
// ---------------------------------------------------------------------------

void _confirmDeleteShot(
  BuildContext context,
  WidgetRef ref,
  ShotV4 shot,
  ReviewUiState uiState,
) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('确认删除'),
      content: Text('确定要删除镜头 #${shot.shotNumber} 吗？此操作不可撤销。'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(ctx);
            ref
                .read(episodeShotsMapProvider.notifier)
                .deleteShot(uiState.selectedEpisodeId!, shot.shotNumber);
            ref.read(reviewUiProvider.notifier).selectShot(null);
            showToast(context, '已删除镜头 #${shot.shotNumber}');
          },
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('删除'),
        ),
      ],
    ),
  );
}

Widget _reviewRadio(String value, String label, Color color, String current) {
  final isActive = current == value;
  return Padding(
    padding: EdgeInsets.symmetric(vertical: Spacing.xxs.h),
    child: Row(
      children: [
        Container(
          width: Spacing.md.w,
          height: Spacing.md.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? color : Colors.transparent,
            border: Border.all(
              color: isActive ? color : AppColors.mutedDarker,
              width: 2,
            ),
          ),
        ),
        SizedBox(width: Spacing.sm.w),
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isActive ? color : AppColors.mutedDark,
          ),
        ),
      ],
    ),
  );
}

Widget _taskChip(String label, bool active) {
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: Spacing.md.w,
      vertical: Spacing.xs.h,
    ),
    decoration: BoxDecoration(
      color: active
          ? AppColors.primary.withValues(alpha: 0.15)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
      border: Border.all(
        color: active
            ? AppColors.primary.withValues(alpha: 0.5)
            : AppColors.border,
      ),
    ),
    child: Text(
      label,
      style: AppTextStyles.tiny.copyWith(
        color: active ? AppColors.primary : AppColors.mutedDark,
        fontWeight: active ? FontWeight.w600 : FontWeight.normal,
      ),
    ),
  );
}
