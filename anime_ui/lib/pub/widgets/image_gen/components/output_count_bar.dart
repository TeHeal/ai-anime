import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';

/// 输出数量选择（紧凑横排药丸，嵌入标题行）
class OutputCountBar extends StatelessWidget {
  const OutputCountBar({
    super.key,
    required this.value,
    required this.maxCount,
    required this.accent,
    required this.onChanged,
  });

  final int value;
  final int maxCount;
  final Color accent;
  final ValueChanged<int> onChanged;

  static const _options = [1, 2, 4, 6];

  @override
  Widget build(BuildContext context) {
    final available = _options.where((n) => n <= maxCount).toList();
    if (available.length <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: available.map((n) {
        final selected = value == n;
        return Padding(
          padding: EdgeInsets.only(left: Spacing.xs.w),
          child: _CountChip(
            count: n,
            selected: selected,
            accent: accent,
            onTap: () => onChanged(n),
          ),
        );
      }).toList(),
    );
  }
}

class _CountChip extends StatefulWidget {
  const _CountChip({
    required this.count,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final int count;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  State<_CountChip> createState() => _CountChipState();
}

class _CountChipState extends State<_CountChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    final selected = widget.selected;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 32.w,
          height: 28.h,
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: 0.15)
                : _hovered
                    ? accent.withValues(alpha: 0.06)
                    : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            border: Border.all(
              color: selected
                  ? accent.withValues(alpha: 0.5)
                  : _hovered
                      ? accent.withValues(alpha: 0.25)
                      : AppColors.border,
            ),
          ),
          child: Center(
            child: Text(
              '${widget.count}',
              style: AppTextStyles.tiny.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? accent
                    : AppColors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
