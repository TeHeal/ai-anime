import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/models/ai_action.dart';
import 'package:anime_ui/pub/models/episode.dart';
import 'package:anime_ui/pub/models/scene.dart';
import 'package:anime_ui/pub/models/scene_block.dart';
import 'package:anime_ui/pub/providers/project_provider.dart';
import 'package:anime_ui/pub/services/script_ai_svc.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/insert_handle.dart';
import 'package:anime_ui/module/script/block_item.dart';
import 'package:anime_ui/module/script/provider.dart';
import 'package:anime_ui/module/script/scene_action_bar.dart';
import 'package:anime_ui/module/script/scene_metadata_section.dart';

const _timeOptions = ['日', '夜', '黄昏', '凌晨'];
const _ieOptions = ['内', '外'];

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

  int? _boundSceneDbId;
  bool _saving = false;
  bool _dirty = false;
  Timer? _autoSaveTimer;

  SaveStatus _saveStatus = SaveStatus.clean;

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
    _saveStatus = SaveStatus.unsaved;
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
    _saveStatus = SaveStatus.clean;
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
      _saveStatus = SaveStatus.saving;
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
        setState(() => _saveStatus = SaveStatus.saved);
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
        setState(() => _saveStatus = SaveStatus.error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('当前块内容为空，请先输入内容')),
      );
      return;
    }

    final contextBlocks = <String>[];
    for (var i = (blockIndex - 3).clamp(0, _blocks.length);
        i < (blockIndex + 2).clamp(0, _blocks.length);
        i++) {
      if (i == blockIndex) continue;
      final b = _blocks[i];
      contextBlocks.add('[${b.type}] ${b.content}');
    }

    final sceneMeta = '地点: ${_locationCtrl.text}, '
        '时间: $_time, 内外: $_ie, '
        '角色: ${_characters.join("、")}';

    final pid = ref.read(currentProjectProvider).value?.id ?? 0;

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
      return const Center(
        child: Text(
          '请从左侧选择一场进行编辑',
          style: TextStyle(color: Color(0xFF6B7280), fontSize: 15),
        ),
      );
    }

    return scenesState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          '加载失败: $e',
          style: const TextStyle(color: Color(0xFFEF4444)),
        ),
      ),
      data: (scenes) {
        final scene = scenes.where((s) => s.id == sel.sceneId).firstOrNull;
        if (scene == null) {
          return const Center(
            child: Text(
              '场景不存在',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          );
        }
        _bindScene(scene);
        return _buildEditor();
      },
    );
  }

  Widget _buildEditor() {
    return Column(
      children: [
        _buildSceneNavBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SceneMetadataSection(
                  sceneIdCtrl: _sceneIdCtrl,
                  locationCtrl: _locationCtrl,
                  characterCtrl: _characterCtrl,
                  time: _time,
                  ie: _ie,
                  characters: _characters,
                  timeOptions: _timeOptions,
                  ieOptions: _ieOptions,
                  onTimeChanged: (v) {
                    setState(() => _time = v);
                    _markDirty();
                  },
                  onIeChanged: (v) {
                    setState(() => _ie = v);
                    _markDirty();
                  },
                  onAddCharacter: _addCharacter,
                  onRemoveCharacter: _removeCharacter,
                  onFieldChanged: _markDirty,
                ),
                const SizedBox(height: 24),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        const Color(0xFF2A2A3C).withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildBlocksSection(),
              ],
            ),
          ),
        ),
        SceneActionBar(
          saveStatus: _saveStatus,
          saving: _saving,
          readOnly: widget.readOnly,
          onSave: () => _save(),
        ),
      ],
    );
  }

  Widget _buildSceneNavBar() {
    final nav = _currentNavInfo();
    final epTitle = nav.episode?.title ?? '';
    final scLabel = nav.scene != null
        ? '${nav.scene!.sceneId} ${nav.scene!.location}'.trim()
        : '';
    final hasPrev = nav.sceneIndex > 0 ||
        (ref.read(episodesProvider).value ?? [])
                .indexWhere((e) => e.id == nav.episode?.id) >
            0;
    final hasNext = nav.sceneIndex < nav.allScenes.length - 1 ||
        (ref.read(episodesProvider).value ?? [])
                .indexWhere((e) => e.id == nav.episode?.id) <
            (ref.read(episodesProvider).value?.length ?? 0) - 1;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF141420),
        border: const Border(bottom: BorderSide(color: Color(0xFF232336))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _navArrowButton(
            icon: AppIcons.chevronLeft,
            enabled: hasPrev,
            tooltip: '上一场',
            onPressed: () => _navigateScene(-1),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$epTitle  ›  $scLabel',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFE4E4E7),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _navArrowButton(
            icon: AppIcons.chevronRight,
            enabled: hasNext,
            tooltip: '下一场',
            onPressed: () => _navigateScene(1),
          ),
        ],
      ),
    );
  }

  Widget _navArrowButton({
    required IconData icon,
    required bool enabled,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon, size: 18),
      color: const Color(0xFF8B5CF6),
      disabledColor: const Color(0xFF2A2A3C),
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
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
                color: const Color(0xFF8B5CF6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '内容块',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE4E4E7),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_blocks.length}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8B5CF6),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
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
              shadowColor: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
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
}
