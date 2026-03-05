import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/character.dart';
import 'package:anime_ui/module/assets/shared/variant_editor.dart';
import 'package:anime_ui/module/assets/shared/confirm_delete_dialog.dart';
import 'package:anime_ui/module/assets/characters/providers/characters.dart';

/// 默认折叠时显示的变体数量
const _collapsedCount = 6;

/// 角色变体卡片：展示变体标签列表，支持新增/编辑/删除
class CharacterVariantsCard extends ConsumerStatefulWidget {
  const CharacterVariantsCard({super.key, required this.character});

  final Character character;

  @override
  ConsumerState<CharacterVariantsCard> createState() =>
      _CharacterVariantsCardState();
}

class _CharacterVariantsCardState extends ConsumerState<CharacterVariantsCard> {
  bool _expanded = false;

  Character get c => widget.character;

  void _showAddVariant() {
    showDialog(
      context: context,
      builder: (_) => VariantEditorDialog(
        title: '新增变体',
        onSave: ({
          required String label,
          String? appearance,
          int? episodeId,
          String? sceneId,
        }) {
          if (c.id == null) return;
          ref.read(assetCharactersProvider.notifier).addVariant(
                c.id!,
                label: label,
                appearance: appearance,
                episodeId: episodeId?.toString(),
                sceneId: sceneId,
              );
        },
      ),
    );
  }

  void _showEditVariant(int idx, Map<String, dynamic> v) {
    showDialog(
      context: context,
      builder: (_) => VariantEditorDialog(
        title: '编辑变体',
        initialLabel: v['label'] as String? ?? '',
        initialAppearance: v['appearance'] as String? ?? '',
        initialSceneId: v['scene_id'] as String?,
        onSave: ({
          required String label,
          String? appearance,
          int? episodeId,
          String? sceneId,
        }) {
          if (c.id == null) return;
          ref.read(assetCharactersProvider.notifier).updateVariant(
                c.id!,
                idx,
                label: label,
                appearance: appearance,
              );
        },
      ),
    );
  }

  Future<void> _confirmDeleteVariant(int idx, String label) async {
    final confirmed = await showConfirmDeleteDialog(
      context,
      title: '删除变体',
      content: '确定要删除变体「$label」吗？',
    );
    if (confirmed == true && c.id != null) {
      ref.read(assetCharactersProvider.notifier).deleteVariant(c.id!, idx);
    }
  }

  @override
  Widget build(BuildContext context) {
    final variants = c.variants;
    final displayList = _expanded
        ? variants
        : variants.take(_collapsedCount).toList();
    final hasMore = variants.length > _collapsedCount;

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
              Text(
                '形象变体',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _showAddVariant,
                icon: Icon(AppIcons.add, size: 18.r),
                tooltip: '新增变体',
                constraints: BoxConstraints(
                  minWidth: 32.r,
                  minHeight: 32.r,
                ),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          SizedBox(height: Spacing.md.h),
          if (variants.isEmpty)
            Text(
              '暂无变体，点击右上角新增',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.mutedDark,
              ),
            )
          else ...[
            Wrap(
              spacing: Spacing.sm.w,
              runSpacing: Spacing.sm.h,
              children: displayList.asMap().entries.map((entry) {
                final idx = entry.key;
                final v = entry.value;
                final label = v['label'] as String? ?? '变体${idx + 1}';
                return _VariantChip(
                  label: label,
                  onTap: () => _showEditVariant(idx, v),
                  onLongPress: () => _confirmDeleteVariant(idx, label),
                );
              }).toList(),
            ),
            if (hasMore)
              Padding(
                padding: EdgeInsets.only(top: Spacing.sm.h),
                child: GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Text(
                    _expanded ? '收起' : '展开更多 (${variants.length})',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// 单个变体标签
class _VariantChip extends StatelessWidget {
  const _VariantChip({
    required this.label,
    this.onTap,
    this.onLongPress,
  });

  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.chipPaddingH.w,
          vertical: Spacing.chipPaddingVSmall.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(RadiusTokens.md.r),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.25),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}
