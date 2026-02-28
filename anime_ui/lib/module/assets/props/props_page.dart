import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/prop.dart';
import 'package:anime_ui/module/assets/shared/confirm_delete_dialog.dart';
import 'package:anime_ui/module/assets/props/providers/props_provider.dart';
import 'package:anime_ui/module/assets/props/providers/props_providers.dart';
import 'package:anime_ui/module/assets/props/widgets/prop_detail_panel.dart';
import 'package:anime_ui/module/assets/props/widgets/prop_edit_dialog.dart';
import 'package:anime_ui/module/assets/props/widgets/prop_list_panel.dart';
import 'package:anime_ui/module/assets/props/widgets/prop_toolbar.dart';

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

    final toolbar = PropToolbar(onAdd: () => _showAddProp(context, ref));

    return asyncProps.when(
      loading: () => Column(
        children: [toolbar, const Expanded(child: Center(child: CircularProgressIndicator()))],
      ),
      error: (e, _) => Column(
        children: [
          toolbar,
          Expanded(child: Center(child: Text('加载失败: $e', style: TextStyle(color: Colors.red[400])))),
        ],
      ),
      data: (allProps) {
        var props = allProps.toList();
        if (statusFilter != null) props = props.where((p) => p.status == statusFilter).toList();
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
              child: Row(
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 260, maxWidth: 400),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: PropListPanel(props: props),
                    ),
                  ),
                  VerticalDivider(width: 1, color: Colors.grey[800]),
                  Expanded(
                    child: selected != null
                        ? PropDetailPanel(
                            key: ValueKey(selected.id),
                            prop: selected,
                            onConfirm: selected.isConfirmed
                                ? null
                                : () => _handleConfirm(context, ref, selected),
                            onDelete: () => _confirmDelete(context, ref, selected),
                            onEdit: () => _showEditProp(context, ref, selected),
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
                Icon(AppIcons.category, size: 64, color: Colors.grey[700]),
                const SizedBox(height: 16),
                Text('暂无道具', style: TextStyle(fontSize: 18, color: Colors.grey[400])),
                const SizedBox(height: 8),
                Text('点击 AI 提取资产，或手动添加道具', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () => _showAddProp(context, ref),
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
          Icon(AppIcons.category, size: 48, color: Colors.grey[700]),
          const SizedBox(height: 12),
          Text('选择左侧道具查看详情', style: TextStyle(fontSize: 15, color: Colors.grey[500])),
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
          ref.read(assetPropsProvider.notifier).update(updated.copyWith(id: prop.id));
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('道具「${prop.name}」已确认')));
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('确认道具', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('以下项目尚未完善，确认后仍可补充：', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
            const SizedBox(height: 10),
            ...warnings.map((w) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(AppIcons.warning, size: 14, color: Colors.orange[400]),
                      const SizedBox(width: 8),
                      Text(w, style: TextStyle(color: Colors.orange[300], fontSize: 13)),
                    ],
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('先去补充')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(assetPropsProvider.notifier).confirm(prop.id!);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('道具「${prop.name}」已确认')));
            },
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF22C55E)),
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
