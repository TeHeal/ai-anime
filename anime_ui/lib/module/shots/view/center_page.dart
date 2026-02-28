import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/module/script/view/provider.dart' show shotsProvider;
import 'package:anime_ui/module/script/provider.dart';
import 'widgets/center_import_card.dart';
import 'widgets/center_model_card.dart';
import 'widgets/center_orchestration_card.dart';
import 'widgets/center_task_section.dart';

/// 镜头 · 生成中心（复合生成：视频+音频+口型）
class ShotsCenterPage extends ConsumerStatefulWidget {
  const ShotsCenterPage({super.key});

  @override
  ConsumerState<ShotsCenterPage> createState() => _ShotsCenterPageState();
}

class _ShotsCenterPageState extends ConsumerState<ShotsCenterPage> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_loaded) {
        _loaded = true;
        ref.read(episodesProvider.notifier).load();
        ref.read(shotsProvider.notifier).load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: CenterOrchestrationCard()),
              SizedBox(width: 16),
              Expanded(flex: 1, child: CenterModelCard()),
              SizedBox(width: 16),
              SizedBox(width: 200, child: CenterImportCard()),
            ],
          ),
          const SizedBox(height: 28),
          const CenterTaskSection(),
        ],
      ),
    );
  }
}
