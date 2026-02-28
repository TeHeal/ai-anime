import 'package:flutter/material.dart';
import 'package:anime_ui/pub/theme/colors.dart';

class PrimaryBtn extends StatelessWidget {
  const PrimaryBtn({
    super.key,
    required this.label,
    this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
      child: Text(label),
    );
  }
}
