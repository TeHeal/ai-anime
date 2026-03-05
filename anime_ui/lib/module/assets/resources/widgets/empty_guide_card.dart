import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';

/// 空状态引导卡片（上传/AI 生成等入口）
class EmptyGuideCard extends StatefulWidget {
  const EmptyGuideCard({
    super.key,
    required this.icon,
    required this.label,
    required this.accent,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final VoidCallback onTap;
  final bool filled;

  @override
  State<EmptyGuideCard> createState() => _EmptyGuideCardState();
}

class _EmptyGuideCardState extends State<EmptyGuideCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: MotionTokens.durationFast,
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.lg.w,
            vertical: Spacing.md.h,
          ),
          decoration: BoxDecoration(
            color: widget.filled
                ? (_hovered
                    ? widget.accent.withValues(alpha: 0.2)
                    : widget.accent.withValues(alpha: 0.12))
                : (_hovered
                    ? widget.accent.withValues(alpha: 0.08)
                    : widget.accent.withValues(alpha: 0.03)),
            borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
            border: Border.all(
              color: _hovered
                  ? widget.accent.withValues(alpha: 0.4)
                  : widget.accent.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 18.r,
                color: widget.accent.withValues(alpha: _hovered ? 0.9 : 0.6),
              ),
              SizedBox(width: Spacing.sm.w),
              Text(
                widget.label,
                style: AppTextStyles.bodySmall.copyWith(
                  color:
                      widget.accent.withValues(alpha: _hovered ? 0.9 : 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
