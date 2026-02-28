import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';

/// A filter chip descriptor for the toolbar.
class FilterChipData {
  final String key;
  final String label;
  final int count;
  final Color? color;

  const FilterChipData({
    required this.key,
    required this.label,
    this.count = 0,
    this.color,
  });
}

/// A group chip for pagination (e.g. "1-10", "11-20").
class GroupChipData {
  final String key;
  final String label;

  const GroupChipData({required this.key, required this.label});
}

/// Reusable filter toolbar with status chips and optional group chips.
class FilterToolbar extends StatelessWidget {
  final List<FilterChipData> filters;
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;
  final List<GroupChipData> groups;
  final String activeGroup;
  final ValueChanged<String>? onGroupChanged;

  const FilterToolbar({
    super.key,
    required this.filters,
    required this.activeFilter,
    required this.onFilterChanged,
    this.groups = const [],
    this.activeGroup = '',
    this.onGroupChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF16162A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(AppIcons.tune, size: 15, color: Colors.grey[500]),
          const SizedBox(width: 10),
          for (int i = 0; i < filters.length; i++) ...[
            _buildFilterChip(filters[i]),
            if (i < filters.length - 1) const SizedBox(width: 6),
          ],
          if (groups.isNotEmpty) ...[
            const Spacer(),
            Text('分组:',
                style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            const SizedBox(width: 8),
            for (int i = 0; i < groups.length; i++) ...[
              _buildGroupChip(groups[i]),
              if (i < groups.length - 1) const SizedBox(width: 4),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(FilterChipData chip) {
    final isActive = activeFilter == chip.key;
    final activeColor = chip.color ?? AppColors.primary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onFilterChanged(chip.key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isActive
                ? activeColor.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isActive
                  ? activeColor.withValues(alpha: 0.4)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(chip.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? activeColor : Colors.grey[400],
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.normal,
                  )),
              if (chip.count > 0) ...[
                const SizedBox(width: 4),
                Text('${chip.count}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isActive
                          ? activeColor.withValues(alpha: 0.7)
                          : Colors.grey[600],
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupChip(GroupChipData chip) {
    final isActive = activeGroup == chip.key;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onGroupChanged?.call(chip.key),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(chip.label,
              style: TextStyle(
                fontSize: 11,
                color: isActive ? AppColors.primary : Colors.grey[500],
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              )),
        ),
      ),
    );
  }
}
