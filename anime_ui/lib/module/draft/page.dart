import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/providers/project.dart';
import 'content.dart';
import 'provider.dart';

/// 剧本草稿页 — 上传、解析、预览
class DraftPage extends ConsumerStatefulWidget {
  const DraftPage({super.key});

  @override
  ConsumerState<DraftPage> createState() => _DraftPageState();
}

class _DraftPageState extends ConsumerState<DraftPage> {
  String? _fileName;
  String _fullText = '';
  int _charCount = 0;
  List<String> _previewLines = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final project = ref.read(currentProjectProvider).value;
      if (project != null && project.story.isNotEmpty) {
        _setContent(project.story, fileName: null);
      }
    });
  }

  void _setContent(String text, {String? fileName}) {
    final lines = text.split('\n');
    setState(() {
      _fullText = text;
      _charCount = text.length;
      _fileName = fileName;
      _previewLines = lines.length > 50 ? lines.sublist(0, 50) : lines;
    });
  }

  Future<void> _uploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'md', 'text'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) return;
      final text = utf8.decode(bytes, allowMalformed: true);
      _setContent(text, fileName: file.name);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已导入「${file.name}」')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: $e')),
        );
      }
    }
  }

  void _clearContent() {
    setState(() {
      _fullText = '';
      _charCount = 0;
      _fileName = null;
      _previewLines = [];
    });
  }

  /// 从剧本文件名得到项目名
  static String _projectNameFromFileName(String? fileName) {
    if (fileName == null || fileName.isEmpty) return '未命名项目';
    final lastDot = fileName.lastIndexOf('.');
    if (lastDot <= 0) return fileName;
    return fileName.substring(0, lastDot);
  }

  Future<void> _startParse() async {
    if (_fullText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先上传剧本文件')),
      );
      return;
    }

    try {
      final projectNotifier = ref.read(currentProjectProvider.notifier);
      var project = ref.read(currentProjectProvider).value;
      if (project?.id == null) {
        project = await projectNotifier.create(
            name: _projectNameFromFileName(_fileName), story: '');
        ref.invalidate(projectListProvider);
      }

      final projectId = ref.read(currentProjectProvider).value?.id;
      if (projectId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('项目创建失败，请重试')),
          );
        }
        return;
      }

      final formatHint = ref.read(formatHintProvider);
      await ref.read(parseStateProvider.notifier).parseSync(
            projectId,
            _fullText,
            formatHint,
          );

      if (!mounted) return;

      final parseState = ref.read(parseStateProvider);
      if (parseState.phase == ParsePhase.preview) {
        context.go(Routes.storyPreview);
      } else if (parseState.phase == ParsePhase.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('解析失败: ${parseState.errorMessage}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatHint = ref.watch(formatHintProvider);
    final parseState = ref.watch(parseStateProvider);
    final isParsing = parseState.phase == ParsePhase.parsing;

    return DraftContent(
      selectedFormat: formatHint,
      onFormatChanged: (i) => ref.read(formatHintProvider.notifier).setHint(i),
      fileName: _fileName,
      charCount: _charCount,
      previewLines: _previewLines,
      hasContent: _fullText.isNotEmpty,
      onParse: isParsing ? null : _startParse,
      isParsing: isParsing,
      parseProgress: parseState.progress,
      parseStepLabel: parseState.stepLabel,
      onUpload: _uploadFile,
      onClear: _clearContent,
    );
  }
}
