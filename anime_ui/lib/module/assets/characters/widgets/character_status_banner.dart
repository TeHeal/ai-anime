import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/character.dart';

/// 角色详情顶部状态横幅（纯引导提示，操作统一在底部栏）
///
/// 骨架：橙色提示 — 引导用户补充信息
/// 待确认：primary 提示 — 引导用户确认
/// 已确认：隐藏
class CharacterStatusBanner extends StatelessWidget {
  const CharacterStatusBanner({
    super.key,
    required this.character,
  });

  final Character character;

  @override
  Widget build(BuildContext context) {
    if (character.isConfirmed) return const SizedBox.shrink();

    final (String message, IconData icon, Color color) = character.isSkeleton
        ? (
            '该角色来自${_sourceHint(character.source)}，请补充基础信息和形象图，或使用底部「AI 补全」',
            Icons.bolt,
            AppColors.warning,
          )
        : (
            '信息已补充，请点击底部「确认角色」以投入生产',
            AppIcons.info,
            AppColors.primary,
          );

    return Container(
      margin: EdgeInsets.only(bottom: Spacing.lg.h),
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.lg.w,
        vertical: Spacing.sm.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(RadiusTokens.card.r),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18.r, color: color),
          SizedBox(width: Spacing.sm.w),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _sourceHint(String source) => switch (source) {
        'skeleton' => '剧本识别',
        'auto_extract' => 'AI 提取',
        'story_extract' => '剧本深度提取',
        _ => '手动添加',
      };
}
