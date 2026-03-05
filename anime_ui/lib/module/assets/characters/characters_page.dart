import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/character.dart';
import 'package:anime_ui/pub/widgets/loading.dart';
import 'package:anime_ui/pub/widgets/image_gen/image_gen_config.dart';
import 'package:anime_ui/pub/widgets/image_gen/image_gen_dialog.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';
import 'package:anime_ui/pub/services/api_svc.dart' show ApiException;
import 'package:anime_ui/module/assets/shared/confirm_delete_dialog.dart';
import 'package:anime_ui/module/assets/shared/import_profile_dialog.dart';
import 'package:anime_ui/module/dashboard/providers/provider.dart';
import 'package:anime_ui/module/assets/styles/providers/styles.dart';
import 'package:anime_ui/module/assets/resources/providers/resource_list.dart';
import 'package:anime_ui/module/assets/characters/providers/characters.dart';
import 'package:anime_ui/module/assets/characters/providers/selection.dart';
import 'package:anime_ui/module/assets/characters/widgets/character_create_dialog.dart';
import 'package:anime_ui/module/assets/characters/widgets/character_detail_panel.dart';
import 'package:anime_ui/module/assets/characters/widgets/character_edit_dialog.dart';
import 'package:anime_ui/module/assets/characters/widgets/character_list_panel.dart';
import 'package:anime_ui/module/assets/characters/widgets/character_toolbar.dart';

/// 角色页：列表 + 详情双栏布局
class AssetsCharactersPage extends ConsumerStatefulWidget {
  const AssetsCharactersPage({super.key});

  @override
  ConsumerState<AssetsCharactersPage> createState() =>
      _AssetsCharactersPageState();
}

