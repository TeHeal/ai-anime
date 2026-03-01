import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import '../voice_gen_config.dart';

/// 音色生成模式切换 Tab（克隆 / 设计）
class VoiceGenModeTabs extends StatelessWidget {
  const VoiceGenModeTabs({
    super.key,
    required this.tabController,
    required this.allowedModes,
    required this.accent,
  });

  final TabController tabController;
  final List<VoiceGenMode> allowedModes;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.surfaceMutedDarker)),
      ),
      child: TabBar(
        controller: tabController,
        indicatorColor: accent,
        labelColor: accent,
        unselectedLabelColor: AppColors.mutedDark,
        labelStyle: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        tabs: allowedModes.map((m) {
          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  m == VoiceGenMode.clone
                      ? AppIcons.upload
                      : AppIcons.magicStick,
                  size: 16.r,
                ),
                SizedBox(width: Spacing.sm.w),
                Text(m.label),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
