import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/character.dart';

/// 角色详情底部操作栏：确认、删除、生成形象、编辑
class CharacterBottomBar extends StatelessWidget {
  const CharacterBottomBar({
    super.key,
    required this.character,
    this.onConfirm,
    required this.onDelete,
    this.onGenerateImage,
    this.onEdit,
  });

  final Character character;
  final VoidCallback? onConfirm;
  final VoidCallback onDelete;
  final VoidCallback? onGenerateImage;
  final VoidCallback? onEdit;

  Character get c => character;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.mid.w,
        vertical: Spacing.md.h,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          _buildStatusBadge(),
          const Spacer(),
          if (!c.isConfirmed && onConfirm != null)
            FilledButton.icon(
              onPressed: onConfirm,
              icon: Icon(AppIcons.check, size: 14.r),
              label: const Text('确认角色'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: EdgeInsets.symmetric(
                  horizontal: Spacing.lg.w,
                  vertical: Spacing.sm.h,
                ),
              ),
            ),
          if (!c.isConfirmed && onConfirm != null) SizedBox(width: Spacing.sm.w),
          if (onGenerateImage != null)
            OutlinedButton.icon(
              onPressed: c.isGenerating ? null : onGenerateImage,
              icon: Icon(
                AppIcons.autoAwesome,
                size: 14.r,
                color: c.isGenerating ? AppColors.muted : null,
              ),
              label: Text(c.isGenerating ? '生成中...' : '生成形象'),
            ),
          if (onGenerateImage != null) SizedBox(width: Spacing.sm.w),
          if (onEdit != null)
            OutlinedButton.icon(
              onPressed: onEdit,
              icon: Icon(AppIcons.edit, size: 14.r),
              label: const Text('编辑'),
            ),
          if (onEdit != null) SizedBox(width: Spacing.sm.w),
          OutlinedButton.icon(
            onPressed: onDelete,
            icon: Icon(AppIcons.delete, size: 14.r, color: AppColors.error),
            label: Text(
              '删除',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final (String label, Color color) = switch (c.status) {
      'confirmed' => ('已确认', AppColors.success),
      'skeleton' => ('骨架', AppColors.onSurface),
      _ => ('待确认', AppColors.newTag),
    };
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.sm.w,
        vertical: Spacing.xs.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
