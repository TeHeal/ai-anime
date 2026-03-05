import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// 脚本锁定状态 Hero 卡片，锁定/未锁定双态视觉
class FreezeStatusCard extends StatelessWidget {
  const FreezeStatusCard({
    super.key,
    required this.isLocked,
    this.lockedAt,
    required this.totalShots,
    required this.approvedShots,
    required this.pendingShots,
    required this.revisionShots,
  });

  final bool isLocked;
  final DateTime? lockedAt;
  final int totalShots;
  final int approvedShots;
  final int pendingShots;
  final int revisionShots;

  double get _passRate =>
      totalShots > 0 ? (approvedShots / totalShots * 100) : 0;

  String _formatTime(DateTime? t) {
    if (t == null) return '';
    return '${t.month}/${t.day} '
        '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = isLocked ? AppColors.success : AppColors.primary;

    return Container(
      padding: EdgeInsets.all(Spacing.xl.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.10),
            accentColor.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(RadiusTokens.xxl.r),
        border: Border.all(color: accentColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          // 左侧图标
          _buildIcon(accentColor),
          SizedBox(width: Spacing.xl.w),
          // 中间文案
          Expanded(child: _buildTextContent(accentColor)),
          // 右侧统计
          _buildStats(accentColor),
        ],
      ),
    );
  }

  Widget _buildIcon(Color color) {
    return Container(
      width: 56.w,
      height: 56.h,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
      ),
      child: Icon(
        isLocked ? AppIcons.lock : AppIcons.lockUnlocked,
        size: 28.r,
        color: color,
      ),
    );
  }

  Widget _buildTextContent(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isLocked ? '脚本已锁定' : '脚本未锁定',
          style: AppTextStyles.h3.copyWith(
            color: isLocked ? color : AppColors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: Spacing.xs.h),
        Text(
          isLocked
              ? '锁定于 ${_formatTime(lockedAt)} — 脚本已定稿，进入生产基线'
              : '审核通过全部镜头后，锁定脚本进入生产阶段',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }

  Widget _buildStats(Color color) {
    if (totalShots == 0) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.lg.w,
          vertical: Spacing.md.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
        ),
        child: Text(
          '暂无镜头',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.mutedDark),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _statItem('$totalShots', '总镜头', AppColors.onSurface),
        SizedBox(width: Spacing.lg.w),
        _statItem('$approvedShots', '已通过', AppColors.success),
        SizedBox(width: Spacing.lg.w),
        _statItem('${_passRate.toStringAsFixed(0)}%', '通过率', color),
      ],
    );
  }

  Widget _statItem(String value, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTextStyles.h3.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: Spacing.xxs.h),
        Text(
          label,
          style: AppTextStyles.tiny.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }
}
