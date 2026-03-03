import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/providers/project_provider.dart'
    show currentProjectProvider, projectListProvider;
import 'package:anime_ui/module/story/page/import_content.dart';
import 'package:anime_ui/module/story/providers/import_provider.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';

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
  bool _isFileLoading = false;

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
    // 只取前 50 行用于预览，避免 split 后分配大量 String 对象
    final preview = _extractPreviewLines(text, maxLines: 50);
    setState(() {
      _fullText = text;
      _charCount = text.length;
      _fileName = fileName;
      _previewLines = preview;
      _isFileLoading = false;
    });
  }

  /// 仅扫描前 maxLines 个换行符，不分割全文
  static List<String> _extractPreviewLines(String text, {required int maxLines}) {
    final lines = <String>[];
    int start = 0;
    for (var i = 0; i < text.length && lines.length < maxLines; i++) {
      if (text[i] == '\n') {
        lines.add(text.substring(start, i));
        start = i + 1;
      }
    }
    if (lines.length < maxLines && start < text.length) {
      lines.add(text.substring(start));
    }
    return lines;
  }

  Future<void> _uploadFile() async {
    // 展示加载态，防止用户重复点击
    setState(() => _isFileLoading = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'md', 'text'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        if (mounted) setState(() => _isFileLoading = false);
        return;
      }
      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) {
        if (mounted) setState(() => _isFileLoading = false);
        return;
      }

      // 大文件解码在 compute 中执行，避免阻塞主线程
      final text = await compute(_decodeFileBytes, bytes);

      if (!mounted) return;
      _setContent(text, fileName: file.name);
    } catch (e) {
      if (mounted) {
        setState(() => _isFileLoading = false);
        showToast(context, '导入失败: $e', isError: true);

      }
    }
  }

  /// 在独立 isolate 中解码文件字节，避免大文件解码阻塞 UI
  static String _decodeFileBytes(Uint8List bytes) {
    return utf8.decode(bytes, allowMalformed: true);
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
      showToast(context, '请先上传剧本文件', isInfo: true);

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
          showToast(context, '项目创建失败，请重试', isError: true);

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
        showToast(context, '解析失败: ${parseState.errorMessage}', isError: true);

      }
    } catch (e) {
      if (mounted) {
        showToast(context, '操作失败: $e', isError: true);

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
      onParse: (isParsing || _fullText.trim().isEmpty) ? null : _startParse,
      isParsing: isParsing,
      parseProgress: parseState.progress,
      parseStepLabel: parseState.stepLabel,
      // 文件读取中时禁用上传按钮，防止重复触发
      onUpload: _isFileLoading ? null : _uploadFile,
      isFileLoading: _isFileLoading,
      onClear: _clearContent,
    );
  }
}
