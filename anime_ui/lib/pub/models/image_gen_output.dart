/// 图生输出目标，与后端 output 参数对齐
class ImageGenOutput {
  const ImageGenOutput({
    required this.type,
    this.targetId,
    this.projectId,
    this.libraryType,
    this.modality,
    this.name,
  });

  /// resource | character | location | shot
  final String type;
  final String? targetId;
  final String? projectId;
  final String? libraryType;
  final String? modality;
  final String? name;

  Map<String, dynamic> toJson() => {
        'type': type,
        if (targetId != null && targetId!.isNotEmpty) 'targetId': targetId,
        if (projectId != null && projectId!.isNotEmpty) 'projectId': projectId,
        if (libraryType != null && libraryType!.isNotEmpty) 'libraryType': libraryType,
        if (modality != null && modality!.isNotEmpty) 'modality': modality,
        if (name != null && name!.isNotEmpty) 'name': name,
      };

  /// output.type=resource，写入素材库
  static ImageGenOutput resource({
    String libraryType = 'style',
    String modality = 'visual',
    String name = '生成图片',
  }) =>
      ImageGenOutput(
        type: 'resource',
        libraryType: libraryType,
        modality: modality,
        name: name,
      );
}
