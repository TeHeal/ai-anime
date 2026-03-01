import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import '../image_gen_controller.dart';

/// 图生弹窗底部操作栏
class ImageGenFooter extends StatelessWidget {
  const ImageGenFooter({
    super.key,
    required this.ctrl,
    required this.accent,
    required this.canGenerate,
    required this.onClose,
    required this.onGenerate,
  });

  final ImageGenController ctrl;
  final Color accent;
  final bool canGenerate;
  final VoidCallback? onClose;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        Spacing.mid.w,
        Spacing.md.h,
        Spacing.mid.w,
        Spacing.lg.h,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.surfaceMutedDarker)),
      ),
      child: Row(
        children: [
          if (ctrl.isGenerating) ...[
            SizedBox(
              width: 14.w,
              height: 14.h,
              child: CircularProgressIndicator(strokeWidth: 2.r, color: accent),
            ),
            SizedBox(width: Spacing.sm.w),
            Text(
              ctrl.progress > 0 ? '生成中 ${ctrl.progress}%…' : '生成中…',
              style: AppTextStyles.caption.copyWith(color: accent),
            ),
          ],
          const Spacer(),
          TextButton(
            onPressed: onClose ?? () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: AppColors.mutedDark),
            child: const Text('取消'),
          ),
          SizedBox(width: Spacing.md.w),
          FilledButton.icon(
            onPressed: canGenerate ? onGenerate : null,
            icon: Icon(
              ctrl.isGenerating ? AppIcons.inProgress : AppIcons.magicStick,
              size: 16.r,
            ),
            label: Text(ctrl.isGenerating ? '生成中…' : '开始生成'),
            style: FilledButton.styleFrom(
              backgroundColor: canGenerate
                  ? accent
                  : AppColors.surfaceContainer,
              foregroundColor: canGenerate
                  ? AppColors.onPrimary
                  : AppColors.mutedDarker,
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.mid.w,
                vertical: Spacing.lg.h,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
