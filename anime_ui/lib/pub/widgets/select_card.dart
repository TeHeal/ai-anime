import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';


class SelectCard extends StatelessWidget {
  const SelectCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.selected,
    this.onTap,
    this.action,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.surface
          : AppColors.surface.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
        child: Container(
          padding: EdgeInsets.all(Spacing.xl.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.surfaceMuted,
              width: selected ? 2.w : 1.w,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: selected ? AppColors.primary : AppColors.mutedDark,
                  size: Spacing.avatarSize.r,
                ),
                SizedBox(height: Spacing.md.h),
              ],
              Text(
                title,
                style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
              ),
              if (subtitle != null) ...[
                SizedBox(height: Spacing.xs.h),
                Text(
                  subtitle!,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
                ),
              ],
              if (action != null) ...[
                SizedBox(height: Spacing.sm.h),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
