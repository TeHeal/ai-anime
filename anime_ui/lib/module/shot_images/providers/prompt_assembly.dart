import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/module/assets/characters/providers/characters.dart';
import 'package:anime_ui/module/assets/locations/providers/list.dart';
import 'package:anime_ui/module/assets/styles/providers/styles.dart';
import 'package:anime_ui/pub/models/character.dart';
import 'package:anime_ui/pub/models/location.dart';
import 'package:anime_ui/pub/models/shot.dart';
import 'package:anime_ui/pub/models/style.dart';

/// 单个镜头的组装提示词结果
class AssembledPrompt {
  final String shotId;
  final String assembled;
  final String? characterName;
  final String? characterImageUrl;
  final String? locationName;
  final String? locationImageUrl;
  final String? styleName;
  final bool isEdited;

  const AssembledPrompt({
    required this.shotId,
    required this.assembled,
    this.characterName,
    this.characterImageUrl,
    this.locationName,
    this.locationImageUrl,
    this.styleName,
    this.isEdited = false,
  });

  AssembledPrompt copyWith({String? assembled, bool? isEdited}) {
    return AssembledPrompt(
      shotId: shotId,
      assembled: assembled ?? this.assembled,
      characterName: characterName,
      characterImageUrl: characterImageUrl,
      locationName: locationName,
      locationImageUrl: locationImageUrl,
      styleName: styleName,
      isEdited: isEdited ?? this.isEdited,
    );
  }
}

/// 从脚本数据 + 素材自动组装提示词（纯前端逻辑）
String assemblePromptFromShot(
  StoryboardShot shot, {
  Style? projectStyle,
  Character? character,
  Location? location,
}) {
  final parts = <String>[];

  // 1. 风格前缀
  if (projectStyle != null && projectStyle.description.isNotEmpty) {
    parts.add(projectStyle.description);
  }

  // 2. 镜头语言（景别+角度）
  final camParts = <String>[];
  if (shot.cameraType?.isNotEmpty == true) camParts.add(shot.cameraType!);
  if (shot.cameraAngle?.isNotEmpty == true) camParts.add(shot.cameraAngle!);
  if (camParts.isNotEmpty) parts.add(camParts.join(', '));

  // 3. 画面描述（脚本核心）
  if (shot.prompt.isNotEmpty) parts.add(shot.prompt);

  // 4. 角色特征
  if (character != null && character.appearance.isNotEmpty) {
    parts.add('${character.name}, ${character.appearance}');
  } else if (shot.characterName?.isNotEmpty == true) {
    parts.add(shot.characterName!);
  }

  // 5. 场景/氛围
  if (location != null) {
    final locParts = <String>[location.name];
    if (location.atmosphere.isNotEmpty) locParts.add(location.atmosphere);
    if (location.colorTone.isNotEmpty) locParts.add(location.colorTone);
    parts.add(locParts.join(', '));
  }

  // 6. 情绪氛围
  if (shot.emotion?.isNotEmpty == true) parts.add(shot.emotion!);

  return parts.where((p) => p.trim().isNotEmpty).join(', ');
}

/// 管理所有镜头的组装提示词
class PromptAssemblyNotifier extends Notifier<Map<String, AssembledPrompt>> {
  @override
  Map<String, AssembledPrompt> build() => {};

  /// 为所有镜头批量生成提示词
  void assembleAll(List<StoryboardShot> shots) {
    final styles = ref.read(assetStylesProvider).value ?? [];
    final characters = ref.read(assetCharactersProvider).value ?? [];
    final locations = ref.read(assetLocationsProvider).value ?? [];

    final defaultStyle = styles.where((s) => s.isProjectDefault).firstOrNull;
    final result = <String, AssembledPrompt>{};

    for (final shot in shots) {
      final sid = shot.id;
      if (sid == null || sid.isEmpty) continue;

      // 已手动编辑的不覆盖
      final existing = state[sid];
      if (existing != null && existing.isEdited) {
        result[sid] = existing;
        continue;
      }

      final char = _matchCharacter(shot, characters);
      final loc = _matchLocation(shot, locations);

      result[sid] = AssembledPrompt(
        shotId: sid,
        assembled: assemblePromptFromShot(
          shot,
          projectStyle: defaultStyle,
          character: char,
          location: loc,
        ),
        characterName: char?.name,
        characterImageUrl: char?.imageUrl,
        locationName: loc?.name,
        locationImageUrl: loc?.imageUrl,
        styleName: defaultStyle?.name,
      );
    }

    state = result;
  }

  /// 用户手动编辑某个镜头的提示词
  void editPrompt(String shotId, String newPrompt) {
    final existing = state[shotId];
    if (existing == null) return;
    final updated = Map<String, AssembledPrompt>.from(state);
    updated[shotId] = existing.copyWith(assembled: newPrompt, isEdited: true);
    state = updated;
  }

  /// 重置某个镜头为自动组装
  void resetPrompt(String shotId, StoryboardShot shot) {
    final styles = ref.read(assetStylesProvider).value ?? [];
    final characters = ref.read(assetCharactersProvider).value ?? [];
    final locations = ref.read(assetLocationsProvider).value ?? [];

    final defaultStyle = styles.where((s) => s.isProjectDefault).firstOrNull;
    final char = _matchCharacter(shot, characters);
    final loc = _matchLocation(shot, locations);

    final updated = Map<String, AssembledPrompt>.from(state);
    updated[shotId] = AssembledPrompt(
      shotId: shotId,
      assembled: assemblePromptFromShot(
        shot,
        projectStyle: defaultStyle,
        character: char,
        location: loc,
      ),
      characterName: char?.name,
      characterImageUrl: char?.imageUrl,
      locationName: loc?.name,
      locationImageUrl: loc?.imageUrl,
      styleName: defaultStyle?.name,
    );
    state = updated;
  }

  /// 通过角色名或 characterId 匹配
  Character? _matchCharacter(StoryboardShot shot, List<Character> all) {
    if (shot.characterId != null && shot.characterId!.isNotEmpty) {
      return all.where((c) => c.id == shot.characterId).firstOrNull;
    }
    if (shot.characterName?.isNotEmpty == true) {
      return all.where((c) => c.name == shot.characterName).firstOrNull;
    }
    return null;
  }

  /// 通过 sceneId 匹配场景资产
  Location? _matchLocation(StoryboardShot shot, List<Location> all) {
    if (shot.sceneId != null && shot.sceneId!.isNotEmpty) {
      return all.where((l) => l.id == shot.sceneId).firstOrNull;
    }
    return null;
  }
}

final promptAssemblyProvider =
    NotifierProvider<PromptAssemblyNotifier, Map<String, AssembledPrompt>>(
  PromptAssemblyNotifier.new,
);
