import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';
import 'package:anime_ui/pub/services/admin_svc.dart';

/// 账户分配对话框 — 用于 AppDialog.show 内
class ManageAccountsDialog extends StatefulWidget {
  final VoidCallback onClose;
  const ManageAccountsDialog({super.key, required this.onClose});

  @override
  State<ManageAccountsDialog> createState() => _ManageAccountsDialogState();
}

class _ManageAccountsDialogState extends State<ManageAccountsDialog> {
  List<dynamic> _users = [];
  bool _loading = true;
  bool _creating = false;

  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _role = 'member';
  bool _pwdVisible = false;

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
      final users = await AdminService().listUsers();
      if (!mounted) return;
      setState(() => _users = users);
    } catch (e, st) {
      debugPrint('ManageAccountsDialog._loadUsers: $e\n$st');
      if (mounted) {
        showToast(context, '加载用户列表失败', isError: true);
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _createUser() async {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (username.isEmpty || password.isEmpty) {
      showToast(context, '请填写用户名和密码', isError: true);
      return;
    }

    setState(() => _creating = true);
    try {
      await AdminService().createUser(
        username: username,
        password: password,
        role: _role,
      );
      _usernameCtrl.clear();
      _passwordCtrl.clear();
      setState(() => _role = 'member');
      await _loadUsers();
      if (mounted) {
        showToast(context, '用户 $username 已创建');
      }
    } catch (e) {
      if (mounted) {
        showToast(context, '创建失败: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Spacing.xl.w),
      child: SizedBox(
        width: 480.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(Spacing.sm.w),
                  decoration: BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                  ),
                  child: Icon(
                    AppIcons.people,
                    size: Spacing.mid.r,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: Spacing.md.w),
                Text(
                  '账户分配',
                  style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
                ),
                const Spacer(),
                IconButton(
                  onPressed: widget.onClose,
                  icon: Icon(
                    AppIcons.close,
                    size: Spacing.mid.r,
                    color: AppColors.mutedDark,
                  ),
                  splashRadius: Spacing.lg.r,
                ),
              ],
            ),
            SizedBox(height: Spacing.lg.h),
            _buildCreateForm(),
            SizedBox(height: Spacing.lg.h),
            Row(
              children: [
                Container(
                  width: 3.w,
                  height: Spacing.gridGap.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: Spacing.sm.w),
                Text(
                  '已有账户',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.mutedLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: Spacing.sm.w),
                if (!_loading)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Spacing.sm.w,
                      vertical: Spacing.xxs.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
                    ),
                    child: Text(
                      '${_users.length}',
                      style: AppTextStyles.labelTinySmall.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: Spacing.sm.h),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 280.h),
              child: _buildUserList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateForm() {
    return Container(
      padding: EdgeInsets.all(Spacing.md.w),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '创建新用户',
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.muted),
          ),
          SizedBox(height: Spacing.md.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _usernameCtrl,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurface,
                  ),
                  decoration: _compactInputDecor(
                    hint: '用户名',
                    icon: AppIcons.person,
                  ),
                ),
              ),
              SizedBox(width: Spacing.sm.w),
              Expanded(
                child: TextField(
                  controller: _passwordCtrl,
                  obscureText: !_pwdVisible,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurface,
                  ),
                  decoration:
                      _compactInputDecor(
                        hint: '密码',
                        icon: AppIcons.lockOutline,
                      ).copyWith(
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _pwdVisible = !_pwdVisible),
                          icon: Icon(
                            _pwdVisible ? AppIcons.lockUnlocked : AppIcons.lock,
                            size: Spacing.gridGap.r,
                            color: AppColors.mutedDark,
                          ),
                          splashRadius: Spacing.lg.r,
                        ),
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: Spacing.md.h),
          Row(
            children: [
              _buildRoleChip('member', '普通用户', AppIcons.person),
              SizedBox(width: Spacing.sm.w),
              _buildRoleChip('admin', '管理员', AppIcons.settings),
              const Spacer(),
              FilledButton.icon(
                onPressed: _creating ? null : _createUser,
                icon: _creating
                    ? SizedBox(
                        width: Spacing.gridGap.w,
                        height: Spacing.gridGap.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : Icon(AppIcons.add, size: Spacing.gridGap.r),
                label: Text(
                  '创建',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withValues(
                    alpha: 0.4,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.lg.w,
                    vertical: Spacing.buttonPaddingV.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleChip(String value, String label, IconData icon) {
    final selected = _role == value;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _role = value),
        child: AnimatedContainer(
          duration: MotionTokens.durationFast,
          curve: MotionTokens.curveStandard,
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.chipPaddingH.w,
            vertical: Spacing.chipPaddingV.h,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.15)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.inputBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: Spacing.gridGap.r,
                color: selected ? AppColors.primary : AppColors.mutedDark,
              ),
              SizedBox(width: Spacing.xs.w),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: selected ? AppColors.primary : AppColors.muted,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _compactInputDecor({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.mutedDark),
      prefixIcon: Icon(
        icon,
        size: Spacing.menuIconSize.r,
        color: AppColors.muted,
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
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.md.r),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.md.r),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Widget _buildUserList() {
    if (_loading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(Spacing.xl.w),
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2.5,
          ),
        ),
      );
    }
    if (_users.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(Spacing.xxl.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(AppIcons.people, size: 40.r, color: AppColors.mutedDarker),
              SizedBox(height: Spacing.md.h),
              Text(
                '暂无用户',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.mutedDark,
                ),
              ),
              SizedBox(height: Spacing.xs.h),
              Text(
                '在上方创建第一个用户',
                style: AppTextStyles.tiny.copyWith(
                  color: AppColors.mutedDarker,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      itemCount: _users.length,
      separatorBuilder: (_, __) => SizedBox(height: Spacing.sm.h),
      itemBuilder: (_, i) => _buildUserCard(_users[i] as Map<String, dynamic>),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> u) {
    final role = u['role'] as String? ?? 'member';
    final isAdmin = role == 'admin';
    final username = u['username'] as String? ?? '';
    final displayName = u['display_name'] as String? ?? '';
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.md.w,
        vertical: Spacing.sm.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(RadiusTokens.md.r),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          Container(
            width: Spacing.xxl.w,
            height: Spacing.xxl.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isAdmin
                    ? [
                        AppColors.primary.withValues(alpha: 0.6),
                        AppColors.primary,
                      ]
                    : [
                        AppColors.surfaceContainerHighest,
                        AppColors.surfaceMuted,
                      ],
              ),
            ),
            child: Center(
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : '?',
                style: AppTextStyles.labelMedium.copyWith(
                  color: isAdmin
                      ? AppColors.onPrimary
                      : AppColors.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: Spacing.md.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (displayName.isNotEmpty)
                  Text(
                    displayName,
                    style: AppTextStyles.tiny.copyWith(color: AppColors.muted),
                  ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.sm.w,
              vertical: Spacing.xs.h,
            ),
            decoration: BoxDecoration(
              color: isAdmin
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
            ),
            child: Text(
              isAdmin ? '管理员' : '普通用户',
              style: AppTextStyles.labelTinySmall.copyWith(
                color: isAdmin ? AppColors.primary : AppColors.muted,
                fontWeight: isAdmin ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
