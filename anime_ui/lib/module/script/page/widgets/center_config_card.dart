import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/models/model_catalog.dart';
import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/models/storyboard_script.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';
import 'package:anime_ui/pub/widgets/generation_center/styled_card.dart';
import 'package:anime_ui/pub/widgets/model_selector/model_selector.dart';
import 'package:anime_ui/pub/widgets/prompt_field_with_assistant.dart';
import 'package:anime_ui/module/assets/resources/providers/provider.dart';
import 'package:anime_ui/module/script/providers/center_ui.dart';
import 'package:anime_ui/module/script/providers/script_center.dart';

/// 脚本生成配置卡片 — 双栏：左(提示词) 右(模型+设置)
///
/// 折叠态显示当前配置概况，展开后双栏并排（窄屏自动堆叠）。
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

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(generateConfigProvider);
    final uiState = ref.watch(scriptCenterUiProvider);
    final uiNotifier = ref.read(scriptCenterUiProvider.notifier);
    final configExpanded = uiState.configExpanded;

    return StyledCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(config, configExpanded, uiNotifier),
          AnimatedSize(
            duration: MotionTokens.durationMedium,
            curve: MotionTokens.curveStandard,
            alignment: Alignment.topCenter,
            child: configExpanded
                ? _buildExpandedBody(config)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // ── Header（折叠/展开通用） ──

  Widget _buildHeader(
    GenerateConfig config,
    bool expanded,
    ScriptCenterUiNotifier uiNotifier,
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

  // ── 展开 Body（响应式双栏 / 纵向堆叠） ──

  Widget _buildExpandedBody(GenerateConfig config) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < Breakpoints.lg;
        final promptCol = _innerCard(child: _buildPromptColumn(config));
        final settingsCol = _innerCard(child: _buildSettingsColumn(config));

        if (isNarrow) {
          return Padding(
            padding: EdgeInsets.all(Spacing.cardPadding.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                promptCol,
                SizedBox(height: Spacing.lg.h),
                settingsCol,
              ],
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.all(Spacing.cardPadding.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: promptCol),
              SizedBox(width: Spacing.xl.w),
              Expanded(flex: 2, child: settingsCol),
            ],
          ),
        );
      },
    );
  }

  /// 内嵌子卡片：圆角 + 淡色背景 + 细边框
  Widget _innerCard({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(Spacing.lg.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.4),
        ),
      ),
      child: child,
    );
  }

  // ── 左栏：提示词 ──

  Widget _buildPromptColumn(GenerateConfig config) {
    final n = ref.read(generateConfigProvider.notifier);
    return PromptFieldWithAssistant(
      value: config.globalStyle,
      onChanged: (v) => n.update(globalStyle: v),
      hint: '描述画面整体风格，如：2D漫风，色调偏暗…',
      accent: AppColors.primary,
      label: '提示词',
      maxLines: 5,
      negValue: config.defaultNegativePrompt,
      negOnChanged: (v) => n.update(defaultNegativePrompt: v),
      onLibraryTap: (setText) => _showPromptLibrary(setText),
      negOnLibraryTap: (setText) => _showPromptLibrary(setText),
      onSaveToLibrary: _saveToLibrary,
    );
  }

  // ── 右栏：模型 + 设置项 ──

  Widget _buildSettingsColumn(GenerateConfig config) {
    final n = ref.read(generateConfigProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        SizedBox(height: Spacing.lg.h),
        _buildDropdownField<ShotDensity>(
          label: '镜头密度',
          tooltip: '控制每场生成的镜头数量，精简适合节奏快的剧情，细致适合重要场景',
          value: config.shotDensity,
          items: const {
            ShotDensity.compact: '精简 (2-3 镜头/场)',
            ShotDensity.standard: '标准 (3-5 镜头/场)',
            ShotDensity.detailed: '细致 (5-8 镜头/场)',
          },
          onChanged: (v) => n.update(shotDensity: v),
        ),
        SizedBox(height: Spacing.lg.h),
        _buildDropdownField<CameraPreset>(
          label: '运镜偏好',
          tooltip: '影响镜头的景别和运动方式，叙事风偏稳重，动作风偏快节奏',
          value: config.cameraPreset,
          items: const {
            CameraPreset.narrative: '叙事风 · 中近景为主',
            CameraPreset.action: '动作风 · 多机位快切',
            CameraPreset.cinematic: '电影风 · 大景别推拉',
            CameraPreset.custom: '自定义 · 自由组合',
          },
          onChanged: (v) => n.update(cameraPreset: v),
        ),
        SizedBox(height: Spacing.lg.h),
        _buildDropdownField<OutputLanguage>(
          label: '输出语言',
          value: config.outputLanguage,
          items: const {
            OutputLanguage.zh: '中文',
            OutputLanguage.en: 'English',
            OutputLanguage.zhEn: '中英混合',
          },
          onChanged: (v) => n.update(outputLanguage: v),
        ),
        SizedBox(height: Spacing.lg.h),
        _buildSwitchField(
          label: '上下集衔接',
          description: '生成时参考前后集的摘要信息',
          value: config.includeAdjacentSummary,
          onChanged: (v) => n.update(includeAdjacentSummary: v),
        ),
      ],
    );
  }

  // ── 通用设置组件 ──

  /// 下拉选择字段
  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required Map<T, String> items,
    required ValueChanged<T> onChanged,
    String? tooltip,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.6),
              ),
            ),
            if (tooltip != null) ...[
              SizedBox(width: Spacing.xs.w),
              Tooltip(
                message: tooltip,
                child: Icon(
                  AppIcons.info,
                  size: 13.r,
                  color: AppColors.mutedDark,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: Spacing.sm.h),
        Container(
          height: 36.h,
          padding: EdgeInsets.symmetric(horizontal: Spacing.sm.w),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isDense: true,
              isExpanded: true,
              dropdownColor: AppColors.surfaceContainerHigh,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurface,
              ),
              items: items.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }

  /// 开关字段
  Widget _buildSwitchField({
    required String label,
    String? description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.6),
                ),
              ),
              if (description != null)
                Text(
                  description,
                  style: AppTextStyles.tiny.copyWith(
                    color: AppColors.mutedDark,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 24.h,
          width: 42.w,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }
}
