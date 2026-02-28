import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/colors.dart';

class OptionChips<T> extends StatelessWidget {
  const OptionChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.chipPadding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    this.fontSize = 13.0,
  });

  final Map<T, String> options;
  final T selected;
  final ValueChanged<T> onSelected;
  final EdgeInsets chipPadding;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.entries.map((e) {
        final isSelected = e.key == selected;
        return GestureDetector(
          onTap: () => onSelected(e.key),
          child: Container(
            padding: chipPadding,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey[700]!,
              ),
            ),
            child: Text(
              e.value,
              style: TextStyle(
                fontSize: fontSize,
                color: isSelected ? AppColors.primary : Colors.grey[400],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
