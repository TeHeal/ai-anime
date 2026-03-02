import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/module/assets/resources/providers/provider.dart';
import 'package:anime_ui/module/shots/page/provider.dart';
import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/widgets/generation_center/styled_card.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';
import 'package:anime_ui/pub/widgets/prompt_field_with_assistant.dart';
import 'video_gen_mode_panel.dart';
import 'video_spec_panel.dart';

/// 生成编排卡片：生成模式 + 子任务开关 + 视频规格 + 提示词 + 并发设置
class CenterOrchestrationCard extends ConsumerWidget {
  const CenterOrchestrationCard({super.key});

  void _showPromptLibrary(
    BuildContext context,
    WidgetRef ref,
    void Function(String) onSelected,
  ) {
    final resources = ref.read(resourceListProvider).value ?? [];
    final prompts = resources.where((r) => r.libraryType == 'prompt').toList();
    showPromptLibrary(
      context,
      prompts: prompts,
      accent: AppColors.primary,
      onSelected: onSelected,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(compositeConfigProvider);
    final notifier = ref.read(compositeConfigProvider.notifier);

    return StyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          SizedBox(height: Spacing.lg.h),

          // 视频生成模式选择
          const VideoGenModePanel(),
          SizedBox(height: Spacing.lg.h),

          // 子任务编排开关
          _subtaskToggles(ref, config),
          SizedBox(height: Spacing.lg.h),

          // 视频输出规格面板
          if (config.enableVideo) ...[
            const VideoSpecPanel(),
            SizedBox(height: Spacing.lg.h),
          ],

          // 提示词区域
          PromptFieldWithAssistant(
            value: config.videoPrompt,
            onChanged: (v) => notifier.update(videoPrompt: v),
            hint: _promptHint(config.videoGenMode),
            accent: AppColors.primary,
            label: '视频提示词',
            maxLines: 3,
            onLibraryTap: (setText) =>
                _showPromptLibrary(context, ref, setText),
            onSaveToLibrary: (text, name, {required bool isNegative}) async {
              await ref
                  .read(resourceListProvider.notifier)
                  .addResource(
                    Resource(
                      name: name,
                      libraryType: 'prompt',
                      modality: 'text',
                      description: text,
                    ),
                  );
            },
          ),
          SizedBox(height: Spacing.md.h),
          Row(
            children: [
              Expanded(
                child: PromptFieldWithAssistant(
                  value: config.negativePrompt,
                  onChanged: (v) => notifier.update(negativePrompt: v),
                  hint: '模糊，抖动，跳帧…',
                  accent: AppColors.primary,
                  label: '反向提示词',
                  negOnly: true,
                  maxLines: 2,
                  onLibraryTap: (setText) =>
                      _showPromptLibrary(context, ref, setText),
                  onSaveToLibrary:
                      (text, name, {required bool isNegative}) async {
                        await ref
                            .read(resourceListProvider.notifier)
                            .addResource(
                              Resource(
                                name: name,
                                libraryType: 'prompt',
                                modality: 'text',
                                description: text,
                              ),
                            );
                      },
                ),
              ),
              SizedBox(width: Spacing.lg.w),
              _concurrencyDropdown(config, notifier),
            ],
          ),

          // 参考图模式的提示词说明
          if (config.videoGenMode == VideoGenMode.referenceImages) ...[
            SizedBox(height: Spacing.sm.h),
            _referenceImageHint(),
          ],
        ],
      ),
    );
  }

  String _promptHint(VideoGenMode mode) => switch (mode) {
        VideoGenMode.text2video =>
          '描述视频内容：主体 + 动作 + 背景 + 镜头运动。例如：写实风格，晴朗蓝天下一大片白色雏菊花田，镜头逐渐拉近…',
        VideoGenMode.firstFrame =>
          '描述视频动作和运镜。例如：女孩睁开眼，温柔地看向镜头，镜头缓缓拉出，头发被风吹动…',
        VideoGenMode.firstLastFrame =>
          '描述首尾帧之间的过渡效果。例如：360度环绕运镜，图中女孩对着镜头微笑…',
        VideoGenMode.referenceImages =>
          '用 [图N] 引用参考图。例如：[图1]戴着眼镜穿蓝色T恤的男生和[图2]的柯基小狗，坐在[图3]的草坪上…',
      };

  Widget _header() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(Spacing.sm.r),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.25),
                AppColors.primary.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
          ),
          child: Icon(AppIcons.settings, size: 18.r, color: AppColors.primary),
        ),
        SizedBox(width: Spacing.md.w),
        Text(
          '生成编排',
          style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
        ),
      ],
    );
  }

  Widget _subtaskToggles(WidgetRef ref, CompositeConfig config) {
    return Container(
      padding: EdgeInsets.all(Spacing.md.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '子任务编排',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: Spacing.sm.h),
          Wrap(
            spacing: Spacing.sm.w,
            runSpacing: Spacing.sm.h,
            children: [
              _taskToggle(ref, '🎬 视频', config.enableVideo, 'video'),
              _taskToggle(ref, '🎤 VO', config.enableVO, 'vo'),
              _taskToggle(ref, '🎵 BGM', config.enableBGM, 'bgm'),
              _taskToggle(ref, '🔊 拟声', config.enableFoley, 'foley'),
              _taskToggle(
                ref,
                '🔊 动态音效',
                config.enableDynamicSFX,
                'dynamic_sfx',
              ),
              _taskToggle(ref, '🔊 氛围', config.enableAmbient, 'ambient'),
              _taskToggle(ref, '👄 口型同步', config.enableLipSync, 'lip_sync'),
            ],
          ),
          if (config.enableLipSync) ...[
            SizedBox(height: Spacing.sm.h),
            Container(
              padding: EdgeInsets.all(Spacing.sm.r),
              decoration: BoxDecoration(
                color: AppColors.tagAmber.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
                border: Border.all(
                  color: AppColors.tagAmber.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    AppIcons.warning,
                    size: 13.r,
                    color: AppColors.tagAmber.withValues(alpha: 0.9),
                  ),
                  SizedBox(width: Spacing.sm.w),
                  Text(
                    '口型同步需要视频和 VO 均完成后才能执行',
                    style: AppTextStyles.tiny.copyWith(
                      color: AppColors.tagAmber.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _taskToggle(WidgetRef ref, String label, bool enabled, String type) {
    return GestureDetector(
      onTap: () =>
          ref.read(compositeConfigProvider.notifier).toggleTask(type, !enabled),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.md.w,
          vertical: Spacing.sm.h,
        ),
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(RadiusTokens.md.r),
          border: Border.all(
            color: enabled
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: enabled
                ? AppColors.primary
                : AppColors.onSurface.withValues(alpha: 0.55),
            fontWeight: enabled ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _concurrencyDropdown(
    CompositeConfig config,
    CompositeConfigNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '并发数',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.onSurface.withValues(alpha: 0.6),
          ),
        ),
        SizedBox(height: Spacing.sm.h),
        DropdownButton<int>(
          value: config.concurrency,
          isDense: true,
          dropdownColor: AppColors.surfaceContainer,
          underline: const SizedBox(),
          style: AppTextStyles.caption.copyWith(color: AppColors.onSurface),
          items: [
            1,
            2,
            3,
            5,
            10,
          ].map((c) => DropdownMenuItem(value: c, child: Text('$c'))).toList(),
          onChanged: (v) {
            if (v != null) notifier.update(concurrency: v);
          },
        ),
      ],
    );
  }

  Widget _referenceImageHint() {
    return Container(
      padding: EdgeInsets.all(Spacing.sm.r),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(AppIcons.info, size: 13.r,
              color: AppColors.info.withValues(alpha: 0.7)),
          SizedBox(width: Spacing.sm.w),
          Expanded(
            child: Text(
              '参考图模式：在提示词中使用 [图1]、[图2]… 引用对应参考图的对象特征。系统会提取各图的关键特征进行还原。',
              style: AppTextStyles.tiny.copyWith(
                color: AppColors.info.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
