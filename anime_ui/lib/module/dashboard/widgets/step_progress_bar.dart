import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';

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
              : Colors.grey[700];
          return Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    margin: const EdgeInsets.only(right: 1),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
                Icon(AppIcons.chevronRight, size: 8, color: color),
                Expanded(
                  child: Container(
                    height: 1,
                    margin: const EdgeInsets.only(left: 1),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(1),
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
                const SizedBox(height: 3),
                Text(
                  steps[i],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: done
                        ? AppColors.primary.withValues(alpha: 0.9)
                        : current
                            ? Colors.grey[300]
                            : Colors.grey[600],
                    fontSize: 9,
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
            : Colors.grey[700]!;

    return Container(
      width: current ? 8 : 6,
      height: current ? 8 : 6,
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
