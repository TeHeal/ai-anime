import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/providers/auth_provider.dart';

/// Shows [child] only if the current user's effective role meets or exceeds
/// [requiredRole]. Otherwise shows [fallback] (defaults to nothing).
///
/// Role hierarchy (highest → lowest): owner > director > editor > viewer
class PermissionGate extends ConsumerWidget {
  final String requiredRole;
  final Widget child;
  final Widget? fallback;

  const PermissionGate({
    super.key,
    required this.requiredRole,
    required this.child,
    this.fallback,
  });

  static const _roleRank = <String, int>{
    'owner': 4,
    'director': 3,
    'editor': 2,
    'viewer': 1,
  };

  static bool hasPermission(String userRole, String requiredRole) {
    final userRank = _roleRank[userRole] ?? 0;
    final requiredRank = _roleRank[requiredRole] ?? 0;
    return userRank >= requiredRank;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final userRole = auth.user?.role ?? 'viewer';

    if (hasPermission(userRole, requiredRole)) {
      return child;
    }
    return fallback ?? const SizedBox.shrink();
  }
}
