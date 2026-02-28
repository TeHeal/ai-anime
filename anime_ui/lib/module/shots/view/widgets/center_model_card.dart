import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/module/shots/view/provider.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/widgets/generation_center/styled_card.dart';
import 'package:anime_ui/pub/widgets/model_selector/model_selector.dart';

/// 模型配置卡片：根据已启用的子任务展示对应模型选择器
class CenterModelCard extends ConsumerWidget {
  const CenterModelCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(compositeConfigProvider);

    return StyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 16),
          if (config.enableVideo)
            _modelRow(ref, '🎬 视频模型', 'video_gen', 'video'),
          if (config.enableVO)
            _modelRow(ref, '🎤 TTS 模型', 'tts', 'tts'),
          if (config.enableBGM)
            _modelRow(ref, '🎵 BGM 模型', 'music_gen', 'bgm'),
          if (config.enableFoley ||
              config.enableDynamicSFX ||
              config.enableAmbient)
            _modelRow(ref, '🔊 音效模型', 'music_gen', 'sfx'),
          if (config.enableLipSync)
            _modelRow(ref, '👄 口型模型', 'video_gen', 'lip_sync'),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.blue.withValues(alpha: 0.25),
              Colors.blue.withValues(alpha: 0.08),
            ]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(AppIcons.settings, size: 18, color: Colors.blue),
        ),
        const SizedBox(width: 12),
        const Text('模型配置',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ],
    );
  }

  Widget _modelRow(
      WidgetRef ref, String label, String serviceType, String configKey) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ModelSelector(
        serviceType: serviceType,
        accent: AppColors.primary,
        style: ModelSelectorStyle.dropdown,
        label: label,
        onChanged: (m) {
          if (m != null) {
            ref
                .read(compositeConfigProvider.notifier)
                .updateModel(configKey, m.operatorLabel, m.modelId);
          }
        },
      ),
    );
  }
}
