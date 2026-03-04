import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/dashed_border_painter.dart';

/// 新建项目卡片 — 霓虹虚线边框 + 脉冲光环 + 悬浮光晕 + 渐变底色
class NewProjectCard extends StatefulWidget {
  const NewProjectCard({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  State<NewProjectCard> createState() => _NewProjectCardState();
}

class _NewProjectCardState extends State<NewProjectCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _glowAnim,
          builder: (context, child) {
            final glowVal = _glowAnim.value;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              transform: _hovered
                  ? (Matrix4.translationValues(0, -6, 0)
                      ..setEntry(0, 0, 1.03)
                      ..setEntry(1, 1, 1.03)
                      ..setEntry(2, 2, 1.03))
                  : Matrix4.identity(),
              child: CustomPaint(
                painter: DashedBorderPainter(
                  color: _hovered
                      ? AppColors.primary
                      : Color.lerp(
                          AppColors.mutedDarker,
                          AppColors.primary.withValues(alpha: 0.5),
                          glowVal,
                        )!,
                  borderRadius: RadiusTokens.xxl,
                  dashLength: 10,
                  gapLength: 6,
                  strokeWidth: _hovered ? 2.0 : 1.5,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(RadiusTokens.xxl.r),
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.3),
                      radius: 1.2,
                      colors: _hovered
                          ? [
                              AppColors.primary.withValues(alpha: 0.1),
                              AppColors.primary.withValues(alpha: 0.03),
                              AppColors.surface.withValues(alpha: 0.15),
                            ]
                          : [
                              AppColors.surface.withValues(alpha: 0.25),
                              AppColors.surface.withValues(alpha: 0.1),
                            ],
                    ),
                    boxShadow: [
                      if (_hovered)
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 32.r,
                          spreadRadius: 4.r,
                        ),
                      BoxShadow(
                        color: AppColors.primary.withValues(
                          alpha: 0.04 + 0.06 * glowVal,
                        ),
                        blurRadius: 16.r,
                        spreadRadius: 1.r,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildPulsingIcon(glowVal),
                        SizedBox(height: Spacing.md.h),
                        Text(
                          '新建项目',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: _hovered
                                ? AppColors.primary
                                : AppColors.onSurface.withValues(alpha: 0.75),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '开始全新创作',
                          style: AppTextStyles.caption.copyWith(
                            color: _hovered
                                ? AppColors.primary.withValues(alpha: 0.6)
                                : AppColors.mutedDark,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPulsingIcon(double glowVal) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: (_hovered ? 72 : 64).w,
          height: (_hovered ? 72 : 64).h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.1 + 0.15 * glowVal),
              width: 1.5.r,
            ),
          ),
        ),
        Container(
          width: 48.w,
          height: 48.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: _hovered ? 0.25 : 0.12),
                AppColors.info.withValues(alpha: _hovered ? 0.15 : 0.06),
              ],
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12.r,
                    ),
                  ]
                : [],
          ),
          child: Icon(
            AppIcons.add,
            size: 24.r,
            color: _hovered
                ? AppColors.primary
                : AppColors.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
