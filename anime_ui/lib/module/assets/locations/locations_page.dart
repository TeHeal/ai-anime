import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/loading.dart';
import 'package:anime_ui/pub/models/location.dart';
import 'package:anime_ui/module/assets/shared/confirm_delete_dialog.dart';
import 'package:anime_ui/module/assets/locations/providers/list.dart';
import 'package:anime_ui/module/assets/locations/providers/selection.dart';
import 'package:anime_ui/module/assets/locations/widgets/location_detail_panel.dart';
import 'package:anime_ui/module/assets/locations/widgets/location_edit_dialog.dart';
import 'package:anime_ui/module/assets/locations/widgets/location_list_panel.dart';
import 'package:anime_ui/module/assets/locations/widgets/location_toolbar.dart';

/// 场景/地点页（locations）
class AssetsLocationsPage extends ConsumerStatefulWidget {
  const AssetsLocationsPage({super.key});

  @override
  ConsumerState<AssetsLocationsPage> createState() =>
      _AssetsLocationsPageState();
}

class _AssetsLocationsPageState extends ConsumerState<AssetsLocationsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(assetLocationsProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncLocs = ref.watch(assetLocationsProvider);
    final selectedId = ref.watch(selectedLocIdProvider);
    final statusFilter = ref.watch(locStatusFilterProvider);
    final nameSearch = ref.watch(locNameSearchProvider);

    final toolbar = LocationToolbar(
      onAdd: () => _showAddLocation(context, ref),
    );

    return asyncLocs.when(
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
      data: (allLocs) {
        var locs = allLocs.toList();
        if (statusFilter != null) {
          locs = locs.where((l) => l.status == statusFilter).toList();
        }
        if (nameSearch.isNotEmpty) {
          final query = nameSearch.toLowerCase();
          locs = locs
              .where((l) => l.name.toLowerCase().contains(query))
              .toList();
        }
        if (locs.isEmpty) return _emptyState(toolbar);

        final selected = selectedId != null
            ? allLocs.where((l) => l.id == selectedId).firstOrNull
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
                        child: LocationListPanel(locations: locs),
                      ),
                      VerticalDivider(width: 1.w, color: AppColors.divider),
                      Expanded(
                        child: selected != null
                            ? LocationDetailPanel(
                                key: ValueKey(selected.id),
                                location: selected,
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
                                    _showEditLocation(context, ref, selected),
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
                  AppIcons.landscape,
                  size: 64.r,
                  color: AppColors.surfaceMuted,
                ),
                SizedBox(height: Spacing.lg.h),
                Text(
                  '暂无场景',
                  style: AppTextStyles.h3.copyWith(color: AppColors.muted),
                ),
                SizedBox(height: Spacing.sm.h),
                Text(
                  '点击 AI 提取资产，或手动添加场景',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.mutedDarker,
                  ),
                ),
                SizedBox(height: Spacing.mid.h),
                OutlinedButton.icon(
                  onPressed: () => _showAddLocation(context, ref),
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
          Icon(AppIcons.landscape, size: 48.r, color: AppColors.surfaceMuted),
          SizedBox(height: Spacing.md.h),
          Text(
            '选择左侧场景查看详情',
            style: AppTextStyles.bodyXLarge.copyWith(
              color: AppColors.mutedDark,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddLocation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => LocationEditDialog(
        title: '新建场景',
        onSave: (loc) => ref.read(assetLocationsProvider.notifier).add(loc),
      ),
    );
  }

  void _showEditLocation(BuildContext context, WidgetRef ref, Location loc) {
    showDialog(
      context: context,
      builder: (_) => LocationEditDialog(
        title: '编辑场景 - ${loc.name}',
        initial: loc,
        onSave: (updated) =>
            ref.read(assetLocationsProvider.notifier).update(updated),
      ),
    );
  }

  void _handleConfirm(BuildContext context, WidgetRef ref, Location loc) {
    final warnings = <String>[];
    if (!loc.hasImage) warnings.add('缺少参考图');
    if (loc.atmosphere.isEmpty) warnings.add('未设定氛围');
    if (loc.colorTone.isEmpty) warnings.add('未设定色调');

    if (warnings.isEmpty) {
      ref.read(assetLocationsProvider.notifier).confirm(loc.id!);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('场景「${loc.name}」已确认')));
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceMutedDarker,
        title: Text(
          '确认场景',
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
              ref.read(assetLocationsProvider.notifier).confirm(loc.id!);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('场景「${loc.name}」已确认')));
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('仍然确认'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Location loc) async {
    final confirmed = await showConfirmDeleteDialog(
      context,
      title: '确认删除',
      content: '确定要删除场景 "${loc.name}" 吗？',
    );
    if (confirmed == true) {
      ref.read(assetLocationsProvider.notifier).remove(loc.id!);
      ref.read(selectedLocIdProvider.notifier).set(null);
    }
  }

  Future<void> _handleGenerateImage(
    BuildContext context,
    WidgetRef ref,
    Location loc,
  ) async {
    if (loc.isGenerating) return;
    // TODO: 接入 ImageGenDialog
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('场景图生成功能待接入')));
  }
}
