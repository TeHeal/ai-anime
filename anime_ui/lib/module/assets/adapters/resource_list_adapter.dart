import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/domain/resource_list_port.dart';
import 'package:anime_ui/pub/models/resource.dart';

import '../resources/providers/provider.dart';

/// 资产模块对 ResourceListPort 的适配器实现
///
/// 委托给 resourceListProvider 的 Notifier，供 layout 注入到 resourceListPortProvider
class AssetResourceListAdapter implements ResourceListPort {
  AssetResourceListAdapter(this._ref);
  final Ref _ref;

  dynamic get _notifier => _ref.read(resourceListProvider.notifier);

  @override
  AsyncValue<List<Resource>> get resources => _ref.watch(resourceListProvider);

  @override
  Future<void> refresh() => _notifier.load();

  @override
  Future<void> addResource(Resource r) => _notifier.addResource(r);

  @override
  Future<int?> generateImage({
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
  }) => _notifier.generateImage(
    name: name,
    libraryType: libraryType,
    modality: modality,
    prompt: prompt,
    negativePrompt: negativePrompt,
    referenceImageUrl: referenceImageUrl,
    provider: provider,
    model: model,
    width: width,
    height: height,
    size: size,
    onProgress: onProgress,
  );

  @override
  Future<void> generateVoice({
    required String name,
    required String sampleUrl,
    String tagsJson = '',
    String description = '',
    void Function(int)? onProgress,
  }) => _notifier.generateVoice(
    name: name,
    sampleUrl: sampleUrl,
    tagsJson: tagsJson,
    description: description,
    onProgress: onProgress,
  );

  @override
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
  }) => _notifier.generateVoiceDesign(
    name: name,
    prompt: prompt,
    previewText: previewText,
    provider: provider,
    model: model,
    voiceId: voiceId,
    tagsJson: tagsJson,
    description: description,
    onProgress: onProgress,
  );

  @override
  Future<String> generatePreviewText({required String voicePrompt}) =>
      _notifier.generatePreviewText(voicePrompt: voicePrompt);

  @override
  Future<Resource> generatePrompt({
    required String name,
    required String instruction,
    String targetModel = '',
    String category = '',
    String tagsJson = '',
    String description = '',
    String libraryType = '',
    String language = '',
  }) => _notifier.generatePrompt(
    name: name,
    instruction: instruction,
    targetModel: targetModel,
    category: category,
    tagsJson: tagsJson,
    description: description,
    libraryType: libraryType,
    language: language,
  );
}
