import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

class ErrorPlaceholder extends StatelessWidget {
  const ErrorPlaceholder({super.key, this.message = 'Failed to load'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          AppIcons.errorOutline,
          size: (Spacing.xl * 2).r,
          color: AppColors.muted,
        ),
        SizedBox(height: Spacing.sm.h),
        Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }
}
