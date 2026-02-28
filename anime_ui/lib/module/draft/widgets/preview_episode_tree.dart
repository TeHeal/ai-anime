import 'package:flutter/material.dart';

import 'package:anime_ui/pub/services/script_parse_svc.dart';
import 'package:anime_ui/pub/theme/colors.dart';

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
                PreviewSceneTile(
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
