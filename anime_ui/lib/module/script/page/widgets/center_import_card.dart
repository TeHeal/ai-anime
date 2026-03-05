import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/models/storyboard_script.dart';
import 'package:anime_ui/pub/widgets/generation_center/import_card_placeholder.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';
import 'package:anime_ui/module/script/providers/script.dart';
import 'package:anime_ui/module/script/providers/center_ui.dart';
import 'package:anime_ui/module/script/providers/script_center.dart';
import 'package:anime_ui/module/script/script_template.dart';
import 'package:anime_ui/module/script/template_download.dart';

/// 脚本导入卡片 — 独立于配置卡片，与镜图导入保持一致布局
///
/// 折叠/展开状态与配置卡片同步（读取 [scriptCenterUiProvider.configExpanded]）。
class CenterImportCard extends ConsumerStatefulWidget {
  const CenterImportCard({super.key});

  @override
  ConsumerState<CenterImportCard> createState() => _CenterImportCardState();
}

class _CenterImportCardState extends ConsumerState<CenterImportCard> {
  /// inline 成功提示（3秒自动消失）
  String? _successMessage;
  Timer? _successTimer;

  @override
  void dispose() {
    _successTimer?.cancel();
    super.dispose();
  }

  void _showInlineSuccess(String msg) {
    _successTimer?.cancel();
    setState(() => _successMessage = msg);
    _successTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _successMessage = null);
    });
  }

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
        if (!mounted) return;
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
        if (!mounted) return;
        showToast(context, '请先在剧本页创建集数', isError: true);
        return;
      }

      // 显示预览摘要 + 选集弹窗
      final selectedEp = await _showImportPreviewDialog(script, episodes);
      if (selectedEp == null || selectedEp.id == null) return;

      ref
          .read(episodeShotsMapProvider.notifier)
          .setShots(selectedEp.id!, script.shots);
      ref
          .read(episodeStatesProvider.notifier)
          .markCompleted(selectedEp.id!, script.shots.length);

      if (!mounted) return;
      final epName = selectedEp.title.isNotEmpty
          ? selectedEp.title
          : '第${selectedEp.sortIndex + 1}集';
      _showInlineSuccess('已导入 ${script.shots.length} 个镜头到「$epName」');
    } catch (e) {
      if (mounted) showToast(context, '导入失败: $e', isError: true);
    }
  }

  /// 带预览摘要的集数选择弹窗
  Future<dynamic> _showImportPreviewDialog(
    StoryboardScript script,
    List<dynamic> episodes,
  ) async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.xxxl.r),
        ),
        title: Text(
          '导入预览',
          style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
        ),
        content: SizedBox(
          width: 380.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 摘要信息 ──
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(Spacing.md.r),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (script.episodeTitle.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(bottom: Spacing.sm.h),
                        child: Text(
                          script.episodeTitle,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    Wrap(
                      spacing: Spacing.lg.w,
                      runSpacing: Spacing.sm.h,
                      children: [
                        _summaryBadge(
                          '${script.shots.length}',
                          '个镜头',
                          AppIcons.play,
                        ),
                        _summaryBadge(
                          'v${script.version}',
                          '格式',
                          AppIcons.document,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: Spacing.lg.h),
              Text(
                '选择导入到哪一集',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.muted,
                ),
              ),
              SizedBox(height: Spacing.sm.h),
              // ── 集数列表 ──
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 260.h),
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
                          borderRadius:
                              BorderRadius.circular(RadiusTokens.md.r),
                        ),
                        hoverColor: AppColors.primary.withValues(alpha: 0.1),
                        leading: Container(
                          width: 32.r,
                          height: 32.r,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius:
                                BorderRadius.circular(RadiusTokens.md.r),
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
                          ep.title.isNotEmpty
                              ? ep.title
                              : '第${ep.sortIndex + 1}集',
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
            ],
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

  Widget _summaryBadge(String value, String label, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13.r, color: AppColors.primary),
        SizedBox(width: Spacing.xs.w),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: 2.w),
        Text(
          label,
          style: AppTextStyles.tiny.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }

  Future<void> _downloadTemplate() async {
    try {
      await downloadScriptTemplate(scriptTemplateJson, scriptTemplateFileName);
    } catch (e) {
      if (mounted) showToast(context, '下载失败: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final expanded = ref.watch(
      scriptCenterUiProvider.select((s) => s.configExpanded),
    );

    return AnimatedSize(
      duration: MotionTokens.durationMedium,
      curve: MotionTokens.curveStandard,
      alignment: Alignment.topCenter,
      child: expanded ? _buildExpandedContent() : const SizedBox.shrink(),
    );
  }

  Widget _buildExpandedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ImportCardPlaceholder(
          title: '导入脚本',
          placeholderLabel: '拖拽或点击上传 JSON',
          hintText: '支持标准分镜脚本格式',
          infoText: '导入后可选择对应集数，\n已有脚本将被覆盖',
          onTap: _uploadJson,
          trailing: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _downloadTemplate,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    AppIcons.download,
                    size: 14.r,
                    color: AppColors.accentImport,
                  ),
                  SizedBox(width: Spacing.xs.w),
                  Text(
                    '下载模板',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accentImport,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // inline 成功提示
        AnimatedSize(
          duration: MotionTokens.durationMedium,
          curve: MotionTokens.curveStandard,
          child: _successMessage != null
              ? Padding(
                  padding: EdgeInsets.only(top: Spacing.sm.h),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Spacing.md.w,
                      vertical: Spacing.sm.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          AppIcons.check,
                          size: 14.r,
                          color: AppColors.success,
                        ),
                        SizedBox(width: Spacing.sm.w),
                        Expanded(
                          child: Text(
                            _successMessage!,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
