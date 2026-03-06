import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';

/// 内嵌在输入框底部的快捷提示词小药丸
class InlineQuickChip extends StatefulWidget {
  const InlineQuickChip({
    super.key,
    required this.label,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final Color accent;
  final VoidCallback onTap;

  @override
  State<InlineQuickChip> createState() => _InlineQuickChipState();
}

class _InlineQuickChipState extends State<InlineQuickChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.sm.w,
            vertical: 2.h,
          ),
          decoration: BoxDecoration(
            color: _hovered
                ? widget.accent.withValues(alpha: 0.12)
                : widget.accent.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            border: Border.all(
              color: _hovered
                  ? widget.accent.withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
          ),
          child: Text(
            widget.label,
            style: AppTextStyles.tiny.copyWith(
              fontSize: 10.sp,
              color: widget.accent,
            ),
          ),
        ),
      ),
    );
  }
}
