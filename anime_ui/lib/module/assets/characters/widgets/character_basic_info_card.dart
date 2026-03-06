import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/character.dart';
import 'package:anime_ui/pub/widgets/form_field_helpers.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';
import 'package:anime_ui/module/assets/characters/providers/characters.dart';

/// 角色基础信息 + 人物小传卡片
class CharacterBasicInfoCard extends ConsumerStatefulWidget {
  const CharacterBasicInfoCard({
    super.key,
    required this.character,
    required this.onEdit,
  });

  final Character character;
  final VoidCallback onEdit;

  @override
  ConsumerState<CharacterBasicInfoCard> createState() =>
      _CharacterBasicInfoCardState();
}

class _CharacterBasicInfoCardState
    extends ConsumerState<CharacterBasicInfoCard> {
  bool _bioLoading = false;

  Character get c => widget.character;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Spacing.lg.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(RadiusTokens.card.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── 名称 + 编辑 ───
          Row(
            children: [
              Expanded(
                child: Text(
                  c.name.isEmpty ? '未命名' : c.name,
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(AppIcons.edit, size: 16.r, color: AppColors.muted),
                tooltip: '编辑基础信息',
                onPressed: widget.onEdit,
                constraints: BoxConstraints(
                  minWidth: 28.r,
                  minHeight: 28.r,
                ),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          SizedBox(height: Spacing.sm.h),
          // ─── 状态 + 来源 行内标签 ───
          Wrap(
            spacing: Spacing.sm.w,
            runSpacing: Spacing.xs.h,
            children: [
              _statusChip(c.status),
              _sourceChip(c.source),
            ],
          ),
          SizedBox(height: Spacing.md.h),
          // ─── 类型 / 重要度 / 一致性 紧凑排列 ───
          _buildMetaGrid(),
          // ─── 标签 ───
          if (c.tags.isNotEmpty) ...[
            SizedBox(height: Spacing.md.h),
            Wrap(
              spacing: Spacing.xs.w,
              runSpacing: Spacing.xs.h,
              children: c.tags.map((t) => _tagChip(t)).toList(),
            ),
          ],
          // ─── 分割线 + 人物小传 ───
          Padding(
            padding: EdgeInsets.only(top: Spacing.lg.h),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          SizedBox(height: Spacing.md.h),
          _buildBioSection(),
        ],
      ),
    );
  }

  /// 类型 / 重要度 / 一致性 — 紧凑的标签值对
  Widget _buildMetaGrid() {
    return Wrap(
      spacing: Spacing.lg.w,
      runSpacing: Spacing.sm.h,
      children: [
        _metaItem(
          '类型',
          c.roleTypeLabel.isNotEmpty ? c.roleTypeLabel : '未设定',
          c.roleTypeLabel.isNotEmpty,
        ),
        _metaItem(
          '重要度',
          c.importanceLabel.isNotEmpty ? c.importanceLabel : '未设定',
          c.importanceLabel.isNotEmpty,
        ),
        _metaItem(
          '一致性',
          c.consistencyLabel.isNotEmpty ? c.consistencyLabel : '未设定',
          c.consistencyLabel.isNotEmpty,
        ),
      ],
    );
  }

  Widget _metaItem(String label, String value, bool hasValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.tiny.copyWith(color: AppColors.mutedDark),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            color: hasValue ? AppColors.onSurface : AppColors.mutedDark,
            fontWeight: hasValue ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _statusChip(String status) {
    final (String label, Color color) = switch (status) {
      'confirmed' => ('已确认', AppColors.success),
      'skeleton' => ('骨架', AppColors.warning),
      _ => ('待确认', AppColors.newTag),
    };
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.sm.w,
        vertical: 2.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
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

  Widget _sourceChip(String source) {
    final label = switch (source) {
      'skeleton' => '剧本识别',
      'auto_extract' => 'AI提取',
      'story_extract' => '深度提取',
      'profile_import' => '角色库导入',
      'character_lib' => '角色库',
      _ => '手动添加',
    };
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.sm.w,
        vertical: 2.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedDarker,
        borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.tiny.copyWith(color: AppColors.muted),
      ),
    );
  }

  Widget _tagChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.sm.w,
        vertical: Spacing.xxs.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.tiny.copyWith(color: AppColors.primary),
      ),
    );
  }

  // ─── 小传 ───

  Widget _buildBioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '人物小传',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const Spacer(),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _showEditBioDialog,
                child: Icon(
                  AppIcons.edit,
                  size: 14.r,
                  color: AppColors.muted,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: Spacing.sm.h),
        if (c.bio.isEmpty)
          Text(
            '暂无小传，可通过 AI 从剧本中自动提取',
            style: AppTextStyles.caption.copyWith(color: AppColors.mutedDark),
          )
        else
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _showEditBioDialog,
              child: Text(
                c.bio,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.onSurface,
                  height: 1.6,
                ),
              ),
            ),
          ),
        SizedBox(height: Spacing.sm.h),
        OutlinedButton.icon(
          onPressed: _bioLoading ? null : _handleBioExtractOrRegenerate,
          icon: _bioLoading
              ? SizedBox(
                  width: 12.r,
                  height: 12.r,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(AppIcons.autoAwesome, size: 12.r),
          label: Text(
            _bioLoading
                ? '生成中...'
                : c.hasBio
                    ? '重新生成'
                    : 'AI 生成',
            style: AppTextStyles.tiny,
          ),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.md.w,
              vertical: Spacing.xs.h,
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  Future<void> _handleBioExtractOrRegenerate() async {
    if (c.id == null) return;
    setState(() => _bioLoading = true);
    try {
      if (c.hasBio) {
        await ref
            .read(assetCharactersProvider.notifier)
            .regenerateBio(c.id!);
        if (mounted) showToast(context, '小传已重新生成');
      } else {
        await ref
            .read(assetCharactersProvider.notifier)
            .extractBio(c.id!);
        if (mounted) showToast(context, '小传已生成');
      }
    } catch (e) {
      if (mounted) showToast(context, '生成失败: $e', isError: true);
    } finally {
      if (mounted) setState(() => _bioLoading = false);
    }
  }

  void _showEditBioDialog() {
    final controller = TextEditingController(text: c.bio);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceMutedDarker,
        title: Text(
          '编辑人物小传',
          style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
        ),
        content: SizedBox(
          width: 480.w,
          child: TextField(
            controller: controller,
            maxLines: 10,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurface,
            ),
            decoration: darkInputDecoration('输入人物小传...'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              '取消',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              final bio = controller.text.trim();
              if (c.id != null) {
                ref
                    .read(assetCharactersProvider.notifier)
                    .updateBio(c.id!, bio);
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('保存'),
          ),
        ],
      ),
    ).then((_) => controller.dispose());
  }
}
