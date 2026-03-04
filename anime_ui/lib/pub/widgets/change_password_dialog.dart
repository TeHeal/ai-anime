import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';
import 'package:anime_ui/pub/services/auth_svc.dart';

/// 修改密码对话框 — 用于 AppDialog.show 内
class ChangePasswordDialog extends StatefulWidget {
  final VoidCallback onClose;
  const ChangePasswordDialog({super.key, required this.onClose});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _loading = false;
  String? _error;
  bool _oldVisible = false;
  bool _newVisible = false;
  bool _confirmVisible = false;

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

    if (oldPwd.isEmpty || newPwd.isEmpty || confirm.isEmpty) {
      setState(() => _error = '请填写所有字段');
      return;
    }
    if (newPwd.length < 6) {
      setState(() => _error = '新密码至少 6 位');
      return;
    }
    if (newPwd != confirm) {
      setState(() => _error = '两次输入的新密码不一致');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await AuthService().changePassword(
        oldPassword: oldPwd,
        newPassword: newPwd,
      );
      if (mounted) {
        widget.onClose();
        showToast(context, '密码修改成功');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '修改失败：$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Spacing.xl.w),
      child: SizedBox(
        width: 380.w,
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
                    AppIcons.lockOutline,
                    size: Spacing.mid.r,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: Spacing.md.w),
                Text(
                  '修改密码',
                  style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
                ),
              ],
            ),
            SizedBox(height: Spacing.xl.h),
            _buildField(
              ctrl: _oldCtrl,
              label: '当前密码',
              icon: AppIcons.lock,
              obscure: !_oldVisible,
              onToggle: () => setState(() => _oldVisible = !_oldVisible),
              visible: _oldVisible,
            ),
            SizedBox(height: Spacing.md.h),
            _buildField(
              ctrl: _newCtrl,
              label: '新密码',
              icon: AppIcons.lockOutline,
              obscure: !_newVisible,
              onToggle: () => setState(() => _newVisible = !_newVisible),
              visible: _newVisible,
            ),
            SizedBox(height: Spacing.md.h),
            _buildField(
              ctrl: _confirmCtrl,
              label: '确认新密码',
              icon: AppIcons.checkOutline,
              obscure: !_confirmVisible,
              onToggle: () =>
                  setState(() => _confirmVisible = !_confirmVisible),
              visible: _confirmVisible,
            ),
            AnimatedSize(
              duration: MotionTokens.durationMedium,
              curve: MotionTokens.curveStandard,
              alignment: Alignment.topCenter,
              child: _error != null
                  ? Padding(
                      padding: EdgeInsets.only(top: Spacing.md.h),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: Spacing.md.w,
                          vertical: Spacing.sm.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(RadiusTokens.md.r),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              AppIcons.warning,
                              size: Spacing.gridGap.r,
                              color: AppColors.error,
                            ),
                            SizedBox(width: Spacing.sm.w),
                            Expanded(
                              child: Text(
                                _error!,
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            SizedBox(height: Spacing.xl.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.onClose,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: Spacing.lg.w,
                      vertical: Spacing.buttonPaddingV.h,
                    ),
                  ),
                  child: Text(
                    '取消',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ),
                SizedBox(width: Spacing.sm.w),
                FilledButton(
                  onPressed: _loading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.4),
                    padding: EdgeInsets.symmetric(
                      horizontal: Spacing.xl.w,
                      vertical: Spacing.buttonPaddingV.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                    ),
                  ),
                  child: _loading
                      ? SizedBox(
                          width: Spacing.lg.w,
                          height: Spacing.lg.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : Text(
                          '确认修改',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.onPrimary,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    required bool obscure,
    required VoidCallback onToggle,
    required bool visible,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.mutedDark,
        ),
        prefixIcon:
            Icon(icon, size: Spacing.menuIconSize.r, color: AppColors.muted),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            visible ? AppIcons.lockUnlocked : AppIcons.lock,
            size: Spacing.menuIconSize.r,
            color: AppColors.mutedDark,
          ),
          splashRadius: Spacing.lg.r,
        ),
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: EdgeInsets.symmetric(
          horizontal: Spacing.md.w,
          vertical: Spacing.md.h,
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
      ),
    );
  }
}
