import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';

/// 三栏审核布局：左侧镜头列表 + 中间编辑器 + 右侧面板
///
/// 窄屏时左右面板宽度缩小，使用 Breakpoints 响应式
class ReviewScaffold extends StatelessWidget {
  final Widget leftNav;
  final Widget center;
  final Widget rightPanel;
  final Widget? topBar;
  final double leftWidth;
  final double rightWidth;

  const ReviewScaffold({
    super.key,
    required this.leftNav,
    required this.center,
    required this.rightPanel,
    this.topBar,
    this.leftWidth = Spacing.reviewLeftWidth,
    this.rightWidth = Spacing.reviewRightWidth,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final narrow = Breakpoints.isNarrow(w);
    final lw = narrow ? leftWidth * 0.85 : leftWidth;
    final rw = narrow ? rightWidth * 0.85 : rightWidth;

    return Column(
      children: [
        if (topBar case Widget w) w,
        Expanded(
          child: Row(
            children: [
              SizedBox(width: lw.w, child: leftNav),
              VerticalDivider(
                width: 1.w,
                thickness: 1.r,
                color: AppColors.divider,
              ),
              Expanded(child: center),
              VerticalDivider(
                width: 1.w,
                thickness: 1.r,
                color: AppColors.divider,
              ),
              SizedBox(width: rw.w, child: rightPanel),
            ],
          ),
        ),
      ],
    );
  }
}
