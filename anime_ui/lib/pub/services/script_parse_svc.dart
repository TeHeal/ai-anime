import 'package:dio/dio.dart';

import 'api.dart';

class ScriptParseService {
  Future<Map<String, dynamic>> submitParse(
    String projectId, {
    required String content,
    String formatHint = 'standard',
  }) async {
    final resp = await dio.post('/projects/$projectId/script/parse', data: {
      'content': content,
      'format_hint': formatHint,
    });
    return extractData<Map<String, dynamic>>(resp);
  }

  Future<ScriptParseResult> parseSync(
    String projectId, {
    required String content,
    String formatHint = 'standard',
  }) async {
    final resp = await dio.post(
      '/projects/$projectId/script/parse-sync',
      data: {
        'content': content,
        'format_hint': formatHint,
      },
      options: Options(
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(minutes: 3),
      ),
    );
    return extractDataObject(resp, ScriptParseResult.fromJson);
  }

  Future<ScriptParseResult> getPreview(String projectId) async {
    final resp = await dio.get('/projects/$projectId/script/preview');
    return extractDataObject(resp, ScriptParseResult.fromJson);
  }

  Future<void> confirm(String projectId, List<ParsedEpisode> episodes) async {
    final resp = await dio.post('/projects/$projectId/script/confirm', data: {
      'episodes': episodes.map((e) => e.toJson()).toList(),
    });
    extractData<dynamic>(resp);
  }
}

class ScriptParseResult {
  final ParsedScript script;
  final List<ValidationIssue> issues;

  ScriptParseResult({required this.script, required this.issues});

  factory ScriptParseResult.fromJson(Map<String, dynamic> json) {
    return ScriptParseResult(
      script: ParsedScript.fromJson(json['script'] as Map<String, dynamic>),
      issues: (json['issues'] as List<dynamic>? ?? [])
          .map((e) => ValidationIssue.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ParsedScript {
  final String title;
  final List<ParsedEpisode> episodes;
  final ParsedMetadata metadata;

  ParsedScript(
      {required this.title, required this.episodes, required this.metadata});

  factory ParsedScript.fromJson(Map<String, dynamic> json) {
    return ParsedScript(
      title: json['title'] as String? ?? '',
      episodes: (json['episodes'] as List<dynamic>? ?? [])
          .map((e) => ParsedEpisode.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata:
          ParsedMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );
  }
}

class ParsedEpisode {
  final int episodeNum;
  final List<ParsedScene> scenes;

  ParsedEpisode({required this.episodeNum, required this.scenes});

  factory ParsedEpisode.fromJson(Map<String, dynamic> json) {
    return ParsedEpisode(
      episodeNum: json['episode_num'] as int? ?? 0,
      scenes: (json['scenes'] as List<dynamic>? ?? [])
          .map((e) => ParsedScene.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'episode_num': episodeNum,
        'scenes': scenes.map((s) => s.toJson()).toList(),
      };
}

class ParsedScene {
  final String sceneNum;
  final String time;
  final String intExt;
  final String location;
  final List<String> characters;
  final List<ParsedBlock> blocks;

  ParsedScene({
    required this.sceneNum,
    required this.time,
    required this.intExt,
    required this.location,
    required this.characters,
    required this.blocks,
  });

  factory ParsedScene.fromJson(Map<String, dynamic> json) {
    return ParsedScene(
      sceneNum: json['scene_num'] as String? ?? '',
      time: json['time'] as String? ?? '',
      intExt: json['int_ext'] as String? ?? '',
      location: json['location'] as String? ?? '',
      characters: (json['characters'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      blocks: (json['blocks'] as List<dynamic>? ?? [])
          .map((e) => ParsedBlock.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'scene_num': sceneNum,
        'time': time,
        'int_ext': intExt,
        'location': location,
        'characters': characters,
        'blocks': blocks.map((b) => b.toJson()).toList(),
      };
}

class ParsedBlock {
  String type;
  String character;
  String emotion;
  String content;
  double confidence;
  final int sourceLine;

  ParsedBlock({
    required this.type,
    this.character = '',
    this.emotion = '',
    required this.content,
    this.confidence = 1.0,
    this.sourceLine = 0,
  });

  bool get isLowConfidence => confidence < 0.8;

  factory ParsedBlock.fromJson(Map<String, dynamic> json) {
    return ParsedBlock(
      type: json['type'] as String? ?? 'unknown',
      character: json['character'] as String? ?? '',
      emotion: json['emotion'] as String? ?? '',
      content: json['content'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      sourceLine: json['source_line'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'character': character,
        'emotion': emotion,
        'content': content,
        'confidence': confidence,
        'source_line': sourceLine,
      };
}

class ParsedMetadata {
  final int totalLines;
  final int recognizedLines;
  final double recognizeRate;
  final int episodeCount;
  final int sceneCount;
  final List<String> characterNames;
  final int unknownBlocks;

  ParsedMetadata({
    required this.totalLines,
    required this.recognizedLines,
    required this.recognizeRate,
    required this.episodeCount,
    required this.sceneCount,
    required this.characterNames,
    required this.unknownBlocks,
  });

  factory ParsedMetadata.fromJson(Map<String, dynamic> json) {
    return ParsedMetadata(
      totalLines: json['total_lines'] as int? ?? 0,
      recognizedLines: json['recognized_lines'] as int? ?? 0,
      recognizeRate: (json['recognize_rate'] as num?)?.toDouble() ?? 0,
      episodeCount: json['episode_count'] as int? ?? 0,
      sceneCount: json['scene_count'] as int? ?? 0,
      characterNames: (json['character_names'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      unknownBlocks: json['unknown_blocks'] as int? ?? 0,
    );
  }
}

class ValidationIssue {
  final String level;
  final String message;
  final String detail;

  ValidationIssue(
      {required this.level, required this.message, required this.detail});

  factory ValidationIssue.fromJson(Map<String, dynamic> json) {
    return ValidationIssue(
      level: json['level'] as String? ?? 'info',
      message: json['message'] as String? ?? '',
      detail: json['detail'] as String? ?? '',
    );
  }
}
