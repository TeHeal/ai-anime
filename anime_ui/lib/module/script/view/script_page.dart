import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/object_tab_bar.dart';

/// 脚本对象主页面 — 4 Tab: 结构 / 生成中心 / 审核编辑 / 锁定
class ScriptObjectPage extends ConsumerWidget {
  const ScriptObjectPage({super.key, required this.child});

  final Widget child;

  static const tabs = [
    ObjectTab(
      label: '结构',
      routePath: Routes.scriptStructure,
      icon: AppIcons.script,
    ),
    ObjectTab(
      label: '生成中心',
      routePath: Routes.scriptCenter,
      icon: AppIcons.magicStick,
    ),
    ObjectTab(
      label: '审核编辑',
      routePath: Routes.scriptReview,
      icon: AppIcons.edit,
    ),
    ObjectTab(
      label: '锁定',
      routePath: Routes.scriptFreeze,
      icon: AppIcons.lock,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoute = GoRouterState.of(context).uri.path;

    return Column(
      children: [
        ObjectTabBar(
          title: '脚本',
          tabs: tabs,
          currentRoute: currentRoute,
          onTabTap: (path) => context.go(path),
        ),
        Expanded(child: child),
      ],
    );
  }
}
