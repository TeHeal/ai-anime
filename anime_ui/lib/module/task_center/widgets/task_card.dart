import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/task.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// 任务类型 → 显示名 + 图标 + 颜色
class _TaskTypeMeta {
  final String label;
  final IconData icon;
  final Color color;
  const _TaskTypeMeta(this.label, this.icon, this.color);
}

final _typeMetaMap = <String, _TaskTypeMeta>{
  'shot_image': const _TaskTypeMeta('镜图生成', AppIcons.image, AppColors.primary),
  'shot_video': const _TaskTypeMeta('镜头生成', AppIcons.video, AppColors.info),
  'script': const _TaskTypeMeta('脚本生成', AppIcons.script, AppColors.success),
  'export': const _TaskTypeMeta('导出', AppIcons.download, AppColors.warning),
  'composite': const _TaskTypeMeta('成片合成', AppIcons.movie, AppColors.secondary),
  'tts': const _TaskTypeMeta('语音合成', AppIcons.mic, AppColors.categoryVoice),
  'music': const _TaskTypeMeta('音乐生成', AppIcons.music, AppColors.categoryStyle),
};

_TaskTypeMeta _metaFor(String type) =>
    _typeMetaMap[type] ?? _TaskTypeMeta(type, AppIcons.bolt, AppColors.muted);

/// 状态 → 颜色 + 标签
Color _statusColor(String status) {
  switch (status) {
    case 'pending':
      return AppColors.muted;
    case 'running':
      return AppColors.primary;
    case 'completed':
      return AppColors.success;
    case 'failed':
      return AppColors.error;
    case 'cancelled':
      return AppColors.mutedDark;
    default:
      return AppColors.muted;
  }
}

String _statusLabel(String status) {
  switch (status) {
    case 'pending':
      return '排队中';
    case 'running':
      return '运行中';
    case 'completed':
      return '已完成';
    case 'failed':
      return '失败';
    case 'cancelled':
      return '已取消';
    default:
      return status;
  }
}

/// 单个任务卡片
class TaskCard extends StatelessWidget {
  final Task task;
  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final meta = _metaFor(task.type);
    final sColor = _statusColor(task.status);

    return Container(
      margin: EdgeInsets.only(bottom: Spacing.sm.h),
      padding: EdgeInsets.all(Spacing.md.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(RadiusTokens.card.r),
        border: Border.all(
          color: task.isRunning
              ? meta.color.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部行：类型图标 + 类型名 + 状态
          Row(
            children: [
              Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color: meta.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                ),
                child: Icon(meta.icon, size: 16.r, color: meta.color),
              ),
              SizedBox(width: Spacing.sm.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meta.label,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    if (task.model.isNotEmpty)
                      Text(
                        task.model,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.mutedDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              _StatusChip(status: task.status, color: sColor),
            ],
          ),

          // 进度条（仅运行中显示）
          if (task.isRunning) ...[
            SizedBox(height: Spacing.sm.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
              child: LinearProgressIndicator(
                value: task.progress / 100,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation(meta.color),
                minHeight: Spacing.progressBarHeight.h,
              ),
            ),
            SizedBox(height: Spacing.xs.h),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${task.progress}%',
                style: AppTextStyles.caption.copyWith(
                  color: meta.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          // 错误信息（仅失败时显示）
          if (task.isFailed && task.error != null) ...[
            SizedBox(height: Spacing.sm.h),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.sm.w,
                vertical: Spacing.xs.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
              ),
              child: Row(
                children: [
                  Icon(AppIcons.error, size: 14.r, color: AppColors.error),
                  SizedBox(width: Spacing.xs.w),
                  Expanded(
                    child: Text(
                      task.error!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.error,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 底部：任务 ID
          SizedBox(height: Spacing.xs.h),
          Text(
            'ID: ${task.taskId}',
            style: AppTextStyles.labelTiny.copyWith(
              color: AppColors.mutedDark,
            ),
          ),
        ],
      ),
    );
  }
}

/// 状态芯片
class _StatusChip extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusChip({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.chipPaddingH.w,
        vertical: Spacing.chipPaddingV.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(RadiusTokens.md.r),
      ),
      child: Text(
        _statusLabel(status),
        style: AppTextStyles.labelMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
