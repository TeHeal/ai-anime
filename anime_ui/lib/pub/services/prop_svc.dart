import 'package:anime_ui/pub/models/prop.dart';
import 'api_svc.dart';

class PropService {
  /// projectId 支持 int 或 String（UUID）
  Future<Prop> create(Object projectId, {
    required String name,
    String appearance = '',
    bool isKeyProp = false,
    String style = '',
    String imageUrl = '',
  }) async {
    final resp = await dio.post('/projects/${projectId.toString()}/asset-props', data: {
      'name': name,
      'appearance': appearance,
      'isKeyProp': isKeyProp,
      'style': style,
      'imageUrl': imageUrl,
    });
    return extractDataObject(resp, Prop.fromJson);
  }

  Future<List<Prop>> list(Object projectId) async {
    final resp = await dio.get('/projects/${projectId.toString()}/asset-props');
    return extractDataList(resp, Prop.fromJson);
  }

  Future<Prop> get(Object projectId, Object propId) async {
    final resp = await dio.get('/projects/${projectId.toString()}/asset-props/${propId.toString()}');
    return extractDataObject(resp, Prop.fromJson);
  }

  Future<Prop> update(Object projectId, Object propId, {
    String? name,
    String? appearance,
    bool? isKeyProp,
    String? style,
    bool? styleOverride,
    String? referenceImagesJson,
    String? imageUrl,
    String? status,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (appearance != null) body['appearance'] = appearance;
    if (isKeyProp != null) body['isKeyProp'] = isKeyProp;
    if (style != null) body['style'] = style;
    if (styleOverride != null) body['styleOverride'] = styleOverride;
    if (referenceImagesJson != null) body['referenceImagesJson'] = referenceImagesJson;
    if (imageUrl != null) body['imageUrl'] = imageUrl;
    if (status != null) body['status'] = status;
    final resp = await dio.put('/projects/${projectId.toString()}/asset-props/${propId.toString()}', data: body);
    return extractDataObject(resp, Prop.fromJson);
  }

  Future<Prop> confirm(Object projectId, Object propId) async {
    final resp = await dio.post('/projects/${projectId.toString()}/asset-props/${propId.toString()}/confirm');
    return extractDataObject(resp, Prop.fromJson);
  }

  Future<List<Prop>> batchConfirm(Object projectId, List<String> ids) async {
    final resp = await dio.post(
      '/projects/${projectId.toString()}/asset-props/batch-confirm',
      data: {'ids': ids},
    );
    return extractDataList(resp, Prop.fromJson);
  }

  Future<void> delete(Object projectId, Object propId) async {
    await dio.delete('/projects/${projectId.toString()}/asset-props/${propId.toString()}');
  }
}
