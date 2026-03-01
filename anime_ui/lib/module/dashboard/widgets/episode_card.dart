import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/models/dashboard.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'step_progress_bar.dart';

/// 集卡片：状态、标题、进度条
class EpisodeCard extends StatefulWidget {
  const EpisodeCard({
    super.key,
    required this.episode,
    required this.onTap,
    this.compact = false,
  });

  final DashboardEpisode episode;
  final VoidCallback onTap;
  final bool compact;

  @override
  State<EpisodeCard> createState() => _EpisodeCardState();
}

class _EpisodeCardState extends State<EpisodeCard> {
  bool _hovered = false;

  DashboardEpisode get ep => widget.episode;

  @override
  Widget build(BuildContext context) {
    return widget.compact ? _buildCompact() : _buildFull();
  }

  Widget _buildFull() {
    final statusInfo = _statusInfo(ep.status);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.all(Spacing.mid.r),
          decoration: BoxDecoration(
            color: _hovered
                ? AppColors.surface.withValues(alpha: 0.9)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(RadiusTokens.xxxl.r),
            border: Border.all(
              color: _hovered
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : AppColors.surfaceMutedDark.withValues(alpha: 0.5),
              width: _hovered ? 1.5 : 1,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 20.r,
                      offset: Offset(0, 4.h),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(statusInfo),
              SizedBox(height: Spacing.gridGap.h),
              _buildTitle(),
              if (ep.summary.isNotEmpty) ...[
                SizedBox(height: Spacing.sm.h),
                _buildSummary(),
              ],
              SizedBox(height: Spacing.lg.h),
              _buildStepIndicator(),
              SizedBox(height: Spacing.gridGap.h),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompact() {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.lg.w,
            vertical: Spacing.md.h,
          ),
          decoration: BoxDecoration(
            color: _hovered
                ? AppColors.surface.withValues(alpha: 0.9)
                : AppColors.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
            border: Border.all(
              color: _hovered
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : AppColors.surfaceMutedDark.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    '第${ep.sortIndex + 1}集',
                    style: AppTextStyles.tiny.copyWith(
                      color: AppColors.mutedDark,
                    ),
                  ),
                  SizedBox(width: Spacing.sm.w),
                  Expanded(
                    child: Text(
                      ep.title.isNotEmpty ? ep.title : '第${ep.sortIndex + 1}集',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (ep.sceneCount > 0)
                    Text(
                      '${ep.sceneCount}场',
                      style: AppTextStyles.tiny.copyWith(
                        color: AppColors.mutedDarker,
                      ),
                    ),
                ],
              ),
              SizedBox(height: Spacing.sm.h),
              _buildStepIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(_StatusInfo info) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: RadiusTokens.lg.w,
            vertical: Spacing.xs.h,
          ),
          decoration: BoxDecoration(
            color: info.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(Spacing.mid.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(info.icon, size: 13.r, color: info.color),
              SizedBox(width: (RadiusTokens.sm + 1).w),
              Text(
                info.label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: info.color,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Text(
          '第${ep.sortIndex + 1}集',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.mutedDark,
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      ep.title.isNotEmpty ? ep.title : '第${ep.sortIndex + 1}集',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
    );
  }

  Widget _buildSummary() {
    return Text(
      ep.summary,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.muted,
        height: 1.4,
      ),
    );
  }

  Widget _buildStepIndicator() {
    final prog = ep.progress;
    final percentages = prog != null
        ? [
            prog.assetsPct,
            prog.scriptPct,
            prog.storyboardPct,
            prog.shotsPct,
            prog.episodePct,
          ]
        : null;
    return StepProgressBar(
      currentStep: ep.currentStep,
      percentages: percentages,
      compact: widget.compact,
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        if (ep.sceneCount > 0) ...[
          Icon(AppIcons.list, size: 13.r, color: AppColors.mutedDark),
          SizedBox(width: Spacing.xs.w),
          Text(
            '${ep.sceneCount}场',
            style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.mutedDark,
          ),
          ),
          SizedBox(width: Spacing.md.w),
        ],
        if (ep.characterNames.isNotEmpty) ...[
          Icon(AppIcons.person, size: 13.r, color: AppColors.mutedDark),
          SizedBox(width: Spacing.xs.w),
          Expanded(
            child: Text(
              ep.characterNames.take(3).join('、'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.mutedDark,
          ),
            ),
          ),
        ],
        if (ep.characterNames.isEmpty) const Spacer(),
        if (_hovered)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: RadiusTokens.lg.w,
              vertical: Spacing.xs.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(Spacing.mid.r),
            ),
            child: Text(
              '进入',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.onPrimary,
              ),
            ),
          ),
      ],
    );
  }

  static _StatusInfo _statusInfo(String status) {
    switch (status) {
      case 'in_progress':
        return const _StatusInfo('进行中', AppIcons.inProgress, AppColors.info);
      case 'completed':
        return const _StatusInfo('已完成', AppIcons.check, AppColors.success);
      default:
        return const _StatusInfo('未开始', AppIcons.circleOutline, AppColors.mutedDark);
    }
  }
}

class _StatusInfo {
  const _StatusInfo(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}
