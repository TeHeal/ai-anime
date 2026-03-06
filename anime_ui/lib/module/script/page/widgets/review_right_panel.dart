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
// 右栏：审核操作面板（简洁化重构）
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
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.lg.w,
          vertical: Spacing.xl.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 审核状态（紧凑按钮组） ──
            if (shot != null) ...[
              _buildReviewStatusCard(shot!, uiNotifier),
              SizedBox(height: Spacing.lg.h),
            ],

            // ── 生成任务 ──
            if (shot != null) ...[
              _buildTaskTags(shot!),
              SizedBox(height: Spacing.lg.h),
            ],

            // ── 批量操作 ──
            _buildBatchActions(context, ref, allShots, uiState),

            SizedBox(height: Spacing.xl.h),

            // ── 删除 ──
            if (shot != null && uiState.selectedEpisodeId != null)
              _buildDeleteButton(context, ref, shot!, uiState),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 审核状态卡片
// ---------------------------------------------------------------------------

Widget _buildReviewStatusCard(ShotV4 shot, ReviewUiNotifier notifier) {
  final status = shot.reviewStatus;
  final statusInfo = _statusMeta(status);

  return Container(
    padding: EdgeInsets.all(Spacing.md.r),
    decoration: BoxDecoration(
      color: statusInfo.color.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
      border: Border.all(
        color: statusInfo.color.withValues(alpha: 0.2),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 当前状态指示
        Row(
          children: [
            Container(
              width: 8.w,
              height: 8.h,
              decoration: BoxDecoration(
                color: statusInfo.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: statusInfo.color.withValues(alpha: 0.4),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            SizedBox(width: Spacing.sm.w),
            Text(
              statusInfo.label,
              style: AppTextStyles.labelMedium.copyWith(
                color: statusInfo.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: Spacing.md.h),

        // 操作按钮行
        Row(
          children: [
            Expanded(
              child: _statusActionBtn(
                icon: AppIcons.check,
                label: '通过',
                color: AppColors.success,
                active: status == 'approved',
                onTap: status == 'approved'
                    ? null
                    : () => notifier.setReview(shot.shotNumber, 'approved'),
              ),
            ),
            SizedBox(width: Spacing.sm.w),
            Expanded(
              child: _statusActionBtn(
                icon: AppIcons.warning,
                label: '修改',
                color: AppColors.warning,
                active: status == 'needsRevision',
                onTap: status == 'needsRevision'
                    ? null
                    : () => notifier.setReview(
                        shot.shotNumber, 'needsRevision'),
              ),
            ),
            SizedBox(width: Spacing.sm.w),
            Expanded(
              child: _statusActionBtn(
                icon: AppIcons.clock,
                label: '待审',
                color: AppColors.muted,
                active: status == 'pending',
                onTap: status == 'pending'
                    ? null
                    : () => notifier.setReview(shot.shotNumber, 'pending'),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _statusActionBtn({
  required IconData icon,
  required String label,
  required Color color,
  required bool active,
  VoidCallback? onTap,
}) {
  return MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          vertical: Spacing.sm.h,
        ),
        decoration: BoxDecoration(
          color: active
              ? color.withValues(alpha: 0.15)
              : AppColors.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(RadiusTokens.md.r),
          border: Border.all(
            color: active
                ? color.withValues(alpha: 0.4)
                : AppColors.border.withValues(alpha: 0.3),
          ),
        ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 14.r,
            color: active ? color : AppColors.mutedDark,
          ),
          SizedBox(height: Spacing.xxs.h),
          Text(
            label,
            style: AppTextStyles.tiny.copyWith(
              color: active ? color : AppColors.mutedDark,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
  ),
  );
}

// ---------------------------------------------------------------------------
// 生成任务标签
// ---------------------------------------------------------------------------

Widget _buildTaskTags(ShotV4 shot) {
  const tasks = ['图像', '视频', 'TTS', 'BGM', '音效', '转场'];
  final active = shot.generateTasks;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(AppIcons.bolt, size: 12.r, color: AppColors.mutedDark),
          SizedBox(width: Spacing.xs.w),
          Text(
            '生成任务',
            style: AppTextStyles.tiny.copyWith(
              color: AppColors.mutedDark,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      SizedBox(height: Spacing.sm.h),
      Wrap(
        spacing: Spacing.xs.w,
        runSpacing: Spacing.xs.h,
        children: tasks.map((t) {
          final on = active.contains(t);
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.sm.w,
              vertical: Spacing.xxs.h,
            ),
            decoration: BoxDecoration(
              color: on
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
              border: Border.all(
                color: on
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : AppColors.border.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              t,
              style: AppTextStyles.tiny.copyWith(
                color: on ? AppColors.primary : AppColors.mutedDarker,
                fontWeight: on ? FontWeight.w600 : FontWeight.normal,
                fontSize: 10.sp,
              ),
            ),
          );
        }).toList(),
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// 批量操作
// ---------------------------------------------------------------------------

Widget _buildBatchActions(
  BuildContext context,
  WidgetRef ref,
  List<ShotV4> allShots,
  ReviewUiState uiState,
) {
  final pendingCount = allShots.where((s) => s.reviewStatus == 'pending').length;
  final totalCount = allShots.length;
  final approvedCount = allShots.where((s) => s.reviewStatus == 'approved').length;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // 进度指示
      if (totalCount > 0) ...[
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
                child: LinearProgressIndicator(
                  value: totalCount > 0 ? approvedCount / totalCount : 0,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: const AlwaysStoppedAnimation(AppColors.success),
                  minHeight: 3.h,
                ),
              ),
            ),
            SizedBox(width: Spacing.sm.w),
            Text(
              '$approvedCount/$totalCount',
              style: AppTextStyles.tiny.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: Spacing.md.h),
      ],

      // 按钮组
      Row(
        children: [
          Expanded(
            child: _batchBtn(
              label: '全部通过',
              icon: AppIcons.check,
              color: AppColors.primary,
              enabled: allShots.isNotEmpty &&
                  uiState.selectedEpisodeId != null,
              onTap: () {
                ref
                    .read(episodeShotsMapProvider.notifier)
                    .approveAll(uiState.selectedEpisodeId!);
                showToast(context, '本集全部镜头已确认通过');
              },
            ),
          ),
          SizedBox(width: Spacing.sm.w),
          Expanded(
            child: _batchBtn(
              label: '通过待审 ($pendingCount)',
              icon: AppIcons.checkOutline,
              color: AppColors.mutedLight,
              outlined: true,
              enabled: pendingCount > 0 &&
                  uiState.selectedEpisodeId != null,
              onTap: () {
                final pending = allShots
                    .where((s) => s.reviewStatus == 'pending')
                    .map((s) => s.shotNumber)
                    .toList();
                ref
                    .read(episodeShotsMapProvider.notifier)
                    .batchApprove(uiState.selectedEpisodeId!, pending);
                showToast(context, '$pendingCount 个待审核镜头已确认通过');
              },
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _batchBtn({
  required String label,
  required IconData icon,
  required Color color,
  bool outlined = false,
  required bool enabled,
  required VoidCallback onTap,
}) {
  return MouseRegion(
    cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
    child: GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: Spacing.sm.h,
          horizontal: Spacing.sm.w,
        ),
        decoration: BoxDecoration(
          color: outlined
              ? Colors.transparent
              : (enabled
                  ? color.withValues(alpha: 0.12)
                  : AppColors.surfaceVariant.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(RadiusTokens.md.r),
          border: Border.all(
            color: enabled
                ? color.withValues(alpha: 0.3)
                : AppColors.border.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 14.r,
            color: enabled ? color : AppColors.mutedDarker,
          ),
          SizedBox(height: Spacing.xxs.h),
          Text(
            label,
            style: AppTextStyles.tiny.copyWith(
              color: enabled ? color : AppColors.mutedDarker,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  ),
  );
}

// ---------------------------------------------------------------------------
// 删除
// ---------------------------------------------------------------------------

Widget _buildDeleteButton(
  BuildContext context,
  WidgetRef ref,
  ShotV4 shot,
  ReviewUiState uiState,
) {
  return Center(
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _confirmDeleteShot(context, ref, shot, uiState),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: Spacing.sm.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                AppIcons.delete,
                size: 12.r,
                color: AppColors.mutedDarker,
              ),
              SizedBox(width: Spacing.xs.w),
              Text(
                '删除镜头',
                style: AppTextStyles.tiny.copyWith(
                  color: AppColors.mutedDarker,
                ),
            ),
          ],
        ),
      ),
    ),
    ),
  );
}

void _confirmDeleteShot(
  BuildContext context,
  WidgetRef ref,
  ShotV4 shot,
  ReviewUiState uiState,
) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.card.r),
      ),
      title: Row(
        children: [
          Icon(AppIcons.warning, size: 18.r, color: AppColors.error),
          SizedBox(width: Spacing.sm.w),
          const Text('确认删除'),
        ],
      ),
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
            if (ctx.mounted) {
              showToast(context, '已删除镜头 #${shot.shotNumber}');
            }
          },
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('删除'),
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// 辅助
// ---------------------------------------------------------------------------

({String label, Color color}) _statusMeta(String status) {
  return switch (status) {
    'approved' => (label: '已确认通过', color: AppColors.success),
    'needsRevision' => (label: '需要修改', color: AppColors.warning),
    _ => (label: '待审核', color: AppColors.muted),
  };
}
