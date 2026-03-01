import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';


class DropdownNew<T> extends StatelessWidget {
  const DropdownNew({
    super.key,
    required this.value,
    required this.items,
    this.onChanged,
    this.isNew = false,
  });

  final T value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButton<T>(
            value: value,
            items: items,
            onChanged: onChanged,
          ),
        ),
        if (isNew)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.iconGapSm.w,
              vertical: (Spacing.xs / 2).h,
            ),
            decoration: BoxDecoration(
              color: AppColors.newTag,
              borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
            ),
            child: Text('NEW', style: AppTextStyles.labelTinySmall),
          ),
      ],
    );
  }
}
