import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/character.dart';
import 'package:anime_ui/pub/widgets/image_gen/image_gen_config.dart';
import 'package:anime_ui/pub/widgets/image_gen/image_gen_dialog.dart';
import 'package:anime_ui/pub/widgets/loading.dart';
import 'package:anime_ui/module/assets/shared/confirm_delete_dialog.dart';
import 'package:anime_ui/module/assets/shared/extract_dialog.dart';
import 'package:anime_ui/module/assets/shared/import_profile_dialog.dart';
import 'package:anime_ui/module/assets/characters/providers/characters.dart';
import 'package:anime_ui/module/assets/characters/providers/selection.dart';
import 'package:anime_ui/module/assets/characters/widgets/character_detail_panel.dart';
import 'package:anime_ui/module/assets/characters/widgets/character_edit_dialog.dart';
import 'package:anime_ui/module/assets/characters/widgets/character_list_panel.dart';
import 'package:anime_ui/module/assets/characters/widgets/character_toolbar.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';

/// 角色页：列表 + 详情双栏布局
class AssetsCharactersPage extends ConsumerStatefulWidget {
  const AssetsCharactersPage({super.key});

  @override
  ConsumerState<AssetsCharactersPage> createState() =>
      _AssetsCharactersPageState();
}

class _AssetsCharactersPageState extends ConsumerState<AssetsCharactersPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(assetCharactersProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncChars = ref.watch(assetCharactersProvider);
    final selectedId = ref.watch(selectedCharIdProvider);
    final statusFilter = ref.watch(charStatusFilterProvider);
    final importanceFilter = ref.watch(charImportanceFilterProvider);
    final roleTypeFilter = ref.watch(charRoleTypeFilterProvider);
    final nameSearch = ref.watch(charNameSearchProvider);

    final toolbar = CharacterToolbar(
      onExtract: () => showDialog(
        context: context,
        builder: (_) => const AssetExtractDialog(),
      ),
      onImportProfile: () => showDialog(
        context: context,
        builder: (_) => const ImportProfileDialog(),
      ),
      onAdd: () => _showAddCharacter(context, ref),
    );

    return asyncChars.when(
      loading: () => Column(
        children: [
          toolbar,
          const Expanded(child: Center(child: LoadingSpinner())),
        ],
      ),
      error: (e, _) => Column(
        children: [
          toolbar,
          Expanded(
            child: Center(
              child: Text(
                '加载失败: $e',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
              ),
            ),
          ),
        ],
      ),
      data: (allChars) {
        var chars = allChars.toList();
        if (statusFilter != null) {
          chars = chars.where((c) => c.status == statusFilter).toList();
        }
        if (importanceFilter != null) {
          chars = chars.where((c) => c.importance == importanceFilter).toList();
        }
        if (roleTypeFilter != null) {
          chars = chars.where((c) => c.roleType == roleTypeFilter).toList();
        }
        if (nameSearch.isNotEmpty) {
          final query = nameSearch.toLowerCase();
          chars = chars
              .where((c) => c.name.toLowerCase().contains(query))
              .toList();
        }
        if (chars.isEmpty) return _emptyState(toolbar);

        final selected = selectedId != null
            ? allChars.where((c) => c.id == selectedId).firstOrNull
            : null;

        return Column(
          children: [
            toolbar,
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final panelW = w < Breakpoints.md
                      ? (w * 0.4).clamp(
                          Spacing.listPanelMinWidth.w,
                          w * 0.6,
                        )
                      : (w * 0.25).clamp(
                          Spacing.listPanelMinWidth.w,
                          Spacing.listPanelMaxWidth.w,
                        );
                  return Row(
                    children: [
                      SizedBox(
                        width: panelW,
                        child: CharacterListPanel(
                          characters: chars,
                          onBatchConfirm: (ids) {
                            ref
                                .read(assetCharactersProvider.notifier)
                                .batchConfirm(ids);
                            showToast(context, '已批量确认');
                          },
                          onBatchStyleDialog: () => _showBatchStylePlaceholder(
                            context,
                          ),
                        ),
                      ),
                      VerticalDivider(
                        width: 1.w,
                        color: AppColors.divider,
                      ),
                      Expanded(
                        child: selected != null
                            ? CharacterDetailPanel(
                                key: ValueKey(selected.id),
                                character: selected,
                                onConfirm: selected.isConfirmed
                                    ? null
                                    : () => _handleConfirm(
                                          context,
                                          ref,
                                          selected,
                                        ),
                                onDelete: () =>
                                    _confirmDelete(context, ref, selected),
                                onGenerateImage: () => _handleGenerateImage(
                                  context,
                                  ref,
                                  selected,
                                ),
                                onEdit: () =>
                                    _showEditCharacter(context, ref, selected),
                              )
                            : _buildSelectHint(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _emptyState(Widget toolbar) {
    return Column(
      children: [
        toolbar,
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  AppIcons.person,
                  size: 64.r,
                  color: AppColors.surfaceMuted,
                ),
                SizedBox(height: Spacing.lg.h),
                Text(
                  '暂无角色',
                  style: AppTextStyles.h3.copyWith(color: AppColors.muted),
                ),
                SizedBox(height: Spacing.sm.h),
                Text(
                  '点击 AI 提取资产，或手动添加角色',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.mutedDarker,
                  ),
                ),
                SizedBox(height: Spacing.mid.h),
                OutlinedButton.icon(
                  onPressed: () => _showAddCharacter(context, ref),
                  icon: Icon(AppIcons.add, size: 18.r),
                  label: const Text('手动添加'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectHint() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppIcons.person,
            size: 48.r,
            color: AppColors.surfaceMuted,
          ),
          SizedBox(height: Spacing.md.h),
          Text(
            '选择左侧角色查看详情',
            style: AppTextStyles.bodyXLarge.copyWith(
              color: AppColors.mutedDark,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCharacter(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => CharacterEditDialog(
        title: '新建角色',
        onSave: (c) =>
            ref.read(assetCharactersProvider.notifier).add(c),
      ),
    );
  }

  void _showEditCharacter(
    BuildContext context,
    WidgetRef ref,
    Character character,
  ) {
    showDialog(
      context: context,
      builder: (_) => CharacterEditDialog(
        title: '编辑角色 - ${character.name}',
        initial: character,
        onSave: (updated) => ref
            .read(assetCharactersProvider.notifier)
            .update(updated.copyWith(id: character.id)),
      ),
    );
  }

  void _handleConfirm(
    BuildContext context,
    WidgetRef ref,
    Character c,
  ) {
    final warnings = <String>[];
    if (!c.hasImage && c.referenceImages.isEmpty) {
      warnings.add('缺少形象图');
    }
    if (c.voiceName.isEmpty && c.roleType != 'narrator') {
      warnings.add('未设定声音');
    }
    if (c.appearance.isEmpty) {
      warnings.add('缺少外貌描述');
    }

    if (warnings.isEmpty) {
      ref.read(assetCharactersProvider.notifier).confirm(c.id!);
      showToast(context, '角色「${c.name}」已确认');
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceMutedDarker,
        title: Text(
          '确认角色',
          style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '以下项目尚未完善，确认后仍可补充：',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
            ),
            SizedBox(height: Spacing.md.h),
            ...warnings.map(
              (w) => Padding(
                padding: EdgeInsets.only(bottom: Spacing.sm.h),
                child: Row(
                  children: [
                    Icon(
                      AppIcons.warning,
                      size: 14.r,
                      color: AppColors.warning,
                    ),
                    SizedBox(width: Spacing.sm.w),
                    Text(
                      w,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('先去补充'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(assetCharactersProvider.notifier).confirm(c.id!);
              showToast(context, '角色「${c.name}」已确认');
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('仍然确认'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGenerateImage(
    BuildContext context,
    WidgetRef ref,
    Character c,
  ) async {
    if (c.isGenerating || c.id == null) return;

    await ImageGenDialog.show(
      context,
      ref,
      config: ImageGenConfig.character(
        onSaved: (urls, mode, {prompt = '', negativePrompt = ''}) async {
          if (urls.isEmpty || c.id == null) return;
          await ref.read(assetCharactersProvider.notifier).addReferenceImage(
                c.id!,
                angle: 'front',
                url: urls.first,
                genMeta: {'prompt': prompt, 'negativePrompt': negativePrompt},
              );
        },
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Character c,
  ) async {
    final confirmed = await showConfirmDeleteDialog(
      context,
      title: '确认删除',
      content: '确定要删除角色 "${c.name}" 吗？',
    );
    if (confirmed == true) {
      ref.read(assetCharactersProvider.notifier).remove(c.id!);
      ref.read(selectedCharIdProvider.notifier).set(null);
    }
  }

  void _showBatchStylePlaceholder(BuildContext context) {
    showToast(context, '风格 API 就绪后可批量设定', isInfo: true);
  }
}
