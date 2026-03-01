import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';


/// SharedAxis 页面过渡（用于对象内 Tab 切换、层级导航）
CustomTransitionPage<T> sharedAxisPage<T>({
  required Widget child,
  required GoRouterState state,
  SharedAxisTransitionType type = SharedAxisTransitionType.horizontal,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: type,
        fillColor: AppColors.background,
        child: child,
      );
    },
  );
}
