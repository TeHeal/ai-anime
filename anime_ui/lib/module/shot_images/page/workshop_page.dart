import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/module/assets/characters/providers/characters.dart';
import 'package:anime_ui/module/assets/locations/providers/list.dart';
import 'package:anime_ui/module/assets/styles/providers/styles.dart';
import 'package:anime_ui/pub/providers/shots_provider.dart' show shotsProvider;
import 'package:anime_ui/pub/providers/project_provider.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'provider.dart';
import 'widgets/center_config_card.dart';
import 'widgets/center_import_card.dart';
import 'widgets/prompt_workshop.dart';

/// 镜图 - 提示词工坊（Tab 1）
///
/// 自动从脚本数据+素材组装提示词，支持逐镜编辑与微调
class ShotImageWorkshopPage extends ConsumerStatefulWidget {
  const ShotImageWorkshopPage({super.key});

  @override
  ConsumerState<ShotImageWorkshopPage> createState() =>
      _ShotImageWorkshopPageState();
}

class _ShotImageWorkshopPageState
    extends ConsumerState<ShotImageWorkshopPage> {
  bool _loaded = false;

  void _loadIfReady() {
    final pid = ref.read(currentProjectProvider).value?.id;
    if (pid != null && !_loaded) {
      _loaded = true;
      ref.read(shotsProvider.notifier).load();
      ref.read(assetStylesProvider.notifier).load();
      ref.read(assetCharactersProvider.notifier).load();
      ref.read(assetLocationsProvider.notifier).load();
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
      if (next.value?.id != null && !_loaded) _loadIfReady();
    });

    final shots = ref.watch(shotsProvider).value ?? [];
    final imgStates = ref.watch(shotImageStatesProvider);

    if (shots.isNotEmpty && imgStates.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(shotImageStatesProvider.notifier).initFromShots(shots);
      });
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(Spacing.xxl.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 生成配置（折叠式）+ 导入
          _buildTopCards(),
          SizedBox(height: Spacing.xl.h),

          // 提示词工坊主体
          PromptWorkshop(shots: shots),
        ],
      ),
    );
  }

  Widget _buildTopCards() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(flex: 3, child: CenterConfigCard()),
        SizedBox(width: Spacing.mid.w),
        const Expanded(flex: 1, child: CenterImportCard()),
      ],
    );
  }
}
