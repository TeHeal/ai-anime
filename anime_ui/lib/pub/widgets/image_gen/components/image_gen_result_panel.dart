import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/gen_form_helpers.dart';
import 'package:anime_ui/pub/widgets/model_selector/model_selector.dart';
import '../image_gen_config.dart';
import '../image_gen_controller.dart';
import 'gen_result_grid.dart';
import 'output_count_bar.dart';
import 'ratio_picker.dart';

/// 图生右侧面板 — 上部可折叠参数配置 + 下部生成预览
///
/// 参数区（比例/分辨率/模型）在生成完成后自动折叠，让图片结果占满空间。
/// 用户可随时手动展开/折叠。
class ImageGenResultPanel extends StatefulWidget {
  const ImageGenResultPanel({
    super.key,
    required this.config,
    required this.ctrl,
    required this.accent,
    required this.isSaving,
    required this.onSave,
    required this.onImageTap,
  });

  final ImageGenConfig config;
  final ImageGenController ctrl;
  final Color accent;
  final bool isSaving;
  final VoidCallback onSave;
  final void Function(String) onImageTap;

  @override
  State<ImageGenResultPanel> createState() => _ImageGenResultPanelState();
}

class _ImageGenResultPanelState extends State<ImageGenResultPanel> {
  bool _configExpanded = true;
  GenControllerState? _prevStatus;

  ImageGenConfig get config => widget.config;
  ImageGenController get ctrl => widget.ctrl;
  Color get accent => widget.accent;

  @override
  void initState() {
    super.initState();
    _prevStatus = ctrl.status;
    ctrl.addListener(_onCtrlChanged);
  }

  @override
  void dispose() {
    ctrl.removeListener(_onCtrlChanged);
    super.dispose();
  }

  /// 生成完成时自动折叠参数区；重置时自动展开
  void _onCtrlChanged() {
    final cur = ctrl.status;
    if (_prevStatus != cur) {
      if (cur == GenControllerState.done && _configExpanded) {
        setState(() => _configExpanded = false);
      } else if (cur == GenControllerState.idle && !_configExpanded) {
        setState(() => _configExpanded = true);
      }
      _prevStatus = cur;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Spacing.mid.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 可折叠参数配置区 ──
          _buildCollapsibleConfig(),

          SizedBox(height: Spacing.lg.h),

          // ── 生成预览区 ──
          Row(
            children: [
              Text(
                '生成预览',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                ),
              ),
              const Spacer(),
              OutputCountBar(
                value: ctrl.outputCount,
                maxCount: config.maxOutputCount,
                accent: accent,
                onChanged: ctrl.setOutputCount,
              ),
            ],
          ),
          SizedBox(height: Spacing.sm.h),

          Expanded(
            child: GenResultGrid(
              results: ctrl.results,
              isGenerating: ctrl.isGenerating,
              progress: ctrl.progress,
              accent: accent,
              outputCount: ctrl.outputCount,
              onImageTap: widget.onImageTap,
              selectedIndices: ctrl.selectedIndices,
              selectionEnabled: ctrl.selectedIndices.isNotEmpty,
              onToggleSelect: ctrl.toggleSelection,
            ),
          ),

          if (ctrl.hasError && ctrl.errorMsg != null) ...[
            SizedBox(height: Spacing.md.h),
            _buildError(ctrl.errorMsg!),
          ],

          if (ctrl.isDone && ctrl.results.isNotEmpty) ...[
            SizedBox(height: Spacing.md.h),
            _buildResultActions(context),
          ],
        ],
      ),
    );
  }

  /// 参数区：带折叠/展开动画和切换按钮
  Widget _buildCollapsibleConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => setState(() => _configExpanded = !_configExpanded),
            child: Row(
              children: [
                Text(
                  '参数配置',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
                SizedBox(width: Spacing.xs.w),
                AnimatedRotation(
                  turns: _configExpanded ? 0.0 : -0.25,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.expand_more_rounded,
                    size: 16.r,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: Padding(
            padding: EdgeInsets.only(top: Spacing.sm.h),
            child: _buildConfigSection(),
          ),
          secondChild: const SizedBox.shrink(),
          crossFadeState: _configExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 250),
          sizeCurve: Curves.easeInOut,
        ),
      ],
    );
  }

  /// 宽高比 + 分辨率 + 模型选择器
  Widget _buildConfigSection() {
    return Container(
      padding: EdgeInsets.all(Spacing.md.r),
      decoration: genSelectBoxDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RatioPicker(
            selectedRatio: ctrl.ratio,
            selectedResolution: ctrl.resolution,
            allowedRatios: config.allowedRatios,
            accent: accent,
            onRatioChanged: ctrl.setRatio,
            onResolutionChanged: ctrl.setResolution,
          ),
          SizedBox(height: Spacing.sm.h),
          ModelSelector(
            serviceType: 'image',
            accent: accent,
            selected: ctrl.selectedModel,
            style: ModelSelectorStyle.dialog,
            onChanged: ctrl.setModel,
          ),
          if (ctrl.sizeValidationError != null) ...[
            SizedBox(height: Spacing.sm.h),
            Row(
              children: [
                Icon(
                  AppIcons.warning,
                  size: (AppTextStyles.bodySmall.fontSize ?? 13).r,
                  color: AppColors.warning,
                ),
                SizedBox(width: Spacing.xs.w),
                Text(
                  ctrl.sizeValidationError!,
                  style: AppTextStyles.tiny.copyWith(color: AppColors.warning),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildError(String msg) {
    return Container(
      padding: EdgeInsets.all(Spacing.md.r),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(RadiusTokens.md.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(AppIcons.error, size: Spacing.lg.r, color: AppColors.error),
          SizedBox(width: Spacing.sm.w),
          Expanded(
            child: Text(
              msg,
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultActions(BuildContext context) {
    final hasSelection = ctrl.selectedIndices.isNotEmpty;
    final saveCount = hasSelection
        ? ctrl.selectedIndices.length
        : ctrl.results.length;

    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: ctrl.reset,
          icon: Icon(AppIcons.refresh, size: 14.r),
          label: const Text('重新生成'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.muted,
            side: const BorderSide(color: AppColors.border),
          ),
        ),
        if (ctrl.results.length > 1) ...[
          SizedBox(width: Spacing.sm.w),
          TextButton(
            onPressed: hasSelection ? ctrl.deselectAll : ctrl.selectAll,
            child: Text(
              hasSelection ? '取消选择' : '选择',
              style: AppTextStyles.caption.copyWith(color: accent),
            ),
          ),
        ],
        const Spacer(),
        FilledButton.icon(
          onPressed: widget.isSaving ? null : widget.onSave,
          icon: widget.isSaving
              ? SizedBox(
                  width: Spacing.gridGap.w,
                  height: Spacing.gridGap.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.r,
                    color: AppColors.onSurface,
                  ),
                )
              : Icon(AppIcons.save, size: 14.r),
          label: Text('保存 $saveCount 张'),
          style: FilledButton.styleFrom(backgroundColor: accent),
        ),
      ],
    );
  }
}
