import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';

/// 剧本操作栏 — 底部操作区（draft、story 等共用）
class StoryActionBar extends StatelessWidget {
  const StoryActionBar({super.key, this.leading, this.trailing, this.center});

  final Widget? leading;
  final Widget? trailing;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.xl.w,
        vertical: Spacing.md.h,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          leading ?? const SizedBox.shrink(),
          if (center != null) ...[const Spacer(), center!],
          const Spacer(),
          trailing ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}
