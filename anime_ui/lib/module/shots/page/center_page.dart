import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/module/script/providers/shots.dart' show shotsProvider;
import 'package:anime_ui/module/script/providers/script.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
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
      padding: EdgeInsets.all(Spacing.xxl.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(flex: 3, child: CenterOrchestrationCard()),
              SizedBox(width: Spacing.lg.w),
              SizedBox(
                width: 280.w,
                child: Column(
                  children: [
                    const CenterModelCard(),
                    SizedBox(height: Spacing.lg.h),
                    const CenterImportCard(),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: Spacing.xxl.h),
          const CenterTaskSection(),
        ],
      ),
    );
  }
}
