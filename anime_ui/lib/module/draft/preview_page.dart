import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/module/draft/provider.dart';
import 'package:anime_ui/module/story/story_action_bar.dart';
import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/providers/project_provider.dart';
import 'package:anime_ui/pub/services/script_parse_svc.dart';
import 'package:anime_ui/pub/theme/colors.dart';

import 'widgets/preview_episode_tree.dart';
import 'widgets/preview_scene_detail.dart';
import 'widgets/preview_unconfirmed_panel.dart';

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
                child: PreviewEpisodeTree(
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
                    ? PreviewUnconfirmedPanel(
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
                    : PreviewSceneDetail(
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
