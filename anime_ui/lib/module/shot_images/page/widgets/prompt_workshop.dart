import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/module/shot_images/providers/prompt_assembly.dart';
import 'package:anime_ui/pub/models/shot.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/utils/url.dart' show resolveFileUrl;
import 'package:anime_ui/pub/widgets/app_network_image.dart';

/// 提示词工坊 — 网格展示每个镜头的组装提示词，支持编辑与素材引用预览
class PromptWorkshop extends ConsumerStatefulWidget {
  final List<StoryboardShot> shots;

  const PromptWorkshop({super.key, required this.shots});

  @override
  ConsumerState<PromptWorkshop> createState() => _PromptWorkshopState();
}

class _PromptWorkshopState extends ConsumerState<PromptWorkshop> {
  bool _collapsed = false;

  @override
  Widget build(BuildContext context) {
    final prompts = ref.watch(promptAssemblyProvider);
    final validShots =
        widget.shots.where((s) => s.id != null && s.id!.isNotEmpty).toList();

    final assembled = validShots.where((s) => prompts.containsKey(s.id)).length;
    final edited = prompts.values.where((p) => p.isEdited).length;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(RadiusTokens.card.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOverlay.withValues(alpha: 0.2),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(validShots.length, assembled, edited),
          AnimatedSize(
            duration: MotionTokens.durationMedium,
            curve: MotionTokens.curveStandard,
            alignment: Alignment.topCenter,
            child: _collapsed
                ? const SizedBox.shrink()
                : _buildBody(validShots, prompts),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int total, int assembled, int edited) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _collapsed = !_collapsed),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.cardPadding.w,
            vertical: Spacing.lg.h,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.info.withValues(alpha: _collapsed ? 0.08 : 0.04),
                Colors.transparent,
              ],
            ),
            border: _collapsed
                ? null
                : const Border(
                    bottom: BorderSide(color: AppColors.border),
                  ),
            borderRadius: _collapsed
                ? BorderRadius.circular(RadiusTokens.card.r)
                : BorderRadius.only(
                    topLeft: Radius.circular(RadiusTokens.card.r),
                    topRight: Radius.circular(RadiusTokens.card.r),
                  ),
          ),
          child: Row(
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
                child: Icon(
                  AppIcons.magicStick,
                  size: 18.r,
                  color: AppColors.info,
                ),
              ),
              SizedBox(width: Spacing.md.w),
              Text(
                '提示词工坊',
                style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
              ),
              SizedBox(width: Spacing.md.w),
              _statChip('$assembled/$total 已组装', AppColors.info),
              if (edited > 0) ...[
                SizedBox(width: Spacing.sm.w),
                _statChip('$edited 已调整', AppColors.warning),
              ],
              const Spacer(),
              if (!_collapsed)
                _actionButton(
                  '一键组装',
                  AppIcons.bolt,
                  AppColors.info,
                  () => ref
                      .read(promptAssemblyProvider.notifier)
                      .assembleAll(widget.shots),
                ),
              SizedBox(width: Spacing.md.w),
              AnimatedRotation(
                turns: _collapsed ? -0.25 : 0.0,
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
    List<StoryboardShot> shots,
    Map<String, AssembledPrompt> prompts,
  ) {
    if (prompts.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(Spacing.xxl.r),
        child: Center(
          child: Column(
            children: [
              Icon(
                AppIcons.magicStick,
                size: 48.r,
                color: AppColors.mutedDarker,
              ),
              SizedBox(height: Spacing.lg.h),
              Text(
                '点击「一键组装」自动从脚本数据生成提示词',
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
              ),
              SizedBox(height: Spacing.md.h),
              Text(
                '将自动引用项目风格、角色外观、场景描述',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.mutedDark,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(Spacing.cardPadding.r),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardMinW = 280.0.w;
          final cols = (constraints.maxWidth / cardMinW).floor().clamp(1, 4);
          final cardW =
              (constraints.maxWidth - (cols - 1) * Spacing.gridGap.w) / cols;

          return Wrap(
            spacing: Spacing.gridGap.w,
            runSpacing: Spacing.gridGap.h,
            children: shots.map((shot) {
              final prompt = prompts[shot.id!];
              return SizedBox(
                width: cardW,
                child: _PromptShotCard(
                  shot: shot,
                  prompt: prompt,
                  onEdit: (text) => ref
                      .read(promptAssemblyProvider.notifier)
                      .editPrompt(shot.id!, text),
                  onReset: () => ref
                      .read(promptAssemblyProvider.notifier)
                      .resetPrompt(shot.id!, shot),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _statChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.sm.w,
        vertical: Spacing.xxs.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(RadiusTokens.xxl.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.tiny.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _actionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.md.w,
            vertical: Spacing.sm.h,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(RadiusTokens.xxl.r),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14.r, color: color),
              SizedBox(width: Spacing.xs.w),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 单个镜头的提示词卡片
class _PromptShotCard extends StatefulWidget {
  final StoryboardShot shot;
  final AssembledPrompt? prompt;
  final ValueChanged<String> onEdit;
  final VoidCallback onReset;

  const _PromptShotCard({
    required this.shot,
    this.prompt,
    required this.onEdit,
    required this.onReset,
  });

  @override
  State<_PromptShotCard> createState() => _PromptShotCardState();
}

class _PromptShotCardState extends State<_PromptShotCard> {
  bool _editing = false;
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.prompt?.assembled ?? '');
  }

  @override
  void didUpdateWidget(covariant _PromptShotCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editing && widget.prompt?.assembled != oldWidget.prompt?.assembled) {
      _ctrl.text = widget.prompt?.assembled ?? '';
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.prompt;
    final shotLabel =
        'S${(widget.shot.sortIndex + 1).toString().padLeft(2, '0')}';
    final hasPrompt = p != null && p.assembled.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
        border: Border.all(
          color: p?.isEdited == true
              ? AppColors.warning.withValues(alpha: 0.4)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 镜头头部信息
          _buildShotHeader(shotLabel),
          // 素材引用
          if (p != null) _buildAssetRefs(p),
          // 提示词区域
          _buildPromptArea(hasPrompt),
        ],
      ),
    );
  }

  Widget _buildShotHeader(String shotLabel) {
    final shot = widget.shot;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.md.w,
        vertical: Spacing.sm.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(RadiusTokens.xl.r),
          topRight: Radius.circular(RadiusTokens.xl.r),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.sm.w,
              vertical: Spacing.xxs.h,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.info.withValues(alpha: 0.2),
                  AppColors.info.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(RadiusTokens.xxl.r),
            ),
            child: Text(
              shotLabel,
              style: AppTextStyles.tiny.copyWith(
                color: AppColors.info,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: Spacing.sm.w),
          if (shot.cameraType?.isNotEmpty == true) ...[
            Text(
              shot.cameraType!,
              style: AppTextStyles.tiny.copyWith(color: AppColors.mutedLight),
            ),
            SizedBox(width: Spacing.xs.w),
          ],
          if (shot.cameraAngle?.isNotEmpty == true)
            Text(
              shot.cameraAngle!,
              style: AppTextStyles.tiny.copyWith(color: AppColors.mutedDark),
            ),
          const Spacer(),
          Text(
            '${shot.duration}s',
            style: AppTextStyles.tiny.copyWith(color: AppColors.mutedDark),
          ),
          if (widget.prompt?.isEdited == true) ...[
            SizedBox(width: Spacing.xs.w),
            Icon(AppIcons.edit, size: 10.r, color: AppColors.warning),
          ],
        ],
      ),
    );
  }

  Widget _buildAssetRefs(AssembledPrompt p) {
    final hasChar =
        p.characterName != null && p.characterName!.isNotEmpty;
    final hasLoc = p.locationName != null && p.locationName!.isNotEmpty;
    final hasStyle = p.styleName != null && p.styleName!.isNotEmpty;

    if (!hasChar && !hasLoc && !hasStyle) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.md.w,
        vertical: Spacing.xs.h,
      ),
      child: Wrap(
        spacing: Spacing.xs.w,
        runSpacing: Spacing.xs.h,
        children: [
          if (hasStyle) _refTag(p.styleName!, AppColors.categoryStyle, null),
          if (hasChar)
            _refTag(
              p.characterName!,
              AppColors.categoryCharacter,
              p.characterImageUrl,
            ),
          if (hasLoc)
            _refTag(
              p.locationName!,
              AppColors.categoryLocation,
              p.locationImageUrl,
            ),
        ],
      ),
    );
  }

  Widget _refTag(String name, Color color, String? imageUrl) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.sm.w,
        vertical: Spacing.xxs.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(RadiusTokens.xxl.r),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (imageUrl != null && imageUrl.isNotEmpty) ...[
            ClipOval(
              child: SizedBox(
                width: 14.r,
                height: 14.r,
                child: AppNetworkImage(
                  url: resolveFileUrl(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: Spacing.xs.w),
          ],
          Text(
            name,
            style: AppTextStyles.labelTiny.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptArea(bool hasPrompt) {
    return Padding(
      padding: EdgeInsets.all(Spacing.md.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_editing)
            _buildEditMode()
          else
            _buildDisplayMode(hasPrompt),
          SizedBox(height: Spacing.sm.h),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildDisplayMode(bool hasPrompt) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 48.h),
      padding: EdgeInsets.all(Spacing.sm.r),
      decoration: BoxDecoration(
        color: AppColors.inputBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(RadiusTokens.md.r),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Text(
        hasPrompt ? widget.prompt!.assembled : '未组装',
        style: AppTextStyles.tiny.copyWith(
          color: hasPrompt ? AppColors.mutedLight : AppColors.mutedDarker,
          height: 1.5,
        ),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildEditMode() {
    return TextField(
      controller: _ctrl,
      maxLines: 5,
      minLines: 3,
      style: AppTextStyles.tiny.copyWith(
        color: AppColors.onSurface,
        height: 1.5,
      ),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.all(Spacing.sm.r),
        filled: true,
        fillColor: AppColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md.r),
          borderSide: const BorderSide(color: AppColors.info),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md.r),
          borderSide: BorderSide(color: AppColors.info.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md.r),
          borderSide: const BorderSide(color: AppColors.info),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        if (_editing) ...[
          _miniBtn('保存', AppIcons.check, AppColors.success, () {
            widget.onEdit(_ctrl.text);
            setState(() => _editing = false);
          }),
          SizedBox(width: Spacing.xs.w),
          _miniBtn('取消', AppIcons.close, AppColors.muted, () {
            _ctrl.text = widget.prompt?.assembled ?? '';
            setState(() => _editing = false);
          }),
        ] else ...[
          _miniBtn('编辑', AppIcons.edit, AppColors.info, () {
            setState(() => _editing = true);
          }),
          if (widget.prompt?.isEdited == true) ...[
            SizedBox(width: Spacing.xs.w),
            _miniBtn('重置', AppIcons.refresh, AppColors.warning, widget.onReset),
          ],
        ],
      ],
    );
  }

  Widget _miniBtn(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.sm.w,
            vertical: Spacing.xxs.h,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 11.r, color: color),
              SizedBox(width: Spacing.xxs.w),
              Text(
                label,
                style: AppTextStyles.labelTiny.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
