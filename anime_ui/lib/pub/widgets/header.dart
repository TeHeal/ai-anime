import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/const/app_const.dart';
import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/widgets/pulse_widget.dart';
import 'package:anime_ui/module/dashboard/provider.dart';
import 'package:anime_ui/pub/providers/notification_provider.dart';
import 'user_menu.dart';

class AppHeader extends ConsumerWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouterState.of(context).uri.path;
    final isDashboard =
        currentPath == Routes.dashboard ||
        currentPath.startsWith('${Routes.dashboard}/');

    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      titleSpacing: 20,
      leadingWidth: 0,
      leading: const SizedBox.shrink(),
      title: InkWell(
        onTap: isDashboard
            ? () => ref.read(dashboardProvider.notifier).load()
            : () => context.go(Routes.dashboard),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isDashboard)
                Icon(AppIcons.chevronLeft, color: Colors.grey[400], size: 16),
              if (!isDashboard) const SizedBox(width: 4),
              isDashboard
                  ? PulseWidget(
                      pulseColor: AppColors.primary,
                      ringPadding: 6,
                      maxScale: 1.08,
                      child: Icon(
                          AppIcons.movieFilter,
                          color: AppColors.primary,
                          size: 28),
                    )
                  : Icon(
                      AppIcons.movieFilter,
                      color: AppColors.primary,
                      size: 22),
              const SizedBox(width: 8),
              if (isDashboard)
                const Text(
                  headerBrand,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      headerBrand,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      '返回驾驶舱',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(AppIcons.folderOpen, size: 18),
          iconSize: 18,
          tooltip: '项目列表',
          onPressed: () => context.go(Routes.projects),
        ),
        const SizedBox(width: 15),
        const _NotificationBadge(),
        const SizedBox(width: 30),
        const Padding(
          padding: EdgeInsets.only(right: 8),
          child: UserMenu(),
        ),
        const SizedBox(width: 20),
      ],
    );
  }
}

/// 通知角标：显示未读通知数（README 2.6），点击弹出通知列表
class _NotificationBadge extends ConsumerWidget {
  const _NotificationBadge();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(unreadNotificationCountProvider);

    return countAsync.when(
      data: (count) => Builder(
        builder: (ctx) => Badge(
          isLabelVisible: count > 0,
          label: Text('$count', style: const TextStyle(fontSize: 10)),
          child: IconButton(
            icon: const Icon(AppIcons.notification, size: 18),
            iconSize: 18,
            tooltip: '站内通知',
            onPressed: () => Scaffold.of(ctx).openEndDrawer(),
          ),
        ),
      ),
      loading: () => Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(AppIcons.notification, size: 18),
          iconSize: 18,
          tooltip: '站内通知',
          onPressed: () => Scaffold.of(ctx).openEndDrawer(),
        ),
      ),
      error: (e, st) => Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(AppIcons.notification, size: 18),
          iconSize: 18,
          tooltip: '站内通知',
          onPressed: () => Scaffold.of(ctx).openEndDrawer(),
        ),
      ),
    );
  }
}
