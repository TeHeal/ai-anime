import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

import 'package:anime_ui/pub/models/episode.dart';

// ---------------------------------------------------------------------------
// 树节点模型
// ---------------------------------------------------------------------------

class ScriptTreeNode {
  ScriptTreeNode({
    required this.id,
    required this.label,
    required this.isEpisode,
    this.episodeId,
    this.sceneDbId,
    this.children = const [],
  });

  final String id;
  final String label;
  final bool isEpisode;
  final String? episodeId;
  final String? sceneDbId;
  final List<ScriptTreeNode> children;
}

// ---------------------------------------------------------------------------
// 树形导航组件
// ---------------------------------------------------------------------------

class ScriptTreeNav extends StatefulWidget {
  const ScriptTreeNav({
    super.key,
    required this.episodes,
    required this.selectedEpisodeId,
    required this.selectedSceneId,
    required this.onSceneSelected,
    this.onAddEpisode,
    this.onAddScene,
    this.onDeleteEpisode,
    this.onDeleteScene,
  });

  final List<Episode> episodes;
  final String? selectedEpisodeId;
  final String? selectedSceneId;
  final void Function(String episodeId, String sceneDbId) onSceneSelected;
  final VoidCallback? onAddEpisode;
  final void Function(String episodeId)? onAddScene;
  final void Function(String episodeId)? onDeleteEpisode;
  final void Function(String episodeId, String sceneDbId)? onDeleteScene;

  @override
  State<ScriptTreeNav> createState() => _ScriptTreeNavState();
}

class _ScriptTreeNavState extends State<ScriptTreeNav> {
  late List<ScriptTreeNode> _roots;
  late TreeController<ScriptTreeNode> _treeController;

  @override
  void initState() {
    super.initState();
    _roots = _buildRoots();
    _treeController = TreeController<ScriptTreeNode>(
      roots: _roots,
      childrenProvider: (node) => node.children,
    );
    for (final root in _roots) {
      _treeController.expand(root);
    }
  }

