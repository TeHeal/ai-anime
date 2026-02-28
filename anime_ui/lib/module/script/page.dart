import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/models/episode.dart';
import 'package:anime_ui/pub/providers/project.dart';
import 'package:anime_ui/module/script/provider.dart';
import 'package:anime_ui/module/script/scene_editor.dart';
import 'package:anime_ui/module/script/tree_nav.dart';

/// 剧本结构主页面：集-场树形导航 + 场景编辑器
/// 无集时显示草稿预览占位
class ScriptStructurePage extends ConsumerStatefulWidget {
  const ScriptStructurePage({super.key});

  @override
  ConsumerState<ScriptStructurePage> createState() =>
      _ScriptStructurePageState();
}

class _ScriptStructurePageState extends ConsumerState<ScriptStructurePage> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadEpisodes());
  }

  Future<void> _loadEpisodes() async {
    if (_loaded) return;
    final pid = ref.read(currentProjectProvider).value?.id;
    if (pid == null) return;
    _loaded = true;
    await ref.read(episodesProvider.notifier).load();
  }

  final _loadedEpisodeScenes = <String>{};

  Future<void> _onSceneSelected(String episodeId, String sceneDbId) async {
    if (!_loadedEpisodeScenes.contains(episodeId)) {
      _loadedEpisodeScenes.add(episodeId);
      await ref.read(scenesProvider.notifier).loadForEpisode(episodeId);
    }
    ref.read(scriptSelectionProvider.notifier).selectScene(episodeId, sceneDbId);
  }

  Future<void> _onAddEpisode() async {
    try {
      final episodes = ref.read(episodesProvider).value ?? [];
      final title = '第${episodes.length + 1}集';
      final ep = await ref.read(episodesProvider.notifier).add(title);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已添加: ${ep.title}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('添加失败: $e')),
        );
      }
    }
  }

  Future<void> _onAddScene(String episodeId) async {
    try {
      final episodes = ref.read(episodesProvider).value ?? [];
      final ep = episodes.where((e) => e.id == episodeId).firstOrNull;
      final epIdx = ep != null ? (ep.sortIndex + 1) : 1;
      final sceneCount = ep?.scenes.length ?? 0;
      final sceneId = '$epIdx-${sceneCount + 1}';

      if (!_loadedEpisodeScenes.contains(episodeId)) {
        _loadedEpisodeScenes.add(episodeId);
        await ref.read(scenesProvider.notifier).loadForEpisode(episodeId);
      }

      final scene = await ref
          .read(scenesProvider.notifier)
          .add(episodeId, sceneId: sceneId);

      await ref.read(episodesProvider.notifier).load();

      ref
          .read(scriptSelectionProvider.notifier)
          .selectScene(episodeId, scene.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已添加场景: $sceneId')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('添加场景失败: $e')),
        );
      }
    }
  }

  Future<void> _onDeleteEpisode(String episodeId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Text('确认删除', style: TextStyle(color: Color(0xFFE4E4E7))),
        content: const Text(
          '删除后不可恢复，确定要删除此集？',
          style: TextStyle(color: Color(0xFF9CA3AF)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final sel = ref.read(scriptSelectionProvider);
      if (sel.episodeId == episodeId) {
        ref.read(scriptSelectionProvider.notifier).clear();
      }
      await ref.read(episodesProvider.notifier).remove(episodeId);
      _loadedEpisodeScenes.remove(episodeId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已删除')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败: $e')),
        );
      }
    }
  }

  Future<void> _onDeleteScene(String episodeId, String sceneDbId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Text('确认删除', style: TextStyle(color: Color(0xFFE4E4E7))),
        content: const Text(
          '删除后不可恢复，确定要删除此场景？',
          style: TextStyle(color: Color(0xFF9CA3AF)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final sel = ref.read(scriptSelectionProvider);
      if (sel.sceneId == sceneDbId) {
        ref.read(scriptSelectionProvider.notifier).clear();
      }
      await ref.read(scenesProvider.notifier).remove(episodeId, sceneDbId);
      await ref.read(episodesProvider.notifier).load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已删除场景')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除场景失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final episodesState = ref.watch(episodesProvider);
    final selection = ref.watch(scriptSelectionProvider);

    ref.listen(currentProjectProvider, (prev, next) {
      if (prev?.value?.id == null && next.value?.id != null) {
        _loaded = false;
        _loadEpisodes();
      }
    });

    return episodesState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('加载失败', style: TextStyle(color: Colors.red[300])),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                _loaded = false;
                _loadEpisodes();
              },
              child: const Text('重试'),
            ),
          ],
        ),
      ),
      data: (episodes) {
        if (episodes.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.folder_open, size: 48, color: Color(0xFF6B7280)),
                SizedBox(height: 16),
                Text(
                  '暂无集数，请先在剧本页创建',
                  style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
                ),
              ],
            ),
          );
        }
        return _buildEditor(episodes, selection);
      },
    );
  }

  Widget _buildEditor(
    List<Episode> episodes,
    ({String? episodeId, String? sceneId}) scriptSelection,
  ) {
    return Row(
      children: [
        ScriptTreeNav(
          episodes: episodes,
          selectedEpisodeId: scriptSelection.episodeId,
          selectedSceneId: scriptSelection.sceneId,
          onSceneSelected: _onSceneSelected,
          onAddEpisode: _onAddEpisode,
          onAddScene: _onAddScene,
          onDeleteEpisode: _onDeleteEpisode,
          onDeleteScene: _onDeleteScene,
        ),
        const VerticalDivider(
          width: 1, thickness: 1, color: Color(0xFF2A2A3C),
        ),
        const Expanded(child: SceneEditor()),
      ],
    );
  }
}