class _AssetsCharactersPageState extends ConsumerState<AssetsCharactersPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: MotionTokens.durationSlow,
    )..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: MotionTokens.curveStandard),
    );

    Future.microtask(() {
      ref.read(assetCharactersProvider.notifier).load();
      ref.read(dashboardProvider.notifier).load();
      ref.read(resourceListProvider.notifier).load();
      final styles = ref.read(assetStylesProvider);
      if (!styles.hasValue || (styles.value?.isEmpty ?? true)) {
        ref.read(assetStylesProvider.notifier).load();
      }
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncChars = ref.watch(assetCharactersProvider);
    final selectedId = ref.watch(selectedCharIdProvider);
    final statusFilter = ref.watch(charStatusFilterProvider);
    final importanceFilter = ref.watch(charImportanceFilterProvider);
    final roleTypeFilter = ref.watch(charRoleTypeFilterProvider);
    final consistencyFilter = ref.watch(charConsistencyFilterProvider);
    final episodeFilter = ref.watch(assetEpisodeFilterProvider);
    final nameSearch = ref.watch(charNameSearchProvider);

    final toolbar = CharacterToolbar(
      onImportProfile: () => showDialog(
        context: context,
        builder: (_) => const ImportProfileDialog(),
      ),
      onAdd: () => _showAddCharacter(context, ref),
      onAiGenerate: () => ImageGenDialog.show(
        context,
        ref,
        config: ImageGenConfig.character(
          onSaved: (urls, mode, {prompt = '', negativePrompt = ''}) async {
            for (final url in urls) {
              await ref.read(assetCharactersProvider.notifier).add(
                    Character(
                      name: '角色-${DateTime.now().millisecondsSinceEpoch}',
                      imageUrl: url,
                    ),
                  );
            }
          },
        ),
      ),
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
        if (episodeFilter != null) {
          chars = chars
              .where((c) => c.episodeNumbers.contains(episodeFilter))
              .toList();
        }
        if (statusFilter != null) {
          chars = chars.where((c) => c.status == statusFilter).toList();
        }
        if (importanceFilter != null) {
          chars = chars.where((c) => c.importance == importanceFilter).toList();
        }
        if (roleTypeFilter != null) {
          chars = chars.where((c) => c.roleType == roleTypeFilter).toList();
        }
        if (consistencyFilter != null) {
          chars = chars
              .where((c) => c.consistency == consistencyFilter)
              .toList();
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
                          onBatchConfirm: (ids) async {
                            // 1. 检查不完整项
                            final allChars =
                                ref.read(assetCharactersProvider).value ?? [];
                            final selectedChars =
                                allChars.where((c) => ids.contains(c.id)).toList();
                            final incompleteCount = selectedChars.where((c) {
                              return (!c.hasImage && c.referenceImages.isEmpty) ||
                                  (c.voiceName.isEmpty &&
                                      c.roleType != 'narrator') ||
                                  c.appearance.isEmpty;
                            }).length;

                            if (incompleteCount > 0) {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: AppColors.surfaceMutedDarker,
                                  title: Text(
                                    '批量确认',
                                    style: AppTextStyles.h4
                                        .copyWith(color: AppColors.onSurface),
                                  ),
                                  content: Text(
                                    '选中的 ${ids.length} 个角色中，有 $incompleteCount 个信息不完整（缺少图片、声音或描述）。\n\n确认后仍可补充，是否继续？',
                                    style: AppTextStyles.bodyMedium
                                        .copyWith(color: AppColors.muted),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text('取消'),
                                    ),
                                    FilledButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      style: FilledButton.styleFrom(
                                          backgroundColor: AppColors.warning),
                                      child: const Text('强制确认'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed != true) return;
                            }

                            // 2. 执行批量确认
                            try {
                              final n = await ref
                                  .read(assetCharactersProvider.notifier)
                                  .batchConfirm(ids);
                              if (!context.mounted) return;
                              if (n == 0 && ids.isNotEmpty) {
                                showToast(
                                  context,
                                  '未成功确认任何角色，请检查权限或是否已冻结',
                                  isError: true,
                                );
                              } else if (n > 0) {
                                showToast(context, '已确认 $n 个');
                              }
                            } catch (e, _) {
                              if (context.mounted) {
                                final msg = e is ApiException
                                    ? e.message
                                    : '批量确认失败';
                                showToast(context, msg, isError: true);
                              }
                              rethrow;
                            }
                          },
                          onBatchStyleDialog: () =>
                              _showBatchStyleDialog(context),
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
                                onEdit: () =>
                                    _showEditCharacter(context, ref, selected),
                                onAIComplete: () => _handleAIComplete(
                                  context,
                                  ref,
                                  selected,
                                ),
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

  // ─── 空状态 + 未选择提示（带脉冲动画）──────────────────

  Widget _emptyState(Widget toolbar) {
    return Column(
      children: [
        toolbar,
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, child) => Transform.scale(
                    scale: _pulseAnim.value,
                    child: child,
                  ),
                  child: Container(
                    width: 64.r,
                    height: 64.r,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      AppIcons.person,
                      size: 32.r,
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ),
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showAddCharacter(context, ref),
                      icon: Icon(AppIcons.add, size: 18.r),
                      label: const Text('手动添加'),
                    ),
                    SizedBox(width: Spacing.md.w),
                    FilledButton.icon(
                      onPressed: () => ImageGenDialog.show(
                        context,
                        ref,
                        config: ImageGenConfig.character(
                          onSaved: (urls, mode,
                              {prompt = '', negativePrompt = ''}) async {
                            for (final url in urls) {
                              await ref
                                  .read(assetCharactersProvider.notifier)
                                  .add(Character(
                                    name:
                                        '角色-${DateTime.now().millisecondsSinceEpoch}',
                                    imageUrl: url,
                                  ));
                            }
                          },
                        ),
                      ),
                      icon: Icon(AppIcons.magicStick, size: 18.r),
                      label: const Text('AI 生成'),
                      style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary),
                    ),
                  ],
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
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, child) => Opacity(
              opacity: 0.5 + _pulseAnim.value * 0.5,
              child: child,
            ),
            child: Icon(
              AppIcons.person,
              size: 48.r,
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
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

  // ─── Actions ──────────────────────────────────────────

  void _showAddCharacter(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => CharacterCreateDialog(
        onCreated: (data) {
          ref.read(assetCharactersProvider.notifier).add(
                Character(
                  name: data['name'] ?? '',
                  appearance: data['appearance'] ?? '',
                  roleType: data['roleType'] ?? 'human',
                  importance: data['importance'] ?? 'main',
                  personality: data['description'] ?? '',
                  imageUrl: data['imageUrl'] ?? '',
                ),
              );
        },
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

  Future<void> _handleAIComplete(
    BuildContext context,
    WidgetRef ref,
    Character c,
  ) async {
    if (c.id == null) return;
    final count = await ref
        .read(assetCharactersProvider.notifier)
        .batchAIComplete([c.id!]);
    if (mounted) {
      showToast(context, 'AI 补全完成，更新了 $count 项');
    }
  }

  void _showBatchStyleDialog(BuildContext context) {
    final styles = ref.read(assetStylesProvider).value ?? [];
    if (styles.isEmpty) {
      showToast(context, '请先在风格库中创建风格', isInfo: true);
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceMutedDarker,
        title: Text(
          '批量设定风格',
          style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
        ),
        content: SizedBox(
          width: 300.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: styles
                .map(
                  (s) => ListTile(
                    title: Text(
                      s.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    subtitle: s.description.isNotEmpty
                        ? Text(
                            s.description,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.mutedDark,
                            ),
                          )
                        : null,
                    onTap: () {
                      Navigator.pop(ctx);
                      showToast(context, '已设定风格「${s.name}」');
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
