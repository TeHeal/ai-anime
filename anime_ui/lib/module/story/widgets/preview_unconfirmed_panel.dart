/// 剧本预览页 — 待确认内容块批量面板
/// 从 preview_page.dart 拆分，满足单文件 ≤600 行规范
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/services/script_parse_svc.dart';

import 'preview_block_widgets.dart';

/// 待确认块引用（集/场/块索引 + 上下文）
class PreviewUnconfirmedRef {
  final int episodeIdx;
  final int sceneIdx;
  final int blockIdx;
  final ParsedBlock block;
  final String? prevContent;
  final String? nextContent;
  final ParsedEpisode episode;
  final ParsedScene scene;

  PreviewUnconfirmedRef({
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

/// 待确认块批量确认面板
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

  List<PreviewUnconfirmedRef> _collectRefs() {
    final refs = <PreviewUnconfirmedRef>[];
    for (var ei = 0; ei < widget.episodes.length; ei++) {
      final ep = widget.episodes[ei];
      for (var si = 0; si < ep.scenes.length; si++) {
        final sc = ep.scenes[si];
        for (var bi = 0; bi < sc.blocks.length; bi++) {
          final b = sc.blocks[bi];
          if (b.type == 'unknown' || b.isLowConfidence) {
            refs.add(
              PreviewUnconfirmedRef(
                episodeIdx: ei,
                sceneIdx: si,
                blockIdx: bi,
                block: b,
                prevContent: bi > 0 ? sc.blocks[bi - 1].content : null,
                nextContent: bi < sc.blocks.length - 1
                    ? sc.blocks[bi + 1].content
                    : null,
                episode: ep,
                scene: sc,
              ),
            );
          }
        }
      }
    }
    return refs;
  }

  void _batchSetType(List<PreviewUnconfirmedRef> refs, String type) {
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

  void _setSingleType(PreviewUnconfirmedRef ref, String type) {
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
            Icon(AppIcons.check, size: 48.r, color: AppColors.success),
            SizedBox(height: Spacing.md.h),
            Text(
              '所有内容块已确认',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.mutedLight,
              ),
            ),
          ],
        ),
      );
    }

    final allSelected = _selected.length == refs.length && refs.isNotEmpty;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.lg.w,
            vertical: RadiusTokens.lg.h,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: Spacing.xl.w,
                height: Spacing.xl.h,
                child: Checkbox(
                  value: allSelected,
                  tristate: true,
                  onChanged: (_) {
                    setState(() {
                      if (allSelected) {
                        _selected.clear();
                      } else {
                        _selected.addAll(refs.map((r) => r.block));
                      }
                    });
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              SizedBox(width: Spacing.sm.w),
              Text(
                '已选 ${_selected.length}/${refs.length}',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
              ),
              SizedBox(width: Spacing.md.w),
              if (_selected.isNotEmpty)
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Text('标为:', style: AppTextStyles.labelMedium),
                        SizedBox(width: Spacing.sm.w),
                        for (final entry in previewBlockLabels.entries)
                          if (entry.key != 'unknown')
                            Padding(
                              padding: EdgeInsets.only(right: Spacing.xs.w),
                              child: _PreviewBatchTypeChip(
                                label: entry.value,
                                color:
                                    previewBlockColors[entry.key] ??
                                    AppColors.muted,
                                onTap: () => _batchSetType(refs, entry.key),
                              ),
                            ),
                      ],
                    ),
                  ),
                )
              else
                const Spacer(),
              TextButton.icon(
                onPressed: () => setState(() => _showContext = !_showContext),
                icon: Icon(
                  _showContext ? AppIcons.unfoldLess : AppIcons.unfoldMore,
                  size: 16.r,
                ),
                label: Text(_showContext ? '收起上下文' : '显示上下文'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.muted,
                  textStyle: AppTextStyles.labelMedium,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
            itemCount: refs.length,
            itemBuilder: (context, i) {
              final ref = refs[i];
              final isSelected = _selected.contains(ref.block);
              final isExpanded =
                  _showContext || _expandedBlocks.contains(ref.block);
              final color =
                  previewBlockColors[ref.block.type] ?? AppColors.muted;

              return Container(
                margin: EdgeInsets.symmetric(
                  horizontal: Spacing.md.w,
                  vertical: Spacing.progressBarHeight.h,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.08)
                      : AppColors.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : AppColors.surfaceContainer,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Spacing.md.w,
                          vertical: RadiusTokens.lg.h,
                        ),
                        child: Row(
                          children: [
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
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
                                      ? AppIcons.expandMore
                                      : AppIcons.chevronRight,
                                  size: 18.r,
                                  color: AppColors.mutedDark,
                                ),
                              ),
                            ),
                            SizedBox(width: Spacing.xs.w),
                            SizedBox(
                              width: Spacing.mid.w,
                              height: Spacing.mid.h,
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
                            SizedBox(width: RadiusTokens.lg.w),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () =>
                                    widget.onLocate(ref.episodeIdx, ref.sceneIdx),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Spacing.sm.w,
                                    vertical: Spacing.xxs.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainer,
                                    borderRadius: BorderRadius.circular(
                                      RadiusTokens.xs.r,
                                    ),
                                  ),
                                  child: Text(
                                  '第${ref.episode.episodeNum}集>场${ref.scene.sceneNum}',
                                  style: AppTextStyles.tiny.copyWith(
                                    color: AppColors.info,
                                  ),
                                ),
                              ),
                              ),
                            ),
                            SizedBox(width: RadiusTokens.lg.w),
                            Expanded(
                              child: Text(
                                ref.block.content,
                                style: AppTextStyles.bodySmall.copyWith(
                                  height: 1.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: Spacing.sm.w),
                            _PreviewMiniTypeDropdown(
                              value: ref.block.type,
                              color: color,
                              onChanged: (v) =>
                                  setState(() => _setSingleType(ref, v)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isExpanded &&
                        (ref.prevContent != null || ref.nextContent != null))
                      Container(
                        margin: EdgeInsets.fromLTRB(
                          52.w,
                          0,
                          Spacing.md.w,
                          RadiusTokens.lg.h,
                        ),
                        padding: EdgeInsets.all(Spacing.sm.r),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMutedDarker,
                          borderRadius: BorderRadius.circular(
                            RadiusTokens.xs.r,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (ref.prevContent != null)
                              Text(
                                '上文: ${ref.prevContent}',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.mutedDark,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            if (ref.prevContent != null &&
                                ref.nextContent != null)
                              SizedBox(height: Spacing.xs.h),
                            if (ref.nextContent != null)
                              Text(
                                '下文: ${ref.nextContent}',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.mutedDark,
                                  height: 1.4,
                                ),
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

class _PreviewBatchTypeChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PreviewBatchTypeChip({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.sm.w,
          vertical: Spacing.xs.h,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(label, style: AppTextStyles.tiny.copyWith(color: color)),
      ),
    );
  }
}

class _PreviewMiniTypeDropdown extends StatelessWidget {
  final String value;
  final Color color;
  final ValueChanged<String> onChanged;

  const _PreviewMiniTypeDropdown({
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final knownTypes = previewBlockLabels.keys
        .where((k) => k != 'unknown')
        .toList();
    final isKnown = knownTypes.contains(value);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Spacing.xs.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
      ),
      child: DropdownButton<String>(
        value: isKnown ? value : null,
        hint: Text(
          '选择类型',
          style: AppTextStyles.tiny.copyWith(color: AppColors.warning),
        ),
        items: knownTypes.map((key) {
          final c = previewBlockColors[key] ?? AppColors.muted;
          return DropdownMenuItem(
            value: key,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: Spacing.sm.w,
                  height: Spacing.sm.h,
                  decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                ),
                SizedBox(width: Spacing.sm.w),
                Text(
                  previewBlockLabels[key] ?? key,
                  style: AppTextStyles.tiny.copyWith(color: c),
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
        style: AppTextStyles.tiny.copyWith(color: color),
      ),
    );
  }
}
