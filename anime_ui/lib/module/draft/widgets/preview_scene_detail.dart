import 'package:flutter/material.dart';

import 'package:anime_ui/pub/services/script_parse_svc.dart';
import 'package:anime_ui/pub/theme/colors.dart';

import 'preview_block_item.dart';

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
      padding: const EdgeInsets.all(24),
      children: [
        PreviewSceneHeader(scene: scene),
        const SizedBox(height: 16),
        for (var i = 0; i < scene.blocks.length; i++)
          PreviewBlockItem(
            block: scene.blocks[i],
            onChanged: onBlockChanged,
          ),
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
              PreviewInfoChip('地点', scene.location),
              PreviewInfoChip('时间', scene.time),
              PreviewInfoChip('内外', scene.intExt),
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

class PreviewInfoChip extends StatelessWidget {
  final String label;
  final String value;

  const PreviewInfoChip(this.label, this.value, {super.key});

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
