import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/const/app_const.dart';
import 'package:anime_ui/pub/models/character.dart';
import 'package:anime_ui/pub/widgets/voice_gen/voice_gen_config.dart';
import 'package:anime_ui/pub/widgets/voice_gen/voice_gen_trigger.dart';
import 'package:anime_ui/module/assets/characters/providers/characters.dart';
import 'package:anime_ui/module/assets/resources/providers/provider.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';

/// 角色音色设定卡片
class CharacterVoiceCard extends ConsumerWidget {
  const CharacterVoiceCard({super.key, required this.character});

  final Character character;

  Character get c => character;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(Spacing.lg.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(RadiusTokens.card.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '音色设定',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          SizedBox(height: Spacing.md.h),
          Container(
            padding: EdgeInsets.all(Spacing.md.r),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(RadiusTokens.md.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(AppIcons.mic, size: 18.r, color: AppColors.muted),
                    SizedBox(width: Spacing.sm.w),
                    Expanded(
                      child: Text(
                        c.voiceName.isNotEmpty ? c.voiceName : '未设定',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: c.voiceName.isNotEmpty
                              ? AppColors.onSurface
                              : AppColors.mutedDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Spacing.sm.h),
                Wrap(
                  spacing: Spacing.sm.w,
                  runSpacing: Spacing.xs.h,
                  children: [
                    if (c.voiceName.isNotEmpty)
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            showToast(context, '试听功能开发中', isInfo: true);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Spacing.sm.w,
                              vertical: Spacing.xs.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius:
                                  BorderRadius.circular(RadiusTokens.sm.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  AppIcons.play,
                                  size: 12.r,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: Spacing.xs.w),
                                Text(
                                  '试听',
                                  style: AppTextStyles.tiny.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    FilledButton.icon(
                      onPressed: () =>
                          _showVoicePickerDialog(context, ref),
                      icon: Icon(AppIcons.mic, size: 14.r),
                      label: const Text('从音色库选择'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.surfaceContainerHigh,
                        foregroundColor: AppColors.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                    VoiceGenTrigger(
                      config: VoiceGenConfig.voiceLibrary(
                        accentColor: AppColors.info,
                        onSaved: (_) async {
                          await ref.read(resourceListProvider.notifier).load();
                        },
                      ),
                      label: '创建音色',
                      icon: AppIcons.mic,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.info,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showVoicePickerDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceMutedDarker,
        title: Text(
          '选择音色',
          style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
        ),
        content: SizedBox(
          width: 360.w,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: Spacing.lg.w,
                    bottom: Spacing.xs.h,
                  ),
                  child: Text(
                    '预设音色风格',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ),
                ...characterVoiceOptions.map(
                  (voice) => ListTile(
                    dense: true,
                    leading: Icon(
                      c.voiceName == voice && c.voiceId.isEmpty
                          ? AppIcons.check
                          : AppIcons.mic,
                      size: 18.r,
                      color: c.voiceName == voice && c.voiceId.isEmpty
                          ? AppColors.primary
                          : AppColors.muted,
                    ),
                    title: Text(
                      voice,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: c.voiceName == voice && c.voiceId.isEmpty
                            ? AppColors.primary
                            : AppColors.onSurface,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      final updated = c.copyWith(
                        voiceName: voice,
                        voiceId: '',
                      );
                      ref.read(assetCharactersProvider.notifier).update(updated);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
