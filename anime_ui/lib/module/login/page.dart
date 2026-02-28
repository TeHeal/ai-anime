import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/const/app_const.dart';
import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/widgets/glow_card.dart';
import 'package:anime_ui/pub/widgets/starfield_background.dart';
import 'package:anime_ui/main.dart';
import 'package:anime_ui/pub/services/api.dart';
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
      await storageService.setToken(result.token);
      if (mounted) context.go(Routes.projects);
    } on DioException catch (e) {
      setState(
        () => _error =
            e.response?.data?['message'] as String? ?? '网络错误，请稍后重试',
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
            child: SingleChildScrollView(
              child: SizedBox(
                width: 420,
                height: 420,
                child: GlowCard(
                  glowColor: AppColors.primary,
                  glowIntensity: 0.1,
                  hoverGlowIntensity: 0.25,
                  hoverElevation: 0,
                  showTopAccent: true,
                  topAccentHeight: 3,
                  padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        AppIcons.movieFilter,
                        size: 44,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        appName,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '登录以继续',
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _usernameCtrl,
                        decoration: InputDecoration(
                          labelText: '用户名',
                          prefixIcon: const Icon(AppIcons.person, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: AppColors.background,
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _passwordCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: '密码',
                          prefixIcon: const Icon(
                            AppIcons.lockOutline,
                            size: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: AppColors.background,
                        ),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _login(),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _error!,
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: FilledButton(
                          onPressed: _loading ? null : _login,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  '登录',
                                  style: TextStyle(fontSize: 15),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
