import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/character.dart';

/// 角色基础信息卡片：姓名、状态、来源、类型、重要度、一致性、标签
class CharacterBasicInfoCard extends StatelessWidget {
  const CharacterBasicInfoCard({
    super.key,
    required this.character,
    required this.onEdit,
  });

  final Character character;
  final VoidCallback onEdit;

  Character get c => character;

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
                onPressed: onEdit,
                constraints: BoxConstraints(
                  minWidth: 28.r,
                  minHeight: 28.r,
                ),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          SizedBox(height: Spacing.md.h),
          _infoRow('状态', _statusLabel(c.status)),
          _infoRow('来源', _sourceLabel(c.source)),
          _infoRow(
            '类型',
            c.roleTypeLabel.isNotEmpty ? c.roleTypeLabel : '未设定',
          ),
          _infoRow(
            '重要度',
            c.importanceLabel.isNotEmpty ? c.importanceLabel : '未设定',
          ),
          _infoRow(
            '一致性',
            c.consistencyLabel.isNotEmpty ? c.consistencyLabel : '未设定',
          ),
          if (c.tags.isNotEmpty) ...[
            SizedBox(height: Spacing.sm.h),
            _buildTagSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildTagSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '标签',
          style: AppTextStyles.caption.copyWith(color: AppColors.muted),
        ),
        SizedBox(height: Spacing.xs.h),
        Wrap(
          spacing: Spacing.sm.w,
          runSpacing: Spacing.xs.h,
          children: c.tags.map((t) => _chip(t)).toList(),
        ),
      ],
    );
  }

  Widget _chip(String label) {
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

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: Spacing.sm.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: Spacing.formLabelWidth.w,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
            ),
          ),
          SizedBox(width: Spacing.md.w),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  static String _statusLabel(String status) => switch (status) {
        'confirmed' => '已确认',
        'skeleton' => '骨架',
        _ => '待确认',
      };

  static String _sourceLabel(String source) => switch (source) {
        'skeleton' => '剧本识别',
        'auto_extract' => 'AI提取',
        'story_extract' => '剧本深度提取',
        'profile_import' => '角色库导入',
        'character_lib' => '角色库',
        _ => '手动添加',
      };
}
