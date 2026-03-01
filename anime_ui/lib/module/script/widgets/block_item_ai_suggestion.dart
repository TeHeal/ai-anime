import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';

/// AI 建议面板（用于 BlockItem）
class BlockItemAiSuggestion extends StatelessWidget {
  const BlockItemAiSuggestion({
    super.key,
    required this.accent,
    required this.suggestion,
    required this.isLoading,
    required this.originalContent,
    required this.showOriginalDiff,
    required this.controller,
    required this.onToggleDiff,
    required this.onDiscard,
    required this.onAcceptReplace,
    required this.onAcceptAppend,
  });

  final Color accent;
  final String? suggestion;
  final bool isLoading;
  final String? originalContent;
  final bool showOriginalDiff;
  final TextEditingController? controller;
  final VoidCallback onToggleDiff;
  final VoidCallback onDiscard;
  final VoidCallback onAcceptReplace;
  final VoidCallback onAcceptAppend;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        44.w,
        Spacing.xs.r,
        Spacing.md.r,
        Spacing.sm.r,
      ),
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppIcons.autoAwesome, size: 14.r, color: accent),
              const SizedBox(width: Spacing.sm),
              Text(
                isLoading ? 'AI 生成中…' : 'AI 建议（可直接编辑）',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: accent,
                ),
              ),
              if (isLoading) ...[
                const SizedBox(width: Spacing.sm),
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: accent,
                  ),
                ),
              ],
              const Spacer(),
              if (originalContent != null && originalContent!.isNotEmpty)
                GestureDetector(
                  onTap: onToggleDiff,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        showOriginalDiff
                            ? AppIcons.unfoldLess
                            : AppIcons.compareArrows,
                        size: 14.r,
                        color: accent.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: Spacing.xs),
                      Text(
                        showOriginalDiff ? '收起原文' : '对比原文',
                        style: AppTextStyles.tiny.copyWith(
                          color: accent.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (showOriginalDiff && originalContent != null) ...[
            const SizedBox(height: Spacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Spacing.sm),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
                border: Border.all(
                  color: AppColors.divider.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '原文',
                    style: AppTextStyles.tiny.copyWith(
                      color: AppColors.onSurface.withValues(alpha: 0.55),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    originalContent!.isEmpty ? '（空）' : originalContent!,
                    style: AppTextStyles.bodySmall.copyWith(
                      height: 1.5,
                      color: AppColors.onSurface.withValues(alpha: 0.55),
                      decoration: TextDecoration.lineThrough,
                      decorationColor: AppColors.onSurface.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: Spacing.sm),
          if (isLoading)
            SelectableText(
              suggestion ?? '',
              style: AppTextStyles.bodyMedium.copyWith(
                height: 1.6,
                color: AppColors.onSurface,
              ),
            )
          else
            TextField(
              controller: controller,
              maxLines: null,
              minLines: 2,
              style: AppTextStyles.bodyMedium.copyWith(
                height: 1.6,
                color: AppColors.onSurface,
              ),
              decoration: InputDecoration(
                hintText: '编辑 AI 建议内容…',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.4),
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.sm,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                  borderSide: BorderSide(
                    color: accent.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                  borderSide: BorderSide(
                    color: accent.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          const SizedBox(height: Spacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onDiscard,
                icon: Icon(AppIcons.close, size: 14.r),
                label: const Text('放弃'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.onSurface.withValues(alpha: 0.6),
                  textStyle: AppTextStyles.caption,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.sm,
                    vertical: Spacing.xs,
                  ),
                ),
              ),
              if (!isLoading &&
                  (controller?.text.isNotEmpty ??
                      suggestion?.isNotEmpty ??
                      false)) ...[
                const SizedBox(width: Spacing.sm),
                OutlinedButton.icon(
                  onPressed: onAcceptAppend,
                  icon: Icon(AppIcons.add, size: 14.r),
                  label: const Text('追加到末尾'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: accent.withValues(alpha: 0.8),
                    side: BorderSide(color: accent.withValues(alpha: 0.3)),
                    textStyle: AppTextStyles.caption,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.sm,
                      vertical: Spacing.xs,
                    ),
                    minimumSize: Size.zero,
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                FilledButton.icon(
                  onPressed: onAcceptReplace,
                  icon: Icon(AppIcons.check, size: 14.r),
                  label: const Text('替换原文'),
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: AppColors.onSurface,
                    textStyle: AppTextStyles.caption,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.md,
                      vertical: Spacing.xs,
                    ),
                    minimumSize: Size.zero,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
