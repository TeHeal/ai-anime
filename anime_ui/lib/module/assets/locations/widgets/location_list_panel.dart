import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/location.dart';
import 'package:anime_ui/pub/utils/url.dart' show resolveFileUrl;
import 'package:anime_ui/module/assets/shared/asset_list_item.dart';
import 'package:anime_ui/module/assets/shared/asset_list_panel.dart';
import 'package:anime_ui/module/assets/shared/asset_status_chip.dart';
import 'package:anime_ui/module/assets/locations/providers/selection.dart';

/// 场景列表面板（支持多选）
class LocationListPanel extends ConsumerWidget {
  const LocationListPanel({
    super.key,
    required this.locations,
    this.onBatchConfirm,
  });

  final List<Location> locations;
  final void Function(List<String> ids)? onBatchConfirm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedLocIdProvider);
    final confirmed = locations.where((l) => l.isConfirmed).length;

    return AssetListPanel(
      totalCount: locations.length,
      confirmedCount: confirmed,
      countLabel: '个场景',
      itemCount: locations.length,
      onBatchConfirm: onBatchConfirm,
      allIds: locations.map((l) => l.id).whereType<String>().toList(),
      itemBuilder: (context, index, multiSelect, selectedIds) {
        final loc = locations[index];
        final isSelected = loc.id == selectedId;
        final isChecked = loc.id != null && selectedIds.contains(loc.id!);
        return AssetListItem(
          name: loc.name,
          isSelected: isSelected,
          onTap: () {
            if (multiSelect && loc.id != null) {
              final panel =
                  context.findAncestorStateOfType<AssetListPanelState>();
              panel?.toggleId(loc.id!);
            } else {
              ref.read(selectedLocIdProvider.notifier).set(loc.id);
            }
          },
          leading: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: Spacing.tinyGap.w,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
            ),
          ),
          thumbnail: _buildThumb(loc),
          titleTrailing: loc.interiorExterior.isNotEmpty
              ? Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.xs.w,
                    vertical: Spacing.xxs.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
                  ),
                  child: Text(
                    loc.interiorExterior,
                    style: AppTextStyles.labelTiny.copyWith(
                      color: AppColors.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                )
              : null,
          subtitleWidget: Row(
            children: [
              AssetStatusChip.fromStatus(loc.status),
              if (loc.time.isNotEmpty) ...[
                SizedBox(width: Spacing.sm.w),
                Text(
                  loc.time,
                  style: AppTextStyles.labelTiny.copyWith(
                    color: AppColors.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
              if (loc.hasImage) ...[
                SizedBox(width: Spacing.sm.w),
                Icon(
                  AppIcons.image,
                  size: 10.r,
                  color: AppColors.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ],
          ),
          trailing: multiSelect
              ? MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      if (loc.id != null) {
                        final panel = context
                            .findAncestorStateOfType<AssetListPanelState>();
                        panel?.toggleId(loc.id!);
                      }
                    },
                    child: Icon(
                      isChecked ? AppIcons.check : AppIcons.circleOutline,
                      size: 18.r,
                      color: isChecked
                          ? AppColors.primary
                          : AppColors.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildThumb(Location location) {
    return Container(
      width: Spacing.thumbnailSize.w,
      height: Spacing.thumbnailSize.h,
      decoration: BoxDecoration(
        color: location.hasImage
            ? Colors.transparent
            : AppColors.info.withValues(alpha: 0.12),
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
          : Icon(AppIcons.landscape, size: 18.r, color: AppColors.info),
    );
  }
}
