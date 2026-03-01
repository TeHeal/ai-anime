import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/module/script/providers/script.dart';
import 'package:anime_ui/module/script/providers/script_center.dart';
import 'package:anime_ui/module/script/page/widgets/center_config_card.dart';
import 'package:anime_ui/module/script/page/widgets/center_import_card.dart';
import 'package:anime_ui/module/script/page/widgets/center_task_section.dart';

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
        final shotCounts = <String, int>{};
        for (final ep in episodes) {
          if (ep.id != null) {
            shotCounts[ep.id!] = shotsMap[ep.id]?.length ?? 0;
          }
        }
        ref
            .read(episodeStatesProvider.notifier)
            .initFromEpisodes(episodes, shotCounts);
      });
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(Spacing.xl.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(flex: 3, child: CenterConfigCard()),
              SizedBox(width: Spacing.mid.w),
              const Expanded(flex: 1, child: CenterImportCard()),
            ],
          ),
          SizedBox(height: Spacing.xxl.h),
          const CenterTaskSection(),
        ],
      ),
    );
  }
}
