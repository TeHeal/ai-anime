import 'package:anime_ui/pub/models/segment.dart';
import 'api.dart';

class SegmentService {
  Future<ScriptSegment> create(int projectId, {required String content, int sortIndex = 0}) async {
    final resp = await dio.post('/projects/$projectId/segments', data: {
      'content': content,
      'sort_index': sortIndex,
    });
    return extractDataObject(resp, ScriptSegment.fromJson);
  }

  Future<List<ScriptSegment>> bulkCreate(int projectId, List<ScriptSegment> segments) async {
    final resp = await dio.put('/projects/$projectId/segments/bulk', data: {
      'segments': segments.map((s) => {'content': s.content, 'sort_index': s.sortIndex}).toList(),
    });
    return extractDataList(resp, ScriptSegment.fromJson);
  }

  Future<List<ScriptSegment>> list(int projectId) async {
    final resp = await dio.get('/projects/$projectId/segments');
    return extractDataList(resp, ScriptSegment.fromJson);
  }

  Future<ScriptSegment> update(int projectId, int segId, {String? content, int? sortIndex}) async {
    final body = <String, dynamic>{};
    if (content != null) body['content'] = content;
    if (sortIndex != null) body['sort_index'] = sortIndex;
    final resp = await dio.put('/projects/$projectId/segments/$segId', data: body);
    return extractDataObject(resp, ScriptSegment.fromJson);
  }

  Future<void> delete(int projectId, int segId) async {
    final resp = await dio.delete('/projects/$projectId/segments/$segId');
    extractData<dynamic>(resp);
  }

  Future<void> reorder(int projectId, List<int> orderedIds) async {
    final resp = await dio.put('/projects/$projectId/segments/reorder', data: {
      'ordered_ids': orderedIds,
    });
    extractData<dynamic>(resp);
  }
}