  @override
  void didUpdateWidget(covariant ScriptTreeNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.episodes != widget.episodes ||
        oldWidget.selectedEpisodeId != widget.selectedEpisodeId ||
        oldWidget.selectedSceneId != widget.selectedSceneId) {
      final expanded = <String>{};
      for (final root in _roots) {
        if (_treeController.getExpansionState(root)) {
          expanded.add(root.id);
        }
      }
      _roots = _buildRoots();
      _treeController
        ..roots = _roots
        ..rebuild();
      for (final root in _roots) {
        if (expanded.contains(root.id)) {
          _treeController.expand(root);
        }
      }
    }
  }

  List<ScriptTreeNode> _buildRoots() {
    return widget.episodes.map((ep) {
      final children = ep.scenes.map((sc) {
        final label =
            sc.sceneId.isNotEmpty ? '${sc.sceneId} ${sc.location}' : sc.location;
        return ScriptTreeNode(
          id: 'scene_${sc.id}',
          label: label.isEmpty ? '未命名场景' : label,
          isEpisode: false,
          episodeId: ep.id,
          sceneDbId: sc.id,
        );
      }).toList();

      return ScriptTreeNode(
        id: 'ep_${ep.id}',
        label: ep.title.isEmpty ? '未命名集' : ep.title,
        isEpisode: true,
        episodeId: ep.id,
        children: children,
      );
    }).toList();
  }

  @override
  void dispose() {
    _treeController.dispose();
    super.dispose();
  }

  void _showDeleteMenu(
    BuildContext context,
    Offset offset,
    ScriptTreeNode node,
  ) {
    final canDelete = (node.isEpisode && widget.onDeleteEpisode != null) ||
        (!node.isEpisode && widget.onDeleteScene != null);
    if (!canDelete) return;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx, offset.dy, offset.dx + 1, offset.dy + 1,
      ),
      items: [const PopupMenuItem(value: 'delete', child: Text('删除'))],
    ).then((value) {
      if (value == 'delete') {
        if (node.isEpisode && node.episodeId != null) {
          widget.onDeleteEpisode?.call(node.episodeId!);
        } else if (!node.isEpisode &&
            node.episodeId != null &&
            node.sceneDbId != null) {
          widget.onDeleteScene?.call(node.episodeId!, node.sceneDbId!);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: const Color(0xFF181825),
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1, color: Color(0xFF2A2A3C)),
          Expanded(
            child: TreeView<ScriptTreeNode>(
              treeController: _treeController,
              nodeBuilder: (BuildContext context, TreeEntry<ScriptTreeNode> entry) {
                return _TreeNodeTile(
                  entry: entry,
                  isSelected: !entry.node.isEpisode &&
                      entry.node.sceneDbId == widget.selectedSceneId,
                  onTap: () {
                    if (entry.node.isEpisode) {
                      _treeController.toggleExpansion(entry.node);
                    } else if (entry.node.episodeId != null &&
                        entry.node.sceneDbId != null) {
                      widget.onSceneSelected(
                        entry.node.episodeId!,
                        entry.node.sceneDbId!,
                      );
                    }
                  },
                  onSecondaryTap: (details) {
                    _showDeleteMenu(
                      context,
                      details.globalPosition,
                      entry.node,
                    );
                  },
                  onAddScene: entry.node.isEpisode &&
                          entry.node.episodeId != null &&
                          widget.onAddScene != null
                      ? () => widget.onAddScene!(entry.node.episodeId!)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.movie_outlined, size: 18, color: Color(0xFFE4E4E7)),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              '剧本结构',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE4E4E7),
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: widget.onAddEpisode,
            child: const Tooltip(
              message: '添加集',
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.add, size: 18, color: Color(0xFF8B5CF6)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 单个树节点瓦片
// ---------------------------------------------------------------------------

class _TreeNodeTile extends StatelessWidget {
  const _TreeNodeTile({
    required this.entry,
    required this.isSelected,
    required this.onTap,
    required this.onSecondaryTap,
    this.onAddScene,
  });

  final TreeEntry<ScriptTreeNode> entry;
  final bool isSelected;
  final VoidCallback onTap;
  final void Function(TapDownDetails) onSecondaryTap;
  final VoidCallback? onAddScene;

  @override
  Widget build(BuildContext context) {
    final node = entry.node;
    final indent = entry.level * 16.0;

    return GestureDetector(
      onSecondaryTapDown: onSecondaryTap,
      child: InkWell(
        onTap: onTap,
        onLongPress: () {
          final renderBox = context.findRenderObject() as RenderBox;
          final offset = renderBox.localToGlobal(Offset.zero);
          onSecondaryTap(TapDownDetails(globalPosition: offset));
        },
        child: Container(
          height: 34,
          color: isSelected
              ? const Color(0xFF8B5CF6).withValues(alpha: 0.18)
              : Colors.transparent,
          padding: EdgeInsets.only(left: 12 + indent, right: 8),
          child: Row(
            children: [
              if (node.isEpisode) ...[
                Icon(
                  entry.isExpanded ? Icons.expand_more : Icons.chevron_right,
                  size: 16,
                  color: const Color(0xFF8B5CF6),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.folder_outlined,
                  size: 16,
                  color: const Color(0xFF8B5CF6),
                ),
              ] else ...[
                const SizedBox(width: 20),
                Icon(
                  Icons.description_outlined,
                  size: 14,
                  color: isSelected
                      ? const Color(0xFF8B5CF6)
                      : const Color(0xFF9CA3AF),
                ),
              ],
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  node.label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: isSelected
                        ? const Color(0xFF8B5CF6)
                        : const Color(0xFFE4E4E7),
                    fontWeight:
                        node.isEpisode ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              if (onAddScene != null)
                InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: onAddScene,
                  child: const Tooltip(
                    message: '添加场',
                    child: Padding(
                      padding: EdgeInsets.all(2),
                      child: Icon(
                        Icons.add,
                        size: 15,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
