import 'package:flutter/foundation.dart';

import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/services/resource_svc.dart';
import 'text_gen_config.dart';

enum TextGenStatus { idle, generating, done, error }

class TextGenController extends ChangeNotifier {
  TextGenController();

  final ResourceService _svc = ResourceService();

  TextGenStatus _status = TextGenStatus.idle;
  TextGenStatus get status => _status;

  String _result = '';
  String get result => _result;

  String _errorMsg = '';
  String get errorMsg => _errorMsg;

  Resource? _savedResource;
  Resource? get savedResource => _savedResource;

  /// 生成文字内容
  Future<void> generate({
    required String instruction,
    required TextGenConfig config,
    String name = '',
  }) async {
    if (instruction.trim().isEmpty) return;

    _status = TextGenStatus.generating;
    _result = '';
    _errorMsg = '';
    _savedResource = null;
    notifyListeners();

    try {
      String fullInstruction = _buildInstruction(instruction, config);

      final resource = await _svc.generatePrompt(
        name: name.isNotEmpty ? name : _autoName(config),
        instruction: fullInstruction,
        targetModel: config.targetModel,
        category: config.mode.name,
        libraryType: config.libraryType,
        language: config.language,
      );

      _result = resource.description;
      _savedResource = config.saveToLibrary ? resource : null;
      _status = TextGenStatus.done;
    } catch (e) {
      _errorMsg = '$e';
      _status = TextGenStatus.error;
    }
    notifyListeners();
  }

  String _buildInstruction(String instruction, TextGenConfig config) {
    final buf = StringBuffer();

    switch (config.mode) {
      case TextGenMode.imagePrompt:
        buf.write('根据以下内容，生成一段用于 AI 图片生成的详细描述词，'
            '描述画面构图、风格、色调、细节：');
        buf.write(instruction);
      case TextGenMode.styleGuide:
        buf.write('根据以下描述生成一套画面风格指令，包括色调、构图规则、'
            '笔触特征、光影处理等，输出为可复用的风格模板：');
        buf.write(instruction);
      case TextGenMode.dialogue:
        buf.write('根据以下场景描述，生成角色台词对白：');
        buf.write(instruction);
        if (config.referenceText.isNotEmpty) {
          buf.write('\n\n参考上下文：${config.referenceText}');
        }
      case TextGenMode.scriptSnippet:
        buf.write('根据以下描述生成一段剧本片段/场景描述：');
        buf.write(instruction);
      case TextGenMode.optimize:
        buf.write('请优化以下文本，优化方向为：$instruction\n\n');
        buf.write('原始文本：\n${config.referenceText}');
      case TextGenMode.freeform:
        buf.write(instruction);
    }

    if (config.language.isNotEmpty) {
      buf.write('\n\n请使用${config.language}输出。');
    }

    return buf.toString();
  }

  String _autoName(TextGenConfig config) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    return '${config.mode.label}-$ts';
  }

  void reset() {
    _status = TextGenStatus.idle;
    _result = '';
    _errorMsg = '';
    _savedResource = null;
    notifyListeners();
  }
}
