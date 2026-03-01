import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/module/draft/script_template.dart';
import 'package:anime_ui/module/draft/template_download.dart';

/// 显示格式说明与模板预览对话框
void showFormatHelpDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 720.w, maxHeight: 600.h),
        child: DefaultTabController(
          length: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  Spacing.xl.w,
                  Spacing.mid.h,
                  Spacing.xl.w,
                  0,
                ),
                child: Row(
                  children: [
                    Text('推荐剧本格式', style: AppTextStyles.h3),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(AppIcons.close, size: 20.r),
                      splashRadius: 18.r,
                    ),
                  ],
                ),
              ),
              TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.onSurface.withValues(
                  alpha: 0.55,
                ),
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(text: '格式说明'),
                  Tab(text: '模板预览'),
                ],
              ),
              Flexible(
                child: TabBarView(
                  children: [_FormatGuideTab(), _TemplatePreviewTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _FormatGuideTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(Spacing.xl.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '按照以下格式整理剧本，可获得最佳解析效果：',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: Spacing.lg.h),
          _helpItem('集标记', '**第1集**'),
          _helpItem(
            '场次头',
            '**1-1日，外，太玄门紫竹林**',
            hint: '格式: 集号-场号 + 日/夜 + 内/外 + 地点',
          ),
          _helpItem('出场角色', '**人物：苏辰，叶凰儿，内门弟子*2**', hint: '多人用逗号分隔，群演用 *数量 表示'),
          _helpItem('动作描写', '△紫竹林中奇花异草遍布...', hint: '以 △ 开头'),
          _helpItem('对白', '苏辰：（愤怒）为什么！', hint: '角色名：（情绪）台词'),
          _helpItem('旁白/OS', '苏辰os：我不甘心...', hint: '角色名os：内容'),
          _helpItem('特写', '●特写：叶凰儿嘴角上扬', hint: '以 ● 开头'),
        ],
      ),
    );
  }

  static Widget _helpItem(String label, String example, {String? hint}) {
    return Padding(
      padding: EdgeInsets.only(bottom: Spacing.gridGap.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: AppTextStyles.labelLarge),
              if (hint != null) ...[
                SizedBox(width: Spacing.sm.w),
                Text(
                  hint,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: Spacing.xs.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(Spacing.sm.r),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
            ),
            child: Text(
              example,
              style: AppTextStyles.bodySmall.copyWith(
                fontFamily: 'monospace',
                color: AppColors.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplatePreviewTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.fromLTRB(
              Spacing.xl.w,
              Spacing.lg.h,
              Spacing.xl.w,
              0,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(RadiusTokens.md.r),
              border: Border.all(color: AppColors.border),
            ),
            child: ListView(
              padding: EdgeInsets.all(Spacing.lg.r),
              children: [
                for (final line in scriptTemplateMd.split('\n'))
                  Padding(
                    padding: EdgeInsets.only(bottom: Spacing.xxs.h),
                    child: Text(
                      line.isEmpty ? ' ' : line,
                      style: AppTextStyles.bodySmall.copyWith(
                        height: 1.6,
                        fontFamily: 'monospace',
                        color: _templateLineColor(line),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(Spacing.lg.r),
          child: SizedBox(
            width: double.infinity,
            height: 42.h,
            child: ElevatedButton.icon(
              onPressed: () => _downloadTemplate(context),
              icon: Icon(AppIcons.download, size: 18.r),
              label: const Text('下载模板文件'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _templateLineColor(String line) {
    final trimmed = line.trimLeft();
    if (trimmed.startsWith('# ')) return AppColors.onSurface;
    if (trimmed.startsWith('**第') && trimmed.contains('集')) {
      return AppColors.tagAmber;
    }
    if (trimmed.startsWith('**') &&
        (trimmed.contains('日') || trimmed.contains('夜'))) {
      return AppColors.categoryVoice;
    }
    if (trimmed.startsWith('**人物')) return AppColors.categoryStyle;
    if (trimmed.startsWith('△')) return AppColors.success;
    if (trimmed.startsWith('●')) return AppColors.categoryProp;
    if (trimmed.contains('os：') || trimmed.contains('os:')) {
      return AppColors.categoryCharacter;
    }
    if (trimmed.contains('：') && !trimmed.startsWith('**')) {
      return AppColors.onSurface.withValues(alpha: 0.9);
    }
    return AppColors.onSurface.withValues(alpha: 0.6);
  }

  Future<void> _downloadTemplate(BuildContext context) async {
    try {
      await downloadTemplateFile(scriptTemplateMd, scriptTemplateFileName);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('模板已下载')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('下载失败: $e')));
      }
    }
  }
}
