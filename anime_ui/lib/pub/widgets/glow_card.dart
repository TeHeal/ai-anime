import 'package:flutter/material.dart';
import 'package:anime_ui/pub/theme/colors.dart';

class GlowCard extends StatefulWidget {
  const GlowCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = 16.0,
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
    final accentColors = widget.topAccentColors ??
        [
          const Color(0xFF8B5CF6),
          const Color(0xFF6366F1),
          const Color(0xFF3B82F6),
        ];

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor:
          widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
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
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: widget.background ??
                const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E1E2E),
                    Color(0xFF252540),
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
                  alpha:
                      _hovered ? widget.hoverGlowIntensity : widget.glowIntensity,
                ),
                blurRadius: _hovered ? 24 : 10,
                spreadRadius: _hovered ? 2 : 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.showTopAccent)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    height: _hovered
                        ? widget.topAccentHeight + 2
                        : widget.topAccentHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: accentColors),
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding:
                        widget.padding ?? const EdgeInsets.all(20),
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
