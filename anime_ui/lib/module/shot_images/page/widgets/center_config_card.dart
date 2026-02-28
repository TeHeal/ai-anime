import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/module/assets/resources/providers/resource_state.dart';
import 'package:anime_ui/module/shot_images/page/center_ui_provider.dart';
import 'package:anime_ui/module/shot_images/page/provider.dart';
import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/theme/text.dart';
import 'package:anime_ui/pub/widgets/generation_center/styled_card.dart';
import 'package:anime_ui/pub/widgets/model_selector/model_selector.dart';
import 'package:anime_ui/pub/widgets/prompt_field_with_assistant.dart';
import 'package:anime_ui/pub/widgets/prompt_library_dialog.dart';

/// 镜图生成配置卡片
class CenterConfigCard extends ConsumerWidget {
  const CenterConfigCard({super.key});

  void _showPromptLibrary(
    BuildContext context,
    WidgetRef ref,
    void Function(String) onSelected,
  ) {
    final resources = ref.read(resourceListProvider).value ?? [];
    final prompts = resources.where((r) => r.libraryType == 'prompt').toList();
    if (prompts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('提示词库中暂无模板'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
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
    final config = ref.watch(shotImageConfigProvider);
    final n = ref.read(shotImageConfigProvider.notifier);
    final uiState = ref.watch(shotImageCenterUiProvider);
    final uiNotifier = ref.read(shotImageCenterUiProvider.notifier);

    return StyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.25),
                      AppColors.primary.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  AppIcons.settings,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '生成配置',
                style: AppTextStyles.h4.copyWith(color: Colors.white),
              ),
              const Spacer(),
              _compactSwitch(
                label: '上下集衔接',
                value: config.includeAdjacent,
                onChanged: (v) => n.update(includeAdjacent: v),
              ),
            ],
          ),
          const SizedBox(height: 20),
          PromptFieldWithAssistant(
            value: config.globalPrompt,
            onChanged: (v) => n.update(globalPrompt: v),
            hint: '描述画面整体风格，如：2D赛璐璐，暗色调…',
            accent: AppColors.primary,
            label: '全局画面提示词',
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
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: PromptFieldWithAssistant(
                  value: config.negativePrompt,
                  onChanged: (v) => n.update(negativePrompt: v),
                  hint: '失真，穿帮，模糊，低质量…',
                  accent: AppColors.primary,
                  label: '默认反向提示词',
                  negOnly: true,
                  maxLines: 2,
                  onLibraryTap: (setText) =>
                      _showPromptLibrary(context, ref, setText),
                  onSaveToLibrary:
                      (text, name, {required bool isNegative}) async {
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
              Expanded(
                child: ModelSelector(
                  serviceType: 'image_gen',
                  accent: AppColors.primary,
                  selected: uiState.selectedModel,
                  style: ModelSelectorStyle.dropdown,
                  label: '生图模型',
                  bestForHint: 'image',
                  onChanged: (m) {
                    uiNotifier.setSelectedModel(m);
                    n.update(
                      provider: m?.operatorLabel ?? '',
                      model: m?.modelId ?? '',
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                '出图数量:',
                style: AppTextStyles.caption.copyWith(color: Colors.grey[400]),
              ),
              const SizedBox(width: 8),
              for (final count in [1, 2, 4])
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _countChip(
                    count,
                    config.outputCount,
                    (v) => n.update(outputCount: v),
                  ),
                ),
              const SizedBox(width: 20),
              Text(
                '画面比例:',
                style: AppTextStyles.caption.copyWith(color: Colors.grey[400]),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: config.aspectRatio,
                isDense: true,
                dropdownColor: Colors.grey[900],
                underline: const SizedBox(),
                style: AppTextStyles.caption.copyWith(color: Colors.white),
                items: ['16:9', '9:16', '1:1', '4:3']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) n.update(aspectRatio: v);
                },
              ),
              const SizedBox(width: 20),
              _compactSwitch(
                label: '抽卡模式',
                value: config.cardMode,
                onChanged: (v) {
                  n.update(cardMode: v);
                  if (v && config.outputCount < 2) n.update(outputCount: 2);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _compactSwitch({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: value
            ? AppColors.primary.withValues(alpha: 0.12)
            : Colors.grey[800]!.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: value
              ? AppColors.primary.withValues(alpha: 0.3)
              : Colors.grey[700]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: value ? AppColors.primary : Colors.grey[400],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 20,
            width: 36,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: AppColors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _countChip(int count, int current, ValueChanged<int> onTap) {
    final active = count == current;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onTap(count),
        child: Container(
          width: 32,
          height: 28,
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary.withValues(alpha: 0.2)
                : AppColors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: active
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : Colors.grey[700]!,
            ),
          ),
          child: Center(
            child: Text(
              '$count',
              style: AppTextStyles.caption.copyWith(
                color: active ? AppColors.primary : Colors.grey[400],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
