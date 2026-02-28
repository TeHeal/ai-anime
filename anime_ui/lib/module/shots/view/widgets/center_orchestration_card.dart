import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/module/assets/resources/providers/resource_state.dart';
import 'package:anime_ui/module/shots/view/provider.dart';
import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/widgets/generation_center/styled_card.dart';
import 'package:anime_ui/pub/widgets/prompt_field_with_assistant.dart';
import 'package:anime_ui/pub/widgets/prompt_library_dialog.dart';

/// 生成编排卡片：子任务开关 + 全局提示词 + 并发设置
class CenterOrchestrationCard extends ConsumerWidget {
  const CenterOrchestrationCard({super.key});

  static void _showPromptLibrary(
    BuildContext context,
    WidgetRef ref,
    void Function(String) onSelected,
  ) {
    final resources = ref.read(resourceListProvider).value ?? [];
    final prompts =
        resources.where((r) => r.libraryType == 'prompt').toList();
    if (prompts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('提示词库中暂无模板'),
          backgroundColor: Colors.grey[800],
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => PromptLibraryDialog(
        prompts: prompts,
        accent: AppColors.primary,
        onSelected: (p) {
          onSelected(p);
          Navigator.pop(ctx);
        },
      ),
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
          const SizedBox(height: 16),
          _subtaskToggles(ref, config),
          const SizedBox(height: 16),
          PromptFieldWithAssistant(
            value: config.videoPrompt,
            onChanged: (v) => notifier.update(videoPrompt: v),
            hint: '运镜流畅，画面稳定，帧间一致性高…',
            accent: AppColors.primary,
            label: '全局视频提示词',
            maxLines: 2,
            onLibraryTap: (setText) => _showPromptLibrary(context, ref, setText),
            onSaveToLibrary: (text, name, {required bool isNegative}) async {
              await ref.read(resourceListProvider.notifier).addResource(
                Resource(
                  name: name,
                  libraryType: 'prompt',
                  modality: 'text',
                  description: text,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: PromptFieldWithAssistant(
                  value: config.negativePrompt,
                  onChanged: (v) => notifier.update(negativePrompt: v),
                  hint: '模糊，抖动，跳帧…',
                  accent: AppColors.primary,
                  label: '默认反向提示词',
                  negOnly: true,
                  maxLines: 2,
                  onLibraryTap: (setText) =>
                      _showPromptLibrary(context, ref, setText),
                  onSaveToLibrary: (text, name, {required bool isNegative}) async {
                    await ref.read(resourceListProvider.notifier).addResource(
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
              const SizedBox(width: 16),
              _concurrencyDropdown(config, notifier),
            ],
          ),
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
              AppColors.primary.withValues(alpha: 0.25),
              AppColors.primary.withValues(alpha: 0.08),
            ]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(AppIcons.settings,
              size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        const Text('生成编排',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ],
    );
  }

  Widget _subtaskToggles(WidgetRef ref, CompositeConfig config) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('子任务编排',
              style: TextStyle(fontSize: 12, color: Colors.grey[400])),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _taskToggle(ref, '🎬 视频', config.enableVideo, 'video'),
              _taskToggle(ref, '🎤 VO', config.enableVO, 'vo'),
              _taskToggle(ref, '🎵 BGM', config.enableBGM, 'bgm'),
              _taskToggle(ref, '🔊 拟声', config.enableFoley, 'foley'),
              _taskToggle(
                  ref, '🔊 动态音效', config.enableDynamicSFX, 'dynamic_sfx'),
              _taskToggle(ref, '🔊 氛围', config.enableAmbient, 'ambient'),
              _taskToggle(
                  ref, '👄 口型同步', config.enableLipSync, 'lip_sync'),
            ],
          ),
          if (config.enableLipSync) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
                border:
                    Border.all(color: Colors.amber.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(AppIcons.warning, size: 13, color: Colors.amber[300]),
                  const SizedBox(width: 6),
                  Text('口型同步需要视频和 VO 均完成后才能执行',
                      style:
                          TextStyle(fontSize: 11, color: Colors.amber[300])),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _taskToggle(
      WidgetRef ref, String label, bool enabled, String type) {
    return GestureDetector(
      onTap: () =>
          ref.read(compositeConfigProvider.notifier).toggleTask(type, !enabled),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled
                ? AppColors.primary.withValues(alpha: 0.4)
                : Colors.grey[700]!,
          ),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                color: enabled ? AppColors.primary : Colors.grey[500],
                fontWeight: enabled ? FontWeight.w600 : FontWeight.normal)),
      ),
    );
  }

  Widget _concurrencyDropdown(
      CompositeConfig config, CompositeConfigNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('并发数', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
        const SizedBox(height: 8),
        DropdownButton<int>(
          value: config.concurrency,
          isDense: true,
          dropdownColor: Colors.grey[900],
          underline: const SizedBox(),
          style: const TextStyle(fontSize: 12, color: Colors.white),
          items: [1, 2, 3, 5, 10]
              .map((c) => DropdownMenuItem(value: c, child: Text('$c')))
              .toList(),
          onChanged: (v) {
            if (v != null) notifier.update(concurrency: v);
          },
        ),
      ],
    );
  }
}
