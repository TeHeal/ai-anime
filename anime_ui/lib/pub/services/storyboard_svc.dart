import 'package:dio/dio.dart';

import 'api.dart';
import 'package:anime_ui/pub/models/task.dart';

/// 提取结果 - 角色
class ExtractCharacter {
  final String name;
  final String appearance;
  final String personality;
  final String voiceHint;
  final List<String> emotions;
  final List<String> scenes;
  final String? existingCharacterId;

  const ExtractCharacter({
    this.name = '',
    this.appearance = '',
    this.personality = '',
    this.voiceHint = '',
    this.emotions = const [],
    this.scenes = const [],
    this.existingCharacterId,
  });

  factory ExtractCharacter.fromJson(Map<String, dynamic> json) => ExtractCharacter(
        name: json['name'] as String? ?? '',
        appearance: json['appearance'] as String? ?? '',
        personality: json['personality'] as String? ?? '',
        voiceHint: json['voice_hint'] as String? ?? '',
        emotions: (json['emotions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        scenes: (json['scenes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        existingCharacterId: json['existing_character_id']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'appearance': appearance,
        'personality': personality,
        'voice_hint': voiceHint,
        'emotions': emotions,
        'scenes': scenes,
        if (existingCharacterId != null) 'existing_character_id': existingCharacterId,
      };
}

/// 提取结果 - 场景
class ExtractLocation {
  final String name;
  final String time;
  final String interiorExterior;
  final String atmosphere;
  final String colorTone;
  final String lighting;
  final String styleNote;
  final List<String> scenes;

  const ExtractLocation({
    this.name = '',
    this.time = '',
    this.interiorExterior = '',
    this.atmosphere = '',
    this.colorTone = '',
    this.lighting = '',
    this.styleNote = '',
    this.scenes = const [],
  });

  factory ExtractLocation.fromJson(Map<String, dynamic> json) => ExtractLocation(
        name: json['name'] as String? ?? '',
        time: json['time'] as String? ?? '',
        interiorExterior: json['interior_exterior'] as String? ?? '',
        atmosphere: json['atmosphere'] as String? ?? '',
        colorTone: json['color_tone'] as String? ?? '',
        lighting: json['lighting'] as String? ?? '',
        styleNote: json['style_note'] as String? ?? '',
        scenes: (json['scenes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'time': time,
        'interior_exterior': interiorExterior,
        'atmosphere': atmosphere,
        'color_tone': colorTone,
        'lighting': lighting,
        'style_note': styleNote,
        'scenes': scenes,
      };
}

/// 提取结果 - 道具
class ExtractProp {
  final String name;
  final String appearance;
  final List<String> relatedCharacters;
  final List<String> scenes;

  const ExtractProp({
    this.name = '',
    this.appearance = '',
    this.relatedCharacters = const [],
    this.scenes = const [],
  });

  factory ExtractProp.fromJson(Map<String, dynamic> json) => ExtractProp(
        name: json['name'] as String? ?? '',
        appearance: json['appearance'] as String? ?? '',
        relatedCharacters:
            (json['related_characters'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        scenes: (json['scenes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'appearance': appearance,
        'related_characters': relatedCharacters,
        'scenes': scenes,
      };
}

/// 确认导入的单镜头（与后端 ConfirmShotInput 对应）
class ConfirmShotInput {
  final String sceneId;
  final String prompt;
  final String stylePrompt;
  final String cameraType;
  final String cameraAngle;
  final String dialogue;
  final String voice;
  final int duration;
  final int sortIndex;
  final String characterName;
  final String? characterId;
  final String emotion;
  final String transition;
  final String negativePrompt;

  const ConfirmShotInput({
    required this.sceneId,
    this.prompt = '',
    this.stylePrompt = '',
    this.cameraType = '',
    this.cameraAngle = '',
    this.dialogue = '',
    this.voice = '',
    this.duration = 3,
    this.sortIndex = 0,
    this.characterName = '',
    this.characterId,
    this.emotion = '',
    this.transition = '',
    this.negativePrompt = '',
  });

  Map<String, dynamic> toJson() => {
        'scene_id': sceneId,
        'prompt': prompt,
        'style_prompt': stylePrompt,
        'camera_type': cameraType,
        'camera_angle': cameraAngle,
        'dialogue': dialogue,
        'voice': voice,
        'duration': duration,
        'sort_index': sortIndex,
        if (characterName.isNotEmpty) 'character_name': characterName,
        if (characterId != null) 'character_id': characterId,
        if (emotion.isNotEmpty) 'emotion': emotion,
        if (transition.isNotEmpty) 'transition': transition,
        if (negativePrompt.isNotEmpty) 'negative_prompt': negativePrompt,
      };

  factory ConfirmShotInput.fromJson(Map<String, dynamic> json) =>
      ConfirmShotInput(
        sceneId: json['scene_id'].toString(),
        prompt: json['prompt'] as String? ?? '',
        stylePrompt: json['style_prompt'] as String? ?? '',
        cameraType: json['camera_type'] as String? ?? '',
        cameraAngle: json['camera_angle'] as String? ?? '',
        dialogue: json['dialogue'] as String? ?? '',
        voice: json['voice'] as String? ?? '',
        duration: (json['duration'] as num?)?.toInt() ?? 3,
        sortIndex: (json['sort_index'] as num?)?.toInt() ?? 0,
        characterName: json['character_name'] as String? ?? '',
        characterId: json['character_id']?.toString(),
        emotion: json['emotion'] as String? ?? '',
        transition: json['transition'] as String? ?? '',
        negativePrompt: json['negative_prompt'] as String? ?? '',
      );
}

class StoryboardService {
  /// AI 资产提取
  Future<ExtractResult> extract(
    String projectId, {
    String mode = 'script_only',
    String characterProfileContent = '',
    Map<String, String> characterMappings = const {},
    String? provider,
    String? model,
  }) async {
    final resp = await dio.post(
      '/projects/$projectId/storyboard/extract',
      data: {
        'mode': mode,
        if (characterProfileContent.isNotEmpty) 'character_profile_content': characterProfileContent,
        if (characterMappings.isNotEmpty) 'character_mappings': characterMappings,
        'provider': ?provider,
        'model': ?model,
      },
      options: Options(receiveTimeout: const Duration(seconds: 180)),
    );
    return extractDataObject(resp, ExtractResult.fromJson);
  }

  /// 确认提取结果
  Future<void> confirmExtract(String projectId, ExtractResult result) async {
    await dio.post(
      '/projects/$projectId/storyboard/extract/confirm',
      data: result.toJson(),
    );
  }

  /// 异步拆镜（整集），返回 Task，需轮询完成后从 result.shots 取结果
  Future<Task> generate(
    String projectId, {
    required String episodeId,
    String? provider,
    String? model,
  }) async {
    final resp = await dio.post(
      '/projects/$projectId/storyboard/generate',
      data: {
        'episode_id': episodeId,
        'provider': ?provider,
        'model': ?model,
      },
    );
    return extractDataObject(resp, Task.fromJson);
  }

  /// 同步拆镜（整集），Redis 未配置时使用
  Future<({List<ConfirmShotInput> shots, String? episodeTitle})> generateSync(
    String projectId, {
    required String episodeId,
    String? provider,
    String? model,
  }) async {
    final resp = await dio.post(
      '/projects/$projectId/storyboard/generate-sync',
      data: {
        'episode_id': episodeId,
        'provider': ?provider,
        'model': ?model,
      },
    );
    final data = extractData<Map<String, dynamic>>(resp);
    final shotsList = data['shots'] as List<dynamic>? ?? [];
    final shots = shotsList
        .map((e) => ConfirmShotInput.fromJson(e as Map<String, dynamic>))
        .toList();
    return (shots: shots, episodeTitle: null);
  }

  /// 预览单场景拆镜
  Future<List<ConfirmShotInput>> preview(
    String projectId, {
    required String sceneId,
    String? provider,
    String? model,
  }) async {
    final resp = await dio.post(
      '/projects/$projectId/storyboard/preview',
      data: {
        'scene_id': sceneId,
        'provider': ?provider,
        'model': ?model,
      },
    );
    final data = extractData<Map<String, dynamic>>(resp);
    final shotsList = data['shots'] as List<dynamic>? ?? [];
    return shotsList
        .map((e) => ConfirmShotInput.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 确认导入
  Future<List<Map<String, dynamic>>> confirm(
    String projectId,
    List<ConfirmShotInput> shots,
  ) async {
    final resp = await dio.post(
      '/projects/$projectId/storyboard/confirm',
      data: {
        'shots': shots.map((s) => s.toJson()).toList(),
      },
    );
    final data = extractData<List<dynamic>>(resp);
    return data.cast<Map<String, dynamic>>();
  }
}

/// 提取状态（分类进度）
class ExtractStatusInfo {
  final String characters; // pending | done | error
  final String locations;
  final String props;
  final String charError;
  final String locError;
  final String propError;

  const ExtractStatusInfo({
    this.characters = 'pending',
    this.locations = 'pending',
    this.props = 'pending',
    this.charError = '',
    this.locError = '',
    this.propError = '',
  });

  factory ExtractStatusInfo.fromJson(Map<String, dynamic> json) => ExtractStatusInfo(
        characters: json['characters'] as String? ?? 'pending',
        locations: json['locations'] as String? ?? 'pending',
        props: json['props'] as String? ?? 'pending',
        charError: json['char_error'] as String? ?? '',
        locError: json['loc_error'] as String? ?? '',
        propError: json['prop_error'] as String? ?? '',
      );
}

/// 提取结果
class ExtractResult {
  final List<ExtractCharacter> characters;
  final List<ExtractLocation> locations;
  final List<ExtractProp> props;
  final ExtractStatusInfo? status;

  const ExtractResult({
    this.characters = const [],
    this.locations = const [],
    this.props = const [],
    this.status,
  });

  factory ExtractResult.fromJson(Map<String, dynamic> json) => ExtractResult(
        characters: (json['characters'] as List<dynamic>?)
                ?.map((e) => ExtractCharacter.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        locations: (json['locations'] as List<dynamic>?)
                ?.map((e) => ExtractLocation.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        props: (json['props'] as List<dynamic>?)
                ?.map((e) => ExtractProp.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        status: json['status'] != null
            ? ExtractStatusInfo.fromJson(json['status'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'characters': characters.map((e) => e.toJson()).toList(),
        'locations': locations.map((e) => e.toJson()).toList(),
        'props': props.map((e) => e.toJson()).toList(),
      };
}
