import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/select_card.dart';
import 'package:anime_ui/pub/widgets/story_action_bar.dart';
import 'package:anime_ui/module/draft/widgets/format_help_dialog.dart';
import 'package:anime_ui/module/draft/widgets/parse_progress_panel.dart';

/// 剧本草稿内容区 — 格式选择、上传、预览
class DraftContent extends StatelessWidget {
  const DraftContent({
    super.key,
    required this.selectedFormat,
    required this.onFormatChanged,
    this.fileName,
    required this.charCount,
    required this.previewLines,
    required this.hasContent,
    required this.onParse,
    this.isParsing = false,
    this.parseProgress = 0,
    this.parseStepLabel = '',
    this.onUpload,
    this.onClear,
  });

  final int selectedFormat;
  final void Function(int) onFormatChanged;
  final String? fileName;
  final int charCount;
  final List<String> previewLines;
  final bool hasContent;
  final VoidCallback? onParse;
  final bool isParsing;
  final int parseProgress;
  final String parseStepLabel;
  final VoidCallback? onUpload;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: (Spacing.xl + Spacing.xl).w,
        vertical: Spacing.xl.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 格式选择卡片
          Row(
            children: [
              Expanded(
                child: Builder(
                  builder: (context) => SelectCard(
                    title: '已按格式规范整理',
                    subtitle: '解析速度快、结构更准确，适合专业剧本',
                    icon: AppIcons.checkCircleOutline,
                    selected: selectedFormat == 0,
                    onTap: () => onFormatChanged(0),
                    action: GestureDetector(
                      onTap: () => showFormatHelpDialog(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppIcons.book,
                            size: 14.r,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: Spacing.xs.w),
                          Text(
                            '查看推荐格式示例',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.lg),
              Expanded(
                child: SelectCard(
                  title: '格式不确定 / 自由格式',
                  subtitle: '适合小说、散文、未整理剧本，AI 自动识别结构',
                  icon: AppIcons.autoFixHigh,
                  selected: selectedFormat == 1,
                  onTap: () => onFormatChanged(1),
                ),
              ),
            ],
          ),
          SizedBox(height: Spacing.xxl.h),

          // 上传区或预览
          Expanded(
            child: hasContent ? _buildPreview() : _buildUploadZone(context),
          ),

          if (!isParsing)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 0,
                vertical: Spacing.sm.h,
              ),
              child: Row(
                children: [
                  Icon(
                    AppIcons.autoAwesome,
                    size: 16.r,
                    color: AppColors.mutedDarker,
                  ),
                  SizedBox(width: Spacing.sm.w),
                  Flexible(
                    child: Text(
                      '解析后将自动生成：集/场景结构 · 角色列表 · 场景列表 · 道具列表 · 场景元数据',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.mutedDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (isParsing)
            ParseProgressPanel(
              progress: parseProgress,
              stepLabel: parseStepLabel,
            )
          else
            StoryActionBar(
              leading: _FormatHelpButton(),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasContent) ...[
                    TextButton.icon(
                      onPressed: onClear,
                      icon: Icon(AppIcons.close, size: 16.r),
                      label: const Text('清除'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.muted,
                      ),
                    ),
                    const SizedBox(width: Spacing.lg),
                  ],
                  ElevatedButton.icon(
                    onPressed: onParse,
                    icon: Icon(AppIcons.playArrow, size: 20.r),
                    label: const Text('开始解析'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(RadiusTokens.md.r),
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

  /// 拖拽式上传区域
  Widget _buildUploadZone(BuildContext context) {
    return GestureDetector(
      onTap: onUpload,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                AppIcons.uploadOutline,
                size: 56.r,
                color: AppColors.mutedDark,
              ),
              const SizedBox(height: Spacing.lg),
              Text(
                '点击上传 .md / .txt 剧本文件',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                '支持长篇剧本（推荐 20 万字以内） · UTF-8 / GBK 自动识别',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.mutedDarker,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 文件加载后：预览前 50 行
  Widget _buildPreview() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 文件信息头
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.mid,
              vertical: Spacing.md,
            ),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Icon(AppIcons.document, size: 20.r, color: AppColors.success),
                SizedBox(width: RadiusTokens.lg.w),
                if (fileName != null)
                  Text(
                    fileName!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (fileName != null) const SizedBox(width: Spacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.sm,
                    vertical: Spacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
                  ),
                  child: Text(
                    _formatCharCount(charCount),
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '预览前 50 行',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.mutedDark,
                  ),
                ),
              ],
            ),
          ),
          // 预览内容
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(Spacing.mid),
              itemCount: previewLines.length,
              itemBuilder: (context, i) {
                final line = previewLines[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: Spacing.xxs),
                  child: Text(
                    line.isEmpty ? ' ' : line,
                    style: AppTextStyles.bodySmall.copyWith(
                      height: 1.6,
                      fontFamily: 'monospace',
                      color: _lineColor(line),
                    ),
                  ),
                );
              },
            ),
          ),
          if (previewLines.length >= 50)
            Container(
              padding: const EdgeInsets.all(Spacing.md),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Text(
                '... 后续内容省略，解析时将处理全文',
                textAlign: TextAlign.center,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.mutedDark,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 按格式标记语法高亮
  Color _lineColor(String line) {
    final trimmed = line.trimLeft();
    if (trimmed.startsWith('**第') && trimmed.contains('集')) {
      return AppColors.tagAmber;
    }
    if (trimmed.startsWith('**') && trimmed.contains('日') ||
        trimmed.contains('夜')) {
      return Colors.cyan;
    }
    if (trimmed.startsWith('△')) return AppColors.success;
    if (trimmed.startsWith('●')) return AppColors.warning;
    if (trimmed.contains('os：') || trimmed.contains('os:')) {
      return AppColors.primary;
    }
    return AppColors.mutedLight;
  }

  String _formatCharCount(int count) {
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)} 万字';
    }
    return '$count 字';
  }
}

class _FormatHelpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => showFormatHelpDialog(context),
      icon: Icon(AppIcons.help, size: 18.r),
      label: const Text('格式说明 & 模板'),
      style: TextButton.styleFrom(foregroundColor: AppColors.muted),
    );
  }
}
