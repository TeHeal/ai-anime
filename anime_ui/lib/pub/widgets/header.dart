import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/const/app_const.dart';
import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/pulse.dart';
import 'package:anime_ui/module/dashboard/index.dart';
import 'package:anime_ui/pub/providers/notification_provider.dart';
import 'user_menu.dart';

class AppHeader extends ConsumerWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Size get preferredSize => Size.fromHeight(56.h);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouterState.of(context).uri.path;
    final isDashboard =
        currentPath == Routes.dashboard ||
        currentPath.startsWith('${Routes.dashboard}/');

    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      titleSpacing: Spacing.xl.w,
      leadingWidth: 0,
      leading: const SizedBox.shrink(),
      title: InkWell(
        onTap: isDashboard
            ? () => ref.read(dashboardProvider.notifier).load()
            : () => context.go(Routes.dashboard),
        borderRadius: BorderRadius.circular(RadiusTokens.md.r),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: (Spacing.xl + Spacing.lg).w,
            vertical: Spacing.sm.h,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isDashboard)
                Icon(
                  AppIcons.chevronLeft,
                  color: AppColors.onSurface.withValues(alpha: 0.7),
                  size: Spacing.lg.r,
                ),
              if (!isDashboard) SizedBox(width: Spacing.xs.w),
              isDashboard
                  ? PulseWidget(
                      pulseColor: AppColors.primary,
                      ringPadding: 6.r,
                      maxScale: 1.08,
                      child: Icon(
                        AppIcons.movieFilter,
                        color: AppColors.primary,
                        size: 28.r,
                      ),
                    )
                  : Icon(
                      AppIcons.movieFilter,
                      color: AppColors.primary,
                        size: 22.r,
                      ),
              SizedBox(width: Spacing.sm.w),
              if (isDashboard)
                Text(
                  headerBrand,
                  style: AppTextStyles.bodyXLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                    letterSpacing: 0.5,
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      headerBrand,
                      style: AppTextStyles.bodyXLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                        letterSpacing: 0.5,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      '返回驾驶舱',
                      style: AppTextStyles.labelTinySmall.copyWith(
                        color: AppColors.onSurface.withValues(alpha: 0.6),
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
          icon: Icon(AppIcons.folderOpen, size: 18.r),
          iconSize: 18.r,
          tooltip: '项目列表',
          onPressed: () => context.go(Routes.projects),
        ),
        SizedBox(width: Spacing.lg.w),
        const _NotificationBadge(),
        SizedBox(width: Spacing.xxl.w),
        Padding(
          padding: EdgeInsets.only(right: Spacing.sm.w),
          child: const UserMenu(),
        ),
        SizedBox(width: Spacing.xl.w),
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
          label: Text('$count', style: AppTextStyles.tiny),
          child: IconButton(
            icon: Icon(AppIcons.notification, size: 18.r),
            iconSize: 18.r,
            tooltip: '站内通知',
            onPressed: () => Scaffold.of(ctx).openEndDrawer(),
          ),
        ),
      ),
      loading: () => Builder(
        builder: (ctx) => IconButton(
          icon: Icon(AppIcons.notification, size: 18.r),
          iconSize: 18.r,
          tooltip: '站内通知',
          onPressed: () => Scaffold.of(ctx).openEndDrawer(),
        ),
      ),
      error: (e, st) => Builder(
        builder: (ctx) => IconButton(
          icon: Icon(AppIcons.notification, size: 18.r),
          iconSize: 18.r,
          tooltip: '站内通知',
          onPressed: () => Scaffold.of(ctx).openEndDrawer(),
        ),
      ),
    );
  }
}
