import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/module/shots/page/provider.dart';
import 'package:anime_ui/pub/utils/url.dart' show resolveFileUrl;
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/app_network_image.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/widgets/task_status/mini_action_button.dart';

/// 单个复合生成任务卡片，展示子任务状态矩阵
class CompositeTaskCard extends StatelessWidget {
  final String shotId;
  final int shotNumber;
  final String cameraScale;
  final String prompt;
  final String imageUrl;
  final CompositeShotStatus status;
  final int completedSubtasks;
  final int totalSubtasks;
  final Map<String, SubtaskState> subtasks;
  final bool isSelected;
  final String viewMode;
  final ValueChanged<bool> onSelectChanged;
  final VoidCallback onGenerate;

  const CompositeTaskCard({
    super.key,
    required this.shotId,
    required this.shotNumber,
    this.cameraScale = '',
    this.prompt = '',
    this.imageUrl = '',
    required this.status,
    this.completedSubtasks = 0,
    this.totalSubtasks = 0,
    this.subtasks = const {},
    required this.isSelected,
    this.viewMode = 'standard',
    required this.onSelectChanged,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final progressPercent = totalSubtasks > 0
        ? completedSubtasks / totalSubtasks
        : 0.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onSelectChanged(!isSelected),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(Spacing.md.r),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.06)
                : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : AppColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              if (viewMode != 'compact') ...[
                SizedBox(height: Spacing.sm.h),
                if (imageUrl.isNotEmpty) _buildThumbnail(),
                SizedBox(height: Spacing.sm.h),
                _buildSubtaskMatrix(),
              ],
              SizedBox(height: Spacing.sm.h),
              _buildProgressBar(progressPercent),
              SizedBox(height: Spacing.sm.h),
              _buildStatusRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 26.w,
          height: 26.h,
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            ),
          child: Center(
            child: Text(
              '$shotNumber',
            style: AppTextStyles.tiny.copyWith(
              color: _statusColor,
              fontWeight: FontWeight.w700,
            ),
            ),
          ),
        ),
        SizedBox(width: Spacing.sm.w),
        Expanded(
          child: Text(
            'S${shotNumber.toString().padLeft(2, '0')}${cameraScale.isNotEmpty ? ' · $cameraScale' : ''}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Icon(
          isSelected ? AppIcons.checkOutline : AppIcons.circleOutline,
          size: 15.r,
          color: isSelected
              ? AppColors.primary
              : AppColors.onSurface.withValues(alpha: 0.5),
        ),
      ],
    );
  }

  Widget _buildThumbnail() {
    if (imageUrl.isEmpty) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(color: AppColors.surfaceContainerHighest),
      );
    }
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(RadiusTokens.md.r),
        child: AppNetworkImage(
          url: resolveFileUrl(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildSubtaskMatrix() {
    const types = [
      ('🎬', 'video'),
      ('🎤', 'vo'),
      ('🎵', 'bgm'),
      ('🔊', 'foley'),
      ('👄', 'lip_sync'),
    ];

    return Wrap(
    spacing: Spacing.sm.w,
    runSpacing: Spacing.xs.h,
      children: types
          .where((t) => subtasks.containsKey(t.$2))
          .map((t) => _subtaskChip(t.$1, subtasks[t.$2]!))
          .toList(),
    );
  }

  Widget _subtaskChip(String emoji, SubtaskState st) {
    Color color;
    String suffix;
    if (st.isComplete) {
      color = AppColors.success;
      suffix = '✅';
    } else if (st.isRunning) {
      color = AppColors.primary;
      suffix = '${st.progress}%';
    } else if (st.isFailed) {
      color = AppColors.error;
      suffix = '❌';
    } else if (st.isWaiting) {
      color = AppColors.tagAmber;
      suffix = '⏳';
    } else {
      color = AppColors.onSurface;
      suffix = '○';
    }

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: Spacing.sm.w, vertical: Spacing.xxs.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
      ),
      child: Text(
        '$emoji $suffix',
        style: AppTextStyles.tiny.copyWith(color: color),
      ),
    );
  }

  Widget _buildProgressBar(double value) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
      child: LinearProgressIndicator(
        value: value,
        backgroundColor: AppColors.surfaceContainerHighest.withValues(
          alpha: 0.5,
        ),
        color: _statusColor,
        minHeight: 4.h,
      ),
    );
  }

  Widget _buildStatusRow() {
    return Row(
      children: [
        Text(
          '$completedSubtasks/$totalSubtasks',
          style: AppTextStyles.tiny.copyWith(
            color: _statusColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        if (status == CompositeShotStatus.notStarted)
          MiniActionButton(
            label: '生成',
            icon: AppIcons.magicStick,
            color: AppColors.primary,
            onTap: onGenerate,
          ),
        if (status == CompositeShotStatus.failed)
          MiniActionButton(
            label: '重试',
            icon: AppIcons.refresh,
            color: AppColors.warning,
            onTap: onGenerate,
          ),
        if (status == CompositeShotStatus.generating)
          SizedBox(
            width: 16.w,
            height: 16.h,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }

  Color get _statusColor => switch (status) {
    CompositeShotStatus.notStarted => AppColors.onSurface,
    CompositeShotStatus.generating => AppColors.primary,
    CompositeShotStatus.partialComplete => AppColors.info,
    CompositeShotStatus.completed => AppColors.success,
    CompositeShotStatus.failed => AppColors.error,
  };
}
