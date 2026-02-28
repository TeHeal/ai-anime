import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';

// ---------------------------------------------------------------------------
// 编辑器通用组件（供各子模块复用）
// ---------------------------------------------------------------------------

Widget reviewSection(String title, Widget child) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFF1E1E30),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey[800]!),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        reviewSectionHeader(title),
        Divider(height: 1, color: Colors.grey[800]),
        Padding(padding: const EdgeInsets.all(16), child: child),
      ],
    ),
  );
}

Widget reviewSectionHeader(String title, {Widget? trailing}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing,
        ],
      ],
    ),
  );
}

Widget readField(String label, String value, {bool fullWidth = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      if (label.isNotEmpty)
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      if (label.isNotEmpty) const SizedBox(height: 3),
      Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF252535),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey[800]!),
        ),
        child: Text(
          value.isNotEmpty ? value : '—',
          style: TextStyle(
              fontSize: 13,
              color: value.isNotEmpty ? Colors.white : Colors.grey[600]),
        ),
      ),
    ],
  );
}

Widget readChip(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label,
          style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      const SizedBox(height: 3),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF252535),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          value.isNotEmpty ? value : '—',
          style: TextStyle(
            fontSize: 13,
            color: value.isNotEmpty ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  );
}

Widget editField(
  String label,
  String value, {
  bool fullWidth = false,
  int maxLines = 1,
  Color? labelColor,
  ValueChanged<String>? onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      if (label.isNotEmpty)
        Text(label,
            style: TextStyle(
                fontSize: 11, color: labelColor ?? Colors.grey[600])),
      if (label.isNotEmpty) const SizedBox(height: 3),
      SizedBox(
        width: fullWidth ? double.infinity : null,
        child: TextFormField(
          initialValue: value,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 13, color: Colors.white),
          decoration: InputDecoration(
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: AppColors.primary.withValues(alpha: 0.6)),
            ),
            filled: true,
            fillColor: const Color(0xFF252535),
          ),
          onChanged: onChanged,
        ),
      ),
    ],
  );
}

Widget editorDropdown(
    String label, String value, List<String> options,
    {ValueChanged<String>? onChanged}) {
  final effectiveValue = options.contains(value) ? value : null;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label,
          style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      const SizedBox(height: 3),
      DropdownButtonFormField<String>(
        initialValue: effectiveValue,
        decoration: InputDecoration(
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          filled: true,
          fillColor: const Color(0xFF252535),
        ),
        dropdownColor: Colors.grey[900],
        items: options
            .map((o) => DropdownMenuItem(
                  value: o,
                  child: Text(o, style: const TextStyle(fontSize: 12)),
                ))
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged?.call(v);
        },
      ),
    ],
  );
}

Widget miniField(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      const SizedBox(height: 2),
      Text(
        value.isNotEmpty ? value : '—',
        style: TextStyle(
            fontSize: 12,
            color: value.isNotEmpty ? Colors.grey[300] : Colors.grey[700]),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}

Widget priorityBadge(String priority) {
  Color color;
  if (priority.contains('P0')) {
    color = Colors.red;
  } else if (priority.contains('P1')) {
    color = Colors.orange;
  } else {
    color = Colors.grey;
  }
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Text(priority,
        style: TextStyle(
            fontSize: 11, color: color, fontWeight: FontWeight.w600)),
  );
}

Widget countBadge(int count) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text('$count',
        style: TextStyle(
            fontSize: 10,
            color: AppColors.primary,
            fontWeight: FontWeight.w600)),
  );
}

Widget enabledDot() {
  return Container(
    width: 6,
    height: 6,
    decoration:
        const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
  );
}

Widget buildCollapsibleCard({
  required String title,
  required IconData icon,
  required bool expanded,
  required VoidCallback onToggle,
  Widget? badge,
  required Widget child,
}) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFF1E1E30),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey[800]!),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius:
              BorderRadius.vertical(top: const Radius.circular(10)),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                if (badge != null) ...[
                  const SizedBox(width: 8),
                  badge,
                ],
                const Spacer(),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(AppIcons.expandMore,
                      size: 16, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: Column(
            children: [
              Divider(height: 1, color: Colors.grey[800]),
              Padding(padding: const EdgeInsets.all(16), child: child),
            ],
          ),
          secondChild: const SizedBox.shrink(),
          crossFadeState: expanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    ),
  );
}
