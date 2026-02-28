import 'package:flutter/material.dart';

/// 输出数量选择条（1 / 2 / 4 / 6 张）
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '输出数量',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: available.map((n) {
            final selected = value == n;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _CountChip(
                count: n,
                selected: selected,
                accent: accent,
                onTap: () => onChanged(n),
              ),
            );
          }).toList(),
        ),
      ],
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
          width: 44,
          height: 36,
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: 0.15)
                : _hovered
                    ? accent.withValues(alpha: 0.06)
                    : Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? accent.withValues(alpha: 0.5)
                  : _hovered
                      ? accent.withValues(alpha: 0.25)
                      : Colors.grey[800]!,
            ),
          ),
          child: Center(
            child: Text(
              '${widget.count}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? accent : Colors.grey[400],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
