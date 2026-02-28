import 'package:anime_ui/pub/models/prop.dart';
import 'api.dart';

class PropService {
  /// projectId 支持 int 或 String（UUID）
  Future<Prop> create(Object projectId, {
    required String name,
    String appearance = '',
    bool isKeyProp = false,
    String style = '',
    String imageUrl = '',
  }) async {
    final resp = await dio.post('/projects/${projectId.toString()}/props-v2', data: {
      'name': name,
      'appearance': appearance,
      'is_key_prop': isKeyProp,
      'style': style,
      'image_url': imageUrl,
    });
    return extractDataObject(resp, Prop.fromJson);
  }

  Future<List<Prop>> list(Object projectId) async {
    final resp = await dio.get('/projects/${projectId.toString()}/props-v2');
    return extractDataList(resp, Prop.fromJson);
  }

  Future<Prop> get(Object projectId, Object propId) async {
    final resp = await dio.get('/projects/${projectId.toString()}/props-v2/${propId.toString()}');
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
    if (isKeyProp != null) body['is_key_prop'] = isKeyProp;
    if (style != null) body['style'] = style;
    if (styleOverride != null) body['style_override'] = styleOverride;
    if (referenceImagesJson != null) body['reference_images_json'] = referenceImagesJson;
    if (imageUrl != null) body['image_url'] = imageUrl;
    if (status != null) body['status'] = status;
    final resp = await dio.put('/projects/${projectId.toString()}/props-v2/${propId.toString()}', data: body);
    return extractDataObject(resp, Prop.fromJson);
  }

  Future<Prop> confirm(Object projectId, Object propId) async {
    final resp = await dio.post('/projects/${projectId.toString()}/props-v2/${propId.toString()}/confirm');
    return extractDataObject(resp, Prop.fromJson);
  }

  Future<void> delete(Object projectId, Object propId) async {
    await dio.delete('/projects/${projectId.toString()}/props-v2/${propId.toString()}');
  }
}
