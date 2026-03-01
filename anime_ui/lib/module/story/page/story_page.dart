import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/providers/lock_provider.dart';
import 'package:anime_ui/pub/widgets/object_tab_bar.dart';

/// 剧本页壳 — 含导入/预览/编辑/锁定四个 Tab
class StoryPage extends ConsumerWidget {
  const StoryPage({super.key, required this.child});

  final Widget child;

  static const tabs = [
    ObjectTab(label: '导入', routePath: Routes.storyImport, icon: AppIcons.upload),
    ObjectTab(label: '预览', routePath: Routes.storyPreview, icon: AppIcons.list),
    ObjectTab(label: '编辑', routePath: Routes.storyEdit, icon: AppIcons.edit),
    ObjectTab(label: '锁定', routePath: Routes.storyConfirm, icon: AppIcons.lock),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoute = GoRouterState.of(context).uri.path;
    final isLocked = ref.watch(lockProvider).storyLocked;

    final disabledRoutes = <String>{};
    final labelOverrides = <String, String>{};

    if (isLocked) {
      disabledRoutes.add(Routes.storyImport);
      labelOverrides[Routes.storyEdit] = '查看';
    }

    return Column(
      children: [
        ObjectTabBar(
          title: '剧本',
          tabs: tabs,
          currentRoute: currentRoute,
          onTabTap: (path) => context.go(path),
          disabledRoutes: disabledRoutes,
          labelOverrides: labelOverrides,
        ),
        Expanded(child: child),
      ],
    );
  }
}
