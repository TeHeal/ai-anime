import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/module/assets/shared/asset_toolbar.dart';
import 'package:anime_ui/module/assets/props/providers/selection.dart';

/// 道具工具栏
class PropToolbar extends ConsumerWidget {
  const PropToolbar({
    super.key,
    required this.onAdd,
    this.onAiGenerate,
  });

  final VoidCallback onAdd;
  final VoidCallback? onAiGenerate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AssetToolbar(
      searchHint: '搜索道具名称…',
      addLabel: '新建道具',
      searchValue: ref.watch(propNameSearchProvider),
      onSearchChanged: (v) => ref.read(propNameSearchProvider.notifier).set(v),
      statusFilter: ref.watch(propStatusFilterProvider),
      onStatusFilterChanged: (v) =>
          ref.read(propStatusFilterProvider.notifier).set(v),
      onAdd: onAdd,
      onAiGenerate: onAiGenerate,
    );
  }
}
