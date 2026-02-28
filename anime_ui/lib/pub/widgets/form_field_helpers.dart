import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/colors.dart';

InputDecoration darkInputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey[600]),
    filled: true,
    fillColor: Colors.grey[850],
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey[700]!),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey[700]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.primary),
    ),
  );
}

class DarkFieldLabel extends StatelessWidget {
  const DarkFieldLabel(
    this.text, {
    super.key,
    this.required = false,
    this.hint,
  });

  final String text;
  final bool required;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[400])),
        if (required)
          const Text(' *', style: TextStyle(fontSize: 13, color: Colors.red)),
        if (hint != null) ...[
          const SizedBox(width: 6),
          Text(hint!, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ],
    );
  }
}
