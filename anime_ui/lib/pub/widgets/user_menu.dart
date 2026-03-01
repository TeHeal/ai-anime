import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/app_dialog.dart';
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
              'admin',
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
      builder: (_, close) {
        return _ChangePasswordDialog(onClose: close);
      },
    );
  }

  void _showManageAccountsDialog(BuildContext context, WidgetRef ref) {
    AppDialog.show(
      context,
      builder: (_, close) {
        return _ManageAccountsDialog(onClose: close);
      },
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  final VoidCallback onClose;
  const _ChangePasswordDialog({required this.onClose});

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _oldCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final oldPwd = _oldCtrl.text;
    final newPwd = _newCtrl.text;
    final confirm = _confirmCtrl.text;

    if (oldPwd.isEmpty || newPwd.isEmpty) {
      setState(() => _error = '请填写所有字段');
      return;
    }
    if (newPwd != confirm) {
      setState(() => _error = '两次输入的新密码不一致');
      return;
    }
    if (newPwd.length < 6) {
      setState(() => _error = '新密码至少 6 位');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await dio.put(
        '/auth/password',
        data: {'old_password': oldPwd, 'new_password': newPwd},
      );
      if (mounted) {
        widget.onClose();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('密码修改成功'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _error = '修改失败：$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.xxl.r),
      ),
      title: Text(
        '修改密码',
        style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
      ),
      content: SizedBox(
        width: 360.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildField(_oldCtrl, '当前密码', obscure: true),
            SizedBox(height: Spacing.gridGap.h),
            _buildField(_newCtrl, '新密码', obscure: true),
            SizedBox(height: Spacing.gridGap.h),
            _buildField(_confirmCtrl, '确认新密码', obscure: true),
            if (_error != null) ...[
              SizedBox(height: Spacing.contentGap.h),
              Text(
                _error!,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.error.withValues(alpha: 0.9),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onClose,
          child: Text(
            '取消',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        FilledButton(
          onPressed: _loading ? null : _submit,
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          child: _loading
              ? SizedBox(
                  width: Spacing.lg.w,
                  height: Spacing.lg.h,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('确认修改'),
        ),
      ],
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label, {
    bool obscure = false,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.onSurface.withValues(alpha: 0.55),
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: Spacing.gridGap.w,
          vertical: Spacing.md.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md.r),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md.r),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

class _ManageAccountsDialog extends StatefulWidget {
  final VoidCallback onClose;
  const _ManageAccountsDialog({required this.onClose});

  @override
  State<_ManageAccountsDialog> createState() => _ManageAccountsDialogState();
}

class _ManageAccountsDialogState extends State<_ManageAccountsDialog> {
  List<dynamic> _users = [];
  bool _loading = true;

  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _role = 'member';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    try {
      final resp = await dio.get('/admin/users');
      final data = extractData<List<dynamic>>(resp);
      setState(() => _users = data);
    } catch (e, st) {
      debugPrint('_ManageAccountsDialog._loadUsers: $e');
      debugPrint(st.toString());
    }
    setState(() => _loading = false);
  }

  Future<void> _createUser() async {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (username.isEmpty || password.isEmpty) return;

    try {
      await dio.post(
        '/admin/users',
        data: {'username': username, 'password': password, 'role': _role},
      );
      _usernameCtrl.clear();
      _passwordCtrl.clear();
      await _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('用户 $username 已创建'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('创建失败: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.xxl.r),
      ),
      title: Text(
        '账户分配',
        style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
      ),
      content: SizedBox(
        width: 480.w,
        height: 400.h,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCreateForm(),
            SizedBox(height: Spacing.lg.h),
            const Divider(color: AppColors.divider),
            SizedBox(height: Spacing.sm.h),
            Text(
              '已有账户',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: Spacing.sm.h),
            Expanded(child: _buildUserList()),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: widget.onClose,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.surfaceContainerHighest,
          ),
          child: const Text('关闭'),
        ),
      ],
    );
  }

  Widget _buildCreateForm() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _usernameCtrl,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
            decoration: InputDecoration(
              hintText: '用户名',
              hintStyle: AppTextStyles.labelMedium.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.5),
              ),
              isDense: true,
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: EdgeInsets.symmetric(
                horizontal: Spacing.md.w,
                vertical: Spacing.buttonPaddingV.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        SizedBox(width: Spacing.sm.w),
        Expanded(
          child: TextField(
            controller: _passwordCtrl,
            obscureText: true,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
            decoration: InputDecoration(
              hintText: '密码',
              hintStyle: AppTextStyles.labelMedium.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.5),
              ),
              isDense: true,
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: EdgeInsets.symmetric(
                horizontal: Spacing.md.w,
                vertical: Spacing.buttonPaddingV.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        SizedBox(width: Spacing.sm.w),
        DropdownButton<String>(
          value: _role,
          isDense: true,
          dropdownColor: AppColors.surfaceContainerHigh,
          underline: const SizedBox(),
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.onSurface.withValues(alpha: 0.75),
          ),
          items: const [
            DropdownMenuItem(value: 'member', child: Text('普通用户')),
            DropdownMenuItem(value: 'admin', child: Text('管理员')),
          ],
          onChanged: (v) => setState(() => _role = v ?? 'member'),
        ),
        SizedBox(width: Spacing.sm.w),
        FilledButton.icon(
          onPressed: _createUser,
          icon: Icon(AppIcons.add, size: Spacing.gridGap.r),
          label: Text('创建', style: AppTextStyles.labelMedium),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.md.w,
              vertical: Spacing.buttonPaddingV.h,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_users.isEmpty) {
      return Center(
        child: Text(
          '暂无用户',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }
    return ListView.separated(
      itemCount: _users.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 1, color: AppColors.divider),
      itemBuilder: (_, i) {
        final u = _users[i] as Map<String, dynamic>;
        final role = u['role'] as String? ?? 'member';
        final isAdmin = role == 'admin';
        return ListTile(
          dense: true,
          leading: CircleAvatar(
            radius: Spacing.lg.r,
            backgroundColor: isAdmin
                ? AppColors.primary.withValues(alpha: 0.2)
                : AppColors.surfaceContainerHighest,
            child: Text(
              (u['username'] as String? ?? '?')[0].toUpperCase(),
              style: AppTextStyles.labelMedium.copyWith(
                color: isAdmin
                    ? AppColors.primary
                    : AppColors.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          title: Text(
            u['username'] as String? ?? '',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
          ),
          subtitle: Text(
            u['display_name'] as String? ?? '',
            style: AppTextStyles.tiny.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.55),
            ),
          ),
          trailing: Container(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.sm.w,
              vertical: Spacing.xs.h,
            ),
            decoration: BoxDecoration(
              color: isAdmin
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
            ),
            child: Text(
              isAdmin ? '管理员' : '普通用户',
              style: AppTextStyles.labelTinySmall.copyWith(
                color: isAdmin
                    ? AppColors.primary
                    : AppColors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        );
      },
    );
  }
}
