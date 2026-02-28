import 'package:flutter/material.dart';

import 'package:anime_ui/pub/services/script_parse_svc.dart';
import 'package:anime_ui/pub/theme/colors.dart';

import 'preview_block_item.dart';

class UnconfirmedRef {
  final int episodeIdx;
  final int sceneIdx;
  final int blockIdx;
  final ParsedBlock block;
  final String? prevContent;
  final String? nextContent;
  final ParsedEpisode episode;
  final ParsedScene scene;

  UnconfirmedRef({
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

class PreviewUnconfirmedPanel extends StatefulWidget {
  final List<ParsedEpisode> episodes;
  final VoidCallback onChanged;
  final void Function(int epIdx, int scIdx) onLocate;
  final VoidCallback onAllConfirmed;

  const PreviewUnconfirmedPanel({
    super.key,
    required this.episodes,
    required this.onChanged,
    required this.onLocate,
    required this.onAllConfirmed,
  });

  @override
  State<PreviewUnconfirmedPanel> createState() =>
      _PreviewUnconfirmedPanelState();
}

class _PreviewUnconfirmedPanelState extends State<PreviewUnconfirmedPanel> {
  final Set<ParsedBlock> _selected = {};
  bool _showContext = false;
  final Set<ParsedBlock> _expandedBlocks = {};

  List<UnconfirmedRef> _collectRefs() {
    final refs = <UnconfirmedRef>[];
    for (var ei = 0; ei < widget.episodes.length; ei++) {
      final ep = widget.episodes[ei];
      for (var si = 0; si < ep.scenes.length; si++) {
        final sc = ep.scenes[si];
        for (var bi = 0; bi < sc.blocks.length; bi++) {
          final b = sc.blocks[bi];
          if (b.type == 'unknown' || b.isLowConfidence) {
            refs.add(UnconfirmedRef(
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

  void _batchSetType(List<UnconfirmedRef> refs, String type) {
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

  void _setSingleType(UnconfirmedRef ref, String type) {
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
                        for (final entry in blockLabels.entries)
                          if (entry.key != 'unknown')
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: PreviewBatchTypeChip(
                                label: entry.value,
                                color:
                                    blockColors[entry.key] ?? Colors.grey,
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
                  blockColors[ref.block.type] ?? Colors.grey;

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
                            PreviewMiniTypeDropdown(
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

class PreviewBatchTypeChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const PreviewBatchTypeChip({
    super.key,
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

class PreviewMiniTypeDropdown extends StatelessWidget {
  final String value;
  final Color color;
  final ValueChanged<String> onChanged;

  const PreviewMiniTypeDropdown({
    super.key,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final knownTypes = blockLabels.keys.where((k) => k != 'unknown').toList();
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
          final c = blockColors[key] ?? Colors.grey;
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
                  blockLabels[key] ?? key,
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
