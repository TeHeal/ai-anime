/// 剧本预览页 — 统计栏、集场树、场景详情等子组件
/// 从 preview_page.dart 拆分，满足单文件 ≤600 行规范
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/services/script_parse_svc.dart';

import 'preview_block_widgets.dart';

// --- Review Hint Bar ---

class PreviewReviewHintBar extends StatelessWidget {
  const PreviewReviewHintBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.xl,
        vertical: RadiusTokens.lg.r,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        border: Border(
          bottom: BorderSide(color: AppColors.primary.withValues(alpha: 0.15)),
        ),
      ),
      child: Row(
        children: [
          Icon(AppIcons.document, size: 16.r, color: AppColors.primary),
          SizedBox(width: Spacing.sm.w),
          Expanded(
            child: Text(
              '这是解析预览，请检查并修正识别错误（类型、角色、内容等）。如需深度编辑或新增内容，请在确认导入后前往「编辑」页。',
              style: AppTextStyles.bodySmall.copyWith(
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

// --- Stats Bar ---

class PreviewStatsBar extends StatelessWidget {
  final ParsedMetadata meta;
  final int issueCount;
  final int liveUnknownCount;
  final List<ParsedEpisode> episodes;

  const PreviewStatsBar({
    super.key,
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
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.xl,
        vertical: Spacing.md,
      ),
      color: AppColors.surface,
      child: Row(
        children: [
          PreviewStatChip(AppIcons.movie, '${meta.episodeCount} 集'),
          const SizedBox(width: Spacing.lg),
          PreviewStatChip(AppIcons.video, '${meta.sceneCount} 场'),
          const SizedBox(width: Spacing.lg),
          PreviewStatChip(AppIcons.people, '${meta.characterNames.length} 个角色'),
          const SizedBox(width: Spacing.lg),
          PreviewStatChip(AppIcons.landscape, '$locationCount 个场景地点'),
          const SizedBox(width: Spacing.lg),
          PreviewStatChip(AppIcons.analytics, '识别率 $ratePercent%'),
          if (liveUnknownCount > 0) ...[
            const SizedBox(width: Spacing.lg),
            PreviewStatChip(
              AppIcons.warning,
              '$liveUnknownCount 处待确认',
              color: AppColors.warning,
            ),
          ],
          if (liveUnknownCount == 0 && meta.unknownBlocks > 0) ...[
            const SizedBox(width: Spacing.lg),
            const PreviewStatChip(
              AppIcons.check,
              '全部已确认',
              color: AppColors.success,
            ),
          ],
          if (issueCount > 0) ...[
            const SizedBox(width: Spacing.lg),
            PreviewStatChip(
              AppIcons.info,
              '$issueCount 条提示',
              color: AppColors.info,
            ),
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

class PreviewStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const PreviewStatChip(this.icon, this.label, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.muted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16.r, color: c),
        const SizedBox(width: Spacing.xs),
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: c)),
      ],
    );
  }
}

// --- Dynamic Issues Bar ---

class PreviewDynamicIssuesBar extends StatelessWidget {
  final int liveUnknownCount;
  final int originalTotal;
  final bool isPanelOpen;
  final VoidCallback onTogglePanel;

  const PreviewDynamicIssuesBar({
    super.key,
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
        ? AppColors.success.withValues(alpha: 0.1)
        : AppColors.warning.withValues(alpha: 0.1);
    final fgColor = allDone ? AppColors.success : AppColors.warning;
    final icon = allDone ? AppIcons.check : AppIcons.warning;
    final text = allDone
        ? '所有内容块已确认，可以导入'
        : '还有 $liveUnknownCount 个内容块需确认（共 $originalTotal 个）';

    return Material(
      color: bgColor,
      child: InkWell(
        onTap: allDone ? null : onTogglePanel,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.xl,
            vertical: Spacing.sm,
          ),
          child: Row(
            children: [
              Icon(icon, size: 16.r, color: fgColor),
              SizedBox(width: Spacing.sm.w),
              Expanded(
                child: Text(
                  text,
                  style: AppTextStyles.bodySmall.copyWith(color: fgColor),
                ),
              ),
              if (!allDone)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isPanelOpen ? '关闭面板' : '批量确认',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: fgColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: Spacing.xs.w),
                    Icon(
                      isPanelOpen
                          ? AppIcons.keyboardArrowUp
                          : AppIcons.keyboardArrowRight,
                      size: 16.r,
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

class PreviewEpisodeTree extends StatelessWidget {
  final List<ParsedEpisode> episodes;
  final int selectedEpisodeIdx;
  final int selectedSceneIdx;
  final void Function(int epIdx, int scIdx) onSelect;

  const PreviewEpisodeTree({
    super.key,
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
        padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
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
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (unknownCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.sm,
                      vertical: Spacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
                    ),
                    child: Text(
                      '$unknownCount',
                      style: AppTextStyles.tiny.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            initiallyExpanded: epIdx == selectedEpisodeIdx,
            childrenPadding: const EdgeInsets.only(left: Spacing.lg),
            children: [
              for (var scIdx = 0; scIdx < ep.scenes.length; scIdx++)
                PreviewSceneTile(
                  scene: ep.scenes[scIdx],
                  selected:
                      epIdx == selectedEpisodeIdx && scIdx == selectedSceneIdx,
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

class PreviewSceneTile extends StatelessWidget {
  final ParsedScene scene;
  final bool selected;
  final VoidCallback onTap;

  const PreviewSceneTile({
    super.key,
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
          ? Icon(AppIcons.warning, size: 16.r, color: AppColors.warning)
          : Icon(AppIcons.check, size: 16.r, color: AppColors.success),
      title: Text(
        '场 ${scene.sceneNum}: ${scene.location}',
        style: AppTextStyles.bodySmall,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${scene.time} · ${scene.intExt}',
        style: AppTextStyles.tiny.copyWith(color: AppColors.mutedDark),
      ),
    );
  }
}

// --- Scene Detail ---

class PreviewSceneDetail extends StatelessWidget {
  final ParsedEpisode? episode;
  final int sceneIdx;
  final VoidCallback? onBlockChanged;

  const PreviewSceneDetail({
    super.key,
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
      padding: const EdgeInsets.all(Spacing.xl),
      children: [
        PreviewSceneHeader(scene: scene),
        const SizedBox(height: Spacing.lg),
        for (var i = 0; i < scene.blocks.length; i++)
          PreviewBlockItem(block: scene.blocks[i], onChanged: onBlockChanged),
      ],
    );
  }
}

class PreviewSceneHeader extends StatelessWidget {
  final ParsedScene scene;

  const PreviewSceneHeader({super.key, required this.scene});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(RadiusTokens.md.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('场 ${scene.sceneNum}', style: AppTextStyles.h4),
          const SizedBox(height: Spacing.sm),
          Wrap(
            spacing: Spacing.md,
            runSpacing: Spacing.xs,
            children: [
              PreviewInfoChip('地点', scene.location),
              PreviewInfoChip('时间', scene.time),
              PreviewInfoChip('内外', scene.intExt),
            ],
          ),
          if (scene.characters.isNotEmpty) ...[
            const SizedBox(height: Spacing.sm),
            Wrap(
              spacing: Spacing.sm,
              children: scene.characters
                  .map(
                    (c) => Chip(
                      label: Text(c, style: AppTextStyles.labelMedium),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class PreviewInfoChip extends StatelessWidget {
  final String label;
  final String value;

  const PreviewInfoChip(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: AppTextStyles.labelMedium.copyWith(color: AppColors.mutedDark),
        ),
        Text(value, style: AppTextStyles.labelMedium),
      ],
    );
  }
}
