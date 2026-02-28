import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/main.dart';
import 'package:anime_ui/pub/widgets/ai_chat_panel.dart';
import 'package:anime_ui/pub/providers/project.dart';
import 'package:anime_ui/pub/services/episode_svc.dart';
import 'package:anime_ui/pub/widgets/header.dart';
import 'package:anime_ui/pub/widgets/side_nav.dart';

/// 主布局 — 侧边栏导航、项目选择、仪表盘入口、AI 助手面板
class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({
    super.key,
    required this.child,
    required this.currentPath,
  });

  final Widget child;
  final String currentPath;

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  bool _restored = false;
  bool _showChat = false;
  String? _lastGateMessage;
  String? _lastAutoRedirectFromPath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreProject());
  }

  /// 恢复上次选中的项目
  Future<void> _restoreProject() async {
    if (_restored) return;
    _restored = true;

    final savedId = storageService.currentProjectId;
    if (savedId != null) {
      await ref.read(currentProjectProvider.notifier).load(savedId);
    }
  }

  String _currentObject() {
    if (widget.currentPath == Routes.dashboard ||
        widget.currentPath.startsWith('${Routes.dashboard}/')) {
      return '';
    }
    if (widget.currentPath == Routes.tasks ||
        widget.currentPath.startsWith('${Routes.tasks}/')) {
      return Routes.tasks;
    }
    for (final path in Routes.objectPaths) {
      if (widget.currentPath == path ||
          widget.currentPath.startsWith('$path/')) {
        return path;
      }
    }
    return '';
  }

  String? _objectFromPath(String path) {
    if (path == Routes.tasks || path.startsWith('${Routes.tasks}/')) {
      return Routes.tasks;
    }
    for (final objectPath in Routes.objectPaths) {
      if (path == objectPath || path.startsWith('$objectPath/')) {
        return objectPath;
      }
    }
    return null;
  }

  ({bool enabled, String? redirectRoute, String? message}) _objectGate(
      String objectPath) {
    return (enabled: true, redirectRoute: null, message: null);
  }

  void _onObjectTap(String objectPath) {
    final gate = _objectGate(objectPath);
    if (!gate.enabled) {
      if (gate.message != null && gate.message != _lastGateMessage) {
        _lastGateMessage = gate.message;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(gate.message!)),
        );
      }
      if (gate.redirectRoute != null) {
        context.go(gate.redirectRoute!);
      }
      return;
    }

    _lastGateMessage = null;

    if (objectPath == Routes.story) {
      _navigateStory();
      return;
    }

    final defaultRoute = Routes.objectDefaults[objectPath] ?? objectPath;
    context.go(defaultRoute);
  }

  /// 剧本入口：有集则进确认页，无集则进导入页
  Future<void> _navigateStory() async {
    final pid = ref.read(currentProjectProvider).value?.id;
    if (pid == null) {
      context.go(Routes.storyImport);
      return;
    }
    try {
      final episodes = await EpisodeService().list(pid);
      if (mounted) {
        context.go(episodes.isNotEmpty
            ? Routes.storyConfirm
            : Routes.storyImport);
      }
    } catch (_) {
      if (mounted) context.go(Routes.storyImport);
    }
  }

  void _enforceCurrentPathGate() {
    final path = widget.currentPath;
    final objectPath = _objectFromPath(path);
    if (objectPath == null) return;

    if (_lastAutoRedirectFromPath != null &&
        _lastAutoRedirectFromPath != path) {
      _lastAutoRedirectFromPath = null;
    }

    final gate = _objectGate(objectPath);
    if (gate.enabled) {
      _lastAutoRedirectFromPath = null;
      return;
    }

    final redirectRoute = gate.redirectRoute;
    if (redirectRoute == null || path == redirectRoute) return;
    if (_lastAutoRedirectFromPath == path) return;
    _lastAutoRedirectFromPath = path;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final livePath = GoRouterState.of(context).uri.path;
      if (livePath != path) return;
      if (gate.message != null && gate.message != _lastGateMessage) {
        _lastGateMessage = gate.message;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(gate.message!)),
        );
      }
      context.go(redirectRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    _enforceCurrentPathGate();
    final disabledObjects = <String>{};
    final disabledHints = <String, String>{};

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(),
      body: Stack(
        children: [
          Row(
            children: [
              SideNav(
                currentObject: _currentObject(),
                onObjectTap: _onObjectTap,
                disabledObjects: disabledObjects,
                disabledHints: disabledHints,
                onAiTap: () => setState(() => _showChat = !_showChat),
                aiActive: _showChat,
              ),
              Expanded(child: widget.child),
            ],
          ),
          if (_showChat)
            Positioned(
              left: 188,
              bottom: 16,
              child: AiChatPanel(
                onClose: () => setState(() => _showChat = false),
              ),
            ),
        ],
      ),
    );
  }
}
