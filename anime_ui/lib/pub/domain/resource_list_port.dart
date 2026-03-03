import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/models/resource.dart';

/// 资源列表端口 — pub 定义接口，module 提供实现
///
/// 实现依赖倒置：image_gen、voice_gen、text_gen 等 pub 组件只依赖此接口，
/// 不依赖 module/assets。由 layout 作为组合根注入具体实现。
abstract class ResourceListPort {
  /// 当前资源列表（可被 watch，支持响应式更新）
  AsyncValue<List<Resource>> get resources;

  /// 刷新资源列表
  Future<void> refresh();

  /// 添加资源到库
  Future<void> addResource(Resource r);

  /// 图生：AI 生成图片并加入资源库
  Future<String?> generateImage({
    required String name,
    required String libraryType,
    required String modality,
    required String prompt,
    String negativePrompt = '',
    String referenceImageUrl = '',
    String provider = '',
    String model = '',
    int? width,
    int? height,
    String size = '',
    void Function(int)? onProgress,
  });

  /// 音色克隆生成，返回生成的 Resource（含试听 URL）
  Future<Resource> generateVoice({
    required String name,
    required String sampleUrl,
    String tagsJson = '',
    String description = '',
    void Function(int)? onProgress,
  });

  /// 音色设计生成（文本提示）
  Future<Resource> generateVoiceDesign({
    required String name,
    required String prompt,
    String previewText = '',
    String provider = '',
    String model = '',
    String voiceId = '',
    String tagsJson = '',
    String description = '',
    void Function(int)? onProgress,
  });

  /// 生成预览文本
  Future<String> generatePreviewText({required String voicePrompt});

  /// LLM 提示词生成
  Future<Resource> generatePrompt({
    required String name,
    required String instruction,
    String targetModel = '',
    String category = '',
    String tagsJson = '',
    String description = '',
    String libraryType = '',
    String language = '',
  });
}
