import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/episode.dart';
import 'package:anime_ui/pub/providers/lock_provider.dart';
import 'package:anime_ui/pub/providers/project_provider.dart';
import 'package:anime_ui/module/script/providers/script.dart';
import 'package:anime_ui/module/script/scene_editor.dart';
import 'package:anime_ui/module/script/tree_nav.dart';

/// 剧本编辑页 — 集/场/块结构化编辑
class StoryEditPage extends ConsumerStatefulWidget {
  const StoryEditPage({super.key});

  @override
  ConsumerState<StoryEditPage> createState() => _StoryEditPageState();
}

class _StoryEditPageState extends ConsumerState<StoryEditPage> {
  bool _loaded = false;
  final _loadedEpisodeScenes = <String>{};

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

  Future<void> _onSceneSelected(String episodeId, String sceneDbId) async {
    final episodes = ref.read(episodesProvider).value ?? [];
    final ep = episodes.where((e) => e.id == episodeId).firstOrNull;
    if (ep != null && ep.scenes.isNotEmpty) {
      ref.read(scenesProvider.notifier).setScenes(ep.scenes);
    } else if (!_loadedEpisodeScenes.contains(episodeId)) {
      _loadedEpisodeScenes.add(episodeId);
      await ref.read(scenesProvider.notifier).loadForEpisode(episodeId);
    }
    ref
        .read(scriptSelectionProvider.notifier)
        .selectScene(episodeId, sceneDbId);
  }

  Future<void> _onAddEpisode() async {
    try {
      final episodes = ref.read(episodesProvider).value ?? [];
      final title = '第${episodes.length + 1}集';
      final ep = await ref.read(episodesProvider.notifier).add(title);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('已添加: ${ep.title}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('添加失败: $e')));
      }
    }
  }

  Future<void> _onAddScene(String episodeId, {int? afterIndex}) async {
    try {
      final episodes = ref.read(episodesProvider).value ?? [];
      final ep = episodes.where((e) => e.id == episodeId).firstOrNull;
      final epIdx = ep != null ? (ep.sortIndex + 1) : 1;
      final sortIndex = afterIndex == null ? 0 : afterIndex + 1;
      final sceneId = '$epIdx-${sortIndex + 1}';

      if (ep != null && ep.scenes.isNotEmpty) {
        ref.read(scenesProvider.notifier).setScenes(ep.scenes);
      } else if (!_loadedEpisodeScenes.contains(episodeId)) {
        _loadedEpisodeScenes.add(episodeId);
        await ref.read(scenesProvider.notifier).loadForEpisode(episodeId);
      }

      final scene = await ref.read(scenesProvider.notifier).add(
            episodeId,
            sceneId: sceneId,
            sortIndex: sortIndex,
          );

      await ref.read(episodesProvider.notifier).load();
      ref
          .read(scriptSelectionProvider.notifier)
          .selectScene(episodeId, scene.id!);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('已添加场景: $sceneId')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('添加场景失败: $e')));
      }
    }
  }

  Future<void> _onDeleteEpisode(String episodeId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text(
          '确认删除',
          style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
        ),
        content: Text(
          '删除后不可恢复，确定要删除此集？',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.mutedDarkest,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('已删除')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('删除失败: $e')));
      }
    }
  }

  Future<void> _onDeleteScene(String episodeId, String sceneDbId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text(
          '确认删除',
          style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
        ),
        content: Text(
          '删除后不可恢复，确定要删除此场景？',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.onSurface.withValues(alpha: 0.6),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('已删除场景')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('删除场景失败: $e')));
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

    // 首次加载后自动选中第一个场景
    ref.listen(episodesProvider, (prev, next) {
      next.whenData((episodes) {
        if (episodes.isEmpty) return;
        final sel = ref.read(scriptSelectionProvider);
        if (sel.sceneId != null) return;
        for (final ep in episodes) {
          if (ep.scenes.isNotEmpty) {
            ref.read(scenesProvider.notifier).setScenes(ep.scenes);
            ref
                .read(scriptSelectionProvider.notifier)
                .selectScene(ep.id!, ep.scenes.first.id!);
            break;
          }
        }
      });
    });

    return Column(
      children: [
        Expanded(
          child: episodesState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '加载失败',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.error.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
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
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        AppIcons.document,
                        size: 64.r,
                        color: AppColors.onSurface.withValues(alpha: 0.4),
                      ),
                      SizedBox(height: Spacing.lg.h),
                      Text(
                        '暂无集数据',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      SizedBox(height: Spacing.sm.h),
                      Text(
                        '请先在「导入」页面导入剧本',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return _buildEditor(episodes, selection);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEditor(
    List<Episode> episodes,
    ({String? episodeId, String? sceneId}) scriptSelection,
  ) {
    final isLocked = ref.watch(lockProvider).storyLocked;

    return Column(
      children: [
        if (isLocked)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.lg.w,
              vertical: Spacing.sm.h,
            ),
            color: AppColors.success.withValues(alpha: 0.08),
            child: Row(
              children: [
                Icon(
                  AppIcons.lock,
                  size: 14.r,
                  color: AppColors.success.withValues(alpha: 0.7),
                ),
                SizedBox(width: Spacing.sm.w),
                Text(
                  '剧本已锁定 — 只读模式',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.success.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: Row(
            children: [
              ScriptTreeNav(
                episodes: episodes,
                selectedEpisodeId: scriptSelection.episodeId,
                selectedSceneId: scriptSelection.sceneId,
                onSceneSelected: _onSceneSelected,
                onAddEpisode: isLocked ? null : _onAddEpisode,
                onAddScene: isLocked ? null : _onAddScene,
                onDeleteEpisode: isLocked ? null : _onDeleteEpisode,
                onDeleteScene: isLocked ? null : _onDeleteScene,
              ),
              VerticalDivider(
                width: 1.w,
                thickness: 1,
                color: AppColors.divider,
              ),
              Expanded(child: SceneEditor(readOnly: isLocked)),
            ],
          ),
        ),
      ],
    );
  }
}
