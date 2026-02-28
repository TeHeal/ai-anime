import 'package:flutter/foundation.dart';

import 'package:anime_ui/pub/models/model_catalog.dart';
import 'package:anime_ui/pub/services/file_svc.dart';
import 'voice_gen_config.dart';

enum VoiceGenState { idle, generating, done, error }

class VoiceGenController extends ChangeNotifier {
  VoiceGenController();

  // ── Mode ──
  VoiceGenMode mode = VoiceGenMode.design;

  // ── Common fields ──
  String name = '';
  String description = '';
  List<String> tags = [];

  // ── Clone mode fields ──
  String sampleAudioUrl = '';
  String sampleFileName = '';

  // ── Design mode fields ──
  String designPrompt = '';
  String previewText = '';

  // ── Model selection (managed externally by ModelSelector) ──
  ModelCatalogItem? selectedModel;

  // ── State ──
  VoiceGenState status = VoiceGenState.idle;
  String? errorMsg;
  int progress = 0;

  String resultAudioUrl = '';

  bool get isGenerating => status == VoiceGenState.generating;
  bool get isDone => status == VoiceGenState.done;
  bool get hasError => status == VoiceGenState.error;

  bool get canGenerate {
    if (isGenerating) return false;
    if (name.isEmpty) return false;
    return mode == VoiceGenMode.clone
        ? sampleAudioUrl.isNotEmpty
        : designPrompt.isNotEmpty;
  }

  // ── Upload sample audio (clone mode) ──

  Future<void> uploadSample(Uint8List bytes, String filename) async {
    try {
      final url =
          await FileService().upload(bytes, filename, category: 'voice');
      sampleAudioUrl = url;
      sampleFileName = filename;
      if (name.isEmpty) {
        final base = filename.contains('.')
            ? filename.substring(0, filename.lastIndexOf('.'))
            : filename;
        name = base;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('VoiceGenController.uploadSample error: $e');
    }
  }

  void removeSample() {
    sampleAudioUrl = '';
    sampleFileName = '';
    notifyListeners();
  }

  // ── Setters ──

  void setMode(VoiceGenMode m) {
    mode = m;
    notifyListeners();
  }

  void setName(String v) {
    name = v;
    notifyListeners();
  }

  void setDescription(String v) {
    description = v;
    notifyListeners();
  }

  void setDesignPrompt(String v) {
    designPrompt = v;
    notifyListeners();
  }

  void setPreviewText(String v) {
    previewText = v;
    notifyListeners();
  }

  void setModel(ModelCatalogItem? m) {
    selectedModel = m;
    notifyListeners();
  }

  void addTag(String tag) {
    if (tag.isNotEmpty && !tags.contains(tag)) {
      tags = [...tags, tag];
      notifyListeners();
    }
  }

  void removeTag(String tag) {
    tags = tags.where((t) => t != tag).toList();
    notifyListeners();
  }

  // ── Generate ──

  Future<void> generate({
    required Future<void> Function({
      required VoiceGenMode mode,
      required String name,
      required String description,
      required List<String> tags,
      required String sampleUrl,
      required String designPrompt,
      required String previewText,
      required String provider,
      required String model,
      required void Function(int progress) onProgress,
      required void Function(String audioUrl) onResult,
    }) onGenerate,
  }) async {
    if (!canGenerate) return;

    status = VoiceGenState.generating;
    errorMsg = null;
    progress = 0;
    resultAudioUrl = '';
    notifyListeners();

    try {
      await onGenerate(
        mode: mode,
        name: name,
        description: description,
        tags: tags,
        sampleUrl: sampleAudioUrl,
        designPrompt: designPrompt,
        previewText: previewText,
        provider: selectedModel?.operator ?? '',
        model: selectedModel?.modelId ?? '',
        onProgress: (p) {
          progress = p;
          notifyListeners();
        },
        onResult: (url) {
          resultAudioUrl = url;
          notifyListeners();
        },
      );
      status = VoiceGenState.done;
    } catch (e) {
      errorMsg = e.toString().replaceFirst('Exception: ', '');
      status = VoiceGenState.error;
    }
    notifyListeners();
  }

  void reset() {
    status = VoiceGenState.idle;
    errorMsg = null;
    progress = 0;
    resultAudioUrl = '';
    notifyListeners();
  }
}
