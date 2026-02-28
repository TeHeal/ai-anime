import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/module/draft/provider.dart';
import 'package:anime_ui/module/story/story_action_bar.dart';
import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/providers/project_provider.dart';
import 'package:anime_ui/pub/services/script_parse_svc.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';

class ScriptPreviewPage extends ConsumerStatefulWidget {
  const ScriptPreviewPage({super.key});

  @override
  ConsumerState<ScriptPreviewPage> createState() => _ScriptPreviewPageState();
}

class _ScriptPreviewPageState extends ConsumerState<ScriptPreviewPage> {
  int _selectedEpisodeIdx = 0;
  int _selectedSceneIdx = 0;
  bool _showUnconfirmedPanel = false;

  @override
  Widget build(BuildContext context) {
    // v2 TODO: 恢复锁定后阻止预览的逻辑

    final parseState = ref.watch(parseStateProvider);
    final result = parseState.result;

    if (result == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text('无解析结果', style: TextStyle(fontSize: 16, color: Colors.grey[400])),
            const SizedBox(height: 8),
            Text('请先在「导入」页面上传并解析剧本',
                style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ],
        ),
      );
    }

    final script = result.script;
    final meta = script.metadata;
    final issues = result.issues;
    final liveUnknown = _countUnknownBlocks(script);
    final isConfirming = parseState.phase == ParsePhase.confirming;

    return Column(
      children: [
        _ReviewHintBar(),
        _StatsBar(
          meta: meta,
          issueCount: issues.length,
          liveUnknownCount: liveUnknown,
          episodes: script.episodes,
        ),
        _DynamicIssuesBar(
          liveUnknownCount: liveUnknown,
          originalTotal: meta.unknownBlocks,
          isPanelOpen: _showUnconfirmedPanel,
          onTogglePanel: () {
            setState(() => _showUnconfirmedPanel = !_showUnconfirmedPanel);
          },
        ),
        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: 280,
                child: _EpisodeTree(
                  episodes: script.episodes,
                  selectedEpisodeIdx: _selectedEpisodeIdx,
                  selectedSceneIdx: _selectedSceneIdx,
                  onSelect: (epIdx, scIdx) {
                    setState(() {
                      _selectedEpisodeIdx = epIdx;
                      _selectedSceneIdx = scIdx;
                      _showUnconfirmedPanel = false;
                    });
                  },
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: _showUnconfirmedPanel
                    ? _UnconfirmedPanel(
                        episodes: script.episodes,
                        onChanged: () => setState(() {}),
                        onLocate: (epIdx, scIdx) {
                          setState(() {
                            _selectedEpisodeIdx = epIdx;
                            _selectedSceneIdx = scIdx;
                            _showUnconfirmedPanel = false;
                          });
                        },
                        onAllConfirmed: () {
                          setState(() => _showUnconfirmedPanel = false);
                        },
                      )
                    : _SceneDetail(
                        episode: script.episodes.isNotEmpty
                            ? script.episodes[_selectedEpisodeIdx]
                            : null,
                        sceneIdx: _selectedSceneIdx,
                        onBlockChanged: () => setState(() {}),
                      ),
              ),
            ],
          ),
        ),
        StoryActionBar(
          leading: TextButton.icon(
            onPressed: () {
              ref.read(parseStateProvider.notifier).reset();
              context.go(Routes.storyImport);
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('重新解析'),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[400]),
          ),
          trailing: ElevatedButton.icon(
            onPressed: isConfirming ? null : _confirmImport,
            icon: isConfirming
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.check, size: 18),
            label: Text(isConfirming ? '导入中...' : '确认导入'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  int _countUnknownBlocks(ParsedScript script) {
    var count = 0;
    for (final ep in script.episodes) {
      for (final sc in ep.scenes) {
        for (final b in sc.blocks) {
          if (b.type == 'unknown' || b.isLowConfidence) count++;
        }
      }
    }
    return count;
  }

  Future<void> _confirmImport() async {
    final projectId = ref.read(currentProjectProvider).value?.id;
    if (projectId == null) return;

    await ref.read(parseStateProvider.notifier).confirm(projectId);

    if (!mounted) return;

    final state = ref.read(parseStateProvider);
    if (state.phase == ParsePhase.done) {
      await ref.read(currentProjectProvider.notifier).refresh();
      if (mounted) {
        context.go(Routes.storyEdit);
      }
    } else if (state.phase == ParsePhase.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导入失败: ${state.errorMessage}')),
      );
    }
  }
}

