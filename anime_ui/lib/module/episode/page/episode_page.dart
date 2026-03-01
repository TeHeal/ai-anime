import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/object_tab_bar.dart';

/// 成片页壳：Tab 导航（时间线、音频、版本、导出）
class EpisodeObjectPage extends StatelessWidget {
  const EpisodeObjectPage({super.key, required this.child});

  final Widget child;

  static const tabs = [
    ObjectTab(
        label: '时间线',
        routePath: Routes.episodeTimeline,
        icon: AppIcons.video),
    ObjectTab(
        label: '音频 / 字幕',
        routePath: Routes.episodeAudio,
        icon: AppIcons.music),
    ObjectTab(
        label: '版本管理',
        routePath: Routes.episodeVersions,
        icon: AppIcons.history),
    ObjectTab(
        label: '导出',
        routePath: Routes.episodeExport,
        icon: AppIcons.download),
  ];

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.path;
    return Column(
      children: [
        ObjectTabBar(
          title: '成片',
          tabs: tabs,
          currentRoute: currentRoute,
          onTabTap: (path) => context.go(path),
        ),
        Expanded(child: child),
      ],
    );
  }
}
