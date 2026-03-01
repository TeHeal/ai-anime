import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';

/// 资产详情壳：可滚动内容区 + 可选底部操作栏
class AssetDetailShell extends StatelessWidget {
  const AssetDetailShell({
    super.key,
    this.bottomBar,
    this.padding,
    required this.children,
  });

  final List<Widget> children;
  final Widget? bottomBar;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? EdgeInsets.all(Spacing.xl.r);
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: effectivePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
        if (bottomBar != null)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.mid.w,
              vertical: Spacing.md.h,
            ),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(color: AppColors.border),
              ),
            ),
            child: bottomBar!,
          ),
      ],
    );
  }
}
