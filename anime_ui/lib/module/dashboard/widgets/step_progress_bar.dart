import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// 步进显示：圆形节点 + 连接线 + 箭头，done/current/pending 三态区分
class StepProgressBar extends StatelessWidget {
  const StepProgressBar({
    super.key,
    required this.currentStep,
    this.steps = _defaultSteps,
    this.percentages,
    this.compact = false,
  });

  final int currentStep;
  final List<String> steps;
  final List<int>? percentages;
  final bool compact;

  /// 五步：资产→脚本→镜图→镜头→成片（从资产到成片，不含剧本）
  static const _defaultSteps = ['资产', '脚本', '镜图', '镜头', '成片'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(steps.length * 2 - 1, (idx) {
        if (idx.isOdd) {
          final prevDone = currentStep > (idx ~/ 2);
          final color = prevDone
              ? AppColors.primary.withValues(alpha: 0.8)
              : AppColors.surfaceMuted;
          return Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    height: 1.h,
                    margin: EdgeInsets.only(right: Spacing.xxs.w),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(Spacing.xxs.r),
                    ),
                  ),
                ),
                Icon(AppIcons.chevronRight, size: 8.r, color: color),
                Expanded(
                  child: Container(
                    height: 1.h,
                    margin: EdgeInsets.only(left: Spacing.xxs.w),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(Spacing.xxs.r),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        final i = idx ~/ 2;
        final done = currentStep > i;
        final current = currentStep == i;

        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StepNode(done: done, current: current),
              if (!compact) ...[
                SizedBox(height: Spacing.progressBarHeight.h),
                Text(
                  steps[i],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.tiny.copyWith(
                    color: done
                        ? AppColors.primary.withValues(alpha: 0.9)
                        : current
                            ? AppColors.mutedLight
                            : AppColors.mutedDarker,
                    fontWeight: current ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}

class _StepNode extends StatelessWidget {
  const _StepNode({required this.done, required this.current});

  final bool done;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final color = done
        ? AppColors.primary
        : current
            ? AppColors.primary.withValues(alpha: 0.9)
            : AppColors.border;

    return Container(
      width: current ? 8.w : 6.w,
      height: current ? 8.h : 6.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? color : Colors.transparent,
        border: Border.all(
          color: color,
          width: current ? 1.5 : 1,
        ),
      ),
    );
  }
}
