import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/widgets/generation_center/styled_card.dart';
import 'package:anime_ui/module/script/provider.dart';
import 'package:anime_ui/module/script/view/script_provider.dart';

/// JSON 导入卡片：上传分镜脚本 JSON 文件并导入到指定集
class CenterImportCard extends ConsumerStatefulWidget {
  const CenterImportCard({super.key});

  @override
  ConsumerState<CenterImportCard> createState() => _CenterImportCardState();
}

class _CenterImportCardState extends ConsumerState<CenterImportCard> {
  void _toast(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red[700] : Colors.green[700],
      behavior: SnackBarBehavior.floating,
    ));
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
        _toast('校验失败: ${importResult.errors.join('; ')}', isError: true);
        return;
      }

      final script = importResult.script!;
      if (!mounted) return;

      final episodes = ref.read(episodesProvider).value ?? [];
      if (episodes.isEmpty) {
        _toast('请先在剧本页创建集数', isError: true);
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

      _toast(
          '成功导入 ${script.shots.length} 个镜头到「${selectedEp.title.isNotEmpty ? selectedEp.title : "第${selectedEp.sortIndex + 1}集"}」');
    } catch (e) {
      _toast('导入失败: $e', isError: true);
    }
  }

  Future<dynamic> _showEpisodePickerDialog(List<dynamic> episodes) async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('选择导入到哪一集',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        content: SizedBox(
          width: 340,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: episodes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 4),
            itemBuilder: (_, i) {
              final ep = episodes[i];
              return Material(
                color: Colors.transparent,
                child: ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  hoverColor: AppColors.primary.withValues(alpha: 0.1),
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text('${ep.sortIndex + 1}',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ),
                  ),
                  title: Text(
                    ep.title.isNotEmpty ? ep.title : '第${ep.sortIndex + 1}集',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
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
            child: Text('取消', style: TextStyle(color: Colors.grey[400])),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.teal.withValues(alpha: 0.25),
                      Colors.teal.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    const Icon(AppIcons.upload, size: 18, color: Colors.tealAccent),
              ),
              const SizedBox(width: 12),
              const Text('导入脚本',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ],
          ),
          const SizedBox(height: 20),
          // 拖拽/点击上传区域
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _uploadJson,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  color: const Color(0xFF16162A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[700]!.withValues(alpha: 0.5),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(AppIcons.uploadOutline,
                          size: 22, color: Colors.tealAccent),
                    ),
                    const SizedBox(height: 12),
                    const Text('点击选择 JSON 文件',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.tealAccent,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    Text('导入现成的分镜脚本',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // 说明
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(AppIcons.info, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '支持标准分镜脚本 JSON 格式，\n导入后可选择对应集数',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500], height: 1.5),
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
