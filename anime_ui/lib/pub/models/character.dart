import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'character.freezed.dart';
part 'character.g.dart';

@freezed
abstract class Character with _$Character {
  const Character._();

  const factory Character({
    int? id,
    int? projectId,
    @Default('') String name,
    @Default('') String aliasJson,
    @Default('') String appearance,
    @Default('') String style,
    @Default(false) bool styleOverride,
    @Default('') String personality,
    @Default('') String voiceHint,
    @Default('') String emotions,
    @Default('') String scenes,
    @Default('') String gender,
    @Default('') String ageGroup,
    @Default('') String voiceId,
    @Default('') String voiceName,
    @Default('') String imageUrl,
    @Default('') String referenceImagesJson,
    @Default('') String taskId,
    @Default('none') String imageStatus,
    @Default(false) bool shared,
    @Default('draft') String status,
    @Default('manual') String source,
    @Default('') String variantsJson,
    // v3: classification
    @Default('') String importance,
    @Default('') String consistency,
    @Default('') String roleType,
    @Default('') String tagsJson,
    @Default('') String propsJson,
    // v3: bio
    @Default('') String bio,
    @Default('') String bioFragmentsJson,
    // v3: image gen override
    @Default('') String imageGenOverrideJson,
  }) = _Character;

  factory Character.fromJson(Map<String, dynamic> json) =>
      _$CharacterFromJson(json);

  bool get isGenerating => imageStatus == 'generating';
  bool get hasImage => imageUrl.isNotEmpty && imageStatus == 'completed';
  bool get isConfirmed => status == 'confirmed';
  bool get isSkeleton => status == 'skeleton';
  bool get isDraft => status == 'draft';

  List<String> get aliases {
    if (aliasJson.isEmpty) return [];
    try {
      return (jsonDecode(aliasJson) as List).cast<String>();
    } catch (_) {
      return [];
    }
  }

  List<String> get tags {
    if (tagsJson.isEmpty) return [];
    try {
      return (jsonDecode(tagsJson) as List).cast<String>();
    } catch (_) {
      return [];
    }
  }

  List<Map<String, dynamic>> get referenceImages {
    if (referenceImagesJson.isEmpty) return [];
    try {
      return (jsonDecode(referenceImagesJson) as List)
          .cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  List<Map<String, dynamic>> get variants {
    if (variantsJson.isEmpty) return [];
    try {
      return (jsonDecode(variantsJson) as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  List<Map<String, dynamic>> get bioFragments {
    if (bioFragmentsJson.isEmpty) return [];
    try {
      return (jsonDecode(bioFragmentsJson) as List)
          .cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  String get importanceLabel => switch (importance) {
        'main' => '主角',
        'support' => '重要配角',
        'functional' => '功能配角',
        'extra' => '群演',
        _ => '',
      };

  String get consistencyLabel => switch (consistency) {
        'strong' => '强',
        'medium' => '中',
        'weak' => '弱',
        _ => '',
      };

  String get roleTypeLabel => switch (roleType) {
        'human' => '人类',
        'nonhuman' => '非人',
        'personified' => '拟人',
        'narrator' => '旁白',
        _ => '',
      };

  bool get hasBio => bio.isNotEmpty;
}
