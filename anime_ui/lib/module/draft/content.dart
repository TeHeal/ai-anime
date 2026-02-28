import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/widgets/select_card.dart';
import 'package:anime_ui/module/story/story_action_bar.dart';
import 'parse_progress_panel.dart';
import 'script_template.dart';
import 'template_download.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
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
                    icon: Icons.check_circle_outline,
                    selected: selectedFormat == 0,
                    onTap: () => onFormatChanged(0),
                    action: GestureDetector(
                      onTap: () => _showFormatHelp(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.menu_book, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            '查看推荐格式示例',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SelectCard(
                  title: '格式不确定 / 自由格式',
                  subtitle: '适合小说、散文、未整理剧本，AI 自动识别结构',
                  icon: Icons.auto_fix_high,
                  selected: selectedFormat == 1,
                  onTap: () => onFormatChanged(1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // 上传区或预览
          Expanded(
            child: hasContent ? _buildPreview() : _buildUploadZone(context),
          ),

          if (!isParsing)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '解析后将自动生成：集/场景结构 · 角色列表 · 场景列表 · 道具列表 · 场景元数据',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
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
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('清除'),
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[400]),
                    ),
                    const SizedBox(width: 16),
                  ],
                  ElevatedButton.icon(
                    onPressed: onParse,
                    icon: const Icon(Icons.play_arrow, size: 20),
                    label: const Text('开始解析'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[700]!,
            width: 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(AppIcons.uploadOutline, size: 56, color: Colors.grey[500]),
              const SizedBox(height: 16),
              Text(
                '点击上传 .md / .txt 剧本文件',
                style: TextStyle(fontSize: 16, color: Colors.grey[400]),
              ),
              const SizedBox(height: 8),
              Text(
                '支持长篇剧本（推荐 20 万字以内） · UTF-8 / GBK 自动识别',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 文件信息头
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Colors.grey[800]!)),
            ),
            child: Row(
              children: [
                const Icon(Icons.description, size: 20, color: Colors.green),
                const SizedBox(width: 10),
                if (fileName != null)
                  Text(
                    fileName!,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                if (fileName != null) const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _formatCharCount(charCount),
                    style:
                        TextStyle(fontSize: 12, color: AppColors.primary),
                  ),
                ),
                const Spacer(),
                Text(
                  '预览前 50 行',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          // 预览内容
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: previewLines.length,
              itemBuilder: (context, i) {
                final line = previewLines[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    line.isEmpty ? ' ' : line,
                    style: TextStyle(
                      fontSize: 13,
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(color: Colors.grey[800]!)),
              ),
              child: Text(
                '... 后续内容省略，解析时将处理全文',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
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
      return Colors.amber;
    }
    if (trimmed.startsWith('**') && trimmed.contains('日') ||
        trimmed.contains('夜')) {
      return Colors.cyan;
    }
    if (trimmed.startsWith('△')) return const Color(0xFF22C55E);
    if (trimmed.startsWith('●')) return const Color(0xFFF97316);
    if (trimmed.contains('os：') || trimmed.contains('os:')) {
      return const Color(0xFF8B5CF6);
    }
    return Colors.grey[300]!;
  }

  String _formatCharCount(int count) {
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)} 万字';
    }
    return '$count 字';
  }
}

void _showFormatHelp(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720, maxHeight: 600),
          child: DefaultTabController(
            length: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Row(
                    children: [
                      const Text(
                        '推荐剧本格式',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, size: 20),
                        splashRadius: 18,
                      ),
                    ],
                  ),
                ),
                TabBar(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.grey[500],
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(text: '格式说明'),
                    Tab(text: '模板预览'),
                  ],
                ),
                Flexible(
                  child: TabBarView(
                    children: [
                      _FormatGuideTab(),
                      _TemplatePreviewTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
}

class _FormatHelpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _showFormatHelp(context),
      icon: const Icon(Icons.help_outline, size: 18),
      label: const Text('格式说明 & 模板'),
      style: TextButton.styleFrom(foregroundColor: Colors.grey[400]),
    );
  }
}

class _FormatGuideTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '按照以下格式整理剧本，可获得最佳解析效果：',
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          _helpItem('集标记', '**第1集**'),
          _helpItem('场次头', '**1-1日，外，太玄门紫竹林**',
              hint: '格式: 集号-场号 + 日/夜 + 内/外 + 地点'),
          _helpItem('出场角色', '**人物：苏辰，叶凰儿，内门弟子*2**',
              hint: '多人用逗号分隔，群演用 *数量 表示'),
          _helpItem('动作描写', '△紫竹林中奇花异草遍布...',
              hint: '以 △ 开头'),
          _helpItem('对白', '苏辰：（愤怒）为什么！',
              hint: '角色名：（情绪）台词'),
          _helpItem('旁白/OS', '苏辰os：我不甘心...',
              hint: '角色名os：内容'),
          _helpItem('特写', '●特写：叶凰儿嘴角上扬',
              hint: '以 ● 开头'),
        ],
      ),
    );
  }

  static Widget _helpItem(String label, String example, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              if (hint != null) ...[
                const SizedBox(width: 8),
                Text(hint,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              example,
              style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: Colors.grey[300]),
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
            margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[800]!),
            ),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final line in scriptTemplateMd.split('\n'))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 1),
                    child: Text(
                      line.isEmpty ? ' ' : line,
                      style: TextStyle(
                        fontSize: 13,
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
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              onPressed: () => _downloadTemplate(context),
              icon: const Icon(Icons.download, size: 18),
              label: const Text('下载模板文件'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _templateLineColor(String line) {
    final trimmed = line.trimLeft();
    if (trimmed.startsWith('# ')) return Colors.white;
    if (trimmed.startsWith('**第') && trimmed.contains('集')) {
      return Colors.amber;
    }
    if (trimmed.startsWith('**') &&
        (trimmed.contains('日') || trimmed.contains('夜'))) {
      return Colors.cyan;
    }
    if (trimmed.startsWith('**人物')) return const Color(0xFFEC4899);
    if (trimmed.startsWith('△')) return const Color(0xFF22C55E);
    if (trimmed.startsWith('●')) return const Color(0xFFF97316);
    if (trimmed.contains('os：') || trimmed.contains('os:')) {
      return const Color(0xFF8B5CF6);
    }
    if (trimmed.contains('：') && !trimmed.startsWith('**')) {
      return Colors.grey[200]!;
    }
    return Colors.grey[400]!;
  }

  Future<void> _downloadTemplate(BuildContext context) async {
    try {
      await downloadTemplateFile(scriptTemplateMd, scriptTemplateFileName);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('模板已下载')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('下载失败: $e')),
        );
      }
    }
  }
}

