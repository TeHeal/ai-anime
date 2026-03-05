import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// AI 生成弹窗统一外壳：渐变发光标题栏 + 底部操作栏 + 可插入 body。
///
/// 与 [AssetFormShell] 的区别：此外壳带 AI 感的渐变发光标题、
/// footer 支持生成进度和多种主按钮状态，适合 AI 生成场景。
class GenDialogShell extends StatelessWidget {
  const GenDialogShell({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = AppIcons.magicStick,
    this.accent = AppColors.primary,
    required this.body,
    this.primaryLabel = '开始生成',
    this.onPrimary,
    this.canPrimary = true,
    this.generating = false,
    this.onClose,
    this.footerLeading,
    this.footerActions,
    this.maxWidth,
    this.maxHeight,
    this.minWidth,
    this.aboveBody,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color accent;
  final Widget body;

  /// 主按钮文案
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final bool canPrimary;
  final bool generating;
  final VoidCallback? onClose;

  /// Footer 左侧区域（进度、模型信息等）
  final Widget? footerLeading;

  /// 完全自定义 footer 右侧按钮区（覆盖默认的取消+主按钮）
  final List<Widget>? footerActions;

  final double? maxWidth;
  final double? maxHeight;
  final double? minWidth;

  /// body 上方额外内容（如 Tab 切换栏），位于 header 与 body 之间
  final Widget? aboveBody;

  @override
  Widget build(BuildContext context) {
    final close = onClose ?? () => Navigator.pop(context);
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? 920.w,
          maxHeight: maxHeight ?? 740.h,
          minWidth: minWidth ?? 480.w,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(close),
            ?aboveBody,
            Flexible(child: body),
            _buildFooter(context, close),
          ],
        ),
      ),
    );
  }

  // ─── 渐变发光标题栏 ───

  Widget _buildHeader(VoidCallback close) {
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
          _GlowIcon(accent: accent, icon: icon),
          SizedBox(width: Spacing.md.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h4.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: Spacing.xxs.h),
                  Text(
                    subtitle!,
                    style: AppTextStyles.caption.copyWith(color: accent),
                  ),
                ],
              ],
            ),
          ),
          _HoverCloseButton(onClose: close),
        ],
      ),
    );
  }

  // ─── 底部操作栏 ───

  Widget _buildFooter(BuildContext context, VoidCallback close) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        Spacing.xl.w, Spacing.md.h, Spacing.mid.w, Spacing.lg.h,
      ),
      decoration: BoxDecoration(
        border: const Border(
          top: BorderSide(color: AppColors.surfaceMutedDarker),
        ),
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [accent.withValues(alpha: 0.02), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          // 左侧信息区
          if (footerLeading != null) Expanded(child: footerLeading!),
          if (footerLeading == null) const Spacer(),
          // 右侧按钮区
          if (footerActions != null)
            ...footerActions!
          else ...[
            TextButton(
              onPressed: generating ? null : close,
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
            _GenButton(
              accent: accent,
              label: generating ? '生成中…' : primaryLabel,
              enabled: canPrimary && !generating,
              generating: generating,
              onTap: onPrimary,
            ),
          ],
        ],
      ),
    );
  }
}

/// 带发光效果的图标容器
class _GlowIcon extends StatelessWidget {
  const _GlowIcon({required this.accent, required this.icon});
  final Color accent;
  final IconData icon;

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
      child: Icon(icon, size: 18.r, color: AppColors.onPrimary),
    );
  }
}

/// 带 hover 态的关闭按钮
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

/// 统一生成按钮：渐变 + 发光 + hover 上浮
class _GenButton extends StatefulWidget {
  const _GenButton({
    required this.accent,
    required this.label,
    required this.enabled,
    required this.generating,
    this.onTap,
  });

  final Color accent;
  final String label;
  final bool enabled;
  final bool generating;
  final VoidCallback? onTap;

  @override
  State<_GenButton> createState() => _GenButtonState();
}

class _GenButtonState extends State<_GenButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: enabled ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.xl.w,
            vertical: Spacing.buttonPaddingV.h,
          ),
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
              if (widget.generating)
                SizedBox(
                  width: 14.w,
                  height: 14.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.r,
                    color: AppColors.onPrimary,
                  ),
                )
              else
                Icon(
                  AppIcons.magicStick,
                  size: 16.r,
                  color: enabled ? AppColors.onPrimary : AppColors.mutedDarker,
                ),
              SizedBox(width: Spacing.sm.w),
              Text(
                widget.label,
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
