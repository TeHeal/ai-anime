import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import '../image_gen_config.dart';
import '../image_gen_controller.dart';
import 'mode_badge.dart';

/// 图生弹窗头部 — 渐变背景 + 发光图标 + 步骤提示
class ImageGenHeader extends StatelessWidget {
  const ImageGenHeader({
    super.key,
    required this.config,
    required this.ctrl,
    required this.accent,
    this.onClose,
  });

  final ImageGenConfig config;
  final ImageGenController ctrl;
  final Color accent;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        Spacing.xl.w,
        Spacing.mid.h,
        Spacing.lg.w,
        Spacing.gridGap.h,
      ),
      decoration: BoxDecoration(
        // 顶部渐变，强化品牌调性
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accent.withValues(alpha: 0.06),
            Colors.transparent,
          ],
        ),
        border: const Border(
          bottom: BorderSide(color: AppColors.surfaceMutedDarker),
        ),
      ),
      child: Row(
        children: [
          // 发光图标容器
          _GlowIcon(accent: accent),
          SizedBox(width: Spacing.md.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.title,
                  style: AppTextStyles.h4.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                SizedBox(height: Spacing.xs.h),
                Row(
                  children: [
                    ModeBadge(mode: ctrl.mode, accent: accent),
                    SizedBox(width: Spacing.sm.w),
                    Text(
                      '填写提示词后点击生成',
                      style: AppTextStyles.tiny.copyWith(
                        color: AppColors.mutedDarker,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _CloseButton(onClose: onClose ?? () => Navigator.pop(context)),
        ],
      ),
    );
  }
}

/// 带发光效果的图标容器
class _GlowIcon extends StatelessWidget {
  const _GlowIcon({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.r,
      height: 40.r,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.35),
            blurRadius: 16.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Icon(AppIcons.magicStick, size: 18.r, color: AppColors.onPrimary),
    );
  }
}

/// 带 hover 态的关闭按钮
class _CloseButton extends StatefulWidget {
  const _CloseButton({required this.onClose});
  final VoidCallback onClose;

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onClose,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 30.r,
          height: 30.r,
          decoration: BoxDecoration(
            color: _hovered
                ? AppColors.surfaceContainerHighest
                : AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            border: Border.all(
              color: _hovered ? AppColors.border : AppColors.surfaceMutedDarker,
            ),
          ),
          child: Center(
            child: Icon(
              AppIcons.close,
              size: 14.r,
              color: AppColors.mutedDark,
            ),
          ),
        ),
      ),
    );
  }
}
