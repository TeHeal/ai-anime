import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/const/job_roles.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';

/// 工种角色 Chip — 可选中/只读两种模式
/// 复用于项目成员管理、团队成员管理、账户分配等场景
class JobRoleChip extends StatelessWidget {
  final String role;
  final bool selected;
  final bool readOnly;
  final ValueChanged<bool>? onChanged;

  const JobRoleChip({
    super.key,
    required this.role,
    this.selected = false,
    this.readOnly = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final roleColor = JobRoles.color(role);
    final label = JobRoles.label(role);

    if (readOnly) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.sm.w,
          vertical: Spacing.xxs.h,
        ),
        decoration: BoxDecoration(
          color: roleColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelTinySmall.copyWith(
            color: roleColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return MouseRegion(
      cursor: onChanged != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: () => onChanged?.call(!selected),
        child: AnimatedContainer(
          duration: MotionTokens.durationFast,
          curve: MotionTokens.curveStandard,
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.chipPaddingH.w,
            vertical: Spacing.chipPaddingV.h,
          ),
          decoration: BoxDecoration(
            color: selected
                ? roleColor.withValues(alpha: 0.15)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            border: Border.all(
              color: selected ? roleColor : AppColors.inputBorder,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: selected ? roleColor : AppColors.muted,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

/// 工种多选 Wrap — 便捷组合 Widget
class JobRoleSelector extends StatelessWidget {
  final List<String> selected;
  final List<String> available;
  final ValueChanged<List<String>> onChanged;
  final bool readOnly;

  const JobRoleSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.available = const [],
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final roles = available.isEmpty ? JobRoles.assignable : available;
    return Wrap(
      spacing: Spacing.sm.w,
      runSpacing: Spacing.xs.h,
      children: roles.map((role) {
        final isSelected = selected.contains(role);
        return JobRoleChip(
          role: role,
          selected: isSelected,
          readOnly: readOnly,
          onChanged: readOnly
              ? null
              : (val) {
                  final newList = List<String>.from(selected);
                  if (val) {
                    newList.add(role);
                  } else {
                    newList.remove(role);
                  }
                  onChanged(newList);
                },
        );
      }).toList(),
    );
  }
}
