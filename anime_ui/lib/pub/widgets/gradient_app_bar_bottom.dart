import 'package:flutter/material.dart';
import 'package:anime_ui/pub/theme/colors.dart';

class GradientAppBarBottom extends StatelessWidget
    implements PreferredSizeWidget {
  const GradientAppBarBottom({
    super.key,
    this.height = 2.0,
    this.colors,
  });

  final double height;
  final List<Color>? colors;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final gradientColors = colors ??
        [
          Colors.transparent,
          AppColors.primary.withValues(alpha: 0.3),
          AppColors.primary.withValues(alpha: 0.7),
          AppColors.primary.withValues(alpha: 0.3),
          Colors.transparent,
        ];

    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
      ),
    );
  }
}
