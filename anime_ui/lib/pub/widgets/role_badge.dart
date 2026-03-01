import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';


class RoleBadge extends StatelessWidget {
  final String role;

  const RoleBadge({super.key, required this.role});

  static const _roleStyles = <String, ({Color bg, Color fg, String label})>{
    'owner': (
      bg: AppColors.roleOwnerBg,
      fg: AppColors.roleOwnerFg,
      label: '所有者',
    ),
    'director': (
      bg: AppColors.roleDirectorBg,
      fg: AppColors.roleDirectorFg,
      label: '总监',
    ),
    'editor': (
      bg: AppColors.roleEditorBg,
      fg: AppColors.roleEditorFg,
      label: '编辑',
    ),
    'viewer': (
      bg: AppColors.roleViewerBg,
      fg: AppColors.roleViewerFg,
      label: '查看者',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final style = _roleStyles[role] ?? _roleStyles['viewer']!;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.sm.w,
        vertical: Spacing.xs.h,
      ),
      decoration: BoxDecoration(
        color: style.bg.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
        border: Border.all(color: style.bg.withValues(alpha: 0.4), width: 1.r),
      ),
      child: Text(
        style.label,
        style: AppTextStyles.labelMedium.copyWith(
          color: style.fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
