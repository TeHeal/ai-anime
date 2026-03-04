import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import '../image_gen_config.dart';
import '../image_gen_controller.dart';
import 'gen_result_grid.dart';
import 'output_count_bar.dart';

/// 图生右侧结果面板 — 输出数量合并到标题行
class ImageGenResultPanel extends StatelessWidget {
  const ImageGenResultPanel({
    super.key,
    required this.config,
    required this.ctrl,
    required this.accent,
    required this.isSaving,
    required this.onSave,
    required this.onImageTap,
  });

  final ImageGenConfig config;
  final ImageGenController ctrl;
  final Color accent;
  final bool isSaving;
  final VoidCallback onSave;
  final void Function(String) onImageTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Spacing.mid.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 标题行：「生成预览」+ 输出数量选择紧凑排列
          Row(
            children: [
              Text(
                '生成预览',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                ),
              ),
              const Spacer(),
              OutputCountBar(
                value: ctrl.outputCount,
                maxCount: config.maxOutputCount,
                accent: accent,
                onChanged: ctrl.setOutputCount,
              ),
            ],
          ),
          SizedBox(height: Spacing.md.h),

          // 空状态用固定高度紧凑显示，有结果时再撑满
          ctrl.results.isEmpty && !ctrl.isGenerating
              ? SizedBox(
                  height: 180.h,
                  child: GenResultGrid(
                    results: ctrl.results,
                    isGenerating: ctrl.isGenerating,
                    progress: ctrl.progress,
                    accent: accent,
                    outputCount: ctrl.outputCount,
                    onImageTap: onImageTap,
                  ),
                )
              : Expanded(
                  child: GenResultGrid(
                    results: ctrl.results,
                    isGenerating: ctrl.isGenerating,
                    progress: ctrl.progress,
                    accent: accent,
                    outputCount: ctrl.outputCount,
                    onImageTap: onImageTap,
                  ),
                ),

          if (ctrl.hasError && ctrl.errorMsg != null) ...[
            SizedBox(height: Spacing.md.h),
            _buildError(ctrl.errorMsg!),
          ],

          if (ctrl.isDone && ctrl.results.isNotEmpty) ...[
            SizedBox(height: Spacing.md.h),
            _buildResultActions(context),
          ],
        ],
      ),
    );
  }

  Widget _buildError(String msg) {
    return Container(
      padding: EdgeInsets.all(Spacing.md.r),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(RadiusTokens.md.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(AppIcons.error, size: Spacing.lg.r, color: AppColors.error),
          SizedBox(width: Spacing.sm.w),
          Expanded(
            child: Text(
              msg,
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.error),
            ),
          ),
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
                  width: Spacing.gridGap.w,
                  height: Spacing.gridGap.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.r,
                    color: AppColors.onSurface,
                  ),
                )
              : Icon(AppIcons.save, size: 14.r),
          label: Text('保存 ${ctrl.results.length} 张'),
          style: FilledButton.styleFrom(backgroundColor: accent),
        ),
      ],
    );
  }
}
