import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/module/script/provider.dart';
import 'package:anime_ui/module/script/view/script_provider.dart';
import 'package:anime_ui/module/script/view/widgets/center_config_card.dart';
import 'package:anime_ui/module/script/view/widgets/center_import_card.dart';
import 'package:anime_ui/module/script/view/widgets/center_task_section.dart';

/// 脚本 - 生成中心（Tab 2）
class ScriptCenterPage extends ConsumerStatefulWidget {
  const ScriptCenterPage({super.key});

  @override
  ConsumerState<ScriptCenterPage> createState() => _ScriptCenterPageState();
}

class _ScriptCenterPageState extends ConsumerState<ScriptCenterPage> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_loaded) {
        _loaded = true;
        ref.read(episodesProvider.notifier).load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final episodes = ref.watch(episodesProvider).value ?? [];
    final epStates = ref.watch(episodeStatesProvider);
    final shotsMap = ref.watch(episodeShotsMapProvider);

    if (episodes.isNotEmpty &&
        epStates.length != episodes.where((e) => e.id != null).length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final shotCounts = <int, int>{};
        for (final ep in episodes) {
          if (ep.id != null) {
            shotCounts[ep.id!] = shotsMap[ep.id]?.length ?? 0;
          }
        }
        ref.read(episodeStatesProvider.notifier).initFromEpisodes(
          episodes,
          shotCounts,
        );
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: CenterConfigCard()),
              SizedBox(width: 20),
              Expanded(flex: 1, child: CenterImportCard()),
            ],
          ),
          const SizedBox(height: 28),
          const CenterTaskSection(),
        ],
      ),
    );
  }
}
