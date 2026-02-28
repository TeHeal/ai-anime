import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/colors.dart';

/// 资产详情壳：可滚动内容区 + 可选底部操作栏
class AssetDetailShell extends StatelessWidget {
  const AssetDetailShell({
    super.key,
    this.bottomBar,
    this.padding = const EdgeInsets.all(24),
    required this.children,
  });

  final List<Widget> children;
  final Widget? bottomBar;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
        if (bottomBar != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(color: Colors.grey[800]!),
              ),
            ),
            child: bottomBar!,
          ),
      ],
    );
  }
}
