import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/module/script/page/provider.dart' show shotsProvider;
import 'package:anime_ui/pub/providers/project.dart';
import 'provider.dart';
import 'widgets/center_config_card.dart';
import 'widgets/center_import_card.dart';
import 'widgets/center_task_section.dart';

/// 镜图 - 生成中心
class ShotImageCenterPage extends ConsumerStatefulWidget {
  const ShotImageCenterPage({super.key});

  @override
  ConsumerState<ShotImageCenterPage> createState() =>
      _ShotImageCenterPageState();
}

class _ShotImageCenterPageState extends ConsumerState<ShotImageCenterPage> {
  bool _loaded = false;

  void _loadIfReady() {
    final pid = ref.read(currentProjectProvider).value?.id;
    if (pid != null && !_loaded) {
      _loaded = true;
      ref.read(shotsProvider.notifier).load();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadIfReady());
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(currentProjectProvider, (_, next) {
      if (next.value?.id != null && !_loaded) {
        _loadIfReady();
      }
    });

    final shots = ref.watch(shotsProvider).value ?? [];
    final imgStates = ref.watch(shotImageStatesProvider);

    if (shots.isNotEmpty && imgStates.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(shotImageStatesProvider.notifier).initFromShots(shots);
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTopCards(),
          const SizedBox(height: 28),
          const CenterTaskSection(),
        ],
      ),
    );
  }

  Widget _buildTopCards() {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: CenterConfigCard()),
        SizedBox(width: 20),
        Expanded(flex: 1, child: CenterImportCard()),
      ],
    );
  }
}
