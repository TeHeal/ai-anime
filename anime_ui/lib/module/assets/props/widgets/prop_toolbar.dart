import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/widgets/app_search_field.dart';
import 'package:anime_ui/module/assets/props/providers/selection.dart';

/// 道具工具栏
class PropToolbar extends ConsumerStatefulWidget {
  const PropToolbar({super.key, required this.onAdd});

  final VoidCallback onAdd;

  @override
  ConsumerState<PropToolbar> createState() => _PropToolbarState();
}

class _PropToolbarState extends ConsumerState<PropToolbar> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchCtrl.text = ref.read(propNameSearchProvider);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusFilter = ref.watch(propStatusFilterProvider);
    final searchState = ref.watch(propNameSearchProvider);

    if (searchState.isEmpty && _searchCtrl.text.isNotEmpty) {
      _searchCtrl.clear();
    }

    final hasFilter = statusFilter != null || searchState.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(bottom: BorderSide(color: Colors.grey[800]!)),
      ),
      child: Row(
        children: [
          AppSearchField(
            controller: _searchCtrl,
            hintText: '搜索道具名称…',
            width: 200,
            height: 34,
            onChanged: (v) => ref.read(propNameSearchProvider.notifier).set(v),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildStatusFilter(statusFilter),
                if (hasFilter)
                  TextButton(
                    onPressed: () {
                      ref.read(propStatusFilterProvider.notifier).set(null);
                      ref.read(propNameSearchProvider.notifier).set('');
                    },
                    child: Text('重置', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: widget.onAdd,
            icon: const Icon(AppIcons.add, size: 16),
            label: const Text('新建道具'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter(String? current) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: current,
          hint: Text('全部状态', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          dropdownColor: Colors.grey[900],
          icon: Icon(AppIcons.expandMore, size: 16, color: Colors.grey[500]),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          isDense: true,
          items: const [
            DropdownMenuItem(value: null, child: Text('全部状态')),
            DropdownMenuItem(value: 'skeleton', child: Text('骨架')),
            DropdownMenuItem(value: 'draft', child: Text('待确认')),
            DropdownMenuItem(value: 'confirmed', child: Text('已确认')),
          ],
          onChanged: (v) => ref.read(propStatusFilterProvider.notifier).set(v),
        ),
      ),
    );
  }
}
