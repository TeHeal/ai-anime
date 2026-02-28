import 'package:flutter/material.dart';

/// 宽高比选择器（含分辨率切换）
class RatioPicker extends StatelessWidget {
  const RatioPicker({
    super.key,
    required this.selectedRatio,
    required this.selectedResolution,
    required this.allowedRatios,
    required this.accent,
    required this.onRatioChanged,
    required this.onResolutionChanged,
  });

  final String selectedRatio;
  final String selectedResolution;
  final List<String> allowedRatios; // 空 list = 全部显示
  final Color accent;
  final ValueChanged<String> onRatioChanged;
  final ValueChanged<String> onResolutionChanged;

  static const _allRatios = [
    ('智能', ''),
    ('1:1', '1:1'),
    ('4:3', '4:3'),
    ('3:4', '3:4'),
    ('16:9', '16:9'),
    ('9:16', '9:16'),
    ('3:2', '3:2'),
    ('2:3', '2:3'),
    ('21:9', '21:9'),
  ];

  List<(String, String)> get _visibleRatios {
    if (allowedRatios.isEmpty) return _allRatios;
    return _allRatios
        .where((e) => allowedRatios.contains(e.$2))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final ratios = _visibleRatios;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 宽高比行
        Row(
          children: [
            Text(
              '宽高比',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[400],
              ),
            ),
            const Spacer(),
            // 分辨率切换
            _ResolutionToggle(
              selected: selectedResolution,
              accent: accent,
              onChanged: onResolutionChanged,
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ratios.map((entry) {
              final (label, value) = entry;
              final isSelected = selectedRatio == value;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _RatioChip(
                  label: label,
                  value: value,
                  selected: isSelected,
                  accent: accent,
                  onTap: () => onRatioChanged(value),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _RatioChip extends StatefulWidget {
  const _RatioChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  State<_RatioChip> createState() => _RatioChipState();
}

class _RatioChipState extends State<_RatioChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    final selected = widget.selected;
    final value = widget.value;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 48,
          height: 52,
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RatioIcon(value: value, accent: accent, selected: selected),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 9,
                  color: selected ? accent : Colors.grey[500],
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RatioIcon extends StatelessWidget {
  const _RatioIcon({
    required this.value,
    required this.accent,
    required this.selected,
  });

  final String value;
  final Color accent;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? accent : Colors.grey[600]!;
    double w = 14, h = 14;
    if (value.contains(':')) {
      final parts = value.split(':');
      final rw = double.tryParse(parts[0]) ?? 1;
      final rh = double.tryParse(parts[1]) ?? 1;
      if (rw > rh) {
        w = 16;
        h = 16 * rh / rw;
      } else {
        h = 16;
        w = 16 * rw / rh;
      }
    } else {
      // 智能模式：显示闪光图标
      return Icon(Icons.auto_awesome_rounded, size: 14, color: color);
    }
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _ResolutionToggle extends StatelessWidget {
  const _ResolutionToggle({
    required this.selected,
    required this.accent,
    required this.onChanged,
  });

  final String selected;
  final Color accent;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: ['2K', '4K'].map((v) {
        final isSelected = selected == v;
        return Padding(
          padding: const EdgeInsets.only(left: 6),
          child: GestureDetector(
            onTap: () => onChanged(v),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? accent.withValues(alpha: 0.15)
                    : Colors.grey[900],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected
                      ? accent.withValues(alpha: 0.4)
                      : Colors.grey[800]!,
                ),
              ),
              child: Text(
                v,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? accent : Colors.grey[500],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
