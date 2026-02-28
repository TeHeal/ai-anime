import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/location.dart';
import 'package:anime_ui/module/assets/shared/confirm_delete_dialog.dart';
import 'package:anime_ui/module/assets/locations/providers/locations_provider.dart';
import 'package:anime_ui/module/assets/locations/providers/selection.dart';
import 'package:anime_ui/module/assets/locations/widgets/location_detail_panel.dart';
import 'package:anime_ui/module/assets/locations/widgets/location_edit_dialog.dart';
import 'package:anime_ui/module/assets/locations/widgets/location_list_panel.dart';
import 'package:anime_ui/module/assets/locations/widgets/location_toolbar.dart';

/// 场景/环境页
class AssetsEnvironmentsPage extends ConsumerStatefulWidget {
  const AssetsEnvironmentsPage({super.key});

  @override
  ConsumerState<AssetsEnvironmentsPage> createState() =>
      _AssetsEnvironmentsPageState();
}

class _AssetsEnvironmentsPageState extends ConsumerState<AssetsEnvironmentsPage> {
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
          const Expanded(child: Center(child: CircularProgressIndicator())),
        ],
      ),
      error: (e, _) => Column(
        children: [
          toolbar,
          Expanded(
            child: Center(
              child: Text(
                '加载失败: $e',
                style: TextStyle(color: Colors.red[400]),
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
              child: Row(
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 260,
                      maxWidth: 400,
                    ),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: LocationListPanel(locations: locs),
                    ),
                  ),
                  VerticalDivider(width: 1, color: Colors.grey[800]),
                  Expanded(
                    child: selected != null
                        ? LocationDetailPanel(
                            key: ValueKey(selected.id),
                            location: selected,
                            onConfirm: selected.isConfirmed
                                ? null
                                : () => _handleConfirm(context, ref, selected),
                            onDelete: () =>
                                _confirmDelete(context, ref, selected),
                            onGenerateImage: () =>
                                _handleGenerateImage(context, ref, selected),
                            onEdit: () =>
                                _showEditLocation(context, ref, selected),
                          )
                        : _buildSelectHint(),
                  ),
                ],
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
                Icon(AppIcons.landscape, size: 64, color: Colors.grey[700]),
                const SizedBox(height: 16),
                Text(
                  '暂无场景',
                  style: TextStyle(fontSize: 18, color: Colors.grey[400]),
                ),
                const SizedBox(height: 8),
                Text(
                  '点击 AI 提取资产，或手动添加场景',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () => _showAddLocation(context, ref),
                  icon: const Icon(Icons.add, size: 18),
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
          Icon(AppIcons.landscape, size: 48, color: Colors.grey[700]),
          const SizedBox(height: 12),
          Text(
            '选择左侧场景查看详情',
            style: TextStyle(fontSize: 15, color: Colors.grey[500]),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('场景「${loc.name}」已确认')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('确认场景', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '以下项目尚未完善，确认后仍可补充：',
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
            const SizedBox(height: 10),
            ...warnings.map(
              (w) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(AppIcons.warning, size: 14, color: Colors.orange[400]),
                    const SizedBox(width: 8),
                    Text(
                      w,
                      style:
                          TextStyle(color: Colors.orange[300], fontSize: 13),
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('场景「${loc.name}」已确认')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF22C55E),
            ),
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('场景图生成功能待接入')),
    );
  }
}
