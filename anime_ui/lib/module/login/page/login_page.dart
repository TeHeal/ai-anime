import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/const/app_const.dart';
import 'package:anime_ui/pub/const/breakpoints.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/glow_card.dart';
import 'package:anime_ui/pub/widgets/starfield_background.dart';
import 'package:anime_ui/pub/providers/auth_provider.dart';
import 'package:anime_ui/pub/providers/storage_provider.dart';
import 'package:anime_ui/pub/services/api_svc.dart';
import 'package:anime_ui/pub/services/auth_svc.dart';

/// 登录页 — 用户名密码表单、Token 存储、登录后跳转项目列表
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = '请输入用户名和密码');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await AuthService().login(username, password);
      setAuthToken(result.token);
      if (!mounted) return;
      final container = ProviderScope.containerOf(context);
      await container.read(storageServiceProvider).setToken(result.token);
      // 拉取当前用户信息，供 UserMenu 等组件显示真实用户名
      await container.read(authProvider.notifier).fetchCurrentUser();
      if (mounted) context.go(Routes.projects);
    } on DioException catch (e) {
      setState(
        () => _error = e.response?.data?['message'] as String? ?? '网络错误，请稍后重试',
      );
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = '登录失败: $e');
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
                // 小屏：占满宽度减边距，使用 Spacing 常量避免硬编码
                final cardW = (screenW - Spacing.xl.w * 2).clamp(
                  Spacing.loginCardMinWidth,
                  Spacing.loginCardMaxWidth,
                );
                final cardH = (screenH - Spacing.xl.h * 2).clamp(
                  Spacing.loginCardMinHeight,
                  Spacing.loginCardMaxHeight,
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
                              AppIcons.movieFilter,
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
                              '登录以继续',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.mutedDark,
                              ),
                            ),
                            SizedBox(height: Spacing.xl.h),
                            TextField(
                              controller: _usernameCtrl,
                              style: AppTextStyles.bodyMedium,
                              decoration: InputDecoration(
                                labelText: '用户名',
                                prefixIcon: Icon(AppIcons.person, size: 20.r),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    RadiusTokens.lg.r,
                                  ),
                                ),
                                filled: true,
                                fillColor: AppColors.background,
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            SizedBox(height: Spacing.gridGap.h),
                            TextField(
                              controller: _passwordCtrl,
                              obscureText: true,
                              style: AppTextStyles.bodyMedium,
                              decoration: InputDecoration(
                                labelText: '密码',
                                prefixIcon: Icon(
                                  AppIcons.lockOutline,
                                  size: 20.r,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    RadiusTokens.lg.r,
                                  ),
                                ),
                                filled: true,
                                fillColor: AppColors.background,
                              ),
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _login(),
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
                            SizedBox(
                              width: double.infinity,
                              height: Spacing.barHeight.h,
                              child: FilledButton(
                                onPressed: _loading ? null : _login,
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
                                    : Text(
                                        '登录',
                                        style: AppTextStyles.labelLarge,
                                      ),
                              ),
                            ),
                            SizedBox(height: Spacing.md.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '没有账号?',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.mutedDark,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => context.go(Routes.register),
                                  child: Text(
                                    '注册',
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
