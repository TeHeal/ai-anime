import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/providers/step_status.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 1),
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
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Icon(
        AppIcons.chevronRight,
        size: 20,
            color: isNextActive
            ? Colors.white.withValues(alpha: 0.5)
            : Colors.grey[600],
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white
              : const Color(0xFF252525),
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStepIcon(index, isActive, status),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? const Color(0xFF1A1A1A) : Colors.grey[400],
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
      return Icon(
        iconData,
        size: 20,
        color: const Color(0xFF1A1A1A),
      );
    }

    switch (status) {
      case StepStatus.completed:
        return Icon(AppIcons.check, size: 20, color: Colors.green[400]);
      case StepStatus.inProgress:
        return Icon(AppIcons.inProgress, size: 20, color: Colors.orange[400]);
      case StepStatus.notStarted:
        return Icon(iconData, size: 20, color: Colors.grey[500]);
    }
  }
}
