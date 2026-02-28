import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/widgets/app_dialog.dart';
import 'package:anime_ui/main.dart';
import 'package:anime_ui/pub/providers/lock.dart';
import 'package:anime_ui/pub/providers/project.dart';
import 'package:anime_ui/pub/services/api.dart';

/// 用户头像菜单 — 提供修改密码、账户分配、退出登录。
/// 在项目列表页和工作区 AppBar 中复用。
class UserMenu extends ConsumerWidget {
  const UserMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      color: const Color(0xFF1E1E30),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[800]!),
      ),
      onSelected: (value) => _onSelected(context, ref, value),
      itemBuilder: (_) => [
        _buildItem('change_password', AppIcons.lockOutline, '修改密码'),
        _buildItem('manage_accounts', AppIcons.person, '账户分配'),
        const PopupMenuDivider(height: 1),
        _buildItem('logout', AppIcons.logout, '退出登录', isDestructive: true),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[800]!.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.7),
                    const Color(0xFF6366F1),
                  ],
                ),
              ),
              child: const Center(
                child: Icon(AppIcons.person, size: 14, color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'admin',
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(AppIcons.expandMore, size: 16, color: Colors.grey[500]),
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
    final color = isDestructive ? Colors.red[400] : Colors.grey[300];
    return PopupMenuItem(
      value: value,
      height: 42,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: color, fontSize: 13)),
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
    await storageService.clearToken();
    await storageService.clearCurrentProjectId();
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
          SnackBar(
            content: const Text('密码修改成功'),
            backgroundColor: Colors.green[700],
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
      backgroundColor: const Color(0xFF1E1E30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Text(
        '修改密码',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildField(_oldCtrl, '当前密码', obscure: true),
            const SizedBox(height: 14),
            _buildField(_newCtrl, '新密码', obscure: true),
            const SizedBox(height: 14),
            _buildField(_confirmCtrl, '确认新密码', obscure: true),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: TextStyle(color: Colors.red[300], fontSize: 12),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onClose,
          child: Text('取消', style: TextStyle(color: Colors.grey[400])),
        ),
        FilledButton(
          onPressed: _loading ? null : _submit,
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
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
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
        filled: true,
        fillColor: const Color(0xFF141425),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[800]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
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
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('创建失败: $e'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Text(
        '账户分配',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      content: SizedBox(
        width: 480,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCreateForm(),
            const SizedBox(height: 16),
            Divider(color: Colors.grey[800]),
            const SizedBox(height: 8),
            Text(
              '已有账户',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildUserList()),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: widget.onClose,
          style: FilledButton.styleFrom(backgroundColor: Colors.grey[700]),
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
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: '用户名',
              hintStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
              isDense: true,
              filled: true,
              fillColor: const Color(0xFF141425),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _passwordCtrl,
            obscureText: true,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: '密码',
              hintStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
              isDense: true,
              filled: true,
              fillColor: const Color(0xFF141425),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: _role,
          isDense: true,
          dropdownColor: const Color(0xFF1E1E30),
          underline: const SizedBox(),
          style: TextStyle(color: Colors.grey[300], fontSize: 12),
          items: const [
            DropdownMenuItem(value: 'member', child: Text('普通用户')),
            DropdownMenuItem(value: 'admin', child: Text('管理员')),
          ],
          onChanged: (v) => setState(() => _role = v ?? 'member'),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: _createUser,
          icon: const Icon(AppIcons.add, size: 14),
          label: const Text('创建', style: TextStyle(fontSize: 12)),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
        child: Text('暂无用户', style: TextStyle(color: Colors.grey[600])),
      );
    }
    return ListView.separated(
      itemCount: _users.length,
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: Colors.grey[800]),
      itemBuilder: (_, i) {
        final u = _users[i] as Map<String, dynamic>;
        final role = u['role'] as String? ?? 'member';
        final isAdmin = role == 'admin';
        return ListTile(
          dense: true,
          leading: CircleAvatar(
            radius: 16,
            backgroundColor: isAdmin
                ? AppColors.primary.withValues(alpha: 0.2)
                : Colors.grey[800],
            child: Text(
              (u['username'] as String? ?? '?')[0].toUpperCase(),
              style: TextStyle(
                color: isAdmin ? AppColors.primary : Colors.grey[400],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          title: Text(
            u['username'] as String? ?? '',
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          subtitle: Text(
            u['display_name'] as String? ?? '',
            style: TextStyle(color: Colors.grey[500], fontSize: 11),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isAdmin
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Colors.grey[800],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              isAdmin ? '管理员' : '普通用户',
              style: TextStyle(
                color: isAdmin ? AppColors.primary : Colors.grey[400],
                fontSize: 10,
              ),
            ),
          ),
        );
      },
    );
  }
}
