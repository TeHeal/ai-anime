import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/character.dart';
import 'package:anime_ui/pub/utils/url.dart' show resolveFileUrl;
import 'package:anime_ui/module/assets/shared/asset_list_item.dart';
import 'package:anime_ui/module/assets/shared/asset_status_chip.dart';
import 'package:anime_ui/module/assets/characters/providers/selection.dart';

/// 角色列表面板：统计、多选、批量确认、列表项
class CharacterListPanel extends ConsumerStatefulWidget {
  const CharacterListPanel({
    super.key,
    required this.characters,
    required this.onBatchConfirm,
    this.onBatchStyleDialog,
  });

  final List<Character> characters;
  final Future<void> Function(List<String> ids) onBatchConfirm;
  final VoidCallback? onBatchStyleDialog;

  @override
  ConsumerState<CharacterListPanel> createState() =>
      _CharacterListPanelState();
}

class _CharacterListPanelState extends ConsumerState<CharacterListPanel> {
  bool _multiSelect = false;
  final Set<String> _selectedIds = {};

  static int _importanceWeight(String imp) => switch (imp) {
        'main' => 0,
        'support' => 1,
        'functional' => 2,
        'extra' => 3,
        _ => 4,
      };

  List<Character> _sortChars(List<Character> chars) {
    final sorted = List<Character>.from(chars);
    sorted.sort((a, b) {
      final impA = _importanceWeight(a.importance);
      final impB = _importanceWeight(b.importance);
      if (impA != impB) return impA.compareTo(impB);
      final statusA = a.isDraft ? 0 : (a.isSkeleton ? 1 : 2);
      final statusB = b.isDraft ? 0 : (b.isSkeleton ? 1 : 2);
      if (statusA != statusB) return statusA.compareTo(statusB);
      return a.name.compareTo(b.name);
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final selectedId = ref.watch(selectedCharIdProvider);
    final sorted = _sortChars(widget.characters);
    final confirmed =
        widget.characters.where((c) => c.isConfirmed).length;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            Spacing.lg.w,
            Spacing.sm.h,
            Spacing.lg.w,
            Spacing.sm.h,
          ),
          child: Row(
            children: [
              Text(
                '${widget.characters.length} 个角色',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(width: Spacing.sm.w),
              Icon(AppIcons.check, size: 12.r, color: AppColors.success),
              Text(
                ' $confirmed',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.7),
                ),
              ),
              if (_multiSelect) ...[
                SizedBox(width: Spacing.md.w),
                Text(
                  '已选 ${_selectedIds.length}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _multiSelect = false;
                      _selectedIds.clear();
                    }),
                    child: Text(
                      '取消多选',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                const Spacer(),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => setState(() => _multiSelect = true),
                    child: Text(
                      '多选',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_multiSelect)
          Padding(
            padding: EdgeInsets.fromLTRB(Spacing.lg.w, 0, Spacing.lg.w, Spacing.sm.h),
            child: Wrap(
              spacing: Spacing.sm.w,
              runSpacing: Spacing.sm.h,
              children: [
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      final ids = sorted.map((c) => c.id).whereType<String>().toSet();
                      final allSelected =
                          ids.isNotEmpty && ids.every((id) => _selectedIds.contains(id));
                      if (allSelected) {
                        _selectedIds.removeWhere(ids.contains);
                      } else {
                        _selectedIds.addAll(ids);
                      }
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: Spacing.sm.w,
                      vertical: Spacing.xs.h,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    _selectedIds.length == sorted.length && sorted.isNotEmpty
                        ? '取消选择'
                        : '当前全选',
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _selectedIds.isEmpty
                      ? null
                      : () async {
                          final ids = _selectedIds.toList();
                          await widget.onBatchConfirm(ids);
                          if (mounted) {
                            setState(() {
                              _selectedIds.clear();
                              _multiSelect = false;
                            });
                          }
                        },
                  icon: Icon(AppIcons.check, size: 14.r),
                  label: Text(
                    _selectedIds.isEmpty ? '确认' : '确认 ${_selectedIds.length}',
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: Spacing.sm.w,
                      vertical: Spacing.xs.h,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                if (widget.onBatchStyleDialog != null)
                  OutlinedButton.icon(
                    onPressed: _selectedIds.isEmpty ? null : widget.onBatchStyleDialog,
                    icon: Icon(AppIcons.brush, size: 14.r),
                    label: const Text('风格'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: Spacing.sm.w,
                        vertical: Spacing.xs.h,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: Spacing.sm.w),
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final c = sorted[index];
              final isSelected = c.id == selectedId;
              final isChecked = c.id != null && _selectedIds.contains(c.id!);
              return AssetListItem(
                name: c.name,
                isSelected: isSelected,
                onTap: () {
                  if (_multiSelect && c.id != null) {
                    setState(() {
                      if (_selectedIds.contains(c.id!)) {
                        _selectedIds.remove(c.id!);
                      } else {
                        _selectedIds.add(c.id!);
                      }
                    });
                  } else {
                    ref.read(selectedCharIdProvider.notifier).set(c.id);
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
                thumbnail: _buildThumb(c),
                titleTrailing: c.importanceLabel.isNotEmpty
                    ? Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Spacing.xs.w,
                          vertical: Spacing.xxs.h,
                        ),
                        decoration: BoxDecoration(
                          color: c.importance == 'main'
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : AppColors.surfaceContainerHighest,
                          borderRadius:
                              BorderRadius.circular(RadiusTokens.xs.r),
                        ),
                        child: Text(
                          c.importanceLabel,
                          style: AppTextStyles.labelTiny.copyWith(
                            color: c.importance == 'main'
                                ? AppColors.primary
                                : AppColors.onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                      )
                    : null,
                subtitleWidget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AssetStatusChip.fromStatus(c.status),
                        if (c.variants.isNotEmpty) ...[
                          SizedBox(width: Spacing.sm.w),
                          Text(
                            '${c.variants.length}变体',
                            style: AppTextStyles.labelTiny.copyWith(
                              color: AppColors.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                        if (c.hasBio) ...[
                          SizedBox(width: Spacing.sm.w),
                          Icon(
                            AppIcons.document,
                            size: 10.r,
                            color: AppColors.onSurface.withValues(alpha: 0.5),
                          ),
                        ],
                        if (c.voiceName.isNotEmpty) ...[
                          SizedBox(width: Spacing.sm.w),
                          Icon(
                            AppIcons.mic,
                            size: 10.r,
                            color: AppColors.onSurface.withValues(alpha: 0.5),
                          ),
                        ],
                      ],
                    ),
                    if (c.tags.isNotEmpty) ...[
                      SizedBox(height: Spacing.xxs.h),
                      Text(
                        c.tags.join(' · '),
                        style: AppTextStyles.labelTiny.copyWith(
                          color: AppColors.onSurface.withValues(alpha: 0.45),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
                trailing: _multiSelect
                    ? MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            if (c.id != null) {
                              setState(() {
                                if (_selectedIds.contains(c.id!)) {
                                  _selectedIds.remove(c.id!);
                                } else {
                                  _selectedIds.add(c.id!);
                                }
                              });
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
          ),
        ),
      ],
    );
  }

  Widget _buildThumb(Character c) {
    final url = c.referenceImages.isNotEmpty
        ? (c.referenceImages.first['url'] as String? ?? '')
        : c.imageUrl;
    final hasImage = url.isNotEmpty;

    return Container(
      width: Spacing.thumbnailSize.w,
      height: Spacing.thumbnailSize.h,
      decoration: BoxDecoration(
        color: hasImage
            ? Colors.transparent
            : AppColors.categoryCharacter.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
        image: hasImage
            ? DecorationImage(
                image: CachedNetworkImageProvider(resolveFileUrl(url)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: hasImage
          ? null
          : Center(
              child: Text(
                c.name.isNotEmpty ? c.name.characters.first : '?',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.categoryCharacter,
                ),
              ),
            ),
    );
  }
}
