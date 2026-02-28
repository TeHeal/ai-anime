import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';

/// Reusable search text field with consistent dark-theme styling.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText = '搜索…',
    this.width = 220,
    this.height = 36,
    this.accentColor,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;
  final double width;
  final double height;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.primary;

    return SizedBox(
      width: width,
      height: height,
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 13, color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 13, color: Colors.grey[600]),
          prefixIcon:
              Icon(AppIcons.search, size: 16, color: Colors.grey[500]),
          filled: true,
          fillColor: Colors.grey[900],
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[800]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: accent),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
