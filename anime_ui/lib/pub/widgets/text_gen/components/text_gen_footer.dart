import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import '../text_gen_config.dart';
import '../text_gen_controller.dart';

/// 文本生成弹窗底部操作栏
class TextGenFooter extends StatelessWidget {
  const TextGenFooter({
    super.key,
    required this.config,
    required this.ctrl,
    required this.accent,
    required this.onClose,
    required this.onGenerate,
    required this.onUseResult,
    required this.onSaveAndUse,
  });

  final TextGenConfig config;
  final TextGenController ctrl;
  final Color accent;
  final VoidCallback? onClose;
  final VoidCallback onGenerate;
  final VoidCallback onUseResult;
  final VoidCallback onSaveAndUse;

  @override
  Widget build(BuildContext context) {
    final hasResult =
        ctrl.status == TextGenStatus.done && ctrl.result.isNotEmpty;
    final isGenerating = ctrl.status == TextGenStatus.generating;

    return Container(
      padding: EdgeInsets.fromLTRB(
        Spacing.xl.w,
        Spacing.md.h,
        Spacing.xl.w,
        Spacing.lg.h,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.surfaceMutedDarker)),
      ),
      child: Row(
        children: [
          if (hasResult && config.saveToLibrary)
            Text(
              ctrl.savedResource != null ? '已保存到素材库' : '',
              style: AppTextStyles.tiny.copyWith(color: AppColors.mutedDark),
            ),
          const Spacer(),
          TextButton(
            onPressed: isGenerating ? null : onClose,
            child: Text(
              '取消',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
            ),
          ),
          SizedBox(width: Spacing.sm.w),
          if (!hasResult)
            FilledButton.icon(
              onPressed: isGenerating ? null : onGenerate,
              icon: isGenerating
                  ? SizedBox(
                      width: Spacing.gridGap.w,
                      height: Spacing.gridGap.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.r,
                        color: AppColors.onPrimary,
                      ),
                    )
                  : Icon(AppIcons.magicStick, size: 14.r),
              label: Text(isGenerating ? '生成中…' : '生成'),
              style: FilledButton.styleFrom(backgroundColor: accent),
            )
          else ...[
            if (config.saveToLibrary && ctrl.savedResource == null)
              OutlinedButton(
                onPressed: onSaveAndUse,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: accent.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '保存并使用',
                  style: AppTextStyles.bodySmall.copyWith(color: accent),
                ),
              ),
            SizedBox(width: Spacing.sm.w),
            FilledButton(
              onPressed: onUseResult,
              style: FilledButton.styleFrom(backgroundColor: accent),
              child: const Text('使用结果'),
            ),
          ],
        ],
      ),
    );
  }
}
