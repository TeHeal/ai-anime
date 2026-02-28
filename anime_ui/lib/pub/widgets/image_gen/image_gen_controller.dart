import 'package:flutter/foundation.dart';

import 'package:anime_ui/pub/models/model_catalog.dart';
import 'package:anime_ui/pub/services/file_svc.dart';

// ─── 生成模式（自动推断，不存储）─────────────────────────────

enum ImageGenMode {
  text2imgSingle('文生图 · 单张'),
  text2imgBatch('文生图 · 组图'),
  img2imgSingle('图生图 · 单张'),
  img2imgBatch('图生图 · 组图'),
  multiRef2imgSingle('多参考图 · 单张'),
  multiRef2imgBatch('多参考图 · 组图');

  const ImageGenMode(this.label);
  final String label;

  bool get requiresRefImage => index >= 2;
  bool get allowsMultiRef => index >= 4;
  bool get isBatchOutput => index.isOdd;
}

// ─── 单张生成结果 ─────────────────────────────────────────

class GenResult {
  const GenResult({required this.url, this.isLoading = false});
  final String url;
  final bool isLoading;
}

// ─── 控制器状态枚举 ────────────────────────────────────────

enum GenControllerState { idle, generating, done, error }

// ─── 控制器 ───────────────────────────────────────────────

class ImageGenController extends ChangeNotifier {
  ImageGenController();

  // ── 输入参数 ──
  String prompt = '';
  String negPrompt = '';
  List<String> refImages = [];
  int outputCount = 1;
  String ratio = '';
  String resolution = '2K';
  int? customWidth;
  int? customHeight;

  // ── 模型（由 ModelSelector 外部管理）──
  ModelCatalogItem? selectedModel;

  // ── 状态 ──
  GenControllerState status = GenControllerState.idle;
  List<GenResult> results = [];
  String? errorMsg;
  int progress = 0;

  // ── 官方推荐尺寸 (Seedream 4.5) ──
  static const _officialSizes = {
    '2K': {
      '1:1': (2048, 2048),
      '4:3': (2304, 1728),
      '3:4': (1728, 2304),
      '16:9': (2560, 1440),
      '9:16': (1440, 2560),
      '3:2': (2496, 1664),
      '2:3': (1664, 2496),
      '21:9': (3024, 1296),
    },
    '4K': {
      '1:1': (4096, 4096),
      '4:3': (4704, 3520),
      '3:4': (3520, 4704),
      '16:9': (5504, 3040),
      '9:16': (3040, 5504),
      '3:2': (4992, 3328),
      '2:3': (3328, 4992),
      '21:9': (6240, 2656),
    },
  };

  static const _minPixels = 3686400;
  static const _maxPixels = 16777216;

  // ── 自动推断当前模式（不存储）──
  ImageGenMode get mode {
    final multi = refImages.length > 1;
    final hasRef = refImages.isNotEmpty;
    final batch = outputCount > 1;
    if (!hasRef) return batch ? ImageGenMode.text2imgBatch : ImageGenMode.text2imgSingle;
    if (!multi) return batch ? ImageGenMode.img2imgBatch : ImageGenMode.img2imgSingle;
    return batch ? ImageGenMode.multiRef2imgBatch : ImageGenMode.multiRef2imgSingle;
  }

  bool get isGenerating => status == GenControllerState.generating;
  bool get isDone => status == GenControllerState.done;
  bool get hasError => status == GenControllerState.error;

  // ── 尺寸 ──

  (int, int)? get resolvedSize {
    if (ratio.isEmpty) return null;
    return _officialSizes[resolution]?[ratio];
  }

  String? get sizeValidationError {
    if (ratio.isEmpty) return null;
    final w = customWidth ?? resolvedSize?.$1 ?? 0;
    final h = customHeight ?? resolvedSize?.$2 ?? 0;
    if (w <= 0 || h <= 0) return '请输入有效的宽高值';
    final total = w * h;
    if (total < _minPixels) return '总像素不足，请提高分辨率';
    if (total > _maxPixels) return '总像素超限，请降低分辨率';
    final r = w / h;
    if (r < 1 / 16 || r > 16) return '宽高比超出限制 [1:16, 16:1]';
    return null;
  }

  // ── 上传参考图 ──

  Future<void> addRefImage(Uint8List bytes, String filename) async {
    final url = await FileService().upload(bytes, filename, category: 'resource');
    refImages = [...refImages, url];
    notifyListeners();
  }

  void removeRefImage(int index) {
    refImages = [...refImages]..removeAt(index);
    notifyListeners();
  }

  void reorderRefImages(int oldIndex, int newIndex) {
    final list = [...refImages];
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    refImages = list;
    notifyListeners();
  }

  // ── setter helpers ──

  void setPrompt(String v) {
    prompt = v;
    notifyListeners();
  }

  void setNegPrompt(String v) {
    negPrompt = v;
    notifyListeners();
  }

  void setOutputCount(int v) {
    outputCount = v;
    notifyListeners();
  }

  void setRatio(String v) {
    ratio = v;
    if (v.isNotEmpty) {
      final size = _officialSizes[resolution]?[v];
      if (size != null) {
        customWidth = size.$1;
        customHeight = size.$2;
      }
    } else {
      customWidth = null;
      customHeight = null;
    }
    notifyListeners();
  }

  void setResolution(String v) {
    resolution = v;
    if (ratio.isNotEmpty) setRatio(ratio);
    notifyListeners();
  }

  void setModel(ModelCatalogItem? m) {
    selectedModel = m;
    notifyListeners();
  }

  void setCustomSize(int? w, int? h) {
    customWidth = w;
    customHeight = h;
    notifyListeners();
  }

  // ── 执行生成 ──

  Future<void> generate({
    required Future<void> Function({
      required String prompt,
      required String negPrompt,
      required List<String> refImages,
      required int outputCount,
      required String ratio,
      required String resolution,
      required int? width,
      required int? height,
      required String provider,
      required String model,
      required void Function(int progress) onProgress,
      required void Function(String url) onResult,
    }) onGenerate,
  }) async {
    if (prompt.isEmpty && refImages.isEmpty) {
      errorMsg = '请输入提示词或上传参考图';
      status = GenControllerState.error;
      notifyListeners();
      return;
    }

    status = GenControllerState.generating;
    results = [];
    errorMsg = null;
    progress = 0;
    notifyListeners();

    try {
      await onGenerate(
        prompt: prompt,
        negPrompt: negPrompt,
        refImages: refImages,
        outputCount: outputCount,
        ratio: ratio,
        resolution: resolution,
        width: customWidth,
        height: customHeight,
        provider: selectedModel?.operator ?? '',
        model: selectedModel?.modelId ?? '',
        onProgress: (p) {
          progress = p;
          notifyListeners();
        },
        onResult: (url) {
          results = [...results, GenResult(url: url)];
          notifyListeners();
        },
      );
      status = GenControllerState.done;
    } catch (e) {
      errorMsg = e.toString().replaceFirst('Exception: ', '');
      status = GenControllerState.error;
    }
    notifyListeners();
  }

  void reset() {
    status = GenControllerState.idle;
    results = [];
    errorMsg = null;
    progress = 0;
    notifyListeners();
  }
}
