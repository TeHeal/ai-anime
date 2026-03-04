import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anime_ui/pub/services/api_svc.dart';
import 'package:anime_ui/pub/providers/project_provider.dart';

/// 项目权限数据
class ProjectPermissions {
  final String effectiveRole;
  final List<String> jobRoles;
  final Set<String> allowedActions;
  final bool isOwner;
  final bool isAdmin;

  const ProjectPermissions({
    this.effectiveRole = 'viewer',
    this.jobRoles = const [],
    this.allowedActions = const {},
    this.isOwner = false,
    this.isAdmin = false,
  });

  /// 检查是否有权执行指定 Action
  bool can(String action) => isAdmin || isOwner || allowedActions.contains(action);

  /// 批量检查：任一 action 满足即可
  bool canAny(List<String> actions) => actions.any(can);

  factory ProjectPermissions.fromJson(Map<String, dynamic> json) {
    final actions = (json['allowedActions'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toSet() ??
        {};
    return ProjectPermissions(
      effectiveRole: json['effectiveRole'] as String? ?? 'viewer',
      jobRoles: (json['jobRoles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      allowedActions: actions,
      isOwner: json['isOwner'] as bool? ?? false,
      isAdmin: json['isAdmin'] as bool? ?? false,
    );
  }

  /// 未加载时的默认值（owner 全权限，保持向下兼容）
  static const fallbackOwner = ProjectPermissions(
    effectiveRole: 'owner',
    isOwner: true,
    allowedActions: {},
  );
}

/// 当前项目的权限 Provider（依赖 currentProjectProvider 自动跟随切换）
final projectPermissionsProvider =
    FutureProvider.autoDispose<ProjectPermissions>((ref) async {
  final projectAsync = ref.watch(currentProjectProvider);
  final project = projectAsync.value;
  if (project == null) return const ProjectPermissions();

  try {
    final resp = await dio.get('/projects/${project.id}/my-permissions');
    final data = extractData<Map<String, dynamic>>(resp);
    return ProjectPermissions.fromJson(data);
  } catch (_) {
    // 接口不可用时回退为 owner（向下兼容单人模式）
    return ProjectPermissions.fallbackOwner;
  }
});
