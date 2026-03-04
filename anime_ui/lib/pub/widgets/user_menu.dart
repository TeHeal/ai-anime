import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/app_dialog.dart';
import 'package:anime_ui/pub/widgets/change_password_dialog.dart';
import 'package:anime_ui/pub/widgets/manage_accounts_dialog.dart';
import 'package:anime_ui/pub/providers/auth_provider.dart';
import 'package:anime_ui/pub/providers/lock_provider.dart';
import 'package:anime_ui/pub/providers/storage_provider.dart';
import 'package:anime_ui/pub/providers/project_provider.dart';
import 'package:anime_ui/pub/services/api_svc.dart';

/// 用户头像菜单 — 提供修改密码、账户分配、退出登录。
/// 在项目列表页和工作区 AppBar 中复用。
class UserMenu extends ConsumerWidget {
  const UserMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username =
        ref.watch(authProvider).user?.username ?? 'admin';
    return PopupMenuButton<String>(
      offset: Offset(0, 48.h),
      color: AppColors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
        side: const BorderSide(color: AppColors.border),
      ),
      onSelected: (value) => _onSelected(context, ref, value),
      itemBuilder: (_) => [
        _buildItem('change_password', AppIcons.lockOutline, '修改密码'),
        _buildItem('manage_accounts', AppIcons.person, '账户分配'),
        const PopupMenuDivider(height: 1),
        _buildItem('logout', AppIcons.logout, '退出登录', isDestructive: true),
      ],
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.md.w,
          vertical: Spacing.chipPaddingVSmall.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(Spacing.mid.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: Spacing.avatarSize.w,
              height: Spacing.avatarSize.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.7),
                    AppColors.primary,
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  AppIcons.person,
                  size: Spacing.gridGap.r,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            SizedBox(width: Spacing.sm.w),
            Text(
              username,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.75),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: Spacing.xs.w),
            Icon(
              AppIcons.expandMore,
              size: Spacing.lg.r,
              color: AppColors.onSurface.withValues(alpha: 0.55),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildItem(
    String value,
    IconData icon,
    String label, {
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? AppColors.error
        : AppColors.onSurface.withValues(alpha: 0.75);
    return PopupMenuItem(
      value: value,
      height: 42.h,
      child: Row(
        children: [
          Icon(icon, size: Spacing.menuIconSize.r, color: color),
          SizedBox(width: Spacing.iconGapMd.w),
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: color)),
        ],
      ),
    );
  }

  void _onSelected(BuildContext context, WidgetRef ref, String value) {
    switch (value) {
      case 'change_password':
        _showChangePasswordDialog(context, ref);
      case 'manage_accounts':
        _showManageAccountsDialog(context, ref);
      case 'logout':
        _logout(context, ref);
    }
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    setAuthToken(null);
    ref.read(currentProjectProvider.notifier).clear();
    ref.read(lockProvider.notifier).clear();
    final storage = ref.read(storageServiceProvider);
    await storage.clearToken();
    await storage.clearCurrentProjectId();
    if (context.mounted) context.go(Routes.login);
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    AppDialog.show(
      context,
      builder: (_, close) => ChangePasswordDialog(onClose: close),
    );
  }

  void _showManageAccountsDialog(BuildContext context, WidgetRef ref) {
    AppDialog.show(
      context,
      builder: (_, close) => ManageAccountsDialog(onClose: close),
    );
  }
}

