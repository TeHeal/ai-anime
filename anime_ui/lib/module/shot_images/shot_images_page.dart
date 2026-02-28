import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/object_tab_bar.dart';

/// 镜图主页面 — 2 Tab: 生成中心 / 审核编辑
class ShotImagesPage extends StatelessWidget {
  const ShotImagesPage({super.key, required this.child});

  final Widget child;

  static const tabs = [
    ObjectTab(
        label: '生成中心',
        routePath: Routes.shotImagesCenter,
        icon: AppIcons.magicStick),
    ObjectTab(
        label: '审核编辑',
        routePath: Routes.shotImagesReview,
        icon: AppIcons.edit),
  ];

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.path;
    return Column(
      children: [
        ObjectTabBar(
          title: '镜图',
          tabs: tabs,
          currentRoute: currentRoute,
          onTabTap: (path) => context.go(path),
        ),
        Expanded(child: child),
      ],
    );
  }
}
