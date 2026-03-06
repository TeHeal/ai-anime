import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import '../voice_gen_controller.dart';
import 'voice_result_preview.dart';

/// 音色生成结果面板 — 右侧面板，带微妙背景区分
class VoiceGenResultPanel extends StatelessWidget {
  const VoiceGenResultPanel({
    super.key,
    required this.ctrl,
    required this.accent,
    required this.isSaving,
    required this.onSave,
  });

  final VoiceGenController ctrl;
  final Color accent;
  final bool isSaving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.015),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.xl.w,
          vertical: Spacing.mid.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 3.w,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(1.5.r),
                  ),
                ),
                SizedBox(width: Spacing.sm.w),
                Text(
                  '生成结果',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            SizedBox(height: Spacing.lg.h),
            VoiceResultPreview(
              accent: accent,
              audioUrl: ctrl.resultAudioUrl,
              isGenerating: ctrl.isGenerating,
              progress: ctrl.progress,
              errorMsg: ctrl.hasError ? ctrl.errorMsg : null,
            ),
            if (ctrl.isDone && ctrl.resultAudioUrl.isNotEmpty) ...[
              SizedBox(height: Spacing.lg.h),
              _buildResultActions(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultActions(BuildContext context) {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: ctrl.reset,
          icon: Icon(AppIcons.refresh, size: 14.r),
          label: const Text('重新生成'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.muted,
            side: const BorderSide(color: AppColors.border),
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.md.w,
              vertical: Spacing.sm.h,
            ),
          ),
        ),
        const Spacer(),
        FilledButton.icon(
          onPressed: isSaving ? null : onSave,
          icon: isSaving
              ? SizedBox(
                  width: 14.w,
                  height: 14.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.r,
                    color: AppColors.onSurface,
                  ),
                )
              : Icon(AppIcons.save, size: 14.r),
          label: const Text('保存音色'),
          style: FilledButton.styleFrom(
            backgroundColor: accent,
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.lg.w,
              vertical: Spacing.sm.h,
            ),
          ),
        ),
      ],
    );
  }
}
