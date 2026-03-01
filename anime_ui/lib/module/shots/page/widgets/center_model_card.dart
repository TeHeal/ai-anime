import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/module/shots/page/provider.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
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
          SizedBox(height: Spacing.lg.h),
          if (config.enableVideo)
            _modelRow(ref, '🎬 视频模型', 'video_gen', 'video'),
          if (config.enableVO) _modelRow(ref, '🎤 TTS 模型', 'tts', 'tts'),
          if (config.enableBGM) _modelRow(ref, '🎵 BGM 模型', 'music_gen', 'bgm'),
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
          padding: EdgeInsets.all(Spacing.sm.r),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.info.withValues(alpha: 0.25),
                AppColors.info.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
          ),
          child: Icon(AppIcons.settings, size: 18.r, color: AppColors.info),
        ),
        SizedBox(width: Spacing.md.w),
        Text(
          '模型配置',
          style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
        ),
      ],
    );
  }

  Widget _modelRow(
    WidgetRef ref,
    String label,
    String serviceType,
    String configKey,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: Spacing.md.h),
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
