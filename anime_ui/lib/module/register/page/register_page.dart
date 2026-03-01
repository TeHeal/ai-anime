import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/const/app_const.dart';
import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/glow_card.dart';
import 'package:anime_ui/pub/widgets/starfield_background.dart';
import 'package:anime_ui/pub/providers/storage_provider.dart';
import 'package:anime_ui/pub/services/api_svc.dart';
import 'package:anime_ui/pub/services/auth_svc.dart';

/// 用户注册页 — 风格与登录页一致，支持表单校验、注册后自动登录
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPwdCtrl = TextEditingController();
  final _displayNameCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPwdCtrl.dispose();
    _displayNameCtrl.dispose();
    super.dispose();
  }

  String? _validate() {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirmPwd = _confirmPwdCtrl.text;

    if (username.isEmpty || password.isEmpty) return '请输入用户名和密码';
    if (username.length < 3 || username.length > 32) return '用户名需 3-32 个字符';
    if (password.length < 6) return '密码至少 6 位';
    if (password != confirmPwd) return '两次密码不一致';
    return null;
  }

  Future<void> _register() async {
    final validationError = _validate();
    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await AuthService().register(
        username: _usernameCtrl.text.trim(),
        password: _passwordCtrl.text,
        displayName: _displayNameCtrl.text.trim(),
      );
      setAuthToken(result.token);
      if (!mounted) return;
      await ProviderScope.containerOf(
        context,
      ).read(storageServiceProvider).setToken(result.token);
      if (mounted) context.go(Routes.projects);
    } on DioException catch (e) {
      setState(
        () => _error = e.response?.data?['message'] as String? ?? '网络错误，请稍后重试',
      );
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = '注册失败: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          StarfieldBackground(
            particleCount: 60,
            particleColor: AppColors.primary,
            speed: 0.2,
            overlayGradient: RadialGradient(
              center: const Alignment(0, 0),
              radius: 1.0,
              colors: [
                AppColors.primary.withValues(alpha: 0.06),
                Colors.transparent,
              ],
            ),
          ),
          Center(
            child: LayoutBuilder(
              builder: (context, _) {
                final screenW = Breakpoints.screenWidth(context);
                final screenH = MediaQuery.sizeOf(context).height;
                final cardW = (screenW - Spacing.xl.w * 2).clamp(
                  Spacing.loginCardMinWidth,
                  Spacing.loginCardMaxWidth,
                );
                final cardH = (screenH - Spacing.xl.h * 2).clamp(
                  460.0,
                  560.0,
                );
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.xl.w,
                    vertical: Spacing.xl.h,
                  ),
                  child: SizedBox(
                    width: cardW,
                    height: cardH,
                    child: GlowCard(
                      glowColor: AppColors.primary,
                      glowIntensity: 0.1,
                      hoverGlowIntensity: 0.25,
                      hoverElevation: 0,
                      showTopAccent: true,
                      topAccentHeight: 3,
                      padding: EdgeInsets.fromLTRB(
                        Spacing.xxl.r,
                        Spacing.dialogPaddingTop.r,
                        Spacing.xxl.r,
                        Spacing.xxl.r,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              AppIcons.person,
                              size: Spacing.thumbnailSize.r,
                              color: AppColors.primary,
                            ),
                            SizedBox(height: Spacing.formGap.h),
                            Text(
                              appName,
                              style: AppTextStyles.h2.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.onPrimary,
                              ),
                            ),
                            SizedBox(height: Spacing.xs.h),
                            Text(
                              '创建新账号',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.mutedDark,
                              ),
                            ),
                            SizedBox(height: Spacing.mid.h),

                            // 用户名
                            TextField(
                              controller: _usernameCtrl,
                              style: AppTextStyles.bodyMedium,
                              decoration: InputDecoration(
                                labelText: '用户名',
                                hintText: '3-32 个字符',
                                prefixIcon: Icon(AppIcons.person, size: 20.r),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
                                ),
                                filled: true,
                                fillColor: AppColors.background,
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            SizedBox(height: Spacing.gridGap.h),

                            // 昵称（可选）
                            TextField(
                              controller: _displayNameCtrl,
                              style: AppTextStyles.bodyMedium,
                              decoration: InputDecoration(
                                labelText: '显示名称（可选）',
                                prefixIcon: Icon(AppIcons.edit, size: 20.r),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
                                ),
                                filled: true,
                                fillColor: AppColors.background,
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            SizedBox(height: Spacing.gridGap.h),

                            // 密码
                            TextField(
                              controller: _passwordCtrl,
                              obscureText: true,
                              style: AppTextStyles.bodyMedium,
                              decoration: InputDecoration(
                                labelText: '密码',
                                hintText: '至少 6 位',
                                prefixIcon: Icon(AppIcons.lockOutline, size: 20.r),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
                                ),
                                filled: true,
                                fillColor: AppColors.background,
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            SizedBox(height: Spacing.gridGap.h),

                            // 确认密码
                            TextField(
                              controller: _confirmPwdCtrl,
                              obscureText: true,
                              style: AppTextStyles.bodyMedium,
                              decoration: InputDecoration(
                                labelText: '确认密码',
                                prefixIcon: Icon(AppIcons.lockOutline, size: 20.r),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
                                ),
                                filled: true,
                                fillColor: AppColors.background,
                              ),
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _register(),
                            ),

                            if (_error != null) ...[
                              SizedBox(height: Spacing.sm.h),
                              Text(
                                _error!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                            SizedBox(height: Spacing.mid.h),

                            // 注册按钮
                            SizedBox(
                              width: double.infinity,
                              height: Spacing.barHeight.h,
                              child: FilledButton(
                                onPressed: _loading ? null : _register,
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      RadiusTokens.lg.r,
                                    ),
                                  ),
                                ),
                                child: _loading
                                    ? SizedBox(
                                        width: Spacing.mid.w,
                                        height: Spacing.mid.h,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text('注册', style: AppTextStyles.labelLarge),
                              ),
                            ),
                            SizedBox(height: Spacing.md.h),

                            // 登录链接
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '已有账号?',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.mutedDark,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => context.go(Routes.login),
                                  child: Text(
                                    '登录',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
