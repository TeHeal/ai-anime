import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/location.dart';
import 'package:anime_ui/pub/utils/url.dart' show resolveFileUrl;
import 'package:anime_ui/module/assets/shared/asset_detail_shell.dart';

/// 场景详情面板
class LocationDetailPanel extends StatelessWidget {
  const LocationDetailPanel({
    super.key,
    required this.location,
    this.onConfirm,
    required this.onDelete,
    this.onGenerateImage,
    required this.onEdit,
  });

  final Location location;
  final VoidCallback? onConfirm;
  final VoidCallback onDelete;
  final VoidCallback? onGenerateImage;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return AssetDetailShell(
      bottomBar: _buildBottomBar(),
      children: [
        if (!location.isConfirmed) _LocationStatusBanner(location: location),
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
              Expanded(child: _LocationStyleCard(location: location)),
              SizedBox(width: Spacing.lg.w),
              Expanded(
                child: _LocationRelatedCard(
                  title: '出场角色',
                  icon: AppIcons.people,
                  iconColor: AppColors.categoryCharacter,
                  hint: '基于剧本解析自动关联',
                ),
              ),
              SizedBox(width: Spacing.lg.w),
              Expanded(
                child: _LocationRelatedCard(
                  title: '涉及道具',
                  icon: AppIcons.category,
                  iconColor: AppColors.categoryProp,
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
                '场景参考图',
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
              image: location.hasImage
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(
                        resolveFileUrl(location.imageUrl),
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: location.hasImage
                ? null
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(AppIcons.landscape, size: 48.r,
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
                  ),
          ),
          SizedBox(height: Spacing.md.h),
          Wrap(
            spacing: Spacing.md.w,
            runSpacing: Spacing.md.h,
            children: [
              _VariantPlaceholder(label: '白天版'),
              _VariantPlaceholder(label: '夜晚版'),
              _VariantPlaceholder(label: '俯瞰图'),
            ],
          ),
          SizedBox(height: Spacing.md.h),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: onGenerateImage,
                icon: Icon(AppIcons.autoAwesome, size: 16.r),
                label: Text(location.isGenerating ? '生成中...' : 'AI 生成'),
              ),
              SizedBox(width: Spacing.sm.w),
              OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(AppIcons.upload, size: 16.r),
                label: const Text('上传'),
              ),
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
          _infoRow('名称', location.name),
          if (location.interiorExterior.isNotEmpty)
            _infoRow('内/外景', location.interiorExterior),
          if (location.time.isNotEmpty) _infoRow('时间段', location.time),
          if (location.atmosphere.isNotEmpty) _infoRow('氛围', location.atmosphere),
          if (location.colorTone.isNotEmpty) _infoRow('色调', location.colorTone),
          if (location.layout.isNotEmpty)
            _infoRow('布局', location.layout, multiLine: true),
          _infoRow('状态', _statusLabel(location.status)),
          _infoRow('来源', _sourceLabel(location.source)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool multiLine = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: Spacing.sm.h),
      child: Row(
        crossAxisAlignment:
            multiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
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
              maxLines: multiLine ? 5 : 1,
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
        if (!location.isConfirmed) ...[
          FilledButton.icon(
            onPressed: onConfirm,
            icon: Icon(AppIcons.check, size: 16.r),
            label: const Text('确认场景'),
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
        OutlinedButton.icon(
          onPressed: onEdit,
          icon: Icon(AppIcons.edit, size: 16.r),
          label: const Text('编辑'),
        ),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: onDelete,
          icon: Icon(AppIcons.delete, size: 16.r),
          label: const Text('删除'),
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
        ),
      ],
    );
  }
}

/// 场景完成度横幅
class _LocationStatusBanner extends StatelessWidget {
  const _LocationStatusBanner({required this.location});
  final Location location;

  @override
  Widget build(BuildContext context) {
    final completeness = _calcCompleteness();
    final missing = <String>[];
    if (!location.hasImage) missing.add('缺少参考图');
    if (location.atmosphere.isEmpty) missing.add('未设定氛围');
    if (location.colorTone.isEmpty) missing.add('未设定色调');

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
                  location.isSkeleton ? '骨架阶段' : '待确认',
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
    int total = 4, done = 0;
    if (location.name.isNotEmpty) done++;
    if (location.hasImage) done++;
    if (location.atmosphere.isNotEmpty) done++;
    if (location.colorTone.isNotEmpty) done++;
    return done / total;
  }
}

/// 风格设定卡片
class _LocationStyleCard extends StatelessWidget {
  const _LocationStyleCard({required this.location});
  final Location location;

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
            location.styleOverride
                ? '个性化风格: ${location.style.isNotEmpty ? location.style : "未设定"}'
                : '跟随统一风格',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
          ),
          if (location.styleNote.isNotEmpty) ...[
            SizedBox(height: Spacing.sm.h),
            Text(
              location.styleNote,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.55),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

/// 关联实体卡片（出场角色 / 涉及道具）
class _LocationRelatedCard extends StatelessWidget {
  const _LocationRelatedCard({
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

/// 场景变体图占位（白天/夜晚/俯瞰等）
class _VariantPlaceholder extends StatelessWidget {
  const _VariantPlaceholder({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80.w,
          height: 56.h,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(AppIcons.add, size: 18.r,
              color: AppColors.onSurface.withValues(alpha: 0.45)),
        ),
        SizedBox(height: Spacing.xs.h),
        Text(
          label,
          style: AppTextStyles.labelTiny.copyWith(
            color: AppColors.onSurface.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}
