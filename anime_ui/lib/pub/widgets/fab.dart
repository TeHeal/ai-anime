import 'package:flutter/material.dart';
import 'package:anime_ui/pub/theme/colors.dart';

class AppFab extends StatelessWidget {
  const AppFab({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.auto_awesome),
    );
  }
}
