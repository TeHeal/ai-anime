import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/models/dashboard.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// 资产概况卡片 — 渐变装饰 + 进度指示器
class AssetOverview extends StatelessWidget {
  const AssetOverview({super.key, required this.summary});

  final AssetSummary? summary;

  @override
  Widget build(BuildContext context) {
    if (summary == null) return const SizedBox.shrink();
    final s = summary!;

    return Container(
      padding: EdgeInsets.all(Spacing.mid.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface.withValues(alpha: 0.9),
            AppColors.info.withValues(alpha: 0.03),
            AppColors.surface.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(RadiusTokens.xxxl.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.info.withValues(alpha: 0.04),
            blurRadius: 16.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(Spacing.sm.r),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      AppColors.info.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                ),
                child: Icon(
                  AppIcons.category,
                  size: 16.r,
                  color: AppColors.primary.withValues(alpha: 0.8),
                ),
              ),
              SizedBox(width: Spacing.sm.w),
              Text(
                '资产概况',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              _GlowOutlineButton(
                onTap: () => context.go(Routes.assets),
                label: '管理资产',
              ),
            ],
          ),
          SizedBox(height: Spacing.lg.h),
          Row(
            children: [
              Expanded(
                child: _AssetProgressItem(
                  icon: AppIcons.person,
                  label: '角色',
                  confirmed: s.charactersConfirmed,
                  total: s.charactersTotal,
                  color: AppColors.categoryCharacter,
                ),
              ),
              SizedBox(width: Spacing.lg.w),
              Expanded(
                child: _AssetProgressItem(
                  icon: AppIcons.landscape,
                  label: '场景',
                  confirmed: s.locationsConfirmed,
                  total: s.locationsTotal,
                  color: AppColors.categoryLocation,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 资产进度项 — 带微型进度条
class _AssetProgressItem extends StatelessWidget {
  const _AssetProgressItem({
    required this.icon,
    required this.label,
    required this.confirmed,
    required this.total,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int confirmed;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final allDone = confirmed == total && total > 0;
    final pct = total > 0 ? confirmed / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16.r,
              color: color.withValues(alpha: 0.7),
            ),
            SizedBox(width: Spacing.sm.w),
            Text(
              '$label ',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.6),
              ),
            ),
            Text(
              '$confirmed',
              style: AppTextStyles.bodyMedium.copyWith(
                color: allDone ? AppColors.success : color,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '/$total',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        SizedBox(height: Spacing.sm.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: pct),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (_, value, _) => SizedBox(
              height: 3.h,
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: AppColors.surfaceContainer,
                valueColor: AlwaysStoppedAnimation(
                  allDone ? AppColors.success : color,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 渐变描边按钮（轻量级）
class _GlowOutlineButton extends StatefulWidget {
  const _GlowOutlineButton({
    required this.onTap,
    required this.label,
  });

  final VoidCallback onTap;
  final String label;

  @override
  State<_GlowOutlineButton> createState() => _GlowOutlineButtonState();
}

class _GlowOutlineButtonState extends State<_GlowOutlineButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.gridGap.w,
            vertical: Spacing.sm.h,
          ),
          decoration: BoxDecoration(
            color: _hovered
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(Spacing.mid.r),
            border: Border.all(
              color: _hovered
                  ? AppColors.primary.withValues(alpha: 0.7)
                  : AppColors.primary.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: Spacing.xs.w),
              Icon(
                AppIcons.chevronRight,
                size: 14.r,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
