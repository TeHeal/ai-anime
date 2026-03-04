import 'package:flutter/material.dart';
import 'package:anime_ui/pub/theme/colors.dart';

/// 工种角色常量（与后端 pub/auth/rbac.go 保持一致）
abstract final class JobRoles {
  static const String director = 'director';
  static const String storyboarder = 'storyboarder';
  static const String designer = 'designer';
  static const String keyAnimator = 'key_animator';
  static const String shotArtist = 'shot_artist';
  static const String post = 'post';
  static const String reviewer = 'reviewer';
  static const String admin = 'admin';

  /// 所有可选工种（不含 admin，admin 为平台级角色）
  static const List<String> assignable = [
    director,
    storyboarder,
    designer,
    keyAnimator,
    shotArtist,
    post,
    reviewer,
  ];

  /// 含 admin 的所有工种
  static const List<String> all = [
    director,
    storyboarder,
    designer,
    keyAnimator,
    shotArtist,
    post,
    reviewer,
    admin,
  ];

  static String label(String role) => switch (role) {
        director => '导演',
        storyboarder => '分镜师',
        designer => '设计师',
        keyAnimator => '原画师',
        shotArtist => '镜头师',
        post => '后期',
        reviewer => '审核',
        admin => '管理员',
        _ => role,
      };

  static Color color(String role) => switch (role) {
        director => AppColors.categoryCharacter,
        storyboarder => AppColors.categoryLocation,
        designer => AppColors.categoryStyle,
        keyAnimator => AppColors.categoryProp,
        shotArtist => AppColors.categoryVoice,
        post => AppColors.success,
        reviewer => AppColors.warning,
        admin => AppColors.error,
        _ => AppColors.muted,
      };
}
