import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';

/// 统计快报芯片
class StatChip extends StatelessWidget {
  const StatChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.gridGap.w,
        vertical: Spacing.sm.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.r, color: color.withValues(alpha: 0.7)),
          SizedBox(width: Spacing.xs.w),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(width: Spacing.sm.w),
          Text(
            value,
            style: AppTextStyles.labelLarge.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// 渐变填充按钮
class GradientActionButton extends StatefulWidget {
  const GradientActionButton({
    super.key,
    required this.onTap,
    required this.icon,
    required this.label,
  });

  final VoidCallback onTap;
  final IconData icon;
  final String label;

  @override
  State<GradientActionButton> createState() => _GradientActionButtonState();
}

class _GradientActionButtonState extends State<GradientActionButton> {
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
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.xl.w,
            vertical: Spacing.gridGap.h,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _hovered
                  ? [AppColors.primary, AppColors.info]
                  : [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.85),
                    ],
            ),
            borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary
                    .withValues(alpha: _hovered ? 0.4 : 0.2),
                blurRadius: _hovered ? 20.r : 10.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 18.r, color: AppColors.onPrimary),
              SizedBox(width: Spacing.sm.w),
              Text(
                widget.label,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 快速开始步骤芯片
class QuickStepChip extends StatelessWidget {
  const QuickStepChip({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
  });

  final IconData icon;
  final String label;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(Spacing.md.r),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.6),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
          ),
          child: Icon(
            icon,
            size: 18.r,
            color: AppColors.primary.withValues(alpha: 0.6),
          ),
        ),
        SizedBox(height: Spacing.sm.h),
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: Spacing.xxs.h),
        Text(
          subtitle,
          style: AppTextStyles.labelTinySmall.copyWith(
            color: AppColors.mutedDarker,
          ),
        ),
      ],
    );
  }
}
