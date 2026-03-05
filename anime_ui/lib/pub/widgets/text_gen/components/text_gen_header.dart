import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import '../text_gen_config.dart';

/// 文本生成弹窗头部：渐变背景 + 发光图标 + 模式标签
class TextGenHeader extends StatelessWidget {
  const TextGenHeader({
    super.key,
    required this.config,
    required this.accent,
    this.onClose,
  });

  final TextGenConfig config;
  final Color accent;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        Spacing.xl.w, Spacing.mid.h, Spacing.lg.w, Spacing.gridGap.h,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [accent.withValues(alpha: 0.06), Colors.transparent],
        ),
        border: const Border(
          bottom: BorderSide(color: AppColors.surfaceMutedDarker),
        ),
      ),
      child: Row(
        children: [
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
                SizedBox(height: Spacing.xxs.h),
                Text(
                  config.mode.label,
                  style: AppTextStyles.caption.copyWith(color: accent),
                ),
              ],
            ),
          ),
          _HoverCloseButton(onClose: onClose ?? () => Navigator.pop(context)),
        ],
      ),
    );
  }
}

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

class _HoverCloseButton extends StatefulWidget {
  const _HoverCloseButton({required this.onClose});
  final VoidCallback onClose;

  @override
  State<_HoverCloseButton> createState() => _HoverCloseButtonState();
}

class _HoverCloseButtonState extends State<_HoverCloseButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onClose,
        child: AnimatedContainer(
          duration: MotionTokens.durationFast,
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
            child: Icon(AppIcons.close, size: 14.r, color: AppColors.mutedDark),
          ),
        ),
      ),
    );
  }
}
