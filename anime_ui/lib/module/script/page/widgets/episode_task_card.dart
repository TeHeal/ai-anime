import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/models/storyboard_script.dart';
import 'package:anime_ui/pub/widgets/task_status/mini_action_button.dart';

/// 单集脚本生成任务卡片
class EpisodeTaskCard extends StatelessWidget {
  const EpisodeTaskCard({
    super.key,
    required this.episodeId,
    required this.title,
    required this.sortIndex,
    this.state,
    required this.isSelected,
    required this.onSelectChanged,
    required this.onGenerate,
    required this.onReview,
  });

  final int episodeId;
  final String title;
  final int sortIndex;
  final EpisodeGenerateState? state;
  final bool isSelected;
  final ValueChanged<bool> onSelectChanged;
  final VoidCallback onGenerate;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final status = state?.status ?? EpisodeScriptStatus.notStarted;
    final progress = state?.progress ?? 0;
    final shotCount = state?.shotCount ?? 0;

    Color accentColor;
    IconData statusIcon;
    String statusText;
    switch (status) {
      case EpisodeScriptStatus.completed:
        accentColor = AppColors.success;
        statusIcon = AppIcons.check;
        statusText = '已完成';
        break;
      case EpisodeScriptStatus.generating:
        accentColor = AppColors.primary;
        statusIcon = AppIcons.sync;
        statusText = '生成中';
        break;
      case EpisodeScriptStatus.failed:
        accentColor = AppColors.error;
        statusIcon = AppIcons.error;
        statusText = '失败';
        break;
      case EpisodeScriptStatus.notStarted:
        accentColor = AppColors.onSurface;
        statusIcon = AppIcons.circleOutline;
        statusText = '待生成';
        break;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onSelectChanged(!isSelected),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(Spacing.lg),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.06)
                : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                    ),
                    child: Center(
                      child: Text(
                        '${sortIndex + 1}',
                        style: AppTextStyles.caption.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    isSelected ? AppIcons.checkOutline : AppIcons.circleOutline,
                    size: 16.r,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.onSurface.withValues(alpha: 0.5),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
                child: LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: AppColors.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  color: accentColor,
                  minHeight: 4.h,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Row(
                children: [
                  Icon(statusIcon, size: 13.r, color: accentColor),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    statusText,
                    style: AppTextStyles.tiny.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (status == EpisodeScriptStatus.completed) ...[
                    const SizedBox(width: Spacing.sm),
                    Text(
                      '$shotCount 镜头',
                      style: AppTextStyles.tiny.copyWith(
                        color: AppColors.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                  if (status == EpisodeScriptStatus.generating) ...[
                    const SizedBox(width: Spacing.sm),
                    Text(
                      '$progress%',
                      style: AppTextStyles.tiny.copyWith(
                        color: AppColors.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                  const Spacer(),
                  _buildAction(status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAction(EpisodeScriptStatus status) {
    switch (status) {
      case EpisodeScriptStatus.completed:
        return MiniActionButton(
          label: '审核',
          icon: AppIcons.arrowForward,
          color: AppColors.success,
          onTap: onReview,
        );
      case EpisodeScriptStatus.generating:
        return const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case EpisodeScriptStatus.failed:
        return MiniActionButton(
          label: '重试',
          icon: AppIcons.refresh,
          color: AppColors.warning,
          onTap: onGenerate,
        );
      case EpisodeScriptStatus.notStarted:
        return MiniActionButton(
          label: '生成',
          icon: AppIcons.magicStick,
          color: AppColors.primary,
          onTap: onGenerate,
        );
    }
  }
}
