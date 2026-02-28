import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/colors.dart';

/// 剧本操作栏 — 底部操作区
class StoryActionBar extends StatelessWidget {
  const StoryActionBar({
    super.key,
    this.leading,
    this.trailing,
    this.center,
  });

  final Widget? leading;
  final Widget? trailing;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: Colors.grey[800]!),
        ),
      ),
      child: Row(
        children: [
          leading ?? const SizedBox.shrink(),
          if (center != null) ...[
            const Spacer(),
            center!,
          ],
          const Spacer(),
          trailing ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}
