import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';


class GlowCard extends StatefulWidget {
  const GlowCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = RadiusTokens.xxxl,
    this.glowColor,
    this.glowIntensity = 0.15,
    this.hoverGlowIntensity = 0.35,
    this.hoverElevation = 4.0,
    this.showTopAccent = true,
    this.topAccentColors,
    this.topAccentHeight = 3.0,
    this.background,
    this.padding,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color? glowColor;
  final double glowIntensity;
  final double hoverGlowIntensity;
  final double hoverElevation;
  final bool showTopAccent;
  final List<Color>? topAccentColors;
  final double topAccentHeight;
  final Gradient? background;
  final EdgeInsetsGeometry? padding;

  @override
  State<GlowCard> createState() => _GlowCardState();
}

class _GlowCardState extends State<GlowCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final glow = widget.glowColor ?? AppColors.primary;
    final accentColors =
        widget.topAccentColors ??
        [
          AppColors.primary,
          AppColors.primary.withValues(alpha: 0.95),
          AppColors.info,
        ];

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(
            0,
            _hovered ? -widget.hoverElevation : 0,
            0,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius.r),
            gradient:
                widget.background ??
                LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _hovered
                      ? [
                          AppColors.surfaceContainerHigh,
                          glow.withValues(alpha: 0.04),
                          AppColors.surfaceContainerHighest,
                        ]
                      : [
                          AppColors.surfaceContainerHigh,
                          AppColors.surfaceContainerHighest,
                        ],
                ),
            border: Border.all(
              color: _hovered
                  ? glow.withValues(alpha: 0.5)
                  : glow.withValues(alpha: 0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: glow.withValues(
                  alpha: _hovered
                      ? widget.hoverGlowIntensity
                      : widget.glowIntensity,
                ),
                blurRadius: _hovered ? 28.r : 10.r,
                spreadRadius: _hovered ? 3.r : 0.r,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.showTopAccent)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    height: _hovered
                        ? (widget.topAccentHeight + 2).h
                        : widget.topAccentHeight.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: accentColors),
                      boxShadow: _hovered
                          ? [
                              BoxShadow(
                                color: glow.withValues(alpha: 0.3),
                                blurRadius: 8.r,
                                offset: Offset(0, 2.h),
                              ),
                            ]
                          : [],
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: widget.padding ?? EdgeInsets.all(Spacing.xl.r),
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
