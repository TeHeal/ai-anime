import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/prop.dart';
import 'package:anime_ui/pub/utils/url.dart' show resolveFileUrl;
import 'package:anime_ui/module/assets/shared/asset_list_item.dart';
import 'package:anime_ui/module/assets/shared/asset_list_panel.dart';
import 'package:anime_ui/module/assets/shared/asset_status_chip.dart';
import 'package:anime_ui/module/assets/props/providers/selection.dart';

/// 道具列表面板（支持多选）
class PropListPanel extends ConsumerWidget {
  const PropListPanel({
    super.key,
    required this.props,
    this.onBatchConfirm,
  });

  final List<Prop> props;
  final void Function(List<String> ids)? onBatchConfirm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedPropIdProvider);
    final confirmed = props.where((p) => p.isConfirmed).length;

    return AssetListPanel(
      totalCount: props.length,
      confirmedCount: confirmed,
      countLabel: '个道具',
      itemCount: props.length,
      onBatchConfirm: onBatchConfirm,
      allIds: props.map((p) => p.id).whereType<String>().toList(),
      itemBuilder: (context, index, multiSelect, selectedIds) {
        final prop = props[index];
        final isSelected = prop.id == selectedId;
        final isChecked = prop.id != null && selectedIds.contains(prop.id!);
        return AssetListItem(
          name: prop.name,
          isSelected: isSelected,
          onTap: () {
            if (multiSelect && prop.id != null) {
              final panel =
                  context.findAncestorStateOfType<AssetListPanelState>();
              panel?.toggleId(prop.id!);
            } else {
              ref.read(selectedPropIdProvider.notifier).set(prop.id);
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
          thumbnail: _buildThumb(prop),
          subtitleWidget: Row(
            children: [
              AssetStatusChip.fromStatus(prop.status),
              if (prop.isKeyProp) ...[
                SizedBox(width: Spacing.sm.w),
                Icon(
                  AppIcons.bolt,
                  size: 10.r,
                  color: AppColors.warning.withValues(alpha: 0.9),
                ),
              ],
            ],
          ),
          trailing: multiSelect
              ? MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      if (prop.id != null) {
                        final panel = context
                            .findAncestorStateOfType<AssetListPanelState>();
                        panel?.toggleId(prop.id!);
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

  Widget _buildThumb(Prop prop) {
    return Container(
      width: Spacing.thumbnailSize.w,
      height: Spacing.thumbnailSize.h,
      decoration: BoxDecoration(
        color: prop.imageUrl.isNotEmpty
            ? Colors.transparent
            : AppColors.categoryProp.withValues(alpha: 0.12),
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
          ? Icon(AppIcons.category, size: 18.r, color: AppColors.categoryProp)
          : null,
    );
  }
}
