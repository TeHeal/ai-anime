import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/providers/step_status_provider.dart';

class StepNav extends StatelessWidget {
  const StepNav({
    super.key,
    required this.currentStep,
    this.onStepTap,
    this.stepStatuses,
  });

  final int currentStep;
  final void Function(int)? onStepTap;
  final StepStatuses? stepStatuses;

  static const steps = [
    ('剧本', AppIcons.script),
    ('资产', AppIcons.assets),
    ('分镜', AppIcons.storyboard),
    ('配置', AppIcons.config),
    ('生成', AppIcons.generate),
    ('剪辑', AppIcons.clipEdit),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.sm.w,
        vertical: Spacing.sm.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
        border: Border.all(
          color: AppColors.onSurface.withValues(alpha: 0.06),
          width: 1.w,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < steps.length; i++) ...[
              if (i > 0) _buildConnector(i),
              _buildStepItem(context, i),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConnector(int nextIndex) {
    final isNextActive = nextIndex == currentStep;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Spacing.xxs.w),
      child: Icon(
        AppIcons.chevronRight,
        size: 20.r,
        color: isNextActive
            ? AppColors.onSurface.withValues(alpha: 0.5)
            : AppColors.onSurface.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildStepItem(BuildContext context, int index) {
    final (label, icon) = steps[index];
    final isActive = index == currentStep;
    final status = stepStatuses?[index] ?? StepStatus.notStarted;

    return GestureDetector(
      onTap: onStepTap != null ? () => onStepTap!(index) : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.lg.w,
          vertical: Spacing.lg.h,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.onSurface
              : AppColors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.shadowOverlay.withValues(alpha: 0.2),
                    blurRadius: 8.r,
                    offset: Offset(0, 2.h),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStepIcon(index, isActive, status),
            SizedBox(width: Spacing.sm.w),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? AppColors.background
                    : AppColors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIcon(int index, bool isActive, StepStatus status) {
    final (_, iconData) = steps[index];

    if (isActive) {
      return Icon(iconData, size: 20.r, color: AppColors.background);
    }

    switch (status) {
      case StepStatus.completed:
        return Icon(AppIcons.check, size: 20.r, color: AppColors.success);
      case StepStatus.inProgress:
        return Icon(AppIcons.inProgress, size: 20.r, color: AppColors.warning);
      case StepStatus.notStarted:
        return Icon(
          iconData,
          size: 20.r,
          color: AppColors.onSurface.withValues(alpha: 0.55),
        );
    }
  }
}
