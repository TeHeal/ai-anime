import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import '../image_gen_controller.dart';

/// 图生弹窗底部操作栏 — 左侧模型信息 + 右侧操作按钮
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
    final modelName = ctrl.selectedModel?.displayName ?? '';

    return Container(
      padding: EdgeInsets.fromLTRB(
        Spacing.xl.w,
        Spacing.md.h,
        Spacing.mid.w,
        Spacing.lg.h,
      ),
      decoration: BoxDecoration(
        border: const Border(
          top: BorderSide(color: AppColors.surfaceMutedDarker),
        ),
        // 底部微渐变
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            accent.withValues(alpha: 0.02),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          // 左侧：模型信息 + 进度
          Expanded(child: _buildLeftInfo(modelName)),
          // 右侧：取消 + 生成
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildLeftInfo(String modelName) {
    if (ctrl.isGenerating) {
      return Row(
        children: [
          SizedBox(
            width: 14.w,
            height: 14.h,
            child: CircularProgressIndicator(
              strokeWidth: 2.r,
              color: accent,
            ),
          ),
          SizedBox(width: Spacing.sm.w),
          Text(
            ctrl.progress > 0 ? '生成中 ${ctrl.progress}%…' : '生成中…',
            style: AppTextStyles.caption.copyWith(color: accent),
          ),
        ],
      );
    }

    return Row(
      children: [
        if (modelName.isNotEmpty) ...[
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.sm.w,
              vertical: Spacing.xxs.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  AppIcons.autoAwesome,
                  size: 11.r,
                  color: AppColors.mutedDark,
                ),
                SizedBox(width: Spacing.xs.w),
                Text(
                  modelName,
                  style: AppTextStyles.tiny.copyWith(
                    color: AppColors.mutedDark,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: Spacing.sm.w),
          Text(
            '预计 15-30s',
            style: AppTextStyles.tiny.copyWith(color: AppColors.mutedDarker),
          ),
        ],
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: onClose ?? () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.mutedDark,
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.lg.w,
              vertical: Spacing.sm.h,
            ),
          ),
          child: const Text('取消'),
        ),
        SizedBox(width: Spacing.md.w),
        _GenerateButton(
          accent: accent,
          canGenerate: canGenerate,
          isGenerating: ctrl.isGenerating,
          onGenerate: onGenerate,
        ),
      ],
    );
  }
}

/// 带渐变 + 发光 + hover 效果的生成按钮
class _GenerateButton extends StatefulWidget {
  const _GenerateButton({
    required this.accent,
    required this.canGenerate,
    required this.isGenerating,
    required this.onGenerate,
  });

  final Color accent;
  final bool canGenerate;
  final bool isGenerating;
  final VoidCallback onGenerate;

  @override
  State<_GenerateButton> createState() => _GenerateButtonState();
}

class _GenerateButtonState extends State<_GenerateButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.canGenerate && !widget.isGenerating;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: enabled ? widget.onGenerate : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.xl.w,
            vertical: Spacing.buttonPaddingV.h,
          ),
          transform: _hovered && enabled
              ? (Matrix4.identity()..translateByDouble(0.0, -1.0, 0.0, 1.0))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            gradient: enabled
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [widget.accent, AppColors.primary],
                  )
                : null,
            color: enabled ? null : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: widget.accent.withValues(
                        alpha: _hovered ? 0.45 : 0.3,
                      ),
                      blurRadius: _hovered ? 24.r : 16.r,
                      offset: Offset(0, 4.h),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.isGenerating
                    ? AppIcons.inProgress
                    : AppIcons.magicStick,
                size: 16.r,
                color: enabled ? AppColors.onPrimary : AppColors.mutedDarker,
              ),
              SizedBox(width: Spacing.sm.w),
              Text(
                widget.isGenerating ? '生成中…' : '开始生成',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: enabled ? AppColors.onPrimary : AppColors.mutedDarker,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
