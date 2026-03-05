import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/storyboard_script.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// 分集就绪度看板——展示每集的审核完成度
class FreezeReadinessBoard extends StatelessWidget {
  const FreezeReadinessBoard({
    super.key,
    required this.episodeStates,
    required this.isLocked,
  });

  final List<EpisodeGenerateState> episodeStates;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final withShots =
        episodeStates.where((s) => s.isComplete && s.shotCount > 0).toList();

    if (withShots.isEmpty) {
      return _emptyState();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(RadiusTokens.xxl.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Padding(
            padding: EdgeInsets.fromLTRB(
              Spacing.xl.w, Spacing.lg.h, Spacing.xl.w, Spacing.md.h,
            ),
            child: Row(
              children: [
                Icon(AppIcons.film, size: 16.r, color: AppColors.primary),
                SizedBox(width: Spacing.sm.w),
                Text(
                  isLocked ? '锁定时各集状态' : '分集就绪度',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const Spacer(),
                _summaryChip(withShots),
              ],
            ),
          ),
          const Divider(color: AppColors.border, height: 1),
          // 集列表
          ...withShots.map((ep) => _episodeRow(ep, withShots.last == ep)),
        ],
      ),
    );
  }

  Widget _summaryChip(List<EpisodeGenerateState> list) {
    final allReady = list.every((s) => s.allApproved);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.md.w,
        vertical: Spacing.xs.h,
      ),
      decoration: BoxDecoration(
        color: allReady
            ? AppColors.success.withValues(alpha: 0.12)
            : AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(RadiusTokens.md.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            allReady ? AppIcons.check : AppIcons.clock,
            size: 12.r,
            color: allReady ? AppColors.success : AppColors.warning,
          ),
          SizedBox(width: Spacing.xs.w),
          Text(
            allReady ? '全部就绪' : '审核中',
            style: AppTextStyles.tiny.copyWith(
              color: allReady ? AppColors.success : AppColors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _episodeRow(EpisodeGenerateState ep, bool isLast) {
    final approved = ep.approvedCount;
    final pending = ep.pendingCount;
    final revision = ep.revisionCount;
    final total = ep.shotCount;
    final rate = total > 0 ? (approved / total * 100) : 0.0;
    final allApproved = ep.allApproved;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.xl.w,
        vertical: Spacing.md.h,
      ),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
              ),
      ),
      child: Row(
        children: [
          // 就绪图标
          _readinessIcon(allApproved, revision),
          SizedBox(width: Spacing.md.w),
          // 集名
          Expanded(
            flex: 2,
            child: Text(
              ep.episodeTitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: Spacing.md.w),
          // 进度条
          Expanded(
            flex: 5,
            child: _progressBar(approved, pending, revision, total),
          ),
          SizedBox(width: Spacing.md.w),
          // 通过率
          SizedBox(
            width: 48.w,
            child: Text(
              '${rate.toStringAsFixed(0)}%',
              style: AppTextStyles.bodySmall.copyWith(
                color: allApproved ? AppColors.success : AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(width: Spacing.md.w),
          // 数量标签
          _countLabel(AppIcons.check, '$approved', AppColors.success),
          SizedBox(width: Spacing.sm.w),
          _countLabel(AppIcons.clock, '$pending', AppColors.muted),
          if (revision > 0) ...[
            SizedBox(width: Spacing.sm.w),
            _countLabel(AppIcons.warning, '$revision', AppColors.warning),
          ],
        ],
      ),
    );
  }

  Widget _readinessIcon(bool allApproved, int revision) {
    if (allApproved) {
      return Container(
        width: 24.w,
        height: 24.h,
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(AppIcons.check, size: 14.r, color: AppColors.success),
      );
    }
    if (revision > 0) {
      return Container(
        width: 24.w,
        height: 24.h,
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(AppIcons.warning, size: 14.r, color: AppColors.warning),
      );
    }
    return Container(
      width: 24.w,
      height: 24.h,
      decoration: const BoxDecoration(
        color: AppColors.surfaceVariant,
        shape: BoxShape.circle,
      ),
      child: Icon(AppIcons.clock, size: 14.r, color: AppColors.muted),
    );
  }

  /// 三色段进度条：通过=绿，需修改=橙，待审=灰
  Widget _progressBar(int approved, int pending, int revision, int total) {
    if (total == 0) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
      child: SizedBox(
        height: 6.h,
        child: Row(
          children: [
            if (approved > 0)
              Expanded(
                flex: approved,
                child: Container(color: AppColors.success),
              ),
            if (revision > 0)
              Expanded(
                flex: revision,
                child: Container(color: AppColors.warning),
              ),
            if (pending > 0)
              Expanded(
                flex: pending,
                child: Container(
                  color: AppColors.muted.withValues(alpha: 0.25),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _countLabel(IconData icon, String count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10.r, color: color),
        SizedBox(width: 2.w),
        Text(
          count,
          style: AppTextStyles.tiny.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return Container(
      padding: EdgeInsets.all(Spacing.xxl.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(RadiusTokens.xxl.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.film, size: 32.r, color: AppColors.mutedDarker),
            SizedBox(height: Spacing.md.h),
            Text(
              '暂无已生成的脚本',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.mutedDark,
              ),
            ),
            SizedBox(height: Spacing.xs.h),
            Text(
              '请先在「生成中心」中生成分镜脚本',
              style: AppTextStyles.tiny.copyWith(color: AppColors.mutedDarker),
            ),
          ],
        ),
      ),
    );
  }
}
