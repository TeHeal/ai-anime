import 'package:anime_ui/pub/models/project.dart';
import 'package:anime_ui/pub/models/prop.dart';
import 'api.dart';

class ProjectService {
  Future<Project> create({
    required String name,
    String story = '',
    String storyMode = 'full_script',
    ProjectConfig? config,
  }) async {
    final resp = await dio.post('/projects', data: {
      'name': name,
      'story': story,
      'story_mode': storyMode,
      if (config != null) 'config': config.toJson(),
    });
    return extractDataObject(resp, Project.fromJson);
  }

  Future<List<Project>> list() async {
    final resp = await dio.get('/projects');
    return extractDataList(resp, Project.fromJson);
  }

  Future<Project> get(String id) async {
    final data = await getRaw(id);
    return Project.fromJson(data);
  }

  Future<Map<String, dynamic>> getRaw(String id) async {
    final resp = await dio.get('/projects/$id');
    return extractData<Map<String, dynamic>>(resp);
  }

  Future<Project> update(String id, {
    String? name,
    String? story,
    String? storyMode,
    ProjectConfig? config,
    bool? mirrorMode,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (story != null) body['story'] = story;
    if (storyMode != null) body['story_mode'] = storyMode;
    if (config != null) body['config'] = config.toJson();
    if (mirrorMode != null) body['mirror_mode'] = mirrorMode;
    final resp = await dio.put('/projects/$id', data: body);
    return extractDataObject(resp, Project.fromJson);
  }

  Future<void> delete(String id) async {
    final resp = await dio.delete('/projects/$id');
    extractData<dynamic>(resp);
  }

  Future<List<Prop>> getProps(String id) async {
    final resp = await dio.get('/projects/$id/props');
    final data = extractData<Map<String, dynamic>>(resp);
    final list = data['props'] as List<dynamic>? ?? [];
    return list
        .map((e) => Prop.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> updateProps(String id, List<Prop> props) async {
    await dio.put('/projects/$id/props', data: {
      'props': props.map((p) => p.toJson()).toList(),
    });
  }
}
