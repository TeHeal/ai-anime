import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/object_tab_bar.dart';

/// 资产对象页壳：Tab 导航 + 子页面
class AssetsObjectPage extends ConsumerWidget {
  const AssetsObjectPage({super.key, required this.child});

  final Widget child;

  static const tabs = [
    ObjectTab(label: '总览', routePath: Routes.assetsOverview, icon: AppIcons.analytics),
    ObjectTab(label: '素材', routePath: Routes.assetsResources, icon: AppIcons.gallery),
    ObjectTab(label: '角色', routePath: Routes.assetsCharacters, icon: AppIcons.person),
    ObjectTab(label: '场景', routePath: Routes.assetsEnvironments, icon: AppIcons.landscape),
    ObjectTab(label: '道具', routePath: Routes.assetsProps, icon: AppIcons.category),
    ObjectTab(label: '版本', routePath: Routes.assetsVersions, icon: AppIcons.history),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoute = GoRouterState.of(context).uri.path;

    return Column(
      children: [
        ObjectTabBar(
          title: '资产',
          tabs: tabs,
          currentRoute: currentRoute,
          onTabTap: (path) => context.go(path),
        ),
        Expanded(child: child),
      ],
    );
  }
}
