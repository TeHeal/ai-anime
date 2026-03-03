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
        _buildImageCard(),
        SizedBox(height: Spacing.lg.h),
        _buildInfoCard(),
      ],
    );
  }

  Widget _buildImageCard() {
    return Container(
      width: double.infinity,
      height: 200.h,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
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
                  Icon(
                    AppIcons.landscape,
                    size: 48.r,
                    color: AppColors.onSurface.withValues(alpha: 0.5),
                  ),
                  SizedBox(height: Spacing.sm.h),
                  Text(
                    '暂无参考图',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                  if (onGenerateImage != null) ...[
                    SizedBox(height: Spacing.md.h),
                    OutlinedButton.icon(
                      onPressed: onGenerateImage,
                      icon: Icon(AppIcons.autoAwesome, size: 14.r),
                      label: const Text('AI 生成'),
                    ),
                  ],
                ],
              ),
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
              Text(
                location.name,
                style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
              ),
              SizedBox(width: Spacing.sm.w),
              _statusChip(location.status),
              const Spacer(),
              IconButton(
                onPressed: onEdit,
                icon: Icon(AppIcons.edit, size: 16.r),
                tooltip: '编辑',
              ),
            ],
          ),
          if (location.time.isNotEmpty) ...[
            SizedBox(height: Spacing.sm.h),
            _infoRow('时间', location.time),
          ],
          if (location.interiorExterior.isNotEmpty) ...[
            SizedBox(height: Spacing.xs.h),
            _infoRow('内外景', location.interiorExterior),
          ],
          if (location.atmosphere.isNotEmpty) ...[
            SizedBox(height: Spacing.xs.h),
            _infoRow('氛围', location.atmosphere),
          ],
          if (location.colorTone.isNotEmpty) ...[
            SizedBox(height: Spacing.xs.h),
            _infoRow('色调', location.colorTone),
          ],
          if (location.styleNote.isNotEmpty) ...[
            SizedBox(height: Spacing.xs.h),
            _infoRow('风格备注', location.styleNote),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: Spacing.formLabelWidth.w,
          child: Text(
            '$label：',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
          ),
        ),
      ],
    );
  }

  Widget _statusChip(String status) {
    final (String label, Color color) = switch (status) {
      'confirmed' => ('已确认', AppColors.success),
      'skeleton' => ('骨架', AppColors.onSurface),
      _ => ('待确认', AppColors.newTag),
    };
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.sm.w,
        vertical: Spacing.xxs.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
      ),
      child: Text(label, style: AppTextStyles.tiny.copyWith(color: color)),
    );
  }

  Widget _buildBottomBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: onDelete,
          icon: Icon(AppIcons.delete, size: 14.r),
          label: const Text('删除'),
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
        ),
        SizedBox(width: Spacing.sm.w),
        if (onConfirm != null && !location.isConfirmed)
          FilledButton.icon(
            onPressed: onConfirm,
            icon: Icon(AppIcons.check, size: 14.r),
            label: const Text('确认'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.success),
          ),
      ],
    );
  }
}