// --- Stats Bar ---

class _StatsBar extends StatelessWidget {
  final ParsedMetadata meta;
  final int issueCount;
  final int liveUnknownCount;
  final List<ParsedEpisode> episodes;

  const _StatsBar({
    required this.meta,
    required this.issueCount,
    required this.liveUnknownCount,
    required this.episodes,
  });

  @override
  Widget build(BuildContext context) {
    final ratePercent = (meta.recognizeRate * 100).toStringAsFixed(0);
    final locationCount = _uniqueLocationCount();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: AppColors.surface,
      child: Row(
        children: [
          _StatChip(Icons.movie, '${meta.episodeCount} 集'),
          const SizedBox(width: 16),
          _StatChip(Icons.theaters, '${meta.sceneCount} 场'),
          const SizedBox(width: 16),
          _StatChip(Icons.people, '${meta.characterNames.length} 个角色'),
          const SizedBox(width: 16),
          _StatChip(Icons.location_on, '$locationCount 个场景地点'),
          const SizedBox(width: 16),
          _StatChip(Icons.analytics, '识别率 $ratePercent%'),
          if (liveUnknownCount > 0) ...[
            const SizedBox(width: 16),
            _StatChip(Icons.warning_amber, '$liveUnknownCount 处待确认',
                color: Colors.orange),
          ],
          if (liveUnknownCount == 0 && meta.unknownBlocks > 0) ...[
            const SizedBox(width: 16),
            _StatChip(Icons.check_circle, '全部已确认', color: Colors.green),
          ],
          if (issueCount > 0) ...[
            const SizedBox(width: 16),
            _StatChip(Icons.info_outline, '$issueCount 条提示',
                color: Colors.blue),
          ],
        ],
      ),
    );
  }

  int _uniqueLocationCount() {
    final locations = <String>{};
    for (final ep in episodes) {
      for (final sc in ep.scenes) {
        if (sc.location.isNotEmpty) locations.add(sc.location);
      }
    }
    return locations.length;
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _StatChip(this.icon, this.label, {this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.grey[400]!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: c),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 13, color: c)),
      ],
    );
  }
}

// --- Dynamic Issues Bar ---

class _DynamicIssuesBar extends StatelessWidget {
  final int liveUnknownCount;
  final int originalTotal;
  final bool isPanelOpen;
  final VoidCallback onTogglePanel;

  const _DynamicIssuesBar({
    required this.liveUnknownCount,
    required this.originalTotal,
    required this.isPanelOpen,
    required this.onTogglePanel,
  });

