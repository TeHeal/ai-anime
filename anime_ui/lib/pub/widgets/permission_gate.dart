import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/providers/permission_provider.dart';

/// 权限门控 Widget — 仅在用户拥有指定 Action 权限时显示子组件
///
/// 用法：
/// ```dart
/// PermissionGate(
///   action: Actions.scriptEdit,
///   child: FilledButton(onPressed: _save, child: Text('保存')),
/// )
/// ```
///
/// 多 Action（任一满足即显示）：
/// ```dart
/// PermissionGate(
///   actions: [Actions.shotImageGenerate, Actions.aiGenerate],
///   child: FilledButton(onPressed: _generate, child: Text('生成')),
/// )
/// ```
class PermissionGate extends ConsumerWidget {
  /// 单个 Action（与 actions 二选一）
  final String? action;

  /// 多个 Action（任一满足即显示）
  final List<String>? actions;

  /// 有权限时显示的子组件
  final Widget child;

  /// 无权限时的替代组件（默认不显示）
  final Widget? fallback;

  /// 无权限时是否禁用（而非隐藏），适用于按钮
  final bool disableInsteadOfHide;

  const PermissionGate({
    super.key,
    this.action,
    this.actions,
    required this.child,
    this.fallback,
    this.disableInsteadOfHide = false,
  }) : assert(action != null || actions != null);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permsAsync = ref.watch(projectPermissionsProvider);

    return permsAsync.when(
      data: (perms) {
        final allowed = action != null
            ? perms.can(action!)
            : perms.canAny(actions!);

        if (allowed) return child;

        if (disableInsteadOfHide) {
          return AbsorbPointer(
            child: Opacity(opacity: 0.4, child: child),
          );
        }

        return fallback ?? const SizedBox.shrink();
      },
      // 加载中：默认显示（避免闪烁）
      loading: () => child,
      // 出错：默认显示（向下兼容）
      error: (_, __) => child,
    );
  }
}
