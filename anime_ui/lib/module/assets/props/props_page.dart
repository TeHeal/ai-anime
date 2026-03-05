import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/loading.dart';
import 'package:anime_ui/pub/models/prop.dart';
import 'package:anime_ui/pub/widgets/image_gen/image_gen_config.dart';
import 'package:anime_ui/pub/widgets/image_gen/image_gen_dialog.dart';
import 'package:anime_ui/module/assets/shared/confirm_delete_dialog.dart';
import 'package:anime_ui/module/assets/props/providers/list.dart';
import 'package:anime_ui/module/assets/props/providers/selection.dart';
import 'package:anime_ui/module/assets/props/widgets/prop_detail_panel.dart';
import 'package:anime_ui/module/assets/props/widgets/prop_edit_dialog.dart';
import 'package:anime_ui/module/assets/props/widgets/prop_list_panel.dart';
import 'package:anime_ui/module/assets/props/widgets/prop_toolbar.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';
import 'package:anime_ui/pub/services/api_svc.dart' show ApiException;

/// 道具页
class AssetsPropsPage extends ConsumerStatefulWidget {
  const AssetsPropsPage({super.key});

  @override
  ConsumerState<AssetsPropsPage> createState() => _AssetsPropsPageState();
}

class _AssetsPropsPageState extends ConsumerState<AssetsPropsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(assetPropsProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final asyncProps = ref.watch(assetPropsProvider);
    final selectedId = ref.watch(selectedPropIdProvider);
    final statusFilter = ref.watch(propStatusFilterProvider);
    final nameSearch = ref.watch(propNameSearchProvider);

    final toolbar = PropToolbar(
      onAdd: () => _showAddProp(context, ref),
      onAiGenerate: () => ImageGenDialog.show(
        context,
        ref,
        config: ImageGenConfig.prop(
          onSaved: (urls, mode, {prompt = '', negativePrompt = ''}) async {
            for (final url in urls) {
              await ref.read(assetPropsProvider.notifier).add(
                    Prop(
                      name: '道具-${DateTime.now().millisecondsSinceEpoch}',
                      imageUrl: url,
                    ),
                  );
            }
          },
        ),
      ),
    );

    return asyncProps.when(
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
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ),
        ],
      ),
      data: (allProps) {
        var props = allProps.toList();
        if (statusFilter != null) {
          props = props.where((p) => p.status == statusFilter).toList();
        }
        if (nameSearch.isNotEmpty) {
          final q = nameSearch.toLowerCase();
          props = props.where((p) => p.name.toLowerCase().contains(q)).toList();
        }
        if (props.isEmpty) return _emptyState(toolbar);

        final selected = selectedId != null
            ? allProps.where((p) => p.id == selectedId).firstOrNull
            : null;

        return Column(
          children: [
            toolbar,
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final panelW = w < Breakpoints.md
                      ? (w * 0.4).clamp(Spacing.listPanelMinWidth.w, w * 0.6)
                      : (w * 0.25).clamp(
                          Spacing.listPanelMinWidth.w,
                          Spacing.listPanelMaxWidth.w,
                        );
                  return Row(
                    children: [
                      SizedBox(
                        width: panelW,
                        child: PropListPanel(
                          props: props,
                          onBatchConfirm: (ids) async {
                            // 1. 检查不完整项
                            final allProps =
                                ref.read(assetPropsProvider).value ?? [];
                            final selectedProps =
                                allProps.where((p) => ids.contains(p.id)).toList();
                            final incompleteCount = selectedProps.where((p) {
                              return p.imageUrl.isEmpty || p.appearance.isEmpty;
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
                                    '选中的 ${ids.length} 个道具中，有 $incompleteCount 个信息不完整（缺少图片或描述）。\n\n确认后仍可补充，是否继续？',
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
                                  .read(assetPropsProvider.notifier)
                                  .batchConfirm(ids);
                              if (!context.mounted) return;
                              if (n == 0 && ids.isNotEmpty) {
                                showToast(
                                  context,
                                  '未成功确认任何道具，请检查权限或是否已冻结',
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
                            }
                          },
                        ),
                      ),
                      VerticalDivider(width: 1.w, color: AppColors.divider),
                      Expanded(
                        child: selected != null
                            ? PropDetailPanel(
                                key: ValueKey(selected.id),
                                prop: selected,
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
                                    _showEditProp(context, ref, selected),
                                onAiGenerate: () => ImageGenDialog.show(
                                  context,
                                  ref,
                                  config: ImageGenConfig.prop(
                                    onSaved: (urls, mode,
                                        {prompt = '',
                                        negativePrompt = ''}) async {
                                      if (urls.isNotEmpty) {
                                        await ref
                                            .read(
                                                assetPropsProvider.notifier)
                                            .update(selected.copyWith(
                                                imageUrl: urls.first));
                                      }
                                    },
                                  ),
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
                  AppIcons.category,
                  size: 64.r,
                  color: AppColors.surfaceMuted,
                ),
                SizedBox(height: Spacing.lg.h),
                Text(
                  '暂无道具',
                  style: AppTextStyles.h3.copyWith(color: AppColors.muted),
                ),
                SizedBox(height: Spacing.sm.h),
                Text(
                  '点击 AI 提取资产，或手动添加道具',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.mutedDarker,
                  ),
                ),
                SizedBox(height: Spacing.mid.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showAddProp(context, ref),
                      icon: Icon(AppIcons.add, size: 18.r),
                      label: const Text('手动添加'),
                    ),
                    SizedBox(width: Spacing.md.w),
                    FilledButton.icon(
                      onPressed: () => ImageGenDialog.show(
                        context,
                        ref,
                        config: ImageGenConfig.prop(
                          onSaved: (urls, mode,
                              {prompt = '', negativePrompt = ''}) async {
                            for (final url in urls) {
                              await ref
                                  .read(assetPropsProvider.notifier)
                                  .add(Prop(
                                    name:
                                        '道具-${DateTime.now().millisecondsSinceEpoch}',
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
          Icon(AppIcons.category, size: 48.r, color: AppColors.surfaceMuted),
          SizedBox(height: Spacing.md.h),
          Text(
            '选择左侧道具查看详情',
            style: AppTextStyles.bodyXLarge.copyWith(
              color: AppColors.mutedDark,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddProp(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => PropEditDialog(
        title: '新建道具',
        onSave: (prop) => ref.read(assetPropsProvider.notifier).add(prop),
      ),
    );
  }

  void _showEditProp(BuildContext context, WidgetRef ref, Prop prop) {
    showDialog(
      context: context,
      builder: (_) => PropEditDialog(
        title: '编辑道具',
        initial: prop,
        onSave: (updated) {
          ref
              .read(assetPropsProvider.notifier)
              .update(updated.copyWith(id: prop.id));
        },
      ),
    );
  }

  void _handleConfirm(BuildContext context, WidgetRef ref, Prop prop) {
    final warnings = <String>[];
    if (prop.imageUrl.isEmpty) warnings.add('缺少参考图');
    if (prop.appearance.isEmpty) warnings.add('缺少外观描述');

    if (warnings.isEmpty) {
      ref.read(assetPropsProvider.notifier).confirm(prop.id!);
      showToast(context, '道具「${prop.name}」已确认');
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceMutedDarker,
        title: Text(
          '确认道具',
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
              ref.read(assetPropsProvider.notifier).confirm(prop.id!);
              showToast(context, '道具「${prop.name}」已确认');
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('仍然确认'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Prop prop) async {
    final confirmed = await showConfirmDeleteDialog(
      context,
      title: '确认删除',
      content: '确定要删除道具 "${prop.name}" 吗？',
    );
    if (confirmed == true) {
      ref.read(assetPropsProvider.notifier).remove(prop.id!);
      ref.read(selectedPropIdProvider.notifier).set(null);
    }
  }
}
