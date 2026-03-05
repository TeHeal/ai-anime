import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/module/assets/resources/providers/provider.dart';
import 'package:anime_ui/module/shot_images/providers/center_ui.dart';
import 'package:anime_ui/module/shot_images/providers/shot_image_gen.dart';
import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';
import 'package:anime_ui/pub/widgets/generation_center/styled_card.dart';
import 'package:anime_ui/pub/widgets/model_selector/model_selector.dart';
import 'package:anime_ui/pub/widgets/prompt_field_with_assistant.dart';

/// 镜图生成配置卡片 — 可折叠，展开后含提示词、模型、出图选项
class CenterConfigCard extends ConsumerWidget {
  const CenterConfigCard({super.key});

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
    final config = ref.watch(shotImageConfigProvider);
    final n = ref.read(shotImageConfigProvider.notifier);
    final uiState = ref.watch(shotImageCenterUiProvider);
    final uiNotifier = ref.read(shotImageCenterUiProvider.notifier);
    final expanded = uiState.configExpanded;

    return StyledCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(config, expanded, uiNotifier),
          AnimatedSize(
            duration: MotionTokens.durationMedium,
            curve: MotionTokens.curveStandard,
            alignment: Alignment.topCenter,
            child: expanded
                ? _buildBody(context, ref, config, n, uiState, uiNotifier)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    ShotImageConfig config,
    bool expanded,
    ShotImageCenterUiNotifier uiNotifier,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => uiNotifier.toggleConfigExpanded(),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.cardPadding.w,
            vertical: Spacing.lg.h,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(
                  alpha: expanded ? 0.04 : 0.08,
                ),
                Colors.transparent,
              ],
            ),
            border: expanded
                ? const Border(bottom: BorderSide(color: AppColors.border))
                : null,
          ),
          child: Row(
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
                child: Icon(
                  AppIcons.settings,
                  size: 18.r,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: Spacing.md.w),
              Text(
                '生成配置',
                style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
              ),
              if (!expanded) ...[
                SizedBox(width: Spacing.lg.w),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Spacing.sm.w,
                      vertical: Spacing.xs.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
                    ),
                    child: Text(
                      config.summaryLabel,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.muted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ] else
                const Spacer(),
              AnimatedRotation(
                turns: expanded ? 0.0 : -0.25,
                duration: MotionTokens.durationFast,
                child: Icon(
                  AppIcons.expandMore,
                  size: 18.r,
                  color: AppColors.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    ShotImageConfig config,
    ShotImageConfigNotifier n,
    ShotImageCenterUiState uiState,
    ShotImageCenterUiNotifier uiNotifier,
  ) {
    return Padding(
      padding: EdgeInsets.all(Spacing.cardPadding.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          SizedBox(height: Spacing.lg.h),
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
          SizedBox(height: Spacing.lg.h),
          Wrap(
            spacing: Spacing.xl.w,
            runSpacing: Spacing.md.h,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '出图数量:',
                    style:
                        AppTextStyles.caption.copyWith(color: AppColors.muted),
                  ),
                  SizedBox(width: Spacing.sm.w),
                  for (final count in [1, 2, 4])
                    Padding(
                      padding: EdgeInsets.only(right: Spacing.sm.w),
                      child: _countChip(
                        count,
                        config.outputCount,
                        (v) => n.update(outputCount: v),
                      ),
                    ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '画面比例:',
                    style:
                        AppTextStyles.caption.copyWith(color: AppColors.muted),
                  ),
                  SizedBox(width: Spacing.sm.w),
                  DropdownButton<String>(
                    value: config.aspectRatio,
                    isDense: true,
                    dropdownColor: AppColors.surfaceMutedDarker,
                    underline: const SizedBox(),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.onSurface,
                    ),
                    items: ['16:9', '9:16', '1:1', '4:3']
                        .map(
                            (r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) n.update(aspectRatio: v);
                    },
                  ),
                ],
              ),
              Tooltip(
                message: '开启后每个镜头生成多张图供挑选',
                child: _compactSwitch(
                  label: '抽卡模式',
                  value: config.cardMode,
                  onChanged: (v) {
                    n.update(cardMode: v);
                    if (v && config.outputCount < 2) n.update(outputCount: 2);
                  },
                ),
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
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.md.w,
        vertical: Spacing.sm.h,
      ),
      decoration: BoxDecoration(
        color: value
            ? AppColors.primary.withValues(alpha: 0.12)
            : AppColors.surfaceMutedDark.withValues(alpha: 0.5),
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
              color: value ? AppColors.primary : AppColors.muted,
            ),
          ),
          SizedBox(width: Spacing.md.w),
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

  Widget _countChip(int count, int current, ValueChanged<int> onTap) {
    final active = count == current;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onTap(count),
        child: Container(
          width: 32.w,
          height: 28.h,
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary.withValues(alpha: 0.2)
                : AppColors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
            border: Border.all(
              color: active
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : AppColors.border,
            ),
          ),
          child: Center(
            child: Text(
              '$count',
              style: AppTextStyles.caption.copyWith(
                color: active ? AppColors.primary : AppColors.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
