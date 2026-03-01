import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/ai_action.dart';
import 'package:anime_ui/pub/models/episode.dart';
import 'package:anime_ui/pub/models/scene.dart';
import 'package:anime_ui/pub/models/scene_block.dart';
import 'package:anime_ui/pub/providers/project_provider.dart';
import 'package:anime_ui/pub/services/script_ai_svc.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/widgets/insert_handle.dart';
import 'package:anime_ui/module/script/block_item.dart';
import 'package:anime_ui/module/script/providers/script.dart';
import 'package:anime_ui/module/script/widgets/scene_editor_metadata.dart';
import 'package:anime_ui/module/script/widgets/scene_editor_nav_bar.dart';

/// 场景编辑器：场景元信息 + 内容块列表
class SceneEditor extends ConsumerStatefulWidget {
  const SceneEditor({super.key, this.readOnly = false});

  final bool readOnly;

  @override
  ConsumerState<SceneEditor> createState() => _SceneEditorState();
}

class _SceneEditorState extends ConsumerState<SceneEditor> {
  final _sceneIdCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _characterCtrl = TextEditingController();
  final _blockKeys = <String, GlobalKey<BlockItemState>>{};
  final _scriptAiSvc = ScriptAiService();
  int _blockKeyCounter = 0;

  String _time = '';
  String _ie = '';
  List<String> _characters = [];
  List<SceneBlock> _blocks = [];

  String? _boundSceneDbId;
  bool _saving = false;
  bool _dirty = false;
  Timer? _autoSaveTimer;

