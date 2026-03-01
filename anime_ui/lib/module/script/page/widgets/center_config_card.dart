import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/models/model_catalog.dart';
import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/widgets/generation_center/styled_card.dart';
import 'package:anime_ui/pub/widgets/model_selector/model_selector.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';
import 'package:anime_ui/pub/widgets/prompt_field_with_assistant.dart';
import 'package:anime_ui/module/assets/resources/providers/provider.dart';
import 'package:anime_ui/module/script/providers/center_ui.dart';
import 'package:anime_ui/module/script/providers/script_center.dart';

/// 生成配置卡片：全局提示词、反向提示词、制作适配、模型选择
class CenterConfigCard extends ConsumerStatefulWidget {
  const CenterConfigCard({super.key});

  @override
  ConsumerState<CenterConfigCard> createState() => _CenterConfigCardState();
}

class _CenterConfigCardState extends ConsumerState<CenterConfigCard> {
  ModelCatalogItem? _selectedLlmModel;

  Future<void> _saveToLibrary(
    String text,
    String name, {
    required bool isNegative,
  }) async {
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
  }

  void _showPromptLibrary(ValueChanged<String> onSelected) {
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
  Widget build(BuildContext context) {
    final config = ref.watch(generateConfigProvider);
    final n = ref.read(generateConfigProvider.notifier);
    final uiState = ref.watch(scriptCenterUiProvider);
    final uiNotifier = ref.read(scriptCenterUiProvider.notifier);
    final configExpanded = uiState.configExpanded;

    return StyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 卡片标题行
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(Spacing.sm),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.25),
                      AppColors.primary.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
                ),
                child: const Icon(
                  AppIcons.settings,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Text(
                '生成配置',
                style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
              ),
              const Spacer(),
              // 上下集衔接开关
              if (configExpanded)
                _buildCompactSwitch(
                  label: '上下集衔接',
                  value: config.includeAdjacentSummary,
                  onChanged: (v) => n.update(includeAdjacentSummary: v),
                ),
              const SizedBox(width: Spacing.sm),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => uiNotifier.toggleConfigExpanded(),
                  child: AnimatedRotation(
                    turns: configExpanded ? 0.0 : -0.25,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      AppIcons.expandMore,
                      size: 18,
                      color: AppColors.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ),
              ),
            ],
          ),

          AnimatedCrossFade(
            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: Spacing.mid),

                // 全局提示词 (全宽，带创作助理 + 提示词库)
                PromptFieldWithAssistant(
                  value: config.globalStyle,
                  onChanged: (v) => n.update(globalStyle: v),
                  hint: '描述画面整体风格，如：2D漫风，色调偏暗…',
                  accent: AppColors.primary,
                  label: '全局提示词',
                  maxLines: 2,
                  onLibraryTap: (setText) => _showPromptLibrary(setText),
                  onSaveToLibrary: _saveToLibrary,
                ),
                const SizedBox(height: Spacing.lg),

                // 反向提示词 + 制作适配 (双列)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: PromptFieldWithAssistant(
                        value: config.defaultNegativePrompt,
                        onChanged: (v) => n.update(defaultNegativePrompt: v),
                        hint: '失真，穿帮，模糊，低质量…',
                        accent: AppColors.primary,
                        label: '默认反向提示词',
                        negOnly: true,
                        maxLines: 2,
                        onLibraryTap: (setText) => _showPromptLibrary(setText),
                        onSaveToLibrary: _saveToLibrary,
                      ),
                    ),
                    const SizedBox(width: Spacing.lg),
                    Expanded(
                      child: _ConfigField(
                        label: '制作适配说明',
                        value: config.productionNotes,
                        onChanged: (v) => n.update(productionNotes: v),
                        icon: AppIcons.movie,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.lg),

                // 文本生成模型选择
                ModelSelector(
                  serviceType: 'llm',
                  accent: AppColors.primary,
                  selected: _selectedLlmModel,
                  style: ModelSelectorStyle.dropdown,
                  label: '文本生成模型',
                  bestForHint: 'chat',
                  onChanged: (m) {
                    setState(() => _selectedLlmModel = m);
                    n.update(
                      provider: m?.operatorLabel ?? '',
                      model: m?.modelId ?? '',
                    );
                  },
                ),
              ],
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: configExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 250),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSwitch({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: value
            ? AppColors.primary.withValues(alpha: 0.12)
            : AppColors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(RadiusTokens.xxl.r),
        border: Border.all(
          color: value
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: value
                  ? AppColors.primary
                  : AppColors.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: Spacing.md),
          SizedBox(
            height: 20.h,
            width: 36.w,
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
}

// ═══════════════════════════════════════════════════════════════════════════════
// 配置字段组件
// ═══════════════════════════════════════════════════════════════════════════════

class _ConfigField extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final IconData? icon;

  const _ConfigField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: AppColors.onSurface.withValues(alpha: 0.55),
              ),
              const SizedBox(width: Spacing.sm),
            ],
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        SizedBox(height: RadiusTokens.lg.r),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
          decoration: InputDecoration(
            isDense: true,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: AppColors.surfaceContainer,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.md,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
              borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
