import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/module/assets/shared/asset_toolbar.dart';
import 'package:anime_ui/module/assets/locations/providers/selection.dart';

/// 场景工具栏
class LocationToolbar extends ConsumerWidget {
  const LocationToolbar({super.key, required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AssetToolbar(
      searchHint: '搜索场景名称…',
      addLabel: '新建场景',
      searchValue: ref.watch(locNameSearchProvider),
      onSearchChanged: (v) => ref.read(locNameSearchProvider.notifier).set(v),
      statusFilter: ref.watch(locStatusFilterProvider),
      onStatusFilterChanged: (v) =>
          ref.read(locStatusFilterProvider.notifier).set(v),
      onAdd: onAdd,
    );
  }
}