  _SaveStatus _saveStatus = _SaveStatus.clean;

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _sceneIdCtrl.dispose();
    _locationCtrl.dispose();
    _characterCtrl.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (widget.readOnly) return;
    _dirty = true;
    _saveStatus = _SaveStatus.unsaved;
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 3), () {
      if (_dirty && mounted) _save(auto: true);
    });
  }

  void _bindScene(Scene scene) {
    if (_boundSceneDbId == scene.id) return;
    _boundSceneDbId = scene.id;

    _sceneIdCtrl.text = scene.sceneId;
    _locationCtrl.text = scene.location;
    _time = scene.time;
    _ie = scene.interiorExterior;
    _characters = List<String>.from(scene.characters);
    _blocks = scene.blocks.isEmpty
        ? [const SceneBlock(type: 'action', sortIndex: 0)]
        : List<SceneBlock>.from(scene.blocks);
    _dirty = false;
    _saveStatus = _SaveStatus.clean;
    _blockKeys.clear();
    _blockStableIds = List.generate(_blocks.length, (_) => _nextBlockKey());
  }

  List<String> _blockStableIds = [];

  String _nextBlockKey() => 'bk_${_blockKeyCounter++}';

  GlobalKey<BlockItemState> _keyForBlock(String stableId) {
    return _blockKeys.putIfAbsent(stableId, () => GlobalKey<BlockItemState>());
  }

  void _addBlock() => _insertBlockAt(_blocks.length);

  void _insertBlockAt(int index) {
    setState(() {
      _blocks.insert(index, SceneBlock(type: 'action', sortIndex: index));
      _blockStableIds.insert(index, _nextBlockKey());
      for (var i = 0; i < _blocks.length; i++) {
        _blocks[i] = _blocks[i].copyWith(sortIndex: i);
      }
    });
    _markDirty();
  }

  void _removeBlock(int index) {
    setState(() {
      final removedId = _blockStableIds.removeAt(index);
      _blockKeys.remove(removedId);
      _blocks.removeAt(index);
      for (var i = 0; i < _blocks.length; i++) {
        _blocks[i] = _blocks[i].copyWith(sortIndex: i);
      }
    });
    _markDirty();
  }

  void _updateBlock(int index, SceneBlock updated) {
    setState(() {
      _blocks[index] = updated.copyWith(sortIndex: index);
    });
    _markDirty();
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _blocks.removeAt(oldIndex);
      _blocks.insert(newIndex, item);
      final sid = _blockStableIds.removeAt(oldIndex);
      _blockStableIds.insert(newIndex, sid);
      for (var i = 0; i < _blocks.length; i++) {
        _blocks[i] = _blocks[i].copyWith(sortIndex: i);
      }
    });
    _markDirty();
  }

  void _addCharacter() {
    final text = _characterCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      if (!_characters.contains(text)) _characters.add(text);
      _characterCtrl.clear();
    });
    _markDirty();
  }

  void _removeCharacter(String name) {
    setState(() => _characters.remove(name));
    _markDirty();
  }

  Future<void> _save({bool auto = false}) async {
    final sel = ref.read(scriptSelectionProvider);
    if (sel.episodeId == null || sel.sceneId == null) return;

    _autoSaveTimer?.cancel();
    setState(() {
      _saving = true;
      _saveStatus = _SaveStatus.saving;
    });
    try {
      final notifier = ref.read(scenesProvider.notifier);
      await notifier.update(
        sel.episodeId!,
        sel.sceneId!,
        sceneId: _sceneIdCtrl.text,
        location: _locationCtrl.text,
        time: _time,
        interiorExterior: _ie,
        characters: _characters,
      );
      await notifier.saveBlocks(sel.episodeId!, sel.sceneId!, _blocks);
      _dirty = false;
      if (mounted) {
        setState(() => _saveStatus = _SaveStatus.saved);
        if (!auto) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('保存成功'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saveStatus = _SaveStatus.error);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存失败: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  ({Episode? episode, Scene? scene, int sceneIndex, List<Scene> allScenes})
  _currentNavInfo() {
    final sel = ref.read(scriptSelectionProvider);
    final episodes = ref.read(episodesProvider).value ?? [];
    final ep = episodes.where((e) => e.id == sel.episodeId).firstOrNull;
    if (ep == null) {
      return (episode: null, scene: null, sceneIndex: -1, allScenes: []);
    }
    final allScenes = ep.scenes;
    final idx = allScenes.indexWhere((s) => s.id == sel.sceneId);
    final sc = idx >= 0 ? allScenes[idx] : null;
    return (episode: ep, scene: sc, sceneIndex: idx, allScenes: allScenes);
  }

  Future<void> _navigateScene(int direction) async {
    if (_dirty) await _save(auto: true);

    final episodes = ref.read(episodesProvider).value ?? [];
    final sel = ref.read(scriptSelectionProvider);
    final epIdx = episodes.indexWhere((e) => e.id == sel.episodeId);
    if (epIdx < 0) return;

    final ep = episodes[epIdx];
    final scIdx = ep.scenes.indexWhere((s) => s.id == sel.sceneId);
    final newIdx = scIdx + direction;

    if (newIdx >= 0 && newIdx < ep.scenes.length) {
      _boundSceneDbId = null;
      final target = ep.scenes[newIdx];
      ref
          .read(scriptSelectionProvider.notifier)
          .selectScene(ep.id!, target.id!);
      await ref.read(scenesProvider.notifier).loadForEpisode(ep.id!);
    } else if (direction < 0 && epIdx > 0) {
      final prevEp = episodes[epIdx - 1];
      if (prevEp.scenes.isNotEmpty) {
        _boundSceneDbId = null;
        final target = prevEp.scenes.last;
        ref
            .read(scriptSelectionProvider.notifier)
            .selectScene(prevEp.id!, target.id!);
        await ref.read(scenesProvider.notifier).loadForEpisode(prevEp.id!);
      }
    } else if (direction > 0 && epIdx < episodes.length - 1) {
      final nextEp = episodes[epIdx + 1];
      if (nextEp.scenes.isNotEmpty) {
        _boundSceneDbId = null;
        final target = nextEp.scenes.first;
        ref
            .read(scriptSelectionProvider.notifier)
            .selectScene(nextEp.id!, target.id!);
        await ref.read(scenesProvider.notifier).loadForEpisode(nextEp.id!);
      }
    }
  }

  void _onAiAction(AiAction action, int blockIndex) {
    final block = _blocks[blockIndex];
    if (block.content.trim().isEmpty && action != AiAction.continueWrite) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('当前块内容为空，请先输入内容')));
      return;
    }

    final contextBlocks = <String>[];
    for (
      var i = (blockIndex - 3).clamp(0, _blocks.length);
      i < (blockIndex + 2).clamp(0, _blocks.length);
      i++
    ) {
      if (i == blockIndex) continue;
      final b = _blocks[i];
      contextBlocks.add('[${b.type}] ${b.content}');
    }

    final sceneMeta =
        '地点: ${_locationCtrl.text}, '
        '时间: $_time, 内外: $_ie, '
        '角色: ${_characters.join("、")}';

    final pid = ref.read(currentProjectProvider).value?.id;
    if (pid == null) return;

    final stream = _scriptAiSvc.assistBlock(
      action: action.name,
      blockType: block.type,
      blockContent: block.content,
      sceneMeta: sceneMeta,
      contextBlocks: contextBlocks,
      projectId: pid,
    );

    final stableId = _blockStableIds[blockIndex];
    final key = _keyForBlock(stableId);
    key.currentState?.startAiStream(stream);
  }

  @override
  Widget build(BuildContext context) {
    final sel = ref.watch(scriptSelectionProvider);
    final scenesState = ref.watch(scenesProvider);

    if (sel.episodeId == null || sel.sceneId == null) {
      return Center(
        child: Text(
          '请从左侧选择一场进行编辑',
          style: AppTextStyles.bodyXLarge.copyWith(
            color: AppColors.mutedDarkest,
          ),
        ),
      );
    }

    return scenesState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          '加载失败: $e',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
        ),
      ),
      data: (scenes) {
        final scene = scenes.where((s) => s.id == sel.sceneId).firstOrNull;
        if (scene == null) {
          return Center(
            child: Text(
              '场景不存在',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mutedDarkest,
              ),
            ),
          );
        }
        _bindScene(scene);
        return _buildEditor();
      },
    );
  }

  bool _hasPrevScene() {
    final nav = _currentNavInfo();
    if (nav.episode == null || nav.sceneIndex < 0) return false;
    final episodes = ref.read(episodesProvider).value ?? [];
    final epIdx = episodes.indexWhere((e) => e.id == nav.episode!.id);
    if (epIdx < 0) return false;
    if (nav.sceneIndex > 0) return true;
    if (epIdx > 0 && episodes[epIdx - 1].scenes.isNotEmpty) return true;
    return false;
  }

  bool _hasNextScene() {
    final nav = _currentNavInfo();
    if (nav.episode == null || nav.sceneIndex < 0) return false;
    final episodes = ref.read(episodesProvider).value ?? [];
    final epIdx = episodes.indexWhere((e) => e.id == nav.episode!.id);
    if (epIdx < 0) return false;
    if (nav.sceneIndex < nav.allScenes.length - 1) return true;
    if (epIdx < episodes.length - 1 && episodes[epIdx + 1].scenes.isNotEmpty) {
      return true;
    }
    return false;
  }

  Widget _buildEditor() {
    final nav = _currentNavInfo();
    return Column(
      children: [
        SceneEditorNavBar(
          episode: nav.episode,
          scene: nav.scene,
          hasPrev: _hasPrevScene(),
          hasNext: _hasNextScene(),
          onNavigatePrev: () => _navigateScene(-1),
          onNavigateNext: () => _navigateScene(1),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Spacing.mid),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SceneEditorMetadata(
                  sceneIdCtrl: _sceneIdCtrl,
                  locationCtrl: _locationCtrl,
                  time: _time,
                  ie: _ie,
                  characters: _characters,
                  characterCtrl: _characterCtrl,
                  onTimeChanged: (v) => setState(() => _time = v),
                  onIeChanged: (v) => setState(() => _ie = v),
                  onAddCharacter: _addCharacter,
                  onRemoveCharacter: _removeCharacter,
                  onMarkDirty: _markDirty,
                ),
                const SizedBox(height: Spacing.xl),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.divider.withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.mid),
                _buildBlocksSection(),
              ],
            ),
          ),
        ),
        _buildActionBar(),
      ],
    );
  }

  Widget _buildBlocksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Text(
              '内容块',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm, vertical: Spacing.xxs),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
              ),
              child: Text(
                '${_blocks.length}',
                style: AppTextStyles.tiny.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.lg),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: _blocks.length,
          onReorder: _onReorder,
          proxyDecorator: (child, index, animation) {
            return Material(
              color: Colors.transparent,
              elevation: 8,
              shadowColor: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
              child: child,
            );
          },
          itemBuilder: (context, index) {
            final block = _blocks[index];
            final stableId = _blockStableIds[index];
            return Column(
              key: ValueKey('block_col_$stableId'),
              mainAxisSize: MainAxisSize.min,
              children: [
                InsertHandle(onInsert: () => _insertBlockAt(index)),
                BlockItem(
                  key: _keyForBlock(stableId),
                  block: block,
                  index: index,
                  onChanged: (updated) => _updateBlock(index, updated),
                  onDelete: () => _removeBlock(index),
                  onAiAction: _onAiAction,
                ),
              ],
            );
          },
        ),
        InsertHandle(onInsert: _addBlock),
      ],
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: Spacing.mid, vertical: Spacing.sm),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.inputBorder)),
      ),
      child: Row(
        children: [
          _buildSaveStatusIndicator(),
          const Spacer(),
          FilledButton.icon(
            onPressed: (_saving || widget.readOnly) ? null : () => _save(),
            icon: _saving
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onPrimary,
                    ),
                  )
                : Icon(AppIcons.save, size: 15.r),
            label: Text(_saving ? '保存中…' : '保存'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.cardPadding, vertical: Spacing.sm),
              textStyle: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildSaveStatusIndicator() {
    IconData icon;
    String text;
    Color color;
    switch (_saveStatus) {
      case _SaveStatus.clean:
      case _SaveStatus.saved:
        icon = AppIcons.checkCircleOutline;
        text = '已保存';
        color = AppColors.success;
      case _SaveStatus.unsaved:
        icon = AppIcons.circleOutline;
        text = '未保存';
        color = AppColors.tagAmber;
      case _SaveStatus.saving:
        icon = AppIcons.sync;
        text = '自动保存中…';
        color = AppColors.info;
      case _SaveStatus.error:
        icon = AppIcons.errorOutline;
        text = '保存失败';
        color = AppColors.error;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.r, color: color),
        const SizedBox(width: Spacing.sm),
        Text(text, style: AppTextStyles.caption.copyWith(color: color)),
      ],
    );
  }
}

enum _SaveStatus { clean, unsaved, saving, saved, error }
