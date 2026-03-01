import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import '../voice_gen_controller.dart';
import 'voice_result_preview.dart';

/// 音色生成右侧结果面板
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
    return SingleChildScrollView(
      padding: EdgeInsets.all(Spacing.mid.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '生成结果',
            style: AppTextStyles.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
          SizedBox(height: Spacing.md.h),
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
          style: FilledButton.styleFrom(backgroundColor: accent),
        ),
      ],
    );
  }
}
