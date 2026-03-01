import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/episode.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';

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
        final label = sc.sceneId.isNotEmpty
            ? '${sc.sceneId} ${sc.location}'
            : sc.location;
        return ScriptTreeNode(
          id: 'scene_${sc.id ?? ""}',
          label: label.isEmpty ? '未命名场景' : label,
          isEpisode: false,
          episodeId: ep.id,
          sceneDbId: sc.id,
        );
      }).toList();

      return ScriptTreeNode(
        id: 'ep_${ep.id ?? ""}',
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
    final canDelete =
        (node.isEpisode && widget.onDeleteEpisode != null) ||
        (!node.isEpisode && widget.onDeleteScene != null);
    if (!canDelete) return;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        offset.dx + 1,
        offset.dy + 1,
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
      color: AppColors.surfaceContainer,
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1, color: AppColors.divider),
          Expanded(
            child: TreeView<ScriptTreeNode>(
              treeController: _treeController,
              nodeBuilder:
                  (BuildContext context, TreeEntry<ScriptTreeNode> entry) {
                    return _TreeNodeTile(
                      entry: entry,
                      isSelected:
                          !entry.node.isEpisode &&
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
                      onAddScene:
                          entry.node.isEpisode &&
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
      padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md, vertical: Spacing.sm),
      child: Row(
        children: [
          Icon(AppIcons.movie, size: 18.r, color: AppColors.onSurface),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              '剧本结构',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
            onTap: widget.onAddEpisode,
            child: Tooltip(
              message: '添加集',
              child: Padding(
                padding: EdgeInsets.all(Spacing.xs.r),
                child: Icon(AppIcons.add, size: 18.r, color: AppColors.primary),
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
              ? AppColors.primary.withValues(alpha: 0.18)
              : Colors.transparent,
          padding: EdgeInsets.only(
              left: Spacing.md + indent, right: Spacing.sm),
          child: Row(
            children: [
              if (node.isEpisode) ...[
                Icon(
                  entry.isExpanded ? AppIcons.expandMore : AppIcons.chevronRight,
                  size: 16.r,
                  color: AppColors.primary,
                ),
                const SizedBox(width: Spacing.xs),
                Icon(AppIcons.folder, size: 16.r, color: AppColors.primary),
              ] else ...[
                SizedBox(width: Spacing.mid.w),
                Icon(
                  AppIcons.document,
                  size: 14.r,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.onSurface.withValues(alpha: 0.6),
                ),
              ],
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  node.label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.onSurface,
                    fontWeight: node.isEpisode
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
              if (onAddScene != null)
                InkWell(
                  borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
                  onTap: onAddScene,
                  child: Tooltip(
                    message: '添加场',
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.xxs),
                      child: Icon(
                        AppIcons.add,
                        size: 15.r,
                        color: AppColors.onSurface.withValues(alpha: 0.6),
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
