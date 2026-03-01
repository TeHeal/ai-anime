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
import 'package:anime_ui/pub/widgets/user_menu.dart';

/// 主布局 AppBar — 仪表盘入口、项目列表、通知、用户菜单
/// 归属 layout 模块，可依赖 dashboard 等同级模块
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
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.h),
        child: Container(
          height: 1.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.primary.withValues(alpha: 0.15),
                AppColors.primary.withValues(alpha: 0.3),
                AppColors.primary.withValues(alpha: 0.15),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
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
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [AppColors.primary, AppColors.info],
                        ).createShader(bounds),
                        child: Icon(
                          AppIcons.movieFilter,
                          color: Colors.white,
                          size: 28.r,
                        ),
                      ),
                    )
                  : Icon(
                      AppIcons.movieFilter,
                      color: AppColors.primary,
                      size: 22.r,
                    ),
              SizedBox(width: Spacing.sm.w),
              if (isDashboard)
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      AppColors.onSurface,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                  ).createShader(bounds),
                  child: Text(
                    headerBrand,
                    style: AppTextStyles.bodyXLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
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
        _HeaderActionButton(
          icon: AppIcons.folderOpen,
          tooltip: '项目列表',
          onTap: () => context.go(Routes.projects),
        ),
        SizedBox(width: Spacing.md.w),
        const _NotificationBadge(),
        SizedBox(width: Spacing.lg.w),
        Padding(
          padding: EdgeInsets.only(right: Spacing.sm.w),
          child: const UserMenu(),
        ),
        SizedBox(width: Spacing.xl.w),
      ],
    );
  }
}

/// 头部操作按钮 — 悬浮高亮效果
class _HeaderActionButton extends StatefulWidget {
  const _HeaderActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  State<_HeaderActionButton> createState() => _HeaderActionButtonState();
}

class _HeaderActionButtonState extends State<_HeaderActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(Spacing.sm.r),
            decoration: BoxDecoration(
              color: _hovered
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            ),
            child: Icon(
              widget.icon,
              size: 18.r,
              color: _hovered
                  ? AppColors.primary
                  : AppColors.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
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
          backgroundColor: AppColors.primary,
          child: _HeaderActionButton(
            icon: AppIcons.notification,
            tooltip: '站内通知',
            onTap: () => Scaffold.of(ctx).openEndDrawer(),
          ),
        ),
      ),
      loading: () => Builder(
        builder: (ctx) => _HeaderActionButton(
          icon: AppIcons.notification,
          tooltip: '站内通知',
          onTap: () => Scaffold.of(ctx).openEndDrawer(),
        ),
      ),
      error: (e, st) => Builder(
        builder: (ctx) => _HeaderActionButton(
          icon: AppIcons.notification,
          tooltip: '站内通知',
          onTap: () => Scaffold.of(ctx).openEndDrawer(),
        ),
      ),
    );
  }
}
