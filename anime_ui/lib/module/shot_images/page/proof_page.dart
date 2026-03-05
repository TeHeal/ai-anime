import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/module/shot_images/providers/center_ui.dart';
import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/providers/shots_provider.dart' show shotsProvider;
import 'package:anime_ui/pub/providers/project_provider.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'provider.dart';
import 'widgets/quick_proof_section.dart';

/// 镜图 - 快速验证（Tab 2）
///
/// 低成本快速出图 → 缩略图预览 → 批量标记通过/需调整
class ShotImageProofPage extends ConsumerStatefulWidget {
  const ShotImageProofPage({super.key});

  @override
  ConsumerState<ShotImageProofPage> createState() =>
      _ShotImageProofPageState();
}

class _ShotImageProofPageState extends ConsumerState<ShotImageProofPage> {
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
          QuickProofSection(
            shots: shots,
            onAllApproved: () {
              final uiState = ref.read(shotImageCenterUiProvider);
              ref
                  .read(shotImageCenterUiProvider.notifier)
                  .toggleSelectAll(uiState.proofApproved.toList());
              // 跳转到正式出图 Tab
              if (context.mounted) context.go(Routes.shotImagesCenter);
            },
          ),
        ],
      ),
    );
  }
}
