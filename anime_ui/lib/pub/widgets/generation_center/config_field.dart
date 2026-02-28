import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/colors.dart';

/// A labelled text field for generation configuration (prompts, notes, etc.).
class ConfigField extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final IconData? icon;
  final String? hint;
  final int maxLines;

  const ConfigField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.icon,
    this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: Colors.grey[500]),
              const SizedBox(width: 6),
            ],
            Text(label,
                style: TextStyle(fontSize: 12, color: Colors.grey[400])),
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 13, color: Colors.white),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[600]),
            filled: true,
            fillColor: const Color(0xFF16162A),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2A2A40)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
            ),
          ),
        ),
      ],
    );
  }
}
