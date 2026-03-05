import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/character.dart';

/// 骨架步骤定义
const _stepDefs = <(String, bool Function(Character))>[
  ('基础信息', _hasBasicInfo),
  ('风格', _hasStyle),
  ('形象图', _hasImage),
  ('声音', _hasVoice),
];

bool _hasBasicInfo(Character c) =>
    c.personality.isNotEmpty || c.appearance.isNotEmpty;
bool _hasStyle(Character c) => c.style.isNotEmpty || !c.styleOverride;
bool _hasImage(Character c) => c.hasImage || c.referenceImages.isNotEmpty;
bool _hasVoice(Character c) => c.voiceName.isNotEmpty;

/// 角色详情底部操作栏
///
/// 骨架状态：左侧步骤指示（可点击跳转）+ 右侧 AI 补全 / 确认 / 删除
/// 未确认：左侧状态 badge + 右侧 确认 / 删除
/// 已确认：左侧状态 badge + 右侧 保存更改 / 删除
class CharacterBottomBar extends StatelessWidget {
  const CharacterBottomBar({
    super.key,
    required this.character,
    this.onConfirm,
    required this.onDelete,
    this.onAIComplete,
    this.onSave,
    this.onScrollToStep,
  });

  final Character character;
  final VoidCallback? onConfirm;
  final VoidCallback onDelete;
  final VoidCallback? onAIComplete;
  final VoidCallback? onSave;
  final void Function(int stepIndex)? onScrollToStep;

  Character get c => character;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.xl.w,
        vertical: Spacing.md.h,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (c.isSkeleton)
            _buildStepIndicators()
          else
            _buildStatusBadge(),
          const Spacer(),
          if (c.isSkeleton && onAIComplete != null) ...[
            FilledButton.icon(
              onPressed: onAIComplete,
              icon: Icon(AppIcons.autoAwesome, size: 14.r),
              label: const Text('AI 补全'),
              style: _filledStyle(AppColors.primary),
            ),
            SizedBox(width: Spacing.sm.w),
          ],
          if (!c.isConfirmed && onConfirm != null) ...[
            FilledButton.icon(
              onPressed: onConfirm,
              icon: Icon(AppIcons.check, size: 14.r),
              label: const Text('确认角色'),
              style: _filledStyle(AppColors.success),
            ),
            SizedBox(width: Spacing.sm.w),
          ],
          if (c.isConfirmed && onSave != null) ...[
            OutlinedButton.icon(
              onPressed: onSave,
              icon: Icon(AppIcons.save, size: 14.r),
              label: const Text('保存更改'),
            ),
            SizedBox(width: Spacing.sm.w),
          ],
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

  ButtonStyle _filledStyle(Color bg) => FilledButton.styleFrom(
        backgroundColor: bg,
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.lg.w,
          vertical: Spacing.sm.h,
        ),
        textStyle: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
      );

  /// 骨架步骤指示器，每个步骤可点击跳转到对应卡片
  Widget _buildStepIndicators() {
    final doneCount = _stepDefs.where((s) => s.$2(c)).length;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(_stepDefs.length, (i) {
          final done = _stepDefs[i].$2(c);
          return Padding(
            padding: EdgeInsets.only(right: Spacing.xs.w),
            child: Tooltip(
              message: _stepDefs[i].$1,
              child: GestureDetector(
                onTap: () => onScrollToStep?.call(i),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 18.r,
                      height: 18.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done ? AppColors.success : AppColors.border,
                      ),
                      child: Center(
                        child: done
                            ? Icon(
                                AppIcons.check,
                                size: 10.r,
                                color: Colors.white,
                              )
                            : Text(
                                '${i + 1}',
                                style: AppTextStyles.tiny.copyWith(
                                  fontSize: 9.sp,
                                  color: AppColors.mutedDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      _stepDefs[i].$1,
                      style: AppTextStyles.tiny.copyWith(
                        color: done ? AppColors.success : AppColors.mutedDark,
                      ),
                    ),
                    if (i < _stepDefs.length - 1) SizedBox(width: Spacing.sm.w),
                  ],
                ),
              ),
            ),
          );
        }),
        SizedBox(width: Spacing.sm.w),
        Text(
          '($doneCount/${_stepDefs.length})',
          style: AppTextStyles.tiny.copyWith(color: AppColors.mutedDark),
        ),
      ],
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
        horizontal: Spacing.chipPaddingH.w,
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
