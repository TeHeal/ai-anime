import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/prop.dart';
import 'package:anime_ui/pub/utils/url.dart' show resolveFileUrl;
import 'package:anime_ui/module/assets/shared/asset_detail_shell.dart';

/// 道具详情面板
class PropDetailPanel extends StatelessWidget {
  const PropDetailPanel({
    super.key,
    required this.prop,
    this.onConfirm,
    required this.onDelete,
    required this.onEdit,
    this.onAiGenerate,
  });

  final Prop prop;
  final VoidCallback? onConfirm;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback? onAiGenerate;

  @override
  Widget build(BuildContext context) {
    return AssetDetailShell(
      bottomBar: _buildBottomBar(),
      children: [
        if (!prop.isConfirmed) _PropStatusBanner(prop: prop),
        SizedBox(height: Spacing.lg.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: _buildImageCard(),
            ),
            SizedBox(width: Spacing.lg.w),
            Expanded(
              flex: 4,
              child: _buildInfoCard(),
            ),
          ],
        ),
        SizedBox(height: Spacing.lg.h),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _PropStyleCard(prop: prop)),
              SizedBox(width: Spacing.lg.w),
              Expanded(
                child: _PropRelatedCard(
                  title: '关联角色',
                  icon: AppIcons.people,
                  iconColor: AppColors.categoryCharacter,
                  hint: '基于剧本解析自动关联',
                ),
              ),
              SizedBox(width: Spacing.lg.w),
              Expanded(
                child: _PropRelatedCard(
                  title: '关联场景',
                  icon: AppIcons.landscape,
                  iconColor: AppColors.info,
                  hint: '基于剧本解析自动关联',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageCard() {
    return Container(
      padding: EdgeInsets.all(Spacing.lg.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppIcons.image, size: 16.r,
                  color: AppColors.onSurface.withValues(alpha: 0.55)),
              SizedBox(width: Spacing.sm.w),
              Text(
                '道具参考图',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: Spacing.md.h),
          Container(
            height: 200.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
              image: prop.imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(
                        resolveFileUrl(prop.imageUrl),
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: prop.imageUrl.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(AppIcons.category, size: 48.r,
                            color: AppColors.onSurface.withValues(alpha: 0.5)),
                        SizedBox(height: Spacing.sm.h),
                        Text(
                          '暂无参考图',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
          ),
          SizedBox(height: Spacing.md.h),
          Row(
            children: [
              FilledButton.icon(
                onPressed: () {},
                icon: Icon(AppIcons.upload, size: 16.r),
                label: const Text('上传'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.surfaceContainerHigh,
                  foregroundColor: AppColors.onSurface.withValues(alpha: 0.8),
                ),
              ),
              if (onAiGenerate != null) ...[
                SizedBox(width: Spacing.sm.w),
                FilledButton.icon(
                  onPressed: onAiGenerate,
                  icon: Icon(AppIcons.magicStick, size: 16.r),
                  label: const Text('AI 生成'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(Spacing.lg.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppIcons.info, size: 16.r,
                  color: AppColors.onSurface.withValues(alpha: 0.55)),
              SizedBox(width: Spacing.sm.w),
              Text(
                '基础信息',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onEdit,
                child: Icon(AppIcons.edit, size: 14.r,
                    color: AppColors.onSurface.withValues(alpha: 0.55)),
              ),
            ],
          ),
          Divider(height: Spacing.mid.h, color: AppColors.border),
          _infoRow('名称', prop.name),
          _infoRow('状态', _statusLabel(prop.status)),
          _infoRow('来源', _sourceLabel(prop.source)),
          if (prop.isKeyProp) _infoRow('类型', '关键道具'),
          if (prop.appearance.isNotEmpty) ...[
            SizedBox(height: Spacing.sm.h),
            Text(
              '外观描述',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.55),
              ),
            ),
            SizedBox(height: Spacing.xs.h),
            Text(
              prop.appearance,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurface,
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: Spacing.sm.h),
      child: Row(
        children: [
          SizedBox(
            width: Spacing.formLabelWidth.w,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ),
          SizedBox(width: Spacing.md.w),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String s) => switch (s) {
        'confirmed' => '已确认',
        'skeleton' => '骨架',
        _ => '待确认',
      };

  String _sourceLabel(String s) => switch (s) {
        'skeleton' => '剧本识别',
        'auto_extract' => 'AI提取',
        _ => '手动添加',
      };

  Widget _buildBottomBar() {
    return Row(
      children: [
        if (!prop.isConfirmed) ...[
          FilledButton.icon(
            onPressed: onConfirm,
            icon: Icon(AppIcons.check, size: 16.r),
            label: const Text('确认道具'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.mid.w,
                vertical: Spacing.md.h,
              ),
            ),
          ),
          SizedBox(width: Spacing.md.w),
        ],
        FilledButton.icon(
          onPressed: onEdit,
          icon: Icon(AppIcons.edit, size: 16.r),
          label: const Text('编辑'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.surfaceContainerHigh,
            foregroundColor: AppColors.onSurface.withValues(alpha: 0.8),
          ),
        ),
        const Spacer(),
        FilledButton.icon(
          onPressed: onDelete,
          icon: Icon(AppIcons.delete, size: 16.r),
          label: const Text('删除'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error.withValues(alpha: 0.12),
            foregroundColor: AppColors.error,
          ),
        ),
      ],
    );
  }
}

/// 道具完成度横幅
class _PropStatusBanner extends StatelessWidget {
  const _PropStatusBanner({required this.prop});
  final Prop prop;

  @override
  Widget build(BuildContext context) {
    final completeness = _calcCompleteness();
    final missing = <String>[];
    if (prop.imageUrl.isEmpty) missing.add('缺少参考图');
    if (prop.appearance.isEmpty) missing.add('缺少外观描述');

    final bannerColor =
        completeness >= 0.8 ? AppColors.success : AppColors.newTag;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.lg.w,
        vertical: Spacing.md.h,
      ),
      decoration: BoxDecoration(
        color: bannerColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
        border: Border.all(color: bannerColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36.r,
            height: 36.r,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: completeness,
                  strokeWidth: 3,
                  backgroundColor: AppColors.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(bannerColor),
                ),
                Text(
                  '${(completeness * 100).round()}%',
                  style: AppTextStyles.labelTiny.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: Spacing.md.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prop.isSkeleton ? '骨架阶段' : '待确认',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                if (missing.isNotEmpty) ...[
                  SizedBox(height: Spacing.xxs.h),
                  Text(
                    missing.join(' · '),
                    style: AppTextStyles.labelTiny.copyWith(
                      color: AppColors.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calcCompleteness() {
    int total = 3, done = 0;
    if (prop.name.isNotEmpty) done++;
    if (prop.imageUrl.isNotEmpty) done++;
    if (prop.appearance.isNotEmpty) done++;
    return done / total;
  }
}

/// 风格设定卡片
class _PropStyleCard extends StatelessWidget {
  const _PropStyleCard({required this.prop});
  final Prop prop;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Spacing.lg.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppIcons.brush, size: 16.r,
                  color: AppColors.onSurface.withValues(alpha: 0.55)),
              SizedBox(width: Spacing.sm.w),
              Text(
                '风格设定',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: Spacing.md.h),
          Text(
            prop.styleOverride
                ? '个性化风格: ${prop.style.isNotEmpty ? prop.style : "未设定"}'
                : '跟随统一风格',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
          ),
        ],
      ),
    );
  }
}

/// 关联实体卡片（关联角色 / 关联场景）
class _PropRelatedCard extends StatelessWidget {
  const _PropRelatedCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.hint,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Spacing.lg.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.r, color: iconColor),
              SizedBox(width: Spacing.sm.w),
              Text(
                title,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: Spacing.md.h),
          Container(
            padding: EdgeInsets.all(Spacing.md.r),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            ),
            child: Row(
              children: [
                Icon(AppIcons.autoAwesome, size: 14.r,
                    color: AppColors.onSurface.withValues(alpha: 0.45)),
                SizedBox(width: Spacing.sm.w),
                Text(
                  hint,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
