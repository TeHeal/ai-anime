import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/prop.dart';
import 'package:anime_ui/pub/services/api_svc.dart';
import 'package:anime_ui/module/assets/shared/asset_detail_shell.dart';

/// 道具详情面板
class PropDetailPanel extends StatelessWidget {
  const PropDetailPanel({
    super.key,
    required this.prop,
    this.onConfirm,
    required this.onDelete,
    required this.onEdit,
  });

  final Prop prop;
  final VoidCallback? onConfirm;
  final VoidCallback onDelete;
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
                  Icon(
                    AppIcons.category,
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
                ],
              ),
            )
          : null,
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
                prop.name,
                style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
              ),
              SizedBox(width: Spacing.sm.w),
              _statusChip(prop.status),
              if (prop.isKeyProp) ...[
                SizedBox(width: Spacing.sm.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.sm.w,
                    vertical: Spacing.xxs.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
                  ),
                  child: Text(
                    '关键',
                    style: AppTextStyles.tiny.copyWith(
                      color: AppColors.warning.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
              const Spacer(),
              IconButton(
                onPressed: onEdit,
                icon: Icon(AppIcons.edit, size: 16.r),
                tooltip: '编辑',
              ),
            ],
          ),
          if (prop.appearance.isNotEmpty) ...[
            SizedBox(height: Spacing.md.h),
            Text(
              '外观描述',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.55),
              ),
            ),
            SizedBox(height: Spacing.xs.h),
            Text(
              prop.appearance,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
            ),
          ],
        ],
      ),
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
      child: Text(
        label,
        style: AppTextStyles.tiny.copyWith(color: color),
      ),
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
        if (onConfirm != null && !prop.isConfirmed)
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
