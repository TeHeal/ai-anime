import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';
import 'package:anime_ui/pub/widgets/generation_center/styled_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anime_ui/module/script/providers/script.dart';
import 'package:anime_ui/module/script/providers/script_center.dart';

/// JSON 导入卡片：上传分镜脚本 JSON 文件并导入到指定集
class CenterImportCard extends ConsumerStatefulWidget {
  const CenterImportCard({super.key});

  @override
  ConsumerState<CenterImportCard> createState() => _CenterImportCardState();
}

class _CenterImportCardState extends ConsumerState<CenterImportCard> {
  Future<void> _uploadJson() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final bytes = result.files.first.bytes;
      if (bytes == null) return;
      final jsonStr = utf8.decode(bytes, allowMalformed: true);
      final importResult = validateAndParseJson(jsonStr);

      if (!importResult.success || importResult.script == null) {
        if (!context.mounted) return;
        showToast(
          context,
          '校验失败: ${importResult.errors.join('; ')}',
          isError: true,
        );
        return;
      }

      final script = importResult.script!;
      if (!mounted) return;

      final episodes = ref.read(episodesProvider).value ?? [];
      if (episodes.isEmpty) {
        if (!context.mounted) return;
        showToast(context, '请先在剧本页创建集数', isError: true);
        return;
      }

      final selectedEp = await _showEpisodePickerDialog(episodes);
      if (selectedEp == null || selectedEp.id == null) return;

      ref
          .read(episodeShotsMapProvider.notifier)
          .setShots(selectedEp.id!, script.shots);
      ref
          .read(episodeStatesProvider.notifier)
          .markCompleted(selectedEp.id!, script.shots.length);

      if (!context.mounted) return;
      showToast(
        context,
        '成功导入 ${script.shots.length} 个镜头到「${selectedEp.title.isNotEmpty ? selectedEp.title : "第${selectedEp.sortIndex + 1}集"}」',
      );
    } catch (e) {
      if (context.mounted) showToast(context, '导入失败: $e', isError: true);
    }
  }

  Future<dynamic> _showEpisodePickerDialog(List<dynamic> episodes) async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.xxxl.r),
        ),
        title: Text(
          '选择导入到哪一集',
          style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
        ),
        content: SizedBox(
          width: 340.w,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: episodes.length,
            separatorBuilder: (_, _) => SizedBox(height: Spacing.xs.h),
            itemBuilder: (_, i) {
              final ep = episodes[i];
              return Material(
                color: Colors.transparent,
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                  ),
                  hoverColor: AppColors.primary.withValues(alpha: 0.1),
                  leading: Container(
                    width: 32.r,
                    height: 32.r,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                    ),
                    child: Center(
                      child: Text(
                        '${ep.sortIndex + 1}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    ep.title.isNotEmpty ? ep.title : '第${ep.sortIndex + 1}集',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                  onTap: () => Navigator.of(ctx).pop(ep),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              '取消',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StyledCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(Spacing.sm.r),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentImport.withValues(alpha: 0.25),
                      AppColors.accentImport.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
                ),
                child: Icon(
                  AppIcons.upload,
                  size: 18.r,
                  color: AppColors.accentImport,
                ),
              ),
              SizedBox(width: Spacing.md.w),
              Text(
                '导入脚本',
                style: AppTextStyles.h4.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: Spacing.mid.h),
          // 拖拽/点击上传区域
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _uploadJson,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: Spacing.xxl.h),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.5),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48.r,
                      height: 48.r,
                      decoration: BoxDecoration(
                        color: AppColors.accentImport.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        AppIcons.uploadOutline,
                        size: 22.r,
                        color: AppColors.accentImport,
                      ),
                    ),
                    SizedBox(height: Spacing.md.h),
                    Text(
                      '点击选择 JSON 文件',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.accentImport,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: Spacing.sm.h),
                    Text(
                      '导入现成的分镜脚本',
                      style: AppTextStyles.tiny.copyWith(
                        color: AppColors.mutedDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: Spacing.gridGap.h),
          // 说明
          Container(
            padding: EdgeInsets.all(Spacing.lg.r),
            decoration: BoxDecoration(
              color: AppColors.accentImport.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(AppIcons.info, size: 14.r, color: AppColors.mutedDark),
                SizedBox(width: Spacing.sm.w),
                Expanded(
                  child: Text(
                    '支持标准分镜脚本 JSON 格式，\n导入后可选择对应集数',
                    style: AppTextStyles.tiny.copyWith(
                      color: AppColors.mutedDark,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