  @override
  Widget build(BuildContext context) {
    if (originalTotal == 0) return const SizedBox.shrink();

    final allDone = liveUnknownCount == 0;
    final bgColor = allDone
        ? Colors.green.withValues(alpha: 0.1)
        : Colors.orange.withValues(alpha: 0.1);
    final fgColor = allDone ? Colors.green : Colors.orange;
    final icon = allDone ? Icons.check_circle : Icons.warning_amber;
    final text = allDone
        ? '所有内容块已确认，可以导入'
        : '还有 $liveUnknownCount 个内容块需确认（共 $originalTotal 个）';

    return Material(
      color: bgColor,
      child: InkWell(
        onTap: allDone ? null : onTogglePanel,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 16, color: fgColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(fontSize: 13, color: fgColor),
                ),
              ),
              if (!allDone)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isPanelOpen ? '关闭面板' : '批量确认',
                      style: TextStyle(
                        fontSize: 12,
                        color: fgColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isPanelOpen
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_right,
                      size: 16,
                      color: fgColor,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Episode Tree ---

class _EpisodeTree extends StatelessWidget {
  final List<ParsedEpisode> episodes;
  final int selectedEpisodeIdx;
  final int selectedSceneIdx;
  final void Function(int epIdx, int scIdx) onSelect;

  const _EpisodeTree({
    required this.episodes,
    required this.selectedEpisodeIdx,
    required this.selectedSceneIdx,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: episodes.length,
        itemBuilder: (context, epIdx) {
          final ep = episodes[epIdx];
          final unknownCount = _episodeUnknownCount(ep);
          return ExpansionTile(
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    '第 ${ep.episodeNum} 集',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                if (unknownCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$unknownCount',
                      style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
            initiallyExpanded: epIdx == selectedEpisodeIdx,
            childrenPadding: const EdgeInsets.only(left: 16),
            children: [
              for (var scIdx = 0; scIdx < ep.scenes.length; scIdx++)
                _SceneTile(
                  scene: ep.scenes[scIdx],
                  selected: epIdx == selectedEpisodeIdx &&
                      scIdx == selectedSceneIdx,
                  onTap: () => onSelect(epIdx, scIdx),
                ),
            ],
          );
        },
      ),
    );
  }

  int _episodeUnknownCount(ParsedEpisode ep) {
    var count = 0;
    for (final scene in ep.scenes) {
      for (final block in scene.blocks) {
        if (block.type == 'unknown' || block.isLowConfidence) count++;
      }
    }
    return count;
  }
}

class _SceneTile extends StatelessWidget {
  final ParsedScene scene;
  final bool selected;
  final VoidCallback onTap;

  const _SceneTile({
    required this.scene,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasWarning = scene.blocks.any((b) => b.isLowConfidence);
    return ListTile(
      dense: true,
      selected: selected,
      selectedTileColor: AppColors.primary.withValues(alpha: 0.15),
      onTap: onTap,
      leading: hasWarning
          ? const Icon(Icons.warning_amber, size: 16, color: Colors.orange)
          : const Icon(Icons.check_circle, size: 16, color: Colors.green),
      title: Text(
        '场 ${scene.sceneNum}: ${scene.location}',
        style: const TextStyle(fontSize: 13),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${scene.time} · ${scene.intExt}',
        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
      ),
    );
  }
}

// --- Scene Detail ---

class _SceneDetail extends StatelessWidget {
  final ParsedEpisode? episode;
  final int sceneIdx;
  final VoidCallback? onBlockChanged;

  const _SceneDetail({
    required this.episode,
    required this.sceneIdx,
    this.onBlockChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (episode == null ||
        episode!.scenes.isEmpty ||
        sceneIdx >= episode!.scenes.length) {
      return const Center(child: Text('请从左侧选择场景'));
    }

    final scene = episode!.scenes[sceneIdx];

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SceneHeader(scene: scene),
        const SizedBox(height: 16),
        for (var i = 0; i < scene.blocks.length; i++)
          _BlockItem(
            block: scene.blocks[i],
            onChanged: onBlockChanged,
          ),
      ],
    );
  }
}

class _SceneHeader extends StatelessWidget {
  final ParsedScene scene;

  const _SceneHeader({required this.scene});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '场 ${scene.sceneNum}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              _InfoChip('地点', scene.location),
              _InfoChip('时间', scene.time),
              _InfoChip('内外', scene.intExt),
            ],
          ),
          if (scene.characters.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: scene.characters
                  .map((c) => Chip(
                        label: Text(c, style: const TextStyle(fontSize: 12)),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ',
            style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        Text(value, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

// Block type colors
const _blockColors = {
  'action': Color(0xFF22C55E),
  'dialogue': Color(0xFF3B82F6),
  'os': Color(0xFF8B5CF6),
  'closeup': Color(0xFFF97316),
  'direction': Color(0xFFEAB308),
  'unknown': Color(0xFF6B7280),
};

const _blockLabels = {
  'action': '动作',
  'dialogue': '对白',
  'os': '旁白',
  'closeup': '特写',
  'direction': '导演',
  'unknown': '未知',
};

class _BlockItem extends StatefulWidget {
  final ParsedBlock block;
  final VoidCallback? onChanged;

  const _BlockItem({
    required this.block,
    this.onChanged,
  });

  @override
  State<_BlockItem> createState() => _BlockItemState();
}

class _BlockItemState extends State<_BlockItem> {
  bool _editing = false;
  late TextEditingController _contentCtrl;
  late TextEditingController _charCtrl;
  late TextEditingController _emotionCtrl;

  @override
  void initState() {
    super.initState();
    _contentCtrl = TextEditingController(text: widget.block.content);
    _charCtrl = TextEditingController(text: widget.block.character);
    _emotionCtrl = TextEditingController(text: widget.block.emotion);
  }

  @override
  void didUpdateWidget(covariant _BlockItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.block != widget.block) {
      _contentCtrl.text = widget.block.content;
      _charCtrl.text = widget.block.character;
      _emotionCtrl.text = widget.block.emotion;
    }
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    _charCtrl.dispose();
    _emotionCtrl.dispose();
    super.dispose();
  }

  void _save() {
    widget.block.content = _contentCtrl.text;
    widget.block.character = _charCtrl.text;
    widget.block.emotion = _emotionCtrl.text;
    widget.block.confidence = 1.0;
    setState(() => _editing = false);
    widget.onChanged?.call();
  }

  void _cancel() {
    _contentCtrl.text = widget.block.content;
    _charCtrl.text = widget.block.character;
    _emotionCtrl.text = widget.block.emotion;
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final block = widget.block;
    final color = _blockColors[block.type] ?? Colors.grey;
    final isLow = block.isLowConfidence;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isLow
              ? Colors.orange.withValues(alpha: 0.6)
              : Colors.grey[800]!,
          width: isLow ? 2 : 1,
        ),
        color: isLow
            ? Colors.orange.withValues(alpha: 0.05)
            : AppColors.surface.withValues(alpha: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            constraints: const BoxConstraints(minHeight: 40),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                bottomLeft: Radius.circular(6),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row: type dropdown + character + emotion + actions
                  Row(
                    children: [
                      _TypeDropdown(
                        value: block.type,
                        onChanged: (v) {
                          setState(() {
                            block.type = v;
                            if (v != 'unknown') block.confidence = 1.0;
                          });
                          widget.onChanged?.call();
                        },
                      ),
                      if (_editing) ...[
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: _charCtrl,
                            style: const TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: '角色',
                              hintStyle:
                                  TextStyle(fontSize: 11, color: Colors.grey[600]),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 6),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        SizedBox(
                          width: 70,
                          child: TextField(
                            controller: _emotionCtrl,
                            style: const TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: '情绪',
                              hintStyle:
                                  TextStyle(fontSize: 11, color: Colors.grey[600]),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 6),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                        ),
                      ] else ...[
                        if (block.character.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            block.character,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                        if (block.emotion.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            '（${block.emotion}）',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[500]),
                          ),
                        ],
                      ],
                      const Spacer(),
                      if (isLow && !_editing)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(AppIcons.warning,
                              size: 14, color: Colors.orange),
                        ),
                      if (_editing) ...[
                        _ActionBtn(
                          icon: AppIcons.check,
                          color: Colors.green,
                          tooltip: '保存',
                          onTap: _save,
                        ),
                        const SizedBox(width: 4),
                        _ActionBtn(
                          icon: AppIcons.close,
                          color: Colors.grey,
                          tooltip: '取消',
                          onTap: _cancel,
                        ),
                      ] else
                        _ActionBtn(
                          icon: AppIcons.editOutline,
                          color: Colors.grey[500]!,
                          tooltip: '编辑',
                          onTap: () => setState(() => _editing = true),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (_editing)
                    TextField(
                      controller: _contentCtrl,
                      maxLines: null,
                      style: const TextStyle(fontSize: 13, height: 1.5),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.all(8),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4)),
                      ),
                    )
                  else
                    Text(
                      block.content,
                      style: const TextStyle(fontSize: 13, height: 1.5),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _TypeDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final color = _blockColors[value] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButton<String>(
        value: _blockLabels.containsKey(value) ? value : 'unknown',
        items: _blockLabels.entries.map((e) {
          final c = _blockColors[e.key] ?? Colors.grey;
          return DropdownMenuItem(
            value: e.key,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(e.value, style: TextStyle(fontSize: 11, color: c)),
              ],
            ),
          );
        }).toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
        isDense: true,
        underline: const SizedBox.shrink(),
        dropdownColor: AppColors.surface,
        style: TextStyle(fontSize: 11, color: color),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}

// --- Unconfirmed Block Reference ---

class _UnconfirmedRef {
  final int episodeIdx;
  final int sceneIdx;
  final int blockIdx;
  final ParsedBlock block;
  final String? prevContent;
  final String? nextContent;
  final ParsedEpisode episode;
  final ParsedScene scene;

  _UnconfirmedRef({
    required this.episodeIdx,
    required this.sceneIdx,
    required this.blockIdx,
    required this.block,
    this.prevContent,
    this.nextContent,
    required this.episode,
    required this.scene,
  });
}

// --- Unconfirmed Panel ---

class _UnconfirmedPanel extends StatefulWidget {
  final List<ParsedEpisode> episodes;
  final VoidCallback onChanged;
  final void Function(int epIdx, int scIdx) onLocate;
  final VoidCallback onAllConfirmed;

  const _UnconfirmedPanel({
    required this.episodes,
    required this.onChanged,
    required this.onLocate,
    required this.onAllConfirmed,
  });

  @override
  State<_UnconfirmedPanel> createState() => _UnconfirmedPanelState();
}

class _UnconfirmedPanelState extends State<_UnconfirmedPanel> {
  final Set<ParsedBlock> _selected = {};
  bool _showContext = false;
  final Set<ParsedBlock> _expandedBlocks = {};

  List<_UnconfirmedRef> _collectRefs() {
    final refs = <_UnconfirmedRef>[];
    for (var ei = 0; ei < widget.episodes.length; ei++) {
      final ep = widget.episodes[ei];
      for (var si = 0; si < ep.scenes.length; si++) {
        final sc = ep.scenes[si];
        for (var bi = 0; bi < sc.blocks.length; bi++) {
          final b = sc.blocks[bi];
          if (b.type == 'unknown' || b.isLowConfidence) {
            refs.add(_UnconfirmedRef(
              episodeIdx: ei,
              sceneIdx: si,
              blockIdx: bi,
              block: b,
              prevContent: bi > 0 ? sc.blocks[bi - 1].content : null,
              nextContent:
                  bi < sc.blocks.length - 1 ? sc.blocks[bi + 1].content : null,
              episode: ep,
              scene: sc,
            ));
          }
        }
      }
    }
    return refs;
  }

  void _batchSetType(List<_UnconfirmedRef> refs, String type) {
    for (final ref in refs) {
      if (_selected.contains(ref.block)) {
        ref.block.type = type;
        ref.block.confidence = 1.0;
      }
    }
    _selected.clear();
    widget.onChanged();
    _checkAllDone();
  }

  void _setSingleType(_UnconfirmedRef ref, String type) {
    ref.block.type = type;
    ref.block.confidence = 1.0;
    _selected.remove(ref.block);
    widget.onChanged();
    _checkAllDone();
  }

  void _checkAllDone() {
    final remaining = _collectRefs();
    if (remaining.isEmpty) {
      widget.onAllConfirmed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final refs = _collectRefs();
    final currentBlocks = refs.map((r) => r.block).toSet();
    _selected.removeWhere((b) => !currentBlocks.contains(b));
    _expandedBlocks.removeWhere((b) => !currentBlocks.contains(b));

    if (refs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 48, color: Colors.green),
            const SizedBox(height: 12),
            Text('所有内容块已确认',
                style: TextStyle(fontSize: 16, color: Colors.grey[300])),
          ],
        ),
      );
    }

    final allSelected =
        _selected.length == refs.length && refs.isNotEmpty;

    return Column(
      children: [
        // Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: Colors.grey[800]!)),
          ),
          child: Row(
            children: [
              // Select all
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: allSelected,
                  tristate: true,
                  onChanged: (_) {
                    setState(() {
                      if (allSelected) {
                        _selected.clear();
                      } else {
                        _selected.addAll(
                            refs.map((r) => r.block));
                      }
                    });
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '已选 ${_selected.length}/${refs.length}',
                style: TextStyle(fontSize: 13, color: Colors.grey[400]),
              ),
              const SizedBox(width: 12),
              if (_selected.isNotEmpty)
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const Text('标为:',
                            style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 6),
                        for (final entry in _blockLabels.entries)
                          if (entry.key != 'unknown')
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: _BatchTypeChip(
                                label: entry.value,
                                color:
                                    _blockColors[entry.key] ?? Colors.grey,
                                onTap: () =>
                                    _batchSetType(refs, entry.key),
                              ),
                            ),
                      ],
                    ),
                  ),
                )
              else
                const Spacer(),
              // Context toggle
              TextButton.icon(
                onPressed: () => setState(() => _showContext = !_showContext),
                icon: Icon(
                  _showContext
                      ? Icons.unfold_less
                      : Icons.unfold_more,
                  size: 16,
                ),
                label: Text(_showContext ? '收起上下文' : '显示上下文'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[400],
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        // List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: refs.length,
            itemBuilder: (context, i) {
              final ref = refs[i];
              final isSelected = _selected.contains(ref.block);
              final isExpanded = _showContext || _expandedBlocks.contains(ref.block);
              final color =
                  _blockColors[ref.block.type] ?? Colors.grey;

              return Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.08)
                      : AppColors.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : Colors.grey[800]!,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main row
                    InkWell(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selected.remove(ref.block);
                          } else {
                            _selected.add(ref.block);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            // Expand arrow
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (_expandedBlocks.contains(ref.block)) {
                                    _expandedBlocks.remove(ref.block);
                                  } else {
                                    _expandedBlocks.add(ref.block);
                                  }
                                });
                              },
                              child: Icon(
                                isExpanded
                                    ? Icons.expand_more
                                    : Icons.chevron_right,
                                size: 18,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(width: 4),
                            // Checkbox
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: isSelected,
                                onChanged: (_) {
                                  setState(() {
                                    if (isSelected) {
                                      _selected.remove(ref.block);
                                    } else {
                                      _selected.add(ref.block);
                                    }
                                  });
                                },
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Location
                            GestureDetector(
                              onTap: () => widget.onLocate(
                                  ref.episodeIdx, ref.sceneIdx),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '第${ref.episode.episodeNum}集>场${ref.scene.sceneNum}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.blue[300],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Content preview
                            Expanded(
                              child: Text(
                                ref.block.content,
                                style: const TextStyle(
                                    fontSize: 13, height: 1.3),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Type dropdown
                            _MiniTypeDropdown(
                              value: ref.block.type,
                              color: color,
                              onChanged: (v) =>
                                  setState(() => _setSingleType(ref, v)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Context (expanded)
                    if (isExpanded &&
                        (ref.prevContent != null ||
                            ref.nextContent != null))
                      Container(
                        margin: const EdgeInsets.fromLTRB(52, 0, 12, 10),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (ref.prevContent != null)
                              Text(
                                '上文: ${ref.prevContent}',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                    height: 1.4),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            if (ref.prevContent != null &&
                                ref.nextContent != null)
                              const SizedBox(height: 4),
                            if (ref.nextContent != null)
                              Text(
                                '下文: ${ref.nextContent}',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                    height: 1.4),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BatchTypeChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _BatchTypeChip({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(label, style: TextStyle(fontSize: 11, color: color)),
      ),
    );
  }
}

class _MiniTypeDropdown extends StatelessWidget {
  final String value;
  final Color color;
  final ValueChanged<String> onChanged;

  const _MiniTypeDropdown({
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final knownTypes = _blockLabels.keys.where((k) => k != 'unknown').toList();
    final isKnown = knownTypes.contains(value);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButton<String>(
        value: isKnown ? value : null,
        hint: Text(
          '选择类型',
          style: TextStyle(fontSize: 11, color: Colors.orange[300]),
        ),
        items: knownTypes.map((key) {
          final c = _blockColors[key] ?? Colors.grey;
          return DropdownMenuItem(
            value: key,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration:
                      BoxDecoration(color: c, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  _blockLabels[key] ?? key,
                  style: TextStyle(fontSize: 11, color: c),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
        isDense: true,
        underline: const SizedBox.shrink(),
        dropdownColor: AppColors.surface,
        style: TextStyle(fontSize: 11, color: color),
      ),
    );
  }
}

// --- Review Hint Bar ---

class _ReviewHintBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        border: Border(
          bottom: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.rate_review_outlined, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '这是解析预览，请检查并修正识别错误（类型、角色、内容等）。如需深度编辑或新增内容，请在确认导入后前往「编辑」页。',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primary.withValues(alpha: 0.85),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
